CREATE VIEW [dbo].[vyuIPGetItemContractDocument]
AS
SELECT IC.intItemId
	,CL.strLocationName
	,IC.strContractItemNo
	,IC.strContractItemName
	,D.strDocumentName 
	,IC.[intSort]
	,IC.intConcurrencyId
	,IC.dtmDateCreated
	,IC.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemContractDocument CD
Left JOIN tblICItemContract IC on CD.intItemContractId =IC.intItemContractId 
LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = IC.intItemLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IC.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IC.intModifiedByUserId
Left JOIN tblICDocument D on D.intDocumentId =CD.intDocumentId 