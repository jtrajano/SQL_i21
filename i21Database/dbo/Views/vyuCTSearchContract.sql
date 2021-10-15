CREATE VIEW vyuCTSearchContract

AS

SELECT CH.intContractHeaderId
	, CH.intContractTypeId
	, CH.dtmContractDate
	, CH.strEntityName AS strCustomerVendor
	, CH.strContractType
	, CH.dblHeaderQuantity
	, CH.strContractNumber
	, CH.ysnPrinted
	, CH.dblTotalBalance
	, CH.intEntityId
	, CH.strCustomerContract
	, CH.ysnSigned
	, CH.dblTotalAppliedQty
	, CH.dtmCreated
	, CH.dtmSigned
	, strHeaderUnitMeasure = CASE WHEN CH.ysnLoad = 1 THEN CH.strHeaderUnitMeasure + '/Load' ELSE CH.strHeaderUnitMeasure END
	-- Hidden fields
	, CH.dtmDeferPayDate
	, CH.dblDeferPayRate
	, CH.strInternalComment
	, CH.strPrintableRemarks
	, CH.dblTolerancePct
	, CH.dblProvisionalInvoicePct
	, CH.ysnPrepaid
	, CH.ysnSubstituteItem
	, CH.ysnUnlimitedQuantity
	, CH.ysnMaxPrice
	, CH.ysnProvisional
	, CH.intNoOfLoad
	, CH.dblQuantityPerLoad
	, CH.ysnCategory
	, CH.ysnMultiplePriceFixation
	, CH.strCommodityDescription
	, CH.strGrade
	, CH.strWeight
	, CH.strTextCode
	, CH.strAssociationName
	, CH.strTerm
	, CH.strPosition
	, CH.strInsuranceBy
	, CH.strInvoiceType
	, CH.strCountry
	, CH.strCommodityCode
	, CH.strApprovalBasis
	, CH.strContractBasis
	, strHeaderPricingType = CH.strPricingType
	, CH.strPricingLevelName
	, CH.strLoadUnitMeasure
	, CH.strINCOLocation
	, CH.strContractPlan
	, CH.strCreatedBy
	, CH.strLastModifiedBy
	, CH.ysnExported
	, CH.dtmExported
	, CH.strCropYear
	, CH.ysnLoad
	, strStatuses = CASE WHEN CH.strStatuses LIKE '%Incomplete%' THEN 'Incomplete'
						WHEN CH.strStatuses LIKE '%Open%' THEN 'Open'
						WHEN CH.strStatuses LIKE '%Complete%' THEN 'Complete'
						ELSE CH.strStatuses END COLLATE Latin1_General_CI_AS
	, CH.intStockCommodityUnitMeasureId
	, CH.strStockCommodityUnitMeasure
	, CH.strProducer
	, CH.strSalesperson
	, CH.strCPContract
	, CH.strCounterParty
	, ysnApproved = CH.ysnApproved
	, CH.intDefaultCommodityUnitMeasureId
	, CH.ysnBrokerage
	, CH.strBook
	, CH.strSubBook
	, CH.intBookId
	, CH.intSubBookId
	, CH.intFreightTermId
	, CH.strFreightTerm
	, CH.strExternalEntity
	, CH.strExternalContractNumber
	, CH.ysnReceivedSignedFixationLetter
	, CH.strReportTo
	, CH.ysnEnableFutures
FROM vyuCTSearchContractHeader CH WITH(NOLOCK)