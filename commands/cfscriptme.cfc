/**
 * Converts Tag based CFCs to CFML Script CFCs
 * .
 * Examples
 * {code:bash}
 * cfscriptme file.cfc
 * {code}
 **/
component extends="commandbox.system.BaseCommand" excludeFromHelp=false {

	/**
	* @sourcePath.hint A CFC file or directory
	* @destinationPath.hint The resulting file or directory, if omitted overwrites
	* @force.hint Force writing the file even if there are errors, default to false. 
	* @recursive.hint When a directory is specified it goes recursivly through all cfc files. Default is true
	**/
	function run( required sourcePath, destinationPath="", boolean force=false, boolean recursive=true)  {
		var fileInfo = "";
		print
	        .orangeLine("cfscript.me v#getVersion()# built by Foundeo Inc.")
	        .line()
	        .grayLine("    ___                      _             ")
	        .grayLine("   / __)                    | |            ")
	        .grayLine(" _| |__ ___  _   _ ____   __| |_____  ___  ")
	        .grayLine("(_   __) _ \| | | |  _ \ / _  | ___ |/ _ \ ")
	        .grayLine("  | | | |_| | |_| | | | ( (_| | ____| |_| |")
	        .grayLine("  |_|  \___/|____/|_| |_|\____|_____)\___/ ")
	        .grayLine("                                         inc.")
	        .line();
		arguments.sourcePath = fileSystemUtil.resolvePath( arguments.sourcePath );
		if (!fileExists(arguments.sourcePath) && !directoryExists(arguments.sourcePath)) {
			error("Sorry: #arguments.sourcePath# is not a file or directory.");
			return;
		}

		fileInfo = getFileInfo(arguments.sourcePath);
		

		if (!len(arguments.destinationPath)) {
			arguments.destinationPath = arguments.sourcePath;
		} else {
			arguments.destinationPath = fileSystemUtil.resolvePath( arguments.destinationPath );
		}

		if (!fileInfo.canRead) {
			error("Sorry: No read permission for source path");
			return;
		}

		if (fileInfo.type == "file") {
			convertFile(source=arguments.sourcePath, destination=arguments.destinationPath, force=arguments.force, pathPrefix=getDirectoryFromPath(arguments.sourcePath));
		} else {

			if (!directoryExists(arguments.destinationPath)) {
				directoryCreate(arguments.destinationPath);
			}

			if (right(arguments.destinationPath, 1) != "/" && right(arguments.destinationPath, 1) != "\") {
				arguments.destinationPath = arguments.destinationPath & "/";
			}

			if (right(arguments.sourcePath, 1) != "/" && right(arguments.sourcePath, 1) != "\") {
				arguments.sourcePath = arguments.sourcePath & "/";
			}
			


			fileInfo = getFileInfo(arguments.destinationPath);
			if (fileInfo.type == "file") {
				error("Sorry: source path is a directory but destination is a file");
				return;
			}

			local.paths = directoryList(arguments.sourcePath, arguments.recursive, "path", "*.cfc");

			for (local.path in local.paths) {
				local.dest = replace(local.path, arguments.sourcePath, arguments.destinationPath);
				if (!directoryExists(getDirectoryFromPath(local.dest))) {

					directoryCreate(getDirectoryFromPath(local.dest));

				}
				convertFile(source=local.path, destination=local.dest, force=arguments.force, pathPrefix=arguments.sourcePath);
			}

		}


		print.line().line("Done. Bugs / Suggestions: https://github.com/foundeo/toscript/issues").line();

	}

	private function getVersion() {
		if (!variables.keyExists("version")) {
			local.boxPath = reReplace(getCurrentTemplatePath(), "commands[/\\]cfscriptme.cfc$", "box.json");
			local.boxJSON = fileRead(local.boxPath);
			if (isJSON(local.boxJSON)) {
				local.box = deserializeJSON(local.boxJSON);
				variables.version = local.box.version;	
			} else {
				return "Unknown Version: box.json was not JSON";
			}
			
		}
		return variables.version;
	}

	private function convertFile(required source, required destination, boolean force=false, pathPrefix="") {

		var toScript = getInstance("ToScript@cfscriptme-command");

		var result = toScript.toScript(filePath=arguments.source);

		var normalizedPath = replace(arguments.source, arguments.pathPrefix, "");

		var fileInfo = getFileInfo(arguments.source);


		if (fileInfo.type != "file") {
			print.redLine("Error Source File: " & arguments.source & " is not a file. Skipping.");
			return;
		}

		if (!fileInfo.canRead) {
			print.redLine("Error No Read Permissions for file: " & arguments.source & " Skipping file.");
			return;
		}

		if (fileExists(arguments.destination)) {
			fileInfo = getFileInfo(arguments.destination);
			if (!fileInfo.canWrite) {
				print.redLine("Error Cannot Write Destination: " & arguments.destination);
			}

			if (!arguments.force && result.converted && arguments.source != arguments.destination) {
				local.answer = ask("Can I overwrite #normalizedPath#? (yes/no): ");

				if (left(local.answer,1) != "y") {
					print.indentedYellowLine("Aye Captin, skipped #normalizedPath#");
					return;
				}

			}
		}


		

		if (!result.converted) {
			print.yellowLine("#checkMark()#  (Already CFML Script): " & normalizedPath);
			if (arguments.source != arguments.destination) {
				fileWrite(arguments.destination, result.code);
			}
			return;
		}

		if (arrayLen(result.errors)) {
			print.redLine("#errorMark()# Error: " & normalizedPath);
			for (local.err in result.errors) {
				if (local.err.keyExists("error") && local.err.error.keyExists("message")) {
					print.indentedYellowLine(local.err.error.message);	
				} else if (local.err.keyExists("tag")) {
					print.indentedYellowLine("Unable to convert: " & local.err.tag);
				} else {
					print.indentedYellowLine("Unknown Error");
				} 
				
			}
			if (!arguments.force) {
				local.check = ask("Even though there was an error do you want to convert #getFileFromPath(arguments.source)# anyway? (yes/no): ");
				if (left(local.check,1) != "y") {
					return;	
				}
				
			}
		} 

		fileWrite(arguments.destination, result.code);


		print.greenLine("#checkMark()#  (Converted): " & normalizedPath).toConsole();






	}

	function checkMark() {
		if (fileSystemUtil.isWindows()) {
			return "+";
		} else {
			return "✅";
		}
	}

	function errorMark() {
		if (fileSystemUtil.isWindows()) {
			return "!";
		} else {
			return "🔴";
		}
	}

}