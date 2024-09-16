<# GET IP DATA FROM SHODAN
Author: Giuseppe Malandrone
Description: Takes as an input a Shodan API key and an IP address and returns some data about it
Input: $ApiKey, $IP
Output: $ShodanIPData
Use:
	$ShodanIPData = GetIPDataFromShodan $APIkey $IP
#>
function GetIPDataFromShodan {
	param( 
	[Parameter(Mandatory = $True)] [string] $APIkey,
 	[Parameter(Mandatory = $True)] [string] $IP
	)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Uri =  "https://api.shodan.io/shodan/host/"+$IP+"?key="+$APIkey

$ShodanIPData =""
try {	
		$ShodanIPData = Invoke-RestMethod -Method Get -Uri $Uri
    } catch {
		Write-Host "Cannot get data. Please insert a valid API key" -Foregroundcolor red
	}

Sleep 5

return $ShodanIPData
}

<# SHODAN QUERY
Author: Giuseppe Malandrone
Description: Takes as an input a Shodan API key and a query returns related results found by the Shodan search engine
Input: $ApiKey, $Query
Output: $ShodanResults
Use:
	1	$ShodanResults = ShodanQuery $APIkey $Query
	2	$ShodanResults = ShodanQuery $APIkey $Query $Facets
#>
function ShodanQuery {
	param( 
	[Parameter(Mandatory = $True)] [string] $APIkey,
 	[Parameter(Mandatory = $True)] [string] $Query,
	[Parameter(Mandatory = $False)] [string] $Facets
	)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if($Facets) {
	$Uri =  'https://api.shodan.io/shodan/host/search?key='+$APIkey+'&query='+$Query+'&facets='+$Facets
} else {
	$Uri =  'https://api.shodan.io/shodan/host/search?key='+$APIkey+'&query='+$Query
}

$ShodanResults =""
try {	
		$ShodanResults = Invoke-RestMethod -Method Get -Uri $Uri
    } catch {
		Write-Host "Cannot get data. Please insert a valid API key" -Foregroundcolor red
	}

Sleep 5

return $ShodanResults
}