CREATE VIEW [dbo].[vyuAREmailTemplate]
AS 
SELECT 
 E.*
,C.strCustomerNumber
,C.strName AS 'strCustomerName'
FROM tblAREmailTemplate E
	INNER JOIN vyuCFCustomerEntity C ON E.intEntityCustomerId = C.[intEntityId]
