CREATE VIEW [dbo].[vyuIPGetItemOwner]
AS
SELECT ItemOwner.intItemId 
	,C.strCustomerNumber 
	,ItemOwner.ysnDefault 
	,ItemOwner.[intSort]
	,ItemOwner.intConcurrencyId
	,ItemOwner.dtmDateCreated
	,ItemOwner.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemOwner ItemOwner
LEFT JOIN tblARCustomer C on C.intEntityId =ItemOwner.intOwnerId 
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ItemOwner.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ItemOwner.intModifiedByUserId
