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
	 , strPrepayment			= CASE WHEN ISNULL(strPrepayment, '') = '' AND CP.ysnAllowContractWithoutPrepayment = 0 THEN 'Not Selectable without Prepayment' ELSE strPrepayment END
	 , strItemNo				= CTICD.strItemNo
FROM dbo.tblCTItemContractHeader CTICH
CROSS APPLY 
   ( 
   SELECT ysnAllowContractWithoutPrepayment FROM tblARCompanyPreference
   ) CP
INNER JOIN (
	SELECT 
		  CTICD.intItemContractHeaderId
		, intItemId		= CTICD.intItemId
		, intCategoryId = ISNULL(ICC.intCategoryId, 0)
		, strCategory	= ICC.strCategoryCode
		, strPrepayment	= ARI.strInvoiceNumber
		, strItemNo		= ICI.strItemNo
	FROM tblCTItemContractDetail CTICD
	INNER JOIN tblICItem ICI
	ON CTICD.intItemId = ICI.intItemId
	INNER JOIN tblICCategory ICC
	ON ICI.intCategoryId = ICC.intCategoryId
	LEFT JOIN tblARInvoiceDetail ARID
	ON CTICD.intItemContractHeaderId = ARID.intItemContractHeaderId
	AND ARID.ysnRestricted = 1
	AND ISNULL(ARID.intItemId, 0) <> 0
	LEFT JOIN tblARInvoice ARI
	ON ARID.intInvoiceId = ARI.intInvoiceId
	WHERE CTICD.intContractStatusId IN (1, 4, 5)
	GROUP BY CTICD.intItemContractHeaderId, CTICD.intItemId, ICC.intCategoryId, ICC.strCategoryCode, ARI.strInvoiceNumber, ICI.strItemNo

	UNION ALL

	SELECT 
		  CTICHC.intItemContractHeaderId
		, intItemId		= 0
		, intCategoryId = CTICHC.intCategoryId
		, strCategory	= ICC.strCategoryCode
		, strPrepayment	= ARI.strInvoiceNumber
		, strItemNo		= ''
	FROM tblCTItemContractHeaderCategory CTICHC
	INNER JOIN tblICCategory ICC
	ON CTICHC.intCategoryId = ICC.intCategoryId
	LEFT JOIN tblARInvoiceDetail ARID
	ON CTICHC.intItemContractHeaderId = ARID.intItemContractHeaderId
	AND ARID.ysnRestricted = 1
	AND ISNULL(ARID.intItemId, 0) = 0
	LEFT JOIN tblARInvoice ARI
	ON ARID.intInvoiceId = ARI.intInvoiceId
	GROUP BY CTICHC.intItemContractHeaderId, CTICHC.intCategoryId, ICC.strCategoryCode, ARI.strInvoiceNumber
) CTICD ON CTICH.intItemContractHeaderId = CTICD.intItemContractHeaderId
GO