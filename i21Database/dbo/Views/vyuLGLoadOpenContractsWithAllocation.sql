CREATE VIEW vyuLGLoadOpenContractsWithAllocation
AS
SELECT
intKeyColumn = Convert(INT, ROW_NUMBER() OVER (ORDER BY (Select 1)))
,*
FROM (
	SELECT
	OC.intContractDetailId
	,OC.intContractHeaderId
	,OC.intContractSeq
	,OC.intItemId
	,OC.strItemDescription
	,OC.strItemNo
	,OC.intCommodityId
	,OC.dblDetailQuantity
	,OC.intUnitMeasureId
	,OC.intItemUOMId
	,OC.strUnitMeasure
	,OC.intNetWeightUOMId
	,OC.intNetWeightUnitMeasureId
	,OC.strNetWeightUnitMeasure
	,OC.intCompanyLocationId
	,OC.strLocationName
	,dblUnLoadedQuantity = CASE WHEN (OAD.intAllocationDetailId IS NOT NULL) THEN OAD.dblSUnAllocatedQty ELSE OC.dblUnLoadedQuantity - ISNULL(PCD.dblAllocatedQty, 0) END
	,OC.intPurchaseSale
	,OC.intEntityId
	,OC.strContractNumber
	,OC.dtmContractDate
	,OC.strEntityName
	,OC.strStartDate
	,OC.strEndDate
	,OC.dtmStartDate
	,OC.dtmEndDate
	,OC.dtmPlannedAvailabilityDate
	,OC.dtmCashFlowDate
	,OC.intDefaultLocationId
	,OC.dblScheduleQty
	,OC.strCustomerContract
	,OC.dblBalance
	,OC.ysnAllowedToShow
	,OC.ysnUnlimitedQuantity
	,OC.ysnLoad
	,OC.dblQuantityPerLoad
	,OC.intNoOfLoad
	,OC.strItemType
	,OC.intPositionId
	,OC.strPositionType
	,OC.intLoadingPortId
	,OC.intDestinationPortId
	,OC.intDestinationCityId
	,OC.strOriginPort
	,OC.strDestinationPort
	,OC.strDestinationCity
	,OC.strPackingDescription
	,OC.intShippingLineEntityId
	,OC.strShippingLine
	,OC.intNumberOfContainers
	,OC.intContainerTypeId
	,OC.strContainerType
	,OC.strVessel
	,OC.intContractTypeId
	,OC.strSampleStatus
	,OC.strSampleNumber
	,OC.strContainerNumber
	,OC.strSampleTypeName
	,OC.strTestingStartDate
	,OC.strTestingEndDate
	,OC.intCompanyLocationSubLocationId
	,OC.strSubLocationName
	,OC.dblContainerQty
	,OC.strStorageLocationName
	,OC.intStorageLocationId
	,OC.intShipmentType
	,OC.strERPPONumber
	,OC.ysnSampleRequired
	,OC.strOrigin
	,OC.intBookId
	,OC.strBook
	,OC.intSubBookId
	,OC.strSubBook
	,OC.dblSeqPrice
	,OC.strPricingType
	,OC.intCropYearId
	,OC.strCropYear
	,OC.dblOptionalityPremium
	,OC.dblQualityPremium
	,OC.intSeqCurrencyId
	,OC.strSeqCurrency
	,OC.intSeqPriceUOMId
	,OC.strSeqPriceUOM
	,OC.ysnSubCurrency
	,OC.intRateTypeId
	,OC.dblRate
	,OC.intInvoiceCurrencyId
	,OC.strInvoiceCurrency
	,OC.strCurrencyExchangeRateType
	,OC.intFreightTermId
	,OC.strFreightTerm
	,OC.intShipToId
	,OC.strShipTo
	,OC.intHeaderBookId
	,OC.intHeaderSubBookId
	,OC.ysnAllowReweighs
	,OC.ysnShowOptionality
	,OC.intTermId
	,OC.intTaxGroupId
	,OC.strTaxGroup
	,OC.strFobPoint

	,OAD.strAllocationNumber
	,OAD.strAllocationDetailRefNo
	,OAD.intAllocationHeaderId
	,OAD.intAllocationDetailId 
	,OAD.intSContractDetailId
	,OAD.intSalesContractHeaderId
	,OAD.strSalesContractNumber
	,OAD.intSContractSeq
	,OAD.intSEntityId
	,OAD.intSCompanyLocationId
	,OAD.strSCompanyLocation
	,OAD.intSItemId
	,OAD.strSContractNumber
	,OAD.dblSAllocatedQty
	,OAD.dblSUnAllocatedQty
	,OAD.intSUnitMeasureId
	,OAD.strSUnitMeasure
	,OAD.strCustomer
	,OAD.strSItemDescription
	FROM vyuLGLoadOpenContracts OC
	INNER JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = OC.intContractDetailId
	LEFT JOIN vyuLGShipmentOpenAllocationDetails OAD ON OAD.intPContractDetailId = OC.intContractDetailId AND OAD.intShipmentType = OC.intShipmentType
	WHERE OC.intPurchaseSale = 1 AND OC.ysnAllowedToShow = 1

	UNION ALL

	SELECT
	OC.intContractDetailId
	,OC.intContractHeaderId
	,OC.intContractSeq
	,OC.intItemId
	,OC.strItemDescription
	,OC.strItemNo
	,OC.intCommodityId
	,OC.dblDetailQuantity
	,OC.intUnitMeasureId
	,OC.intItemUOMId
	,OC.strUnitMeasure
	,OC.intNetWeightUOMId
	,OC.intNetWeightUnitMeasureId
	,OC.strNetWeightUnitMeasure
	,OC.intCompanyLocationId
	,OC.strLocationName
	,OC.dblUnLoadedQuantity - ISNULL(PCD.dblAllocatedQty, 0)
	,OC.intPurchaseSale
	,OC.intEntityId
	,OC.strContractNumber
	,OC.dtmContractDate
	,OC.strEntityName
	,OC.strStartDate
	,OC.strEndDate
	,OC.dtmStartDate
	,OC.dtmEndDate
	,OC.dtmPlannedAvailabilityDate
	,OC.dtmCashFlowDate
	,OC.intDefaultLocationId
	,OC.dblScheduleQty
	,OC.strCustomerContract
	,OC.dblBalance
	,OC.ysnAllowedToShow
	,OC.ysnUnlimitedQuantity
	,OC.ysnLoad
	,OC.dblQuantityPerLoad
	,OC.intNoOfLoad
	,OC.strItemType
	,OC.intPositionId
	,OC.strPositionType
	,OC.intLoadingPortId
	,OC.intDestinationPortId
	,OC.intDestinationCityId
	,OC.strOriginPort
	,OC.strDestinationPort
	,OC.strDestinationCity
	,OC.strPackingDescription
	,OC.intShippingLineEntityId
	,OC.strShippingLine
	,OC.intNumberOfContainers
	,OC.intContainerTypeId
	,OC.strContainerType
	,OC.strVessel
	,OC.intContractTypeId
	,OC.strSampleStatus
	,OC.strSampleNumber
	,OC.strContainerNumber
	,OC.strSampleTypeName
	,OC.strTestingStartDate
	,OC.strTestingEndDate
	,OC.intCompanyLocationSubLocationId
	,OC.strSubLocationName
	,OC.dblContainerQty
	,OC.strStorageLocationName
	,OC.intStorageLocationId
	,OC.intShipmentType
	,OC.strERPPONumber
	,OC.ysnSampleRequired
	,OC.strOrigin
	,OC.intBookId
	,OC.strBook
	,OC.intSubBookId
	,OC.strSubBook
	,OC.dblSeqPrice
	,OC.strPricingType
	,OC.intCropYearId
	,OC.strCropYear
	,OC.dblOptionalityPremium
	,OC.dblQualityPremium
	,OC.intSeqCurrencyId
	,OC.strSeqCurrency
	,OC.intSeqPriceUOMId
	,OC.strSeqPriceUOM
	,OC.ysnSubCurrency
	,OC.intRateTypeId
	,OC.dblRate
	,OC.intInvoiceCurrencyId
	,OC.strInvoiceCurrency
	,OC.strCurrencyExchangeRateType
	,OC.intFreightTermId
	,OC.strFreightTerm
	,OC.intShipToId
	,OC.strShipTo
	,OC.intHeaderBookId
	,OC.intHeaderSubBookId
	,OC.ysnAllowReweighs
	,OC.ysnShowOptionality
	,OC.intTermId
	,OC.intTaxGroupId
	,OC.strTaxGroup
	,OC.strFobPoint

	,strAllocationNumber = NULL
	,strAllocationDetailRefNo = NULL
	,intAllocationHeaderId = NULL
	,intAllocationDetailId = NULL
	,intSContractDetailId = NULL
	,intSalesContractHeaderId = NULL
	,strSalesContractNumber = NULL
	,intSContractSeq = NULL
	,intSEntityId = NULL
	,intSCompanyLocationId = NULL
	,strSCompanyLocation = NULL
	,intSItemId = NULL
	,strSContractNumber = NULL
	,dblSAllocatedQty = NULL
	,dblSUnAllocatedQty = NULL
	,intSUnitMeasureId = NULL
	,strSUnitMeasure = NULL
	,strCustomer = NULL
	,strSItemDescription = NULL
	FROM vyuLGLoadOpenContracts OC
	INNER JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = OC.intContractDetailId
	WHERE OC.intPurchaseSale = 1 AND OC.ysnAllowedToShow = 1
) tbl