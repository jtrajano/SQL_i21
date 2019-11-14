CREATE VIEW [dbo].[vyuIPGetItemCommodityCost]
AS
SELECT IC.intItemId
	,CL.strLocationName 
	,IC.dblLastCost
	,IC.dblStandardCost
	,IC.dblAverageCost
	,IC.dblEOMCost
	,IC.[intSort]
	,IC.intConcurrencyId
	,IC.dtmDateCreated
	,IC.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemCommodityCost IC
LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = IC.intItemLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IC.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IC.intModifiedByUserId
