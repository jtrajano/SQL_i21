CREATE VIEW [dbo].[vyuIPGetItemManufacturingUOM]
AS
SELECT MU.intItemId 
	,UM.strUnitMeasure
	,MU.[intSort]
	,MU.intConcurrencyId
	,MU.dtmDateCreated
	,MU.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemManufacturingUOM MU
LEFT JOIN tblICUnitMeasure UM on UM.intUnitMeasureId =MU.intUnitMeasureId 
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = MU.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = MU.intModifiedByUserId
