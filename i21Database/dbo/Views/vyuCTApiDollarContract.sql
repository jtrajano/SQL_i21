CREATE VIEW [dbo].[vyuCTApiDollarContract]
AS

SELECT 
	  ch.intItemContractHeaderId
	, ch.strContractType
	, ch.strEntityName
	, ch.strContractCategoryId
	, ch.intEntityId
	, ch.strLocationName
	, ch.dtmContractDate
	, ch.dtmExpirationDate
	, ch.dtmDueDate
	, ch.dtmSigned
	, ch.strEntryContract
	, ch.strContractNumber
	, ch.strCurrency
	, ch.intFreightTermId
	, ch.strFreightTerm
	, ch.strCountry
	, ch.strTerm
	, ch.strSalesperson
	, ch.strTextCode
	, ch.intContractTextId
	, ch.ysnPrepaid
	, ch.ysnIsUsed
	, ch.ysnSigned
	, ch.ysnPrinted
	, ch.intCurrencyId
	, ch.intCompanyLocationId
	, ch.strCPContract
	, ch.intCountryId
	, ch.ysnMailSent
	, ch.intShipToLocationId
	, ch.strOpportunityName
	, ch.intOpportunityId
	, ch.intSalespersonId
	, ch.ysnMarketSubCurrency
	, ch.strPrepaidIds
	, ch.intTermId
	, ch.intLineOfBusinessId
	, ch.strLineOfBusiness
FROM vyuCTItemContractHeader ch
WHERE ch.strContractCategoryId = 'Dollar'