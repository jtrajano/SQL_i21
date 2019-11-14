Create VIEW dbo.vyuIPGetItemUPC
AS
SELECT IUPC.intItemId
	,UM.strUnitMeasure
	,IUPC.dblUnitQty  
	,IUPC.strUPCCode
	,IUPC.intSort
	,IUPC.intConcurrencyId
	,IUPC.dtmDateCreated
	,IUPC.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemUPC IUPC
JOIN tblICItemUOM IU on IU.intItemUOMId =IUPC.intItemUnitMeasureId 
JOIN tblICUnitMeasure UM On UM.intUnitMeasureId =IU.intUnitMeasureId  
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IUPC.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IUPC.intModifiedByUserId
