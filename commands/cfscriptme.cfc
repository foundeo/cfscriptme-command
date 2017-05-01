/**
 * Converts Tag based CFCs to CFML Script CFCs
 * .
 * Examples
 * {code:bash}
 * cfscriptme file.cfc
 * {code}
 **/
component extends="commandbox.system.BaseCommand" aliases="cfscriptme" excludeFromHelp=false {

	/**
	* @source.hint A CFC file or directory
	* @destination.hint The resulting file or directory, if omitted overwrites
	* @force.hint Force writing the file even if there are errors, default to false. 
	* @recursive.hint When a directory is specified it goes recursivly through all cfc files.
	**/
	function run( required source, destination="", boolean force=false, boolean recursive=true)  {
		var fileInfo = "";
		print.orangeLine("cfscript.me v1.0.0 built by Foundeo Inc.").line();
		print.grayLine("    ___                      _             ");
		print.grayLine("   / __)                    | |            ");		
		print.grayLine(" _| |__ ___  _   _ ____   __| |_____  ___  ");
		print.grayLine("(_   __) _ \| | | |  _ \ / _  | ___ |/ _ \ ");
		print.grayLine("  | | | |_| | |_| | | | ( (_| | ____| |_| |");
		print.grayLine("  |_|  \___/|____/|_| |_|\____|_____)\___/ ");
		print.grayLine("                                         inc.");
		print.line();

		if (!fileExists(arguments.source) && !directoryExists(arguments.source)) {
			print.boldRedLine("Sorry: #arguments.source# is not a file or directory.");
			return;
		}

		fileInfo = getFileInfo(arguments.source);
		

		if (!len(arguments.destination)) {
			arguments.destination = arguments.source;
		}

		if (!fileInfo.canRead) {
			print.boldReadLine("Sorry: No read permission for source path");
			return;
		}

		if (fileInfo.type == "file") {
			convertFile(source=arguments.source, destination=arguments.destination, force=arguments.force, pathPrefix=getDirectoryFromPath(arguments.source));
		} else {

			if (!directoryExists(arguments.destination)) {
				directoryCreate(arguments.destination);
			}

			if (right(arguments.destination, 1) != "/" && right(arguments.destination, 1) != "\") {
				arguments.destination = arguments.destination & "/";
			}

			if (right(arguments.source, 1) != "/" && right(arguments.source, 1) != "\") {
				arguments.source = arguments.source & "/";
			}
			//fixme windows path seperator


			fileInfo = getFileInfo(arguments.destination);
			if (fileInfo.type == "file") {
				print.boldReadLine("Sorry: source path is a directory but destination is a file");
				return;
			}

			local.paths = directoryList(arguments.source, arguments.recursive, "path", "*.cfc");

			for (local.path in local.paths) {
				local.dest = replace(local.path, arguments.source, arguments.destination);
				if (!directoryExists(getDirectoryFromPath(local.dest))) {

					directoryCreate(getDirectoryFromPath(local.dest));

				}
				convertFile(source=local.path, destination=local.dest, force=arguments.force, pathPrefix=arguments.source);
			}

		}


		print.line().line("Done.").line();

	}

	private function convertFile(required source, required destination, boolean force=false, pathPrefix="") {

		var toScript = getInstance("model:toscript.ToScript");

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

			if (!arguments.force) {
				local.answer = ask("Can I overwrite #normalizedPath#? (yes/no): ");

				if (left(local.answer,1) != "y") {
					print.indentedYellowLine("Aye Captin, skipped #normalizedPath#");
					return;
				}

			}
		}


		

		if (!result.converted) {
			print.greenLine("✅  (Already CFML Script): " & normalizedPath);
			if (arguments.source != arguments.destination) {
				fileWrite(arguments.destination, result.code);
			}
			return;
		}

		if (arrayLen(result.errors)) {
			print.redLine("🔴 Error: " & normalizedPath);
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


		print.greenLine("✅  (Converted): " & normalizedPath);






	}

}