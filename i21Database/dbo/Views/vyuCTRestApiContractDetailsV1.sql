CREATE VIEW dbo.vyuCTRestApiContractDetailsV1
AS
SELECT
      intContractDetailId
	, intSplitFromId
	, intParentDetailId
	, ysnSlice
	, intConcurrencyId
	, intContractHeaderId
	, intContractStatusId
	, strFinancialStatus
	, intContractSeq
	, intCompanyLocationId
	, intShipToId
	, dtmStartDate
	, dtmEndDate
	, intFreightTermId
	, intShipViaId
	, intItemContractId
	, intItemBundleId
	, intItemId
	, strItemSpecification
	, intCategoryId
	, dblQuantity
	, intItemUOMId
	, dblOriginalQty
	, dblBalance
	, dblIntransitQty
	, dblScheduleQty
	, dblBalanceLoad
	, dblScheduleLoad
	, dblShippingInstructionQty
	, dblNetWeight
	, intNetWeightUOMId
	, intUnitMeasureId
	, intCategoryUOMId
	, intNoOfLoad
	, dblQuantityPerLoad
	, intIndexId
	, dblAdjustment
	, intAdjItemUOMId
	, intPricingTypeId
	, intFutureMarketId
	, intFutureMonthId
	, dblFutures
	, dblBasis
	, dblOriginalBasis
	, dblConvertedBasis
	, intBasisCurrencyId
	, intBasisUOMId
	, dblFreightBasisBase
	, intFreightBasisBaseUOMId
	, dblFreightBasis
	, intFreightBasisUOMId
	, dblRatio
	, dblCashPrice
	, dblTotalCost
	, intCurrencyId
	, dblNoOfLots
	, dtmLCDate
	, dtmLastPricingDate
	, dblConvertedPrice
	, intConvPriceCurrencyId
	, intConvPriceUOMId
	, intMarketZoneId
	, intDiscountTypeId
	, intDiscountId
	, intDiscountScheduleId
	, intDiscountScheduleCodeId
	, intStorageScheduleRuleId
	, intContractOptHeaderId
	, strBuyerSeller
	, intBillTo
	, intFreightRateId
	, strFobBasis
	, intRailGradeId
	, strRailRemark
	, strLoadingPointType
	, intLoadingPortId
	, strDestinationPointType
	, intDestinationPortId
	, strShippingTerm
	, intShippingLineId
	, strVessel
	, intDestinationCityId
	, intShipperId
	, strRemark
	, intSubLocationId
	, intStorageLocationId
	, intPurchasingGroupId
	, intFarmFieldId
	, intSplitId
	, strGrade
	, strGarden
	, strVendorLotID
	, strInvoiceNo
	, strReference
	, strERPPONumber
	, strERPItemNumber
	, strERPBatchNumber
	, intUnitsPerLayer
	, intLayersPerPallet
	, dtmEventStartDate
	, dtmPlannedAvailabilityDate
	, dtmUpdatedAvailabilityDate
	, dtmM2MDate
	, intBookId
	, intSubBookId
	, intContainerTypeId
	, intNumberOfContainers
	, intInvoiceCurrencyId
	, dtmFXValidFrom
	, dtmFXValidTo
	, dblFXPrice
	, ysnUseFXPrice
	, intFXPriceUOMId
	, strFXRemarks
	, dblAssumedFX
	, strFixationBy
	, strPackingDescription
	, dblYield
	, intCurrencyExchangeRateId
	, intRateTypeId
	, intCreatedById
	, dtmCreated
	, intLastModifiedById
	, dtmLastModified
	, ysnInvoice
	, ysnProvisionalInvoice
	, ysnQuantityFinal
	, intProducerId
	, ysnClaimsToProducer
	, ysnRiskToProducer
	, ysnBackToBack
	, dblAllocatedQty
	, dblReservedQty
	, dblAllocationAdjQty
	, dblInvoicedQty
	, ysnPriceChanged
	, intContractDetailRefId
	, ysnStockSale
	, strCertifications
	, ysnSplit
	, ysnProvisionalPNL
	, ysnFinalPNL
	, dtmProvisionalPNL
	, dtmFinalPNL
	, intPricingStatus
	, dtmStartDateUTC
	, strLocationName
	, strLocationNumber
	, dblRate
	, intPriceItemUOMId
	, dblExchangeRate
	, strPricingStatus
	, strPricingType
	, dblAppliedQty
	, strSequenceNumber
	, dblCashPriceInQtyUOM
	, dblQtyInPriceUOM
	, dblQtyInStockUOM
	, dblCashPriceInStockUOM
	, dblWeightToQtyConvFactor
	, dblAvailableNetWeight
	, dblAvailableLoad
	, strContractStatus
	, strFutMarketName
	, strFutureMonth
	, dblUnpricedQty
	, dblUnpricedLots
FROM vyuCTRestApiContractDetails