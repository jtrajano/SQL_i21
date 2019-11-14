CREATE VIEW [dbo].[vyuIPGetItemBundle]
AS
SELECT IA.intItemId
	,I.strItemNo AS strBundleItemNo
	,IA.strDescription
	,IA.dblQuantity
	,UM.strUnitMeasure
	,IA.ysnAddOn
	,IA.dblMarkUpOrDown
	,IA.dtmBeginDate
	,IA.dtmEndDate
	,IA.intConcurrencyId
	,IA.dtmDateCreated
	,IA.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemBundle  IA
LEFT JOIN tblICItem I ON I.intItemId = IA.intBundleItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = IA.intItemUnitMeasureId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IA.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IA.intModifiedByUserId
