CREATE VIEW [dbo].[vyuAREmailTemplate]
AS 
SELECT 
 E.*
,C.strCustomerNumber
,C.strName AS 'strCustomerName'
FROM 
	tblAREmailTemplate E WITH(NOLOCK)
LEFT JOIN 
	(SELECT 
		intEntityId,
		strCustomerNumber,
		strName
	 FROM 
		vyuCFCustomerEntity WITH (NOLOCK)) C ON E.intEntityCustomerId = C.intEntityId