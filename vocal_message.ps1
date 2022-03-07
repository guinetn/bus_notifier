# REQUIRED LIBRARIES
Add-Type -AssemblyName System.speech;       # SPEECH SYNTHETIS
. ./apiservice.ps1      # if executed from task-scheduler... define full path here for the .ps1 file OR specifying the running directory for scheduled task (-WorkingDirectory argument)

function getSchedules() {

    # GET DATA AS JSON
    $apiService = [ApiService]::new($apiParams)
    $apiJsonResponse = ConvertTo-Json $apiService.Invoke() 
    
    # FILTER DATA
    
    $dataFilter = "[.[]| select(.station==$stationOrigin and .destination==$stationDestination" + ')] | group_by(.line, .updated) | map({ "line": .[0].line, "updated": .[0].updated, "delays_minutes": map(.delay/60) | unique })'
    $filteredResponse = $apiJsonResponse | jq $dataFilter
    
    return $filteredResponse
    <# [ {
        "line": "R1",
        "updated": "2022-02-22T17:04:43",
        "delays_minutes": [ 1.2833333333333334, 7.283333333333333 ] } ]
     #>
}

function vocalNotification($schedules) {
    
    $nextBuses = $schedules | ConvertFrom-Json

    $speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer;     
    foreach ($bus in $nextBuses)
    {
        write-host "  Line $($bus.line)"
        $speaker.Speak("Next bus to Saint Germain-en-Laye, line $($bus.line.split('')) in");
        $bus.delays_minutes | foreach {
            $nextDeparture = [System.Math]::Floor($_)
            $sentence = ($nextDeparture -lt 1) ? "less than one minute" : "$($nextDeparture) minutes";
            write-host "   🚌 $sentence"
            $speaker.Speak($sentence);
        }
    }
    $speaker.Dispose()
}

# API CALL PARAMETERS
$apiParams = @{   
    contentType = 'application/json';
    method = 'POST';
    body = 'token=undefined';
    uri = 'https://www.transdev-idf.com/ajax/station/540445338/nextbus';
    headers = @{ 'Host' = 'www.transdev-idf.com'
        'Accept' = 'application/json, text/javascript, */*; q=0.01'
        'X-Requested-With' = 'XMLHttpRequest'
        'Origin' = 'https://www.transdev-idf.com'
        'Accept-Encoding' = 'gzip, deflate, br'};
}

# Data Filter Parameters
$stationOrigin = "540445338"        # Lycée Leonard de Vinci
$stationDestination = "50012439"    # Saint Germain en Laye RER

$schedules = getSchedules
vocalNotification($schedules)
