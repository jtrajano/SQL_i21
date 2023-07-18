﻿CREATE VIEW [dbo].[vyuARMultiCurrencyRevalue]
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
	,strTicket					= '' COLLATE Latin1_General_CI_AS
	,strContractNumber			= CTCH.strContractNumber
	,strItemId					= ICI.strItemNo
	,dblQuantity				= ARID.dblQtyShipped
	,dblUnitPrice				= ARID.dblPrice
	,dblAmount					= ARID.dblTotal * (CASE WHEN strTransactionType ='Credit Memo' THEN -1 ELSE 1 END)
	,intCurrencyId				= ARI.intCurrencyId
	,intForexRateType			= ARID.intCurrencyExchangeRateTypeId
	,strForexRateType			= SMCERT.strCurrencyExchangeRateType 
	,dblForexRate				= ARID.dblCurrencyExchangeRate
	,dblHistoricAmount			= ARID.dblTotal * (CASE WHEN strTransactionType ='Credit Memo' THEN -1 ELSE 1 END) * ARID.dblCurrencyExchangeRate
	,dblNewForexRate			= 0 --Calcuate By GL
	,dblNewAmount				= 0 --Calcuate By GL
	,dblUnrealizedDebitGain		= 0 --Calcuate By GL
	,dblUnrealizedCreditGain	= 0 --Calcuate By GL
	,dblDebit					= 0 --Calcuate By GL
	,dblCredit					= 0 --Calcuate By GL
	,intAccountId				= ISNULL(ARID.intSalesAccountId, ARID.intAccountId)
	,intCompanyLocationId 		= ARI.intCompanyLocationId
FROM 
	tblARInvoiceDetail ARID
INNER JOIN
	tblARInvoice ARI
		ON ARID.intInvoiceId = ARI.intInvoiceId
INNER JOIN
	tblARCustomer ARC
		ON ARI.intEntityCustomerId = ARC.[intEntityId]	
INNER JOIN 
	tblEMEntity EME
		ON ARC.[intEntityId] = EME.intEntityId
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


