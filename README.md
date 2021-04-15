# Bexelon ![Bexelon Logo](https://i.ibb.co/GWhXyMK/Bexelon-50-no-bg.png)
## _A script to make your DayZ server installation better_

Bexelon is a Powershell script created to install your DayZ server and auto-updates your mods fully automatically. You just have one file to configure, you can then let the script make your installation.

## Features

- Install a new DayZ server or add Bexelon to an existing server
- Choose between your own local mod list or an online Steam mod Collection (from Steam Workshop)
- Enable or disable Battleye Anti-Cheat
- Auto-update mods from Steam Workshop and DayZ Server when the the script is executed and at every server reboot

## Prerequisites

Bexelon was created with this techonlogies :

- [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/overview) - Terminal
- [Git](https://git-scm.com/) - Git version control system
- [steamcmd.exe](https://developer.valvesoftware.com/wiki/SteamCMD#Downloading_SteamCMD) - The Steam Console Client

## Installation

Bexelon requires [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/overview) 5 or higher to work

If you want to install Bexelon for a new server, create a folder where you want to create your server, start Powershell and clone this repo into the folder that you have created. You can give it the name of the server you want to create.

If you want to install Bexelon in an existing server, just clone the repo at the root of your server.

```sh
git clone https://github.com/Firebels/Bexelon.git
```

## Configuration

Before launching the script, you have to edit the **config.xml** file. the configuration file is split into multiple parts.
Here will only be listed the important parameters.

Configure your server profile name (you can leave the default setting) :
```xml
<Settings>
	<Profile>ServerProfile</Profile>		<!-- The Server Profile you want to use (ex: ServerName) -->
	<BattleEye>False</BattleEye>			<!-- Enable BattleEye Anti-Cheat [True/False]? -->
</Settings>
```
> To set `BattleEye` to **true**, you have to put the BattleEye folder into your server dir (Path/Server config)

Configure your server paths (**important**) :

```xml
<Path>
	<SteamCMD>C:\steam</SteamCMD>	        <!-- Where is steamcmd.exe ? -->
	<Server>C:\steam\steamapps\common\DayZServer</Server>		<!-- Path to Game Server (ex: C:\servers\DayzServer) -->
</Path>
```
> You can download steamcmd [here](https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip).


BE AWARE! The script files cannot be stored in the Root Location Path of the DayZServer Directory, Unless They are stored in a Subfile of the DayZServer Directory.

>	DayZServer Root Location Path ----> C:\steam\steamapps\common\DayZServer
>	DayZServer Subfile Location Path --> C:\steam\steamapps\common\DayZServer\Subfile


Make sure your Path does not end with a Back Slash : "\\". 
>	Good exemple --> C:\User\Desktop\File\Subfile
>	Bad exemple ---> C:\User\Desktop\File\ 
>	Good exemple --> C:\User\Desktop\File


Configure your mods source :

```xml
<Game>
	<UseLocalModList>True</UseLocalModList>		<!-- Set True to use LocalModList.txt -->
	<CollectionId>2376686769</CollectionId>		<!-- Set Steam Workshop Collection ID (If API List) -->
</Game>
```
> If you want a Vanilla server without mods, set `UseLocalModList` to **True** and delete all the **LocalModList.txt** content.
> Set `UseLocalModList` to **True** for using the **LocalModList.txt** mod list
> The  `CollectionId` setting is used when `UseLocalModList` is set to **False**.

```xml
<Credentials> 
	<Username>username</Username>		<!-- Set steam username -->
	<Password>password</Password>		<!-- Set steam password -->
</Credentials>
```
> Enter your Steam credentials : **For security reasons it is recommended that you create a new Steam account just for your dedicated servers**.

## The LocalModList.txt
If you have enabled the `UseLocalModList` parameter, you can configure **LocalModList.txt** now. Use the format you want. You can find this file at the root of the script, if not exist create one.

Example :
```
### Standard mods ###
CF = 1559212036 you can put URL or not (this mod will be loaded)
Community online tools = https://steamcommunity.com/sharedfiles/filedetails/?id=1564026768
Ignore this mod: ~1564026799 (ignored)
```

> You can put **EVERYTHING** you want in this file. As long as the file contains a workshop mod ID (10-digit), the script will detect it, **no matter where it is in the file!**
To comment (and therefore ignore) a mod, add `~` in front of it.

## Installation Zero (Create a new server and go back to square one)

> You can use Bexelon on an existing DayZ server, skip this section and go to the next section.

Go to the Bexelon installation dir launch the **run.ps1** script with Powershell.

```sh
./run.ps1
```

> Powershell will surely ask you to make a choice regarding the execution policy :
> https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy

Let the script install your DayZ server...

## Launch the server

To launch your DayZ server, you just have to start the **run.ps1** script

## DayZ server updating

Your DayZ steam server will check update at each restart. The update will be installed automaticly.

## Mod installation

Add a new mod into the **LocalModList.txt** or into your Steam Workshop Collection (it depends on the `useLocalModList` parameter), and start (or restart) the script. The new mods will be installed on your DayZ server folder, and the .keys files will be pushed into the keys folder automaticly.

## Mod update

Your mods will be updated automatically each time you start the script. 
The mods concerned will be those that you put in your local mod list or those present in the workshop collection that you have configured in **config.xml**.

## Server configuration

You have to configure your mods yourself by entering into your server profile folder 🙂

## License

MIT 

**Free Software, Hell Yeah!**
