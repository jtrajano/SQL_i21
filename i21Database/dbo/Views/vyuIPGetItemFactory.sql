CREATE VIEW [dbo].[vyuIPGetItemFactory]
AS
SELECT ItemFactory.intItemId 
	,CL.strLocationName 
	,ItemFactory.ysnDefault
	,ItemFactory.[intSort]
	,ItemFactory.intConcurrencyId
	,ItemFactory.dtmDateCreated
	,ItemFactory.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemFactory ItemFactory
LEFT JOIN tblSMCompanyLocation  CL on CL.intCompanyLocationId=ItemFactory.intFactoryId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ItemFactory.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ItemFactory.intModifiedByUserId
