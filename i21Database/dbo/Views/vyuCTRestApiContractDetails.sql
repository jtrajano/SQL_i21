CREATE VIEW [dbo].[vyuCTRestApiContractDetails]
AS
SELECT
	  cd.intContractDetailId
	, cd.intSplitFromId
	, cd.intParentDetailId
	, cd.ysnSlice
	, cd.intConcurrencyId
	, cd.intContractHeaderId
	, cd.intContractStatusId
	, cd.strFinancialStatus
	, cd.intContractSeq
	, cd.intCompanyLocationId
	, cd.intShipToId
	, cd.dtmStartDate
	, cd.dtmEndDate
	, cd.intFreightTermId
	, cd.intShipViaId
	, cd.intItemContractId
	, cd.intItemBundleId
	, cd.intItemId
	, cd.strItemSpecification
	, cd.intCategoryId
	, cd.dblQuantity
	, cd.intItemUOMId
	, cd.dblOriginalQty
	, cd.dblBalance
	, cd.dblIntransitQty
	, cd.dblScheduleQty
	, cd.dblBalanceLoad
	, cd.dblScheduleLoad
	, cd.dblShippingInstructionQty
	, cd.dblNetWeight
	, cd.intNetWeightUOMId
	, cd.intUnitMeasureId
	, cd.intCategoryUOMId
	, cd.intNoOfLoad
	, cd.dblQuantityPerLoad
	, cd.intIndexId
	, cd.dblAdjustment
	, cd.intAdjItemUOMId
	, cd.intPricingTypeId
	, cd.intFutureMarketId
	, cd.intFutureMonthId
	, cd.dblFutures
	, cd.dblBasis
	, cd.dblOriginalBasis
	, cd.dblConvertedBasis
	, cd.intBasisCurrencyId
	, cd.intBasisUOMId
	, cd.dblFreightBasisBase
	, cd.intFreightBasisBaseUOMId
	, cd.dblFreightBasis
	, cd.intFreightBasisUOMId
	, cd.dblRatio
	, cd.dblCashPrice
	, cd.dblTotalCost
	, cd.intCurrencyId
	, cd.dblNoOfLots
	, cd.dtmLCDate
	, cd.dtmLastPricingDate
	, cd.dblConvertedPrice
	, cd.intConvPriceCurrencyId
	, cd.intConvPriceUOMId
	, cd.intMarketZoneId
	, cd.intDiscountTypeId
	, cd.intDiscountId
	, cd.intDiscountScheduleId
	, cd.intDiscountScheduleCodeId
	, cd.intStorageScheduleRuleId
	, cd.intContractOptHeaderId
	, cd.strBuyerSeller
	, cd.intBillTo
	, cd.intFreightRateId
	, cd.strFobBasis
	, cd.intRailGradeId
	, cd.strRailRemark
	, cd.strLoadingPointType
	, cd.intLoadingPortId
	, cd.strDestinationPointType
	, cd.intDestinationPortId
	, cd.strShippingTerm
	, cd.intShippingLineId
	, cd.strVessel
	, cd.intDestinationCityId
	, cd.intShipperId
	, cd.strRemark
	, cd.intSubLocationId
	, cd.intStorageLocationId
	, cd.intPurchasingGroupId
	, cd.intFarmFieldId
	, cd.intSplitId
	, cd.strGrade
	, cd.strGarden
	, cd.strVendorLotID
	, cd.strInvoiceNo
	, cd.strReference
	, cd.strERPPONumber
	, cd.strERPItemNumber
	, cd.strERPBatchNumber
	, cd.intUnitsPerLayer
	, cd.intLayersPerPallet
	, cd.dtmEventStartDate
	, cd.dtmPlannedAvailabilityDate
	, cd.dtmUpdatedAvailabilityDate
	, cd.dtmM2MDate
	, cd.intBookId
	, cd.intSubBookId
	, cd.intContainerTypeId
	, cd.intNumberOfContainers
	, cd.intInvoiceCurrencyId
	, cd.dtmFXValidFrom
	, cd.dtmFXValidTo
	, cd.dblFXPrice
	, cd.ysnUseFXPrice
	, cd.intFXPriceUOMId
	, cd.strFXRemarks
	, cd.dblAssumedFX
	, cd.strFixationBy
	, cd.strPackingDescription
	, cd.dblYield
	, cd.intCurrencyExchangeRateId
	, cd.intRateTypeId
	, cd.intCreatedById
	, cd.dtmCreated
	, cd.intLastModifiedById
	, cd.dtmLastModified
	, cd.ysnInvoice
	, cd.ysnProvisionalInvoice
	, cd.ysnQuantityFinal
	, cd.intProducerId
	, cd.ysnClaimsToProducer
	, cd.ysnRiskToProducer
	, cd.ysnBackToBack
	, cd.dblAllocatedQty
	, cd.dblReservedQty
	, cd.dblAllocationAdjQty
	, cd.dblInvoicedQty
	, cd.ysnPriceChanged
	, cd.intContractDetailRefId
	, cd.ysnStockSale
	, cd.strCertifications
	, cd.ysnSplit
	, cd.ysnProvisionalPNL
	, cd.ysnFinalPNL
	, cd.dtmProvisionalPNL
	, cd.dtmFinalPNL
	, cd.intPricingStatus
	, cd.dtmStartDateUTC
	, cd.dblRefFuturesQty
	, cd.intRefFuturesItemUOMId
	, cd.intRefFuturesCurrencyId
	, cd.intRefFuturesMarketId
	, cd.intRefFuturesMonthId
	, c.strLocationName
	, c.strLocationNumber
	, dbo.fnCTGetCurrencyExchangeRate(cd.intContractDetailId,0) AS dblRate
	, ISNULL(cd.intPriceItemUOMId,cd.intItemUOMId) AS intPriceItemUOMId
	, dbo.fnCTGetCurrencyExchangeRate(cd.intContractDetailId,0) AS dblExchangeRate
	, CASE WHEN cd.intPricingTypeId = 2
		THEN CASE WHEN ISNULL(pf.dblTotalLots, 0) = 0 THEN	'Unpriced' ELSE 
			CASE WHEN ISNULL(pf.dblTotalLots, 0)-ISNULL([dblLotsFixed], 0) = 0 THEN 'Fully Priced' 
				WHEN ISNULL([dblLotsFixed], 0) = 0 THEN 'Unpriced'
				ELSE 'Partially Priced' END
			END
		WHEN cd.intPricingTypeId = 1 THEN 'Priced' ELSE	'' 
	  END	COLLATE Latin1_General_CI_AS AS strPricingStatus
	, pt.strPricingType
	, CASE WHEN	ch.ysnLoad = 1
	  THEN ISNULL(cd.intNoOfLoad, 0) - ISNULL(cd.dblBalanceLoad, 0)
	  ELSE ISNULL(cd.dblQuantity, 0) - ISNULL(cd.dblBalance, 0) END AS dblAppliedQty
	, ch.strContractNumber + ' - ' + LTRIM(cd.intContractSeq) AS strSequenceNumber
	, dbo.fnCTConvertQtyToTargetItemUOM(cd.intItemUOMId, cd.intPriceItemUOMId, cd.dblCashPrice) AS dblCashPriceInQtyUOM
	, dbo.fnCTConvertQtyToTargetItemUOM(cd.intItemUOMId, cd.intPriceItemUOMId, cd.dblQuantity) AS dblQtyInPriceUOM
	, dbo.fnCTConvertQtyToTargetItemUOM(cd.intItemUOMId, sm.intItemUOMId, cd.dblQuantity) AS dblQtyInStockUOM
	, dbo.fnCTConvertQtyToTargetItemUOM(sm.intItemUOMId, cd.intPriceItemUOMId, cd.dblCashPrice) AS dblCashPriceInStockUOM
	, dbo.fnCTConvertQtyToTargetItemUOM(cd.intNetWeightUOMId, cd.intItemUOMId,1) AS dblWeightToQtyConvFactor
	, dbo.fnCTConvertQtyToTargetItemUOM(cd.intItemUOMId, cd.intNetWeightUOMId, ISNULL(cd.dblBalance,0) - ISNULL(cd.dblScheduleQty,0)) AS dblAvailableNetWeight
	, cd.dblBalanceLoad - ISNULL(cd.dblScheduleLoad, 0) AS dblAvailableLoad
	, cs.strContractStatus
	, fm.strFutMarketName
	, mo.strFutureMonth
	, CASE WHEN cd.intPricingTypeId IN(1, 6) THEN NULL ELSE cd.dblQuantity - ISNULL(qpf.dblQuantityPriceFixed, 0) END dblUnpricedQty
	, CASE WHEN cd.intPricingTypeId IN(1, 6) THEN NULL ELSE cd.dblNoOfLots - ISNULL(pf.dblLotsFixed, 0) END dblUnpricedLots
FROM tblCTContractDetail cd
JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
LEFT JOIN tblCTPriceFixation pf	ON pf.intContractHeaderId = ch.intContractHeaderId
	AND pf.intContractDetailId = cd.intContractDetailId
OUTER APPLY (
	SELECT SUM(d.dblQuantity) dblQuantityPriceFixed
	FROM tblCTPriceFixationDetail d
	WHERE intPriceFixationId = pf.intPriceFixationId
	GROUP BY intPriceFixationId
) qpf
JOIN tblCTPricingType pt ON pt.intPricingTypeId = cd.intPricingTypeId
LEFT JOIN tblICItemUOM sm ON sm.intItemId = cd.intItemId
JOIN tblCTContractStatus cs ON cs.intContractStatusId = cd.intContractStatusId
LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
LEFT JOIN tblRKFuturesMonth	mo ON mo.intFutureMonthId =	cd.intFutureMonthId
INNER JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = cd.intCompanyLocationId

GO


