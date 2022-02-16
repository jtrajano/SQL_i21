CREATE VIEW vyuCTRestApiContractHeader
AS

SELECT ch.*
	, pt.strPricingType
	, tp.strContractType
	, dbo.fnCTGetContractStatuses(ch.intContractHeaderId) COLLATE Latin1_General_CI_AS AS strStatuses
	, c.strCommodityCode
	, c.strDescription strCommodityDescription
	, COALESCE(created.dtmDate, ch.dtmCreated) dtmDateCreated
	, COALESCE(updated.dtmDate, created.dtmDate, ch.dtmLastModified, ch.dtmCreated) dtmDateLastUpdated
FROM tblCTContractHeader ch
LEFT JOIN tblCTPricingType pt ON pt.intPricingTypeId = ch.intPricingTypeId
LEFT JOIN tblCTContractType tp ON tp.intContractTypeId = ch.intContractTypeId
LEFT JOIN tblICCommodity c ON c.intCommodityId = ch.intCommodityId
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = ch.intContractHeaderId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'ContractManagement.view.Contract'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = ch.intContractHeaderId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'ContractManagement.view.Contract'
) updated
