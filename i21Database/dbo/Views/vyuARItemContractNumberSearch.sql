CREATE VIEW [dbo].[vyuARItemContractNumberSearch]
AS 
SELECT intItemContractHeaderId		= ICH.intItemContractHeaderId	 
	 , strItemContractNumber		= ICH.strContractNumber	 
	 , strContractCategoryId		= ICH.strContractCategoryId
	 , intContractTypeId			= ICH.intContractTypeId
	 , intEntityCustomerId			= ICH.intEntityId
	 , intCompanyLocationId			= ICH.intCompanyLocationId
	 , dtmContractDate				= ICH.dtmContractDate
     , dtmExpirationDate            = ICH.dtmExpirationDate
	 , ysnPrepaid					= NULL  
FROM dbo.tblCTItemContractHeader ICH
INNER JOIN (
	SELECT intItemContractHeaderId
	FROM tblCTItemContractDetail ICD
	WHERE ICD.intContractStatusId IN (1, 4)
	GROUP BY ICD.intItemContractHeaderId

	UNION ALL

	SELECT intItemContractHeaderId
	FROM tblCTItemContractHeaderCategory
	GROUP BY intItemContractHeaderId
) ICD ON ICH.intItemContractHeaderId = ICD.intItemContractHeaderId