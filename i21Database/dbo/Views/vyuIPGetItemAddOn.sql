Create VIEW [dbo].[vyuIPGetItemAddOn]
AS
SELECT IA.intItemId 
	,I.strItemNo strAddOnItemNo
	,IA.dblQuantity 
	,UM.strUnitMeasure 
	,IA.intConcurrencyId
	,IA.dtmDateCreated
	,IA.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
	,IA.ysnAutoAdd
FROM tblICItemAddOn IA
LEFT JOIN tblICItem I on I.intItemId=IA.intAddOnItemId
Left JOIN tblICItemUOM IU On IU.intItemUOMId =IA.intItemUOMId 
Left JOIN tblICUnitMeasure UM on UM.intUnitMeasureId =IU.intUnitMeasureId 
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IA.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IA.intModifiedByUserId
