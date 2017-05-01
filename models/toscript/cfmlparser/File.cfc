component {
	variables.fileContent = "";
	variables.filePath = "";
	variables.parser = "";
	variables.isScript = false;
	variables.fileLength = 0;

	function init(string filePath="", string fileContent="") {
		if (len(arguments.fileContent) == 0 && len(arguments.filePath) > 0) {
			variables.fileContent = fileRead(filePath);
		} else {
			variables.fileContent = arguments.fileContent;
		}
		variables.filePath = arguments.filePath;
		variables.fileLength = len(variables.fileContent);

		local.hasScriptComponentPattern = reFindNoCase("component[^>]*{", variables.fileContent);
		local.hasTagComponentPattern = !findNoCase("<" & "cfcomponent", variables.fileContent);
		if (local.hasTagComponentPattern && !local.hasTagComponentPattern) {
			//script cfc
			variables.isScript = true;
			
		} else if (local.hasTagComponentPattern && local.hasScriptComponentPattern) {

			//possible that cfcomponent it could be in a comment
			if (reFindNoCase("//[^\n]*cfcomponent[^\n]*[\n]", variables.fileContent)) {
				variables.isScript = true;
			}
			
			else if (!reFindNoCase("<" & "cffunction", variables.fileContent) && !reFindNoCase("<" & "cfproperty", variables.fileContent)) {
				//if it does not have a cffunction or cfproperty assume scritp
				variables.isScript = true;
			} else {
				variables.isScript=false;
			}

		}

		else {
			//tag based file
			variables.isScript = false;
		}

		if (variables.isScript) {
			variables.parser = new ScriptParser();
		} else {
			variables.parser = new TagParser();
		}
		
		variables.parser.parse(this);

	}

	function getFileContent() {
		return variables.fileContent;
	}

	function getFilePath() {
		return variables.filePath;
	}

	function getFileLength() {
		return variables.fileLength;
	}

	function getParser() {
		return variables.parser;
	}

	function getStatements() {
		return getParser().getStatements();
	}

	boolean function isScript() {
		return variables.isScript;
	}

	numeric function getLineNumber(numeric position) {
		var i = 0;
		var line = 1;
		var c = "";
		for ( i=1 ; i<=arguments.position ; i++ ) {
			c = Mid(variables.fileContent, i, 1);
			if ( c == Chr(10) ) {
				line = line + 1;
			}
		}
		return line;
	}

	numeric function getPositionInLine(numeric position) {
		var i = 0;
		var line = 1;
		var c = "";
		var p = 0;
		for ( i=1 ; i<=arguments.position ; i++ ) {
			p = p+1;
			c = Mid(variables.fileContent, i, 1);
			if ( c == Chr(10) ) {
				line = line + 1;
				if ( i != arguments.position ) {
					p = 0;
				}
			} else if ( c == Chr(13) && i != arguments.position ) {
				p = 0;
			}
		}
		return p;
	}

	public string function getLineContent(numeric lineNumber) {
		var i = "";
		var c = "";
		var lineNum = 1;
		var lineStart = 1;
		var lineEnd = variables.fileLength;
		for ( i=1 ; i<=variables.fileLength ; i++ ) {
			c = Mid(variables.fileContent, i, 1);
			if ( c == Chr(10) ) {
				lineNum = lineNum + 1;
				if ( lineNum == arguments.lineNumber + 1 ) {
					lineEnd = i;
					break;
				} else if ( lineNum == arguments.lineNumber ) {
					lineStart = i;
				}
			}
		}
		return Mid(variables.fileContent, lineStart, lineEnd-lineStart+1);
	}

	public array function getStatementsByName(string name) {
		var stmts = [];
		var s = "";
		for (s in getStatements()) {
			if (listFindNoCase(arguments.name, s.getName())) {
				arrayAppend(stmts, s);
			}
		}
		return stmts;
	}

}