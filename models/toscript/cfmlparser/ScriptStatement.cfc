component extends="Statement" accessors="false" {

	variables.bodyOpen = 0;
	variables.bodyClose = 0;

	

	public function setBodyOpen(position) {
		variables.bodyOpen = arguments.position;
	}

	public function setBodyClose(position) {
		variables.bodyClose = arguments.position;
	}
	
	public numeric function getBodyOpen() {
		return variables.bodyOpen;
	}

	public numeric function getBodyClose() {
		return variables.bodyClose;
	}

	public boolean function isFunction() {
		return getName() == "function";
	}
}