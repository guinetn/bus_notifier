# DETALS ON THE BUS SERVICE API USED

1. WEBSITE USED

    https://www.transdev-idf.com/horaires-ligne-R1/lycee-de-vinci-vers-gare-de-st-germain-en-laye/012-RESALY-540445338-50012439

    We are interested in the "MON PROCHAIN BUS DANS..." area which contains the next two schedule

2. API REQUEST PARAMETERS

        POST   https://www.transdev-idf.com/ajax/station/540445338/nextbus
        BODY   token:undefined         !! MANDATORY, AS IT IS !!
        HEADERS
            Host=www.transdev-idf.com;
            Accept=application/json, text/javascript, */*; q=0.01
            X-Requested-With=XMLHttpRequest
            Origin=https://www.transdev-idf.com
            Accept-Encoding=gzip, deflate, br

    The above request has been cleaned, the complete original request, below, has some headers that are not essential:

        All HEADERS before headers cleanup:
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

3. GETTING DATA WITH POWERSHELL

    ```powershell
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
    ```


    RESPONSE
        
        Next bus in  ...  8 min
                    ... 23 min  
            Updated at 12h51 

        We are interested only in the 'R1' bus line

        [
        {
            "charge": -1,
            "station": 540445338,
            "line": "R1",                           📌 The line we want
            "delay": 525,                           📌 525 / 60 = 8.75 min     ← 1st next bus at... 
            "direction": "backward",
            "wheelchair": true,
            "source": "INEO_RT",
            "updated": "2022-02-22T12:51:15",       ← updated at...
            "destination": 50012439
        },
        {
            "charge": -1,
            "station": 540445338,
            "line": "R1",                           📌 The line we want
            "delay": 1425,                          📌 1425 / 60 = 23 min      ← 2nd next bus at...
            "direction": "backward",
            "wheelchair": true,
            "source": "INEO_RT",
            "updated": "2022-02-22T12:51:15",
            "destination": 50012439
        },
        {
            "charge": -1,
            "station": 540445338,
            "line": "R6",                           ← not interested in the R6 line
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
            "line": "R6",                           ← not interested in the R6 line
            "delay": 5325,
            "direction": "backward",
            "wheelchair": false,
            "source": "INEO_RT",
            "updated": "2022-02-22T12:51:15",
            "destination": 50012444
        }
        ]



4. FILTER JSON DATA WITH THE JQ JSON processor

    |||
    --|--
    Command-line JSON processor | https://stedolan.github.io/jq/
    A playground for jq, written in Go | https://jqplay.org/


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

# EXPERIMENT JQ FILTERS
    
Goal: extract schedule for the bus line 'R1' from bus station #540445338 to bus station #50012439 

### FILTER #1
`Extract next schedule for line R1`

    ⚠️ Trim filter's spaces if you past it in jq playground from here

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



### FILTER #2
`Group schedules for the R1 line`

    [ .[] | select((.line== "R1") and .destination==50012439 and .station==540445338) |  {line,  delay, delay_min:(.delay/60), updated:.updated} ] | group_by(.line) | map({ "line": .[0].line, "delays": map(.delay) | unique })

    RESULT
        [
        {
            "line": "R1",
            "delays": [
            869,
            1769
            ]
        }
        ]


### FILTER #3 
`Convert seconds to minutes, add 'updated' field`

    [ .[] | select(.destination==50012439 and .station==540445338)] |  group_by(.line, .updated) | map({ "line": .[0].line, "updated": .[0].updated, "delays_minutes": map(.delay/60) | unique })

    RESULT
        [
        {
            "line": "R1",
            "updated": "2022-02-22T13:00:31",
            "delays_minutes": [
            14.483333333333333,
            29.483333333333334
            ]
        }
        ]