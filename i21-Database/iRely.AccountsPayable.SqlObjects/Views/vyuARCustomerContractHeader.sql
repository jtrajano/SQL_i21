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
	 , intCurrencyId
     , strCurrency

FROM vyuCTCustomerContract
GROUP BY intContractHeaderId
       , intCompanyLocationId
	   , intEntityCustomerId
	   , strContractNumber
	   , strContractType
	   , strContractStatus
	   , ysnUnlimitedQuantity
	   , strPricingType
	   , dblAvailableQty
	   , intCurrencyId
	   , strCurrency    

HAVING dblAvailableQty > 0