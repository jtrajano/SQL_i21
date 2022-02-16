CREATE VIEW vyuCTRestApiContractHeader
AS

SELECT
	  ch.intContractHeaderId
	, ch.intConcurrencyId
	, ch.intContractTypeId
	, ch.intEntityId
	, ch.intBookId
	, ch.intSubBookId
	, ch.intCounterPartyId
	, ch.intEntityContactId
	, ch.intContractPlanId
	, ch.intCommodityId
	, ch.dblQuantity
	, ch.intCommodityUOMId
	, ch.strContractNumber
	, ch.dtmContractDate
	, ch.strCustomerContract
	, ch.strCPContract
	, ch.dtmDeferPayDate
	, ch.dblDeferPayRate
	, ch.intContractTextId
	, ch.ysnSigned
	, ch.dtmSigned
	, ch.ysnPrinted
	, ch.intSalespersonId
	, ch.intGradeId
	, ch.intWeightId
	, ch.intCropYearId
	, ch.strInternalComment
	, ch.strPrintableRemarks
	, ch.intAssociationId
	, ch.intTermId
	, ch.intPricingTypeId
	, ch.intApprovalBasisId
	, ch.intContractBasisId
	, ch.intFreightTermId
	, ch.intPositionId
	, ch.intInsuranceById
	, ch.intInvoiceTypeId
	, ch.dblTolerancePct
	, ch.dblProvisionalInvoicePct
	, ch.ysnSubstituteItem
	, ch.ysnUnlimitedQuantity
	, ch.ysnMaxPrice
	, ch.intINCOLocationTypeId
	, ch.intWarehouseId
	, ch.intCountryId
	, ch.intCompanyLocationPricingLevelId
	, ch.ysnProvisional
	, ch.ysnLoad
	, ch.intNoOfLoad
	, ch.dblQuantityPerLoad
	, ch.intLoadUOMId
	, ch.ysnCategory
	, ch.ysnMultiplePriceFixation
	, ch.intFutureMarketId
	, ch.intFutureMonthId
	, ch.dblFutures
	, ch.dblNoOfLots
	, ch.intCategoryUnitMeasureId
	, ch.intLoadCategoryUnitMeasureId
	, ch.intArbitrationId
	, ch.intProducerId
	, ch.ysnClaimsToProducer
	, ch.ysnRiskToProducer
	, ch.ysnExported
	, ch.dtmExported
	, ch.intCreatedById
	, ch.dtmCreated
	, ch.intLastModifiedById
	, ch.dtmLastModified
	, ch.ysnMailSent
	, ch.strAmendmentLog
	, ch.ysnBrokerage
	, ch.ysnBestPriceOnly
	, ch.intCompanyId
	, ch.intContractHeaderRefId
	, ch.strReportTo
	, ch.intBrokerId
	, ch.intBrokerageAccountId
	, ch.strExternalEntity
	, ch.strExternalContractNumber
	, ch.ysnReceivedSignedFixationLetter
	, ch.ysnReadOnlyInterCoContract
	, ch.ysnEnableFutures
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
