CREATE VIEW [dbo].[vyuARItemContractNumberSearch]
AS 
SELECT DISTINCT intItemContractHeaderId		= ICH.intItemContractHeaderId	 
	 , strItemContractNumber		= ICH.strContractNumber	 
	 , strContractCategoryId		= ICH.strContractCategoryId
	 , intContractTypeId			= ICH.intContractTypeId
	 , intItemId						= ICD.intItemId
	 , intEntityCustomerId			= ICH.intEntityId
	 , intCompanyLocationId			= ICH.intCompanyLocationId
	 , dtmContractDate				= ICH.dtmContractDate
     , dtmExpirationDate            = ICH.dtmExpirationDate
	 , ysnPrepaid					= NULL  
FROM dbo.tblCTItemContractHeader ICH
INNER JOIN (
	SELECT intItemContractHeaderId, intItemId
	FROM tblCTItemContractDetail ICD
	WHERE ICD.intContractStatusId IN (1, 4)
	GROUP BY ICD.intItemContractHeaderId, intItemId

	UNION ALL

	SELECT intItemContractHeaderId, intItemId = NULL
	FROM tblCTItemContractHeaderCategory
	GROUP BY intItemContractHeaderId
) ICD ON ICH.intItemContractHeaderId = ICD.intItemContractHeaderId