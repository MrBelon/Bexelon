#################################################################
# Project	:  Bexelon (https://github.com/Firebels/Bexelon)	#
# Version	:  Beta 1.6.0 										#
# Developer :  Robin Belon (belon.rbn@gmail.com)				#
# Server	:  DayZ (https://www.survivalistes.fr)				#
# Important	:  Configure "config.xml" before running this		#
#################################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$host.UI.RawUI.WindowTitle = "Bexelon is Running..."

[XML]$_xml_config = Get-Content config.xml # Get the config
	 $Config = $_xml_config.Config
	 $LogFile = "./Bexelon.log"
	 $WorkshopPath = "..\steamapps\workshop\content\221100"
	 $GameBranch = 223350

function LogWrite
{
	param( 
		[string]$Log, 
		[Parameter(Mandatory=$false)]
		[string]$Tc = "White",
		[Parameter(Mandatory=$false)]
		[string]$isLog = "True" )

	if(!$(Test-Path $LogFile -PathType Leaf)) # Check if .log file exists
	{
		New-Item -ItemType "file" -Path $LogFile # If not, create .log file
	}

	$Time = (Get-Date).toString("yyyy/MM/dd HH:mm:ss") # Get actual datetime

	Add-content $Logfile -value "[$Time] $Log" # Write a log

	if($isLog -eq 'True') {
		Write-Host $Log -ForegroundColor $Tc } # Write & color the log text
}

