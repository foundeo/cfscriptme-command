component extends="BaseBlockTagConverter" {

	public string function toScript(tag) {
		if( !tag.hasInnerContent() ) {
			throw(message="cfmailpart tag must have a start and end tag: [#tag.getInnerContent()#]");
		}
		return super.toScript(tag);
	}
	
}