CREATE VIEW dbo.vyuIPGetItemSubstitutionDetail
AS
SELECT ISub.intItemId
	,I.strItemNo AS strSubstitutionItem
	,ISD.dtmValidFrom
	,ISD.dtmValidTo
	,ISD.dblRatio
	,ISD.dblPercent
	,ISD.ysnYearValidationRequired
	,ISD.intSort
	,ISD.intConcurrencyId
	,ISD.dtmDateCreated
	,ISD.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemSubstitutionDetail ISD
JOIN tblICItemSubstitution ISub ON ISub.intItemSubstitutionId = ISD.intItemSubstitutionId
JOIN tblICItem I ON I.intItemId = ISD.intSubstituteItemId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ISD.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ISD.intModifiedByUserId
