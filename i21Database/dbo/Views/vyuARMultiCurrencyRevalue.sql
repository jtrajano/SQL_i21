CREATE VIEW [dbo].[vyuARMultiCurrencyRevalue]
AS
SELECT DISTINCT
	 strTransactionType			= ARI.strTransactionType
	,strTransactionId			= ARI.strInvoiceNumber
	,strTransactionDate			= ARI.dtmDate
	,strTransactionDueDate		= ARI.dtmDueDate
	,strVendorName				= EME.strName
	,strCommodity				= ICCom.strDescription
	,strLineOfBusiness			= ICC.strDescription
	,strLocation				= EMEL.strLocationName
	,strTicket					= ''
	,strContractNumber			= CTCH.strContractNumber
	,strItemId					= ICI.strItemNo
	,dblQuantity				= ARID.dblQtyShipped
	,dblUnitPrice				= ARID.dblPrice
	,dblAmount					= ARID.dblTotal
	,intCurrencyId				= ARI.intCurrencyId
	,intForexRateType			= ARID.intCurrencyExchangeRateTypeId
	,strForexRateType			= SMCERT.strCurrencyExchangeRateType 
	,dblForexRate				= ARID.dblCurrencyExchangeRate
	,dblHistoricAmount			= ARID.dblTotal * ARID.dblCurrencyExchangeRate
	,dblNewForexRate			= 0 --Calcuate By GL
	,dblNewAmount				= 0 --Calcuate By GL
	,dblUnrealizedDebitGain		= 0 --Calcuate By GL
	,dblUnrealizedCreditGain	= 0 --Calcuate By GL
	,dblDebit					= 0 --Calcuate By GL
	,dblCredit					= 0 --Calcuate By GL
FROM 
	tblARInvoiceDetail ARID
INNER JOIN
	tblARInvoice ARI
		ON ARID.intInvoiceId = ARI.intInvoiceId
INNER JOIN
	tblARCustomer ARC
		ON ARI.intEntityCustomerId = ARC.intEntityCustomerId	
INNER JOIN 
	tblEMEntity EME
		ON ARC.intEntityCustomerId = EME.intEntityId
LEFT JOIN
	tblEMEntityLocation EMEL
		ON ARI.intShipToLocationId = EMEL.intEntityLocationId
LEFT JOIN
	tblSMCurrencyExchangeRateType SMCERT
		ON ARID.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
LEFT JOIN
	tblICItem ICI
		ON ARID.intItemId = ICI.intItemId
LEFT JOIN
	tblICCategory ICC
		ON ICI.intCategoryId = ICC.intCategoryId
LEFT JOIN
	tblICCommodity ICCom
		ON ICI.intCommodityId = ICCom.intCommodityId		 
LEFT JOIN 
	tblCTContractHeader CTCH 
		ON ARID.intContractHeaderId = CTCH.intContractHeaderId
LEFT JOIN 
	tblSMCurrency SMC 
		ON  ARI.intCurrencyId = SMC.intCurrencyID
WHERE
	ARI.ysnPosted = 1 
	AND ARI.ysnPaid = 0