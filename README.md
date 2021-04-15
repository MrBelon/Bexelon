# Bexelon
## _A script to make your DayZ Server installation better_

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Bexelon is a Powershell script install your DayZ server fully automaticly. You just have to configure one file and let the script make your installation.

## Features

- Choose local mod list or online Steam mod Collection (from Workshop)
- Enable or disable Battleye Anti-Cheat
- Auto-update mods from workshop when the server starts

## Tech

Dillinger uses a number of open source projects to work properly:

- [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1) - Cross-platform task automation solution

## Installation

Bexelon requires [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1) 5+ to work

Start Powershell and clone this repo.

```sh
git clone https://github.com/Firebels/Bexelon.git
```

Before launching the script, you have to edit the **config.xml** file.

```xml
<Settings>
	<Profile>ServerProfile</Profile>		<!-- The Server Profile you want to use (ex: ServerName) -->
	<CPU>4</CPU>							<!-- Number of CPU you want to use for your server -->
	<BattleEye>False</BattleEye>			<!-- Enable BattleEye Anti Cheat ? -->
	<DeleteOldLogs>True</DeleteOldLogs>		<!-- Delete old .log files when server restart ? -->
</Settings>
```

## Development

Want to contribute? Great!


```sh
docker run -d -p 8000:8080 --restart=always --cap-add=SYS_ADMIN --name=dillinger <youruser>/dillinger:${package.json.version}
```

> Note: `--capt-add=SYS-ADMIN` is required for PDF rendering.

## License

MIT

**Free Software, Hell Yeah!**
Markdown is a lightweight markup language based on the formatting conventions
that people naturally use in email.
As [John Gruber] writes on the [Markdown site][df1]

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [dill]: <https://github.com/joemccann/dillinger>
   [git-repo-url]: <https://github.com/joemccann/dillinger.git>
   [john gruber]: <http://daringfireball.net>
   [df1]: <http://daringfireball.net/projects/markdown/>
   [markdown-it]: <https://github.com/markdown-it/markdown-it>
   [Ace Editor]: <http://ace.ajax.org>
   [node.js]: <http://nodejs.org>
   [Twitter Bootstrap]: <http://twitter.github.com/bootstrap/>
   [jQuery]: <http://jquery.com>
   [@tjholowaychuk]: <http://twitter.com/tjholowaychuk>
   [express]: <http://expressjs.com>
   [AngularJS]: <http://angularjs.org>
   [Gulp]: <http://gulpjs.com>

   [PlDb]: <https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md>
   [PlGh]: <https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md>
   [PlGd]: <https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md>
   [PlOd]: <https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md>
   [PlMe]: <https://github.com/joemccann/dillinger/tree/master/plugins/medium/README.md>
   [PlGa]: <https://github.com/RahulHP/dillinger/blob/master/plugins/googleanalytics/README.md>
