CREATE VIEW [dbo].[vyuARCollectionCreditViewReport]
AS
SELECT DISTINCT 
	A.intCompanyLocationId
	, A.strCompanyAddress
	, A.strCompanyPhone
	, A.intEntityCustomerId 
	, A.strCustomerAddress
	, A.strCustomerPhone
	, A.intTermsId
	, Term.strTerm 
FROM vyuARCollectionOverdueReport A
LEFT JOIN (SELECT intTermID, strTerm  FROM tblSMTerm) Term ON A.intTermsId = Term.intTermID 