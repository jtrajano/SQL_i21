CREATE VIEW [dbo].[vyuIPGetItemCustomerXref]
AS
SELECT CX.intItemId
	,CL.strLocationName
	,E.strName AS strCustomerName
	,CX.[strCustomerProduct]
	,CX.[strProductDescription]
	,CX.[strPickTicketNotes]
	,CX.[intSort]
	,CX.intConcurrencyId
	,CX.dtmDateCreated
	,CX.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemCustomerXref CX
LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = CX.intItemLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = CX.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = CX.intModifiedByUserId
LEFT JOIN tblARCustomer C ON C.intEntityId = CX.intCustomerId
LEFT JOIN tblEMEntity E ON E.intEntityId = C.intEntityId
