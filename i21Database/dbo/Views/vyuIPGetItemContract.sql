CREATE VIEW [dbo].[vyuIPGetItemContract]
AS
SELECT IC.intItemId
	,CL.strLocationName
	,IC.strContractItemNo
	,IC.strContractItemName
	,C.strCountry 
	,IC.strGrade
	,IC.strGradeType
	,IC.strGarden
	,IC.dblYieldPercent
	,IC.dblTolerancePercent
	,IC.dblFranchisePercent
	,IC.strStatus
	,IC.[intSort]
	,IC.intConcurrencyId
	,IC.dtmDateCreated
	,IC.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemContract IC
LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = IC.intItemLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IC.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IC.intModifiedByUserId
Left JOIN tblSMCountry C on C.intCountryID=IC.intCountryId 
