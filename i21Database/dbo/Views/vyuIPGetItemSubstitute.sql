CREATE VIEW dbo.vyuIPGetItemSubstitute
AS
SELECT ISub.intItemId
	,I.strItemNo AS strSubstituteItem
	,ISub.strDescription
	,ISub.dblQuantity
	,UM.strUnitMeasure 
	,ISub.dblMarkUpOrDown
	,ISub.dtmBeginDate
	,ISub.dtmEndDate
	,ISub.intConcurrencyId
	,ISub.dtmDateCreated
	,ISub.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemSubstitute ISub
JOIN tblICItem I ON I.intItemId = ISub.intSubstituteItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = ISub.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ISub.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ISub.intModifiedByUserId
