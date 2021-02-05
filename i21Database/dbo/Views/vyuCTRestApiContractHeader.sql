CREATE VIEW vyuCTRestApiContractHeader
AS

SELECT ch.*
	, pt.strPricingType
	, tp.strContractType
	, dbo.fnCTGetContractStatuses(ch.intContractHeaderId) COLLATE Latin1_General_CI_AS AS strStatuses
FROM tblCTContractHeader ch
LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = ch.intPricingTypeId
LEFT JOIN tblCTContractType tp ON tp.intContractTypeId = ch.intContractTypeId