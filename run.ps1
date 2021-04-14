#################################################################
# Project	:  Bexelon (https://github.com/Firebels/FireDayZ)	#
# Version	:  Beta 1.5.1 										#
# Developer :  Robin Belon (belon.rbn@gmail.com)				#
# Server	:  DayZ (https://www.survivalistes.fr)				#
# Important	:  Configure "config.xml" before running this		#
#################################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$host.UI.RawUI.WindowTitle = "Bexelon - Running..."

[XML]$_xml_config = Get-Content config.xml # Get the config
	 $Config = $_xml_config.Config
	 $LogFile = "$($Config.Path.Server)\logs\Bexelon.log"

function startServer # Start the server
{
	Write-Output "Starting DayZ Server using Bexelon (thank you :D)..." >> $LogFile

	Set-Location -Path $Config.Path.Server
	Start-Process -FilePath "$($Config.Path.Server)\DayZServer_x64.exe" -ArgumentList "-instanceId=1 -config=serverDZ.cfg -profiles=$($Config.Settings.Profile) -port=2302 `"-mod=@$($ModList -join ';@')`" -cpuCount=$($Config.Settings.CPU) -noFilePatching -dologs -adminlog -freezecheck"

	30..0 | ForEach-Object { Write-Output "Server initializing, please wait $($_) sec. before launching BattleEye-Extended-Controls..."; Start-Sleep -Seconds 1 }

	if($Config.Settings.BattleEye -eq 'True') { startBec } checkServer
}

function sendHooks
{
	# In a future version
	startServer
}

function startBec # Start BEC if enabled
{
	if($(Test-Path "$($Config.Path.Server)\battleye\Config\Config.cfg" -PathType Leaf))
	{
		Write-Output "Starting BattleEye Anti-Cheat" >> $LogFile
		Start-Process -FilePath "$($Config.Path.Server)\battleye\Bec.exe" -ArgumentList "-f Config.cfg --dsc"
	}
	else{ Write-Output "BattleEye config not found, starting server without BEC" >> $LogFile }
	
	checkServer
}

function copyFolders
{
	$ModList = @()
	Write-Output "Copying Workshop files... (This operation may take a several minutes)" >> $LogFile

	$Collection | ForEach-Object {
		$modName = $(Get-Content -Path "$($Config.Path.Workshop)\$($_.publishedfileid)\meta.cpp" | Select-String 'name = "(.+)";' -AllMatches).Matches.Groups[1].Value -Replace '[@#?\{ ]','_' -Replace '[\[\]]',''
		
		if(!$(Test-Path "$($Config.Path.Server)\`@$($modName)\meta.cpp" -PathType Leaf)) { $exists = ""	}
		if(Compare-Object -ReferenceObject $(Get-Content "$($Config.Path.Workshop)\$($_.publishedfileid)\meta.cpp") -DifferenceObject $(Get-Content "$($Config.Path.Server)\`@$($modName)\meta.cpp" -ErrorAction SilentlyContinue)) { $exists = "*" }

		Copy-Item -Path "$($Config.Path.Workshop)\$($_.publishedfileid)\$($exists)" -Destination "$($Config.Path.Server)\`@$($modName)\" -Recurse -Force -PassThru

		$ModList += $modName
	} # Copy Workshop downloaded content
	
	$Collection | ForEach-Object { Get-ChildItem -Path "$($Config.Path.Workshop)\$($_.publishedfileid)" -Filter *.bikey -Recurse -File | Copy-Item -Destination "$($Config.Path.Server)\keys\" -PassThru } #Copy Keys
	
	Write-Host "Loaded mods: " -ForegroundColor Green -NoNewline; Write-Host $($ModList -join ', ') -ForegroundColor Blue
	Write-Output "Loaded $($ModList.Length) mod(s): $($ModList -join ', ')" >> $LogFile

	sendHooks
}

function dlMods 
{
	$Collection | ForEach-Object { $WS_Collection = "$($WS_Collection) +workshop_download_item $($Config.Game.GameId) $($_.publishedfileid) " }
		
	Start-Process -FilePath "$($Config.Path.SteamCMD)\steamcmd.exe" -ArgumentList "+login $($Config.Credentials.Username) $($Config.Credentials.Password) +app_update $($Config.Game.Branch) $($WS_Collection) validate +quit"
	
	Write-Output "Steam is downloading mods..." >> $LogFile

	$i = 0
	Do { # Server won't start while Steam is downloading mods
		$i++
		Write-Output "Steam is downloading missing mods, please wait... ($i seconds elapsed)"
		Start-Sleep -Seconds 1
	} While(Get-Process -Name steamcmd -ErrorAction SilentlyContinue)
	
	Write-Output "Mods downloaded from workshop $($i) secondes elapsed" >> $LogFile

	copyFolders
}

function getCollection # Get the modlist from the API (Steam Workshop Collection)
{
	if($Config.Game.UseLocalModList -eq 'True') {
		# Get collection from local file
		$Collection = @()
		$($(Get-Content .\localModList.txt) | Select-String '[^~]\d{10}' -AllMatches).Matches | ForEach-Object {
			$Collection += @{publishedfileid = $_.ToString().substring(1)}
		}
		Write-Output "Getting collection from local file, $($Collection.Length) mods" >> $LogFile
	} else {
		# Get collection from SteamAPI
		$PostParams = @{ collectioncount = 1;
			'publishedfileids[0]' = $Config.Game.CollectionId }
		$ApiCollection = Invoke-WebRequest -Uri 'https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v0001/?format=json' -Method POST -Body $PostParams
		$Collection = $($ApiCollection.Content | ConvertFrom-Json).response.collectiondetails.children 
		Write-Output "Getting collection from Steam API, $($Collection.Length) mods" >> $LogFile
	}

	dlMods # Download mods
}

function checkServer # The first step, check if the server is running
{
	if(!$(Test-Path $LogFile -PathType Leaf)) # Check if .log file exists
	{
		New-Item -ItemType "file" -Path $LogFile # If not, create .log file
	}

	if(!$(Get-Process -name DayZServer_x64 -ErrorAction SilentlyContinue)) # Check if server is running
	{
		Write-Output "Server not detected! Initializing server..." >> $LogFile
		Stop-Process -name DZSALModServer -ErrorAction SilentlyContinue
		Stop-Process -name Bec -ErrorAction SilentlyContinue
		getCollection # Not running, get mod list
	}

	if(!$(Get-Process -name Bec -ErrorAction SilentlyContinue)) { startBec } # Server running, check BEC

	30..0 | ForEach { "Server started. Verification in $_"; Start-Sleep -Seconds 1 } # Verification every 30 sec
	checkServer
}

Write-Output "Starting DayZ Bexelon script" > $LogFile
checkServer