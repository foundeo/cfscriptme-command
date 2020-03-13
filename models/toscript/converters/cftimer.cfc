component extends="BaseBlockTagConverter" {

	public string function toScript(tag) {
		if( !tag.hasInnerContent() ) {
			throw(message="cftimer tag must have a start and end tag");
		}
		return super.toScript(tag);
	}
	
}