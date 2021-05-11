
CREATE VIEW [dbo].[vyuARCustomerDocument]
AS
SELECT intCustomerDocumentId	= CD.intCustomerDocumentId
     , intEntityCustomerId		= CD.intEntityCustomerId
	 , strCustomerName			= E.strName
	 , strCustomerNumber		= C.strCustomerNumber
	 , strFileType				= CD.strFileType
	 , strFileName				= CD.strFileName
	 , strDocumentType			= CD.strDocumentType
	 , dtmDateCreated			= CD.dtmDateCreated
	 , intSize					= CD.intSize
	 , intEntityId				= CD.intEntityId
FROM tblARCustomerDocument CD
INNER JOIN tblARCustomer C ON CD.intEntityCustomerId = C.intEntityId
INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId