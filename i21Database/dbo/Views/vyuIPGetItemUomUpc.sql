Create VIEW dbo.vyuIPGetItemUomUpc
AS
SELECT IU.intItemId
	,UM.strUnitMeasure
	,IUUpc.strUpcCode  
	,IUUpc.strLongUpcCode
	,IUUpc.intConcurrencyId
	,IUUpc.dtmDateCreated
	,IUUpc.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemUomUpc IUUpc
JOIN tblICItemUOM IU on IU.intItemUOMId =IUUpc.intItemUOMId 
JOIN tblICUnitMeasure UM On UM.intUnitMeasureId =IU.intUnitMeasureId  
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IUUpc.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IUUpc.intModifiedByUserId
