CREATE VIEW [dbo].[vyuIPGetItemKitDetail]
AS
SELECT IKD.intItemId
	,IKD.[dblQuantity]
	,UM.strUnitMeasure 
	,IKD.[dblPrice]
	,IKD.[ysnSelected]
	,IKD.inSort
	,IKD.intConcurrencyId
	,IKD.dtmDateCreated
	,IKD.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemKitDetail IKD
Left JOIN tblICItemUOM IU on IU.intItemUOMId=IKD.intItemUnitMeasureId 
Left JOIN tblICUnitMeasure UM on UM.intUnitMeasureId =IU.intUnitMeasureId 
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IKD.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IKD.intModifiedByUserId
