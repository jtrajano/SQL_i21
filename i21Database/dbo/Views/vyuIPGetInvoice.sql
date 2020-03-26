CREATE VIEW dbo.vyuIPGetInvoice
AS
SELECT CASE 
		WHEN EXISTS (
				SELECT *
				FROM tblLGWeightClaimDetail WCD
				WHERE WCD.intInvoiceId = IV.intInvoiceId
				) and IV.strTransactionType='Credit Memo'
			THEN 'Claim'
		ELSE IV.strTransactionType
		END As strTransactionType
	,B.strBook
	,SB.strSubBook
	,IV.dtmDate AS dtmInvoiceDate
	,CL.strLocationName
	,IV.strInvoiceNumber
	,C.strCurrency
	,IV.strComments
	,IV.intInvoiceId
	,E.strName AS strCreatedBy
FROM dbo.tblARInvoice IV
JOIN dbo.tblCTBook B ON B.intBookId = IV.intBookId
LEFT JOIN dbo.tblCTSubBook SB ON SB.intSubBookId = IV.intSubBookId
JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IV.intCompanyLocationId
JOIN dbo.tblSMCurrency C ON C.intCurrencyID = IV.intCurrencyId
JOIN dbo.tblEMEntity E ON E.intEntityId = IV.intEntityId