function startServer # Start the server
{
	LogWrite "Starting DayZ Server using Bexelon (thank you :D)..."

	Start-Process -FilePath "..\DayZServer_x64.exe" -ArgumentList "-instanceId=1 -config=serverDZ.cfg -profiles=$($Config.Settings.Profile) -port=2302 `"-mod=@$($ModList -join ';@')`" -cpuCount=$($Config.Settings.CPU) -noFilePatching -dologs -adminlog -freezecheck"

	if($Config.Settings.BattleEye -eq 'True') { startBec } checkServer # Start BattleEye if enabled in the config
}

function sendHooks
{
	# In a future version
	startServer
}

function startBec # Start BEC if enabled
{
	30..0 | ForEach-Object { Write-Output "Server initializing, please wait $($_) sec. before launching BattleEye-Extended-Controls..."; Start-Sleep -Seconds 1 }

	if($(Test-Path "..\battleye\Config\Config.cfg" -PathType Leaf)) # BEC config file exists ?
	{
		LogWrite "Starting BattleEye Anti-Cheat" 
		Start-Process -FilePath "..\battleye\Bec.exe" -ArgumentList "-f Config.cfg --dsc" # Start BEC
	}
	else{ LogWrite "BattleEye config not found, starting server without BEC" Red }
	
	checkServer
}

function copyFolders
{
	$ModList = @()
	LogWrite "Copying Workshop files... (This operation may take a several minutes)"

	$Collection | ForEach-Object {
		$modName = $(Get-Content -Path "$($WorkshopPath)\$($_.publishedfileid)\meta.cpp" | Select-String 'name = "(.+)";' -AllMatches).Matches.Groups[1].Value -Replace '[@#?\{ ]','_' -Replace '[\[\]]',''
		
		if(!$(Test-Path "..\`@$($modName)\meta.cpp" -PathType Leaf)) { 
			Copy-Item -Path "$($WorkshopPath)\$($_.publishedfileid)\" -Destination "..\`@$($modName)\" -Recurse -Force -PassThru
		}
		if(Compare-Object -ReferenceObject $(Get-Content "$($WorkshopPath)\$($_.publishedfileid)\meta.cpp") -DifferenceObject $(Get-Content "..\`@$($modName)\meta.cpp" -ErrorAction SilentlyContinue)) { 
			Copy-Item -Path "$($WorkshopPath)\$($_.publishedfileid)\*" -Destination "..\`@$($modName)\" -Recurse -Force -PassThru
		}

		$ModList += $modName
	} # Copy Workshop downloaded content
	
	$Collection | ForEach-Object { Get-ChildItem -Path "$($WorkshopPath)\$($_.publishedfileid)" -Filter *.bikey -Recurse -File | Copy-Item -Destination "..\keys\" -PassThru } #Copy Keys
	
	Write-Host "Loaded $($ModList.Length) mod(s): " -ForegroundColor Green -NoNewline; Write-Host $($ModList -join ', ') -ForegroundColor Blue
	LogWrite "Loaded $($ModList.Length) mod(s): $($ModList -join ', ')" White False

	sendHooks
}

function noSteamCmd
{
	LogWrite "Downloading and installing steamcmd..." Red
	$tempArchive = "./steamcmd/steamcmd.temp.zip"
	Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile $($tempArchive)
	LogWrite "Extracting steamcmd. Please wait a few seconds..." Red
	Expand-Archive -Path $($tempArchive) -DestinationPath "./steamcmd/"
	Remove-Item $tempArchive
}

function dlMods 
{
	if(!$(Test-Path steamcmd.exe -PathType Leaf)) { noSteamCmd }
	
	$Collection | ForEach-Object { $WS_Collection = "$($WS_Collection) +workshop_download_item 221100 $($_.publishedfileid) " }
	
	Start-Process -FilePath steamcmd\steamcmd.exe -ArgumentList "+login $($Config.Credentials.Username) $($Config.Credentials.Password) +force_install_dir ../../ +app_update $($GameBranch) $($WS_Collection) validate +quit"
	
	LogWrite "Steam is downloading updates & mods..."

	$i = 0
	Do { # Server won't start while Steam is downloading mods
		$i++
		Write-Output "Steam is downloading updates & mods, please wait... ($i seconds elapsed)"
		Start-Sleep -Seconds 1
	} While(Get-Process -Name steamcmd -ErrorAction SilentlyContinue)
	
	LogWrite "Mods downloaded from workshop $($i) secondes elapsed" Yellow

	copyFolders
}

function getCollection # Get the modlist from the API (Steam Workshop Collection)
{
	if($Config.Mods.UseLocalModList -eq 'True') {
		# Get collection from local file
		$Collection = @()
		$($(Get-Content .\LocalModList.txt) | Select-String '[^~]\d{10}' -AllMatches).Matches | ForEach-Object {
			$Collection += @{publishedfileid = $_.ToString().substring(1)}
		}
		LogWrite "Getting collection from local file, $($Collection.Length) mods"
	} else {
		# Get collection from SteamAPI
		$PostParams = @{ collectioncount = 1;
			'publishedfileids[0]' = $Config.Mods.CollectionId }
		$ApiCollection = Invoke-WebRequest -Uri 'https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v0001/?format=json' -Method POST -Body $PostParams
		$Collection = $($ApiCollection.Content | ConvertFrom-Json).response.collectiondetails.children 
		LogWrite "Getting collection from Steam API, $($Collection.Length) mods"
	}

	dlMods # Download mods
}

function checkServer # The first step, check if the server is running
{
	if(!$(Get-Process -name DayZServer_x64 -ErrorAction SilentlyContinue)) # Check if server is running
	{
		LogWrite "Server not detected! Initializing server..." DarkRed
		Stop-Process -name DZSALModServer -ErrorAction SilentlyContinue
		Stop-Process -name Bec -ErrorAction SilentlyContinue
		getCollection # Not running, get mod list
	}

	if(!$(Get-Process -name Bec -ErrorAction SilentlyContinue) -And $($Config.Settings.BattleEye -eq 'True')) { startBec } # Server running, check BEC

	Write-Host "All is alright !" -ForegroundColor Green

	30..0 | ForEach { "Server started. Verification in $_"; Start-Sleep -Seconds 1 } # Verification every 30 sec
	checkServer
}

checkServer

LogWrite "Starting DayZ Bexelon script" Green