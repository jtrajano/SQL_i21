CREATE VIEW [dbo].[vyuARCustomerContractHeader]
AS
SELECT intContractHeaderId
     , intCompanyLocationId
	 , intEntityCustomerId
	 , strContractNumber
	 , strContractType
	 , strContractStatus
	 , dblAvailableQty	 = SUM(ISNULL(dblAvailableQty, 0))
	 , ysnUnlimitedQuantity
	 , strPricingType
FROM vyuARCustomerContract
GROUP BY intContractHeaderId
       , intCompanyLocationId
	   , intEntityCustomerId
	   , strContractNumber
	   , strContractType
	   , strContractStatus
	   , ysnUnlimitedQuantity
	   , strPricingType
	   , dblAvailableQty
HAVING dblAvailableQty > 0