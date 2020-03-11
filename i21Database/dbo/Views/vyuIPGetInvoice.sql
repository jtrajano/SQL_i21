CREATE VIEW dbo.vyuIPGetInvoice
AS
SELECT IV.strTransactionType
	,B.strBook
	,SB.strSubBook
	,IV.dtmDate AS dtmInvoiceDate
	,CL.strLocationName
	,IV.strInvoiceNumber
	,C.strCurrency
	,IV.strComments
	,IV.intInvoiceId
FROM dbo.tblARInvoice IV
JOIN dbo.tblCTBook B ON B.intBookId = IV.intBookId
LEFT JOIN dbo.tblCTSubBook SB ON SB.intSubBookId = IV.intSubBookId
JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IV.intCompanyLocationId
JOIN dbo.tblSMCurrency C ON C.intCurrencyID = IV.intCurrencyId

