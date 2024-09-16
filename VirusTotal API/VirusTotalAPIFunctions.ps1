<# GET VIRUS TOTAL FILE REPORT
Description: Takes as an input a hash and a VirusTotal API key and checks its reputation returning a report
Input: $Hash, $VTApiKey
Output: $VTReport
Use:
	$VTReport = GetVirusTotalFileReport $Hash $VTApiKey
#>
function GetVirusTotalFileReport {
    param (
	[Parameter(Mandatory=$true)] [string] $Hash,
	[Parameter(Mandatory=$true)] [string] $VTApiKey
	)

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	$Uri = 'https://www.virustotal.com/vtapi/v2/file/report'
    $VTbody = @{resource = $Hash; apikey = $VTApiKey}
    
	try {	
		$VTresult = Invoke-RestMethod -Method GET -Uri $Uri -Body $VTbody
    } catch {
		Write-Host "Cannot get VirusTotal rating. Please insert a valid API key" -Foregroundcolor red
	}
	
    if ($VTresult.positives -ge 1) {
            $VTpct = (($VTresult.positives) / ($VTresult.total)) * 100
            $VTpct = [math]::Round($VTpct,2)
    } else {
            $VTpct = 0
        }
    $VTReport = [PSCustomObject]@{   
						resource    = $VTresult.resource
                        scan_date   = $VTresult.scan_date
                        positives   = $VTresult.positives
                        total       = $VTresult.total
                        permalink   = $VTresult.permalink
                        percent     = $VTpct
                    }
					
    Start-Sleep 15;
	
	return $VTReport 
}

<# GET VIRUS TOTAL IP REPORT
Description: Takes as an input an IP address and a VirusTotal API key and checks its reputation returning a report
Input: $IP, $VTApiKey
Output: $VTReport
Use:
	$VTReport = GetVirusTotalFileReport $IP $VTApiKey
#>
function GetVirusTotalIPReport {
    param (
	[Parameter(Mandatory=$true)] [string] $IP,
	[Parameter(Mandatory=$true)] [string] $VTApiKey
	)

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	$Uri ="https://www.virustotal.com/api/v3/ip_addresses/"+$IP
	$Header = @{
    'X-Apikey' = $VTApiKey
	}
    
	$VTresult = ""
	try {	
		$VTresult = Invoke-RestMethod -Method GET -Uri $Uri -Header $Header
    } catch {
		Write-Host "Cannot get VirusTotal rating. Please insert a valid API key" -Foregroundcolor red
	}
	
	$VTReport = ""
	if($VTresult) {		
		$VTReport = [PSCustomObject]@{   
							ip          = $VTresult.data.id
							type        = $VTresult.data.type
							link        = $VTresult.data.links.self
							attributes  = $VTresult.data.attributes
						}
					
    }
	
	Start-Sleep 15;
	
	return $VTReport 
}