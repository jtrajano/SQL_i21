CREATE VIEW [dbo].[vyuIPGetItemAssembly]
AS
SELECT IA.intItemId
	,I.strItemNo AS strAssemblyItemNo
	,IA.dblQuantity
	,UM.strUnitMeasure
	,IA.dblUnit
	,IA.dblCost
	,IA.intSort
	,IA.intConcurrencyId
	,IA.dtmDateCreated
	,IA.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemAssembly IA
LEFT JOIN tblICItem I ON I.intItemId = IA.intAssemblyItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = IA.intItemUnitMeasureId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IA.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IA.intModifiedByUserId
