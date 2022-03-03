# WINDOW
Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase

$window = new-object Windows.Window
$stackPanel = new-object Windows.Controls.StackPanel

$title = New-Object Windows.Controls.Label
$title.Content = "BUS R1 VERS SAINT-GERMAIN RER"

$Timer = [System.Windows.Threading.DispatcherTimer]::new()

$labelUpdateFreq = New-Object Windows.Controls.Label
$labelUpdateFreq.Content = "Update Frequency (seconds)"
$sliderUpdateFreq = New-Object Windows.Controls.Slider
$sliderUpdateFreq.value = 10      # 10 seconds
$sliderUpdateFreq.Maximum = 60 # 10 min
$sliderUpdateFreq.Minimum = 5     #  1 seconds
$sliderUpdateFreq.add_valuechanged({ 
    $delay =  [int]$sliderUpdateFreq.value
    $labelUpdateFreq.Content = "Update Frequency: $delay sec" 
    $Timer.Interval = [Timespan]::FromSeconds($delay)
    write-host "interval set to:" $Timer.Interval

}) 
<#
private void Slider_ValueChanged(object sender,
            RoutedPropertyChangedEventArgs<double> e)
        {
            // ... Get Slider reference.
            var slider = sender as Slider;
            // ... Get Value.
            double value = slider.Value;
            // ... Set Window Title.
            this.Title = "Value: " + value.ToString("0.0") + "/" + slider.Maximum;
        }
        #>

$nextBuses = New-Object Windows.Controls.Label
$nextBuses.Content = "---"

# BUTTON "Close"
$buttonClose = New-Object Windows.Controls.Button 
$buttonClose.Width = 100 
$buttonClose.Height = 40 
$buttonClose.Margin = 10
$buttonClose.Background = "Gray"
$buttonClose.Foreground = "White"
$buttonClose.Content = "CLOSE"
$buttonClose.add_Click({ 
    $Timer.stop()
    $window.Close() 
}) 

$Components = $title, $labelUpdateFreq, $sliderUpdateFreq,  $nextBuses, $buttonClose
$Components | % { $null = $stackPanel.Children.Add($_) } 

$window.Content = $stackPanel
$window.SizeToContent = "WidthAndHeight"

$Timer.Interval = [timespan]"0:0:30"
$Timer.Add_Tick( { 
    write-output "interval:" $Timer.Interval
    Get-Date -Format "yyyy-MM-dd HH:mm:ss" | write-host 
    $scriptFilePath = Join-Path $PSScriptRoot -ChildPath "aural_message.ps1"
    $threadJob = Start-ThreadJob -FilePath $scriptFilePath #-ArgumentList "Hello"
} )
$Timer.Start()
$null = $window.ShowDialog()
$Timer.Stop()




# $params = @{
#             Uri         = $busServiceUri
#             Headers     = $busServiceHeaders
#             Method      = $busServiceMethod
#             Body        = $busServiceBody
#             ContentType = $busServiceContentType
# }
# $ret = Invoke-RestMethod @params 
# write-output $ret



<#
$ret = '[
    {
        "line": "R1",
        "charge": -1,
    "station": 540445338,
    "delay": 27,
    "direction": "backward",
    "wheelchair": true,
    "source": "INEO_RT",
    "updated": "2022-02-22T15:14:33",
    "destination": 50012439
},
{
    "line": "R1",
    "charge": -1,
    "station": 540445338,
    "delay": 927,
    "direction": "backward",
    "wheelchair": true,
    "source": "INEO_RT",
    "updated": "2022-02-22T15:14:33",
    "destination": 50012439
},
{
    "line": "R6",
    "charge": -1,
    "station": 540445338,
    "delay": 27,
    "direction": "backward",
    "wheelchair": true,
    "source": "INEO_RT",
    "updated": "2022-02-22T15:14:33",
    "destination": 50012444
}
]'
$ret | jq '[.[] | select((.line==\"R1\") and .destination==50012439 and .station==540445338) | { line,  delay, delay_min:(.delay/60), updated:.updated} ]'
#>





