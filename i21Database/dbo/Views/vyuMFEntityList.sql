CREATE VIEW vyuMFEntityList
AS
SELECT E.intEntityId
	,E.strName
	,ET.strType
	,E.strExternalERPId AS strAliasName
FROM tblEMEntity E
JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
LEFT JOIN tblARCustomer C ON C.intEntityId = E.intEntityId
