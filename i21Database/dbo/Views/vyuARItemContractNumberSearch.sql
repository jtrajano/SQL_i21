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
FROM dbo.tblCTItemContractHeader CTICH
INNER JOIN (
	SELECT 
		  intItemContractHeaderId
		, intItemId = CTICD.intItemId
		, intCategoryId = ISNULL(ICC.intCategoryId, 0)
		, strCategory = ICC.strCategoryCode
	FROM tblCTItemContractDetail CTICD
	INNER JOIN tblICItem ICI
	ON CTICD.intItemId = ICI.intItemId
	INNER JOIN tblICCategory ICC
	ON ICI.intCategoryId = ICC.intCategoryId
	WHERE CTICD.intContractStatusId IN (1, 4)
	GROUP BY CTICD.intItemContractHeaderId, CTICD.intItemId, ICC.intCategoryId, ICC.strCategoryCode

	UNION ALL

	SELECT 
		  intItemContractHeaderId
		, intItemId = 0
		, intCategoryId = CTICHC.intCategoryId
		, strCategory = ICC.strCategoryCode
	FROM tblCTItemContractHeaderCategory CTICHC
	INNER JOIN tblICCategory ICC
	ON CTICHC.intCategoryId = ICC.intCategoryId
	GROUP BY intItemContractHeaderId, CTICHC.intCategoryId, ICC.strCategoryCode
) CTICD ON CTICH.intItemContractHeaderId = CTICD.intItemContractHeaderId