component extends="Statement" {
	
	public boolean function isComment() {
		return true;
	}

	public string function getComment() {
		var text = getText();
		if (getName() == "!---") {
			text = replace(text, "<!---", "", "ALL");
			text = replace(text, "--->", "", "ALL");
		}
		return text;
	}

}