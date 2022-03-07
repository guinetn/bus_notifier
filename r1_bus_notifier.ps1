#
# BUS NOTIFIER V1.0.1
# https://github.com/guinetn/bus_notifier/edit/main/readme.md
#

# REQUIRED LIBRARIES
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xamlMainWindow = @"
<Window 
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"     
SizeToContent="WidthAndHeight" Title="BUS NOTIFIER 🚌">
    <Border Background="#FFD700" BorderBrush="Gray" BorderThickness="2">
        <Grid>
            <Image Source="$PSScriptRoot\bus.png" Stretch="None" Margin="-5,30,0,-20" HorizontalAlignment="Left"/>
            <StackPanel Margin="10">
            <TextBlock FontSize="14" ToolTip="Click to open timetable source">
                    <Hyperlink Name="linkToTimeTable" 
                            NavigateUri="https://www.transdev-idf.com/horaires-ligne-R1/lycee-de-vinci-vers-gare-de-st-germain-en-laye/012-RESALY-540445338-50012439">
                            BUS R1 ▶▶ SAINT-GERMAIN RER</Hyperlink>
                </TextBlock>
                <Label FontWeight="Bold" Content="{Binding Path=Value, ElementName=sliderNotificationFrequency}" ContentStringFormat="Vocal Information Frequency: {0:###} seconds" />
                <Slider Name="sliderNotificationFrequency" Value="60" Maximum="600" Minimum="30" TickFrequency="30" IsSnapToTickEnabled="True" TickPlacement="BottomRight"></Slider>
                <Button Name="buttonCloseApp" Content="Close" Background="#000000" Foreground="#FFF" Margin="10" HorizontalAlignment="Right" Width="100px" Height="40px"></Button>
            </StackPanel> 
        </Grid>
    </Border>
</Window>
"@

$timerNotification = [System.Windows.Threading.DispatcherTimer]::new()

$MainFunction = {

    $window = CreateWindow
    GenerateVariables
    RegisterEvents
    StartNotifications
    NotifyUser # notify user immediately
    
    $window.ShowDialog() | Out-Null
    UnRegisterEvents
 }

 function CreateWindow {
    $xmlReader=(New-Object System.Xml.XmlNodeReader $xamlMainWindow)
    return [Windows.Markup.XamlReader]::Load( $xmlReader )
}

function GenerateVariables() {
    # Create variables from xaml nodes having a 'NAME' attribute. Make them script scoped
    $xamlMainWindow.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Scope Script -Name ($_.Name) -Value $window.FindName($_.Name)}
}

function UnRegisterEvents() {
    $timerNotification.Stop()
}

function RegisterEvents() {
    
    $linkToTimeTable.add_Click({
        Start-Process $linkToTimeTable.NavigateUri;
    })

    $sliderNotificationFrequency.add_valuechanged({ 
        $actionFrequency = [int]$sliderNotificationFrequency.value
        $timerNotification.Interval = [Timespan]::FromSeconds($actionFrequency)
    }) 

    $buttonCloseApp.add_Click({ 
        UnRegisterEvents
        $window.Close() 
    }) 
}

function StartNotifications {
  
    $timerNotification.Interval =  [Timespan]::FromSeconds([int]$sliderNotificationFrequency.value)
    $timerNotification.Add_Tick( { 
        NotifyUser
    } )
    $timerNotification.Start()
}

function NotifyUser {
    write-host  "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") Vocal notification" 
    $actionScript = Join-Path $PSScriptRoot -ChildPath "vocal_message.ps1"
    Start-ThreadJob -FilePath $actionScript 
}

& $MainFunction
