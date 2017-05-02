# cfscriptme-command

A CommandBox command for CFML Tag to Script Conversion. This command uses the same engine as [cfscript.me](http://cfscript.me/)


## To Install

Run the following from commandbox:

	box install cfscriptme-command

## Examples

If you wish to convert your `Application.cfc` from tag to script run the following:

	cfscriptme Application.cfc

The above example will overwrite your `Application.cfc` if you want to save the file to `ApplicationScript.cfc` instead then just do this:
	
	cfscriptme Application.cfc ApplicationScript.cfc

You can also specify directories instead of single files, for example:

	cfscriptme some-folder/components/

## About

This tool was built by [Pete Freitag](https://www.petefreitag.com/) / [Foundeo Inc.](https://foundeo.com/) 

Besides CommandBox it uses two other packages: [toscript](https://github.com/foundeo/toscript) and [cfmlparser](https://github.com/foundeo/cfmlparser)