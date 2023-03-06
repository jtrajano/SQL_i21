CREATE VIEW [dbo].[vyuARItemContractNumberSearch]
AS 
SELECT DISTINCT 
	   intItemContractHeaderId	= CTICH.intItemContractHeaderId	 
	 , strItemContractNumber	= CTICH.strContractNumber	 
	 , strContractCategoryId	= CTICH.strContractCategoryId
	 , intContractTypeId		= CTICH.intContractTypeId
	 , intItemId				= CTICD.intItemId
	 , intEntityCustomerId		= CTICH.intEntityId
	 , intCompanyLocationId		= CTICH.intCompanyLocationId
	 , dtmContractDate			= CTICH.dtmContractDate
     , dtmExpirationDate		= CTICH.dtmExpirationDate
	 , ysnPrepaid				= NULL  
	 , intCategoryId			= intCategoryId
	 , strCategory				= strCategory
	 , strPrepayment			= CASE WHEN ISNULL(strPrepayment, '') = '' THEN 'Not Selectable without Prepayment' ELSE strPrepayment END
	 , strContractType			= TP.strContractType
	 , strContractStatus		= CTICD.strContractStatus
	 , dblAvailableQty			= CTICD.dblAvailable
	 , intCurrencyId			= CTICH.intCurrencyId
	 , strCurrency				= CUR.strCurrency
FROM dbo.tblCTItemContractHeader CTICH
INNER JOIN (
	SELECT intItemContractHeaderId	= CTICD.intItemContractHeaderId
		 , intItemId				= CTICD.intItemId
		 , intCategoryId			= ISNULL(ICC.intCategoryId, 0)
		 , strCategory				= ICC.strCategoryCode
		 , strPrepayment			= ARI.strInvoiceNumber
		 , strContractStatus		= CS.strContractStatus
		 , dblAvailable				= CTICD.dblAvailable
	FROM tblCTItemContractDetail CTICD
	INNER JOIN tblICItem ICI ON CTICD.intItemId = ICI.intItemId
	INNER JOIN tblICCategory ICC ON ICI.intCategoryId = ICC.intCategoryId
	LEFT JOIN tblARInvoiceDetail ARID ON CTICD.intItemContractHeaderId = ARID.intItemContractHeaderId 
								     AND ARID.ysnRestricted = 1
									 AND ARID.intItemId IS NOT NULL
	LEFT JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
	LEFT JOIN tblCTContractStatus CS ON CTICD.intContractStatusId = CS.intContractStatusId
	WHERE CTICD.intContractStatusId IN (1, 4, 5)
	GROUP BY CTICD.intItemContractHeaderId, CTICD.intItemId, ICC.intCategoryId, ICC.strCategoryCode, ARI.strInvoiceNumber, CS.strContractStatus, CTICD.dblAvailable

	UNION ALL

	SELECT intItemContractHeaderId	= CTICHC.intItemContractHeaderId
		, intItemId					= 0
		, intCategoryId				= CTICHC.intCategoryId
		, strCategory				= ICC.strCategoryCode
		, strPrepayment				= ARI.strInvoiceNumber
		, strContractStatus			= CAST('Open' AS NVARCHAR(10))
		, dblAvailable				= CAST(1 AS NUMERIC(18, 6))
	FROM tblCTItemContractHeaderCategory CTICHC
	INNER JOIN tblICCategory ICC ON CTICHC.intCategoryId = ICC.intCategoryId
	LEFT JOIN tblARInvoiceDetail ARID ON CTICHC.intItemContractHeaderId = ARID.intItemContractHeaderId
									 AND ARID.ysnRestricted = 1
									 AND ARID.intItemId IS NOT NULL
	LEFT JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
	GROUP BY CTICHC.intItemContractHeaderId, CTICHC.intCategoryId, ICC.strCategoryCode, ARI.strInvoiceNumber
) CTICD ON CTICH.intItemContractHeaderId = CTICD.intItemContractHeaderId
LEFT JOIN tblCTContractType	TP ON TP.intContractTypeId = CTICH.intContractTypeId
LEFT JOIN tblSMCurrency CUR ON CTICH.intCurrencyId = CUR.intCurrencyID