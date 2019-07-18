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
	 , ysnPrepaid					= ICH.ysnPrepaid
FROM dbo.tblCTItemContractHeader ICH
