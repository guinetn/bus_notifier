# REQUIRED LIBRARIES
Add-Type -AssemblyName System.speech;       # SPEECH SYNTHETIS
. ./apiservice.ps1

function getSchedules() {

    # GET DATA AS JSON
    $apiService = [ApiService]::new($apiParams)
    $apiJsonResponse = $apiService.Invoke() |  Select-Object -Property * | ConvertTo-Json 
    
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

function auralMessage($schedules) {
    
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
auralMessage($schedules)



<# BUS SERVICE API: DETAILS

Api      https://www.transdev-idf.com/horaires-ligne-R1/lycee-de-vinci-vers-gare-de-st-germain-en-laye/012-RESALY-540445338-50012439
Extract  Next buses departures

API REQUEST
    POST   https://www.transdev-idf.com/ajax/station/540445338/nextbus
    BODY   token:undefined    !! MANDATORY, AS IT IS !!
    HEADERS
        Host=www.transdev-idf.com;
        Accept=application/json, text/javascript, */*; q=0.01
        X-Requested-With=XMLHttpRequest
        Origin=https://www.transdev-idf.com
        Accept-Encoding=gzip, deflate, br

    All HEADERS before headers cleanup: some are not essential
        Host: www.transdev-idf.com
        Connection: keep-alive
        Content-Length: 15
        sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"
        Accept: application/json, text/javascript, */*; q=0.01
        Content-Type: application/x-www-form-urlencoded; charset=UTF-8
        X-Requested-With: XMLHttpRequest
        sec-ch-ua-mobile: ?0
        User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36
        sec-ch-ua-platform: "Windows"
        Origin: https://www.transdev-idf.com
        Sec-Fetch-Site: same-origin
        Sec-Fetch-Mode: cors
        Sec-Fetch-Dest: empty
        Referer: https://www.transdev-idf.com/horaires-ligne-R1/lycee-de-vinci-vers-gare-de-st-germain-en-laye/012-RESALY-540445338-50012439
        Accept-Encoding: gzip, deflate, br
        Accept-Language: fr,en;q=0.9

        
TEST
    $params = @{   
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
    $ret = Invoke-RestMethod @params 
    write-output $ret


RESPONSE
    
    Next bus in  ...  8 min
                 ... 23 min  
        Updated at 12h51 

    [
    {
        "charge": -1,
        "station": 540445338,
        "line": "R1",
        "delay": 525,                           525 / 60 = 8.75 min     ← 1st next bus at... 
        "direction": "backward",
        "wheelchair": true,
        "source": "INEO_RT",
        "updated": "2022-02-22T12:51:15",       ← updated at...
        "destination": 50012439
    },
    {
        "charge": -1,
        "station": 540445338,
        "line": "R1",
        "delay": 1425,                      1425 / 60 = 23 min      ← next bus at...
        "direction": "backward",
        "wheelchair": true,
        "source": "INEO_RT",
        "updated": "2022-02-22T12:51:15",
        "destination": 50012439
    },
    {
        "charge": -1,
        "station": 540445338,
        "line": "R6",                       ← not interested in the R6 line
        "delay": 1725,
        "direction": "backward",
        "wheelchair": true,
        "source": "INEO_RT",
        "updated": "2022-02-22T12:51:15",
        "destination": 50012444
    },
    {
        "charge": -1,
        "station": 540445338,
        "line": "R6",                       ← not interested in the R6 line
        "delay": 5325,
        "direction": "backward",
        "wheelchair": false,
        "source": "INEO_RT",
        "updated": "2022-02-22T12:51:15",
        "destination": 50012444
    }
    ]



## JQ: JSON processor

- Command-line JSON processor: https://stedolan.github.io/jq/
- A playground for jq, written in Go: https://jqplay.org/


INPUT

    [
    {
        "source": "INEO_RT",
        "updated": "2022-02-22T13:00:31",
        "direction": "backward",
        "charge": -1,
        "line": "R1",
        "destination": 50012439,
        "delay": 869,
        "wheelchair": true,
        "station": 540445338
    },
    {
        "source": "INEO_RT",
        "updated": "2022-02-22T13:00:31",
        "direction": "backward",
        "charge": -1,
        "line": "R1",
        "destination": 50012439,
        "delay": 1769,
        "wheelchair": true,
        "station": 540445338
    },
    {
        "source": "INEO_RT",
        "updated": "2022-02-22T13:00:31",
        "direction": "backward",
        "charge": -1,
        "line": "R6",
        "destination": 50012444,
        "delay": 1169,
        "wheelchair": true,
        "station": 540445338
    },
    {
        "source": "INEO_RT",
        "updated": "2022-02-22T13:00:31",
        "direction": "backward",
        "charge": -1,
        "line": "R6",
        "destination": 50012444,
        "delay": 4769,
        "wheelchair": false,
        "station": 540445338
    }
    ]

FILTERS
    keep line R1 from bus station 540445338 to 50012439 

JQ FILTER 1

    .[] | select((.line== "R1") and .destination==50012439 and .station==540445338) | {line,  delay, delay_min:(.delay/60), updated:.updated}

    RESULT

        {
        "line": "R1",
        "delay": 869,
        "delay_min": 14.483333333333333,
        "updated": "2022-02-22T13:00:31"
        }
        {
        "line": "R1",
        "delay": 1769,
        "delay_min": 29.483333333333334,
        "updated": "2022-02-22T13:00:31"
        }


JQ FILTER 2

    [ .[] | select((.line== "R1") and .destination==50012439 and .station==540445338) |  {line,  delay, delay_min:(.delay/60), updated:.updated} ] | group_by(.line) | map({ "line": .[0].line, "delays": map(.delay) | unique }) 

    RESULT
    
        [
        {
            "line": "R1",
            "delays": [
            0.45,
            15.45
            ]
        }
        ]

JQ FILTER 3

    [ .[] | select(.destination==50012439 and .station==540445338)] |  group_by(.line, .updated) | map({ "line": .[0].line, "updated": .[0].updated, "delays_minutes": map(.delay/60) | unique }) 
#>