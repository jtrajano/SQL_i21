CREATE VIEW [dbo].[vyuIPGetItemFactoryManufacturingCell]
AS
SELECT ItemFactory.intItemId 
	,CL.strLocationName 
	,MC1.strCellName
	,MC.ysnDefault
	,MC.intPreference
	,MC.[intSort]
	,MC.intConcurrencyId
	,MC.dtmDateCreated
	,MC.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemFactoryManufacturingCell  MC
JOIN tblICItemFactory ItemFactory on ItemFactory.intItemFactoryId =MC.intItemFactoryId 
JOIN tblSMCompanyLocation  CL on CL.intCompanyLocationId=ItemFactory.intFactoryId
JOIN tblMFManufacturingCell MC1 on MC1.intManufacturingCellId =MC.intManufacturingCellId 
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ItemFactory.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ItemFactory.intModifiedByUserId
