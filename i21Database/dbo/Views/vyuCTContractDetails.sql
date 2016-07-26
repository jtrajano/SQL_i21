CREATE VIEW dbo.vyuCTContractDetails
AS
SELECT 
	detail.intContractDetailId, detail.intContractHeaderId, detail.intContractStatusId, detail.intContractSeq, detail.intCompanyLocationId,
	detail.dtmStartDate, detail.dtmEndDate, detail.intFreightTermId, detail.intShipViaId, detail.intItemContractId, detail.intItemId,
	detail.intCategoryId, detail.dblQuantity, detail.intUnitMeasureId, detail.intItemUOMId, detail.intCategoryUOMId, detail.intNoOfLoad,
	detail.dblQuantityPerLoad, detail.intIndexId, detail.dblAdjustment, detail.intAdjItemUOMId, detail.intPricingTypeId, detail.intFutureMarketId,
	detail.intFutureMonthId, detail.dblFutures, detail.dblBasis, detail.dblCashPrice, detail.dblTotalCost, detail.intCurrencyId, detail.intPriceItemUOMId,
	detail.dblNoOfLots, detail.intMarketZoneId, detail.intDiscountTypeId, detail.intDiscountId, detail.intContractOptHeaderId, detail.strBuyerSeller,
	detail.intBillTo, detail.intFreightRateId, detail.strFobBasis, detail.intRailGradeId, detail.strRailRemark, detail.dblOriginalQty,
	detail.dblBalance, detail.dblIntransitQty, detail.dblScheduleQty, detail.strLoadingPointType, detail.intLoadingPortId, detail.strDestinationPointType,
	detail.intDestinationPortId, detail.strShippingTerm, detail.intShippingLineId, detail.strVessel, detail.intDestinationCityId, detail.intShipperId,
	detail.strRemark, detail.intFarmFieldId, detail.strVendorLotID, detail.strInvoiceNo, detail.intUnitsPerLayer, detail.intLayersPerPallet, detail.dtmEventStartDate,
	detail.dtmPlannedAvailabilityDate, detail.dtmUpdatedAvailabilityDate, detail.intBookId, detail.intSubBookId, detail.intContainerTypeId, detail.intNumberOfContainers,
	detail.intInvoiceCurrencyId, detail.dtmFXValidFrom, detail.dtmFXValidTo, detail.dblRate, detail.intFXPriceUOMId, detail.strFXRemarks, detail.dblAssumedFX,
	detail.strFixationBy, detail.strReference, detail.dblNetWeight, detail.intNetWeightUOMId, detail.strPackingDescription, detail.intCurrencyExchangeRateId,
	detail.dblOriginalBasis, detail.intDiscountScheduleId, detail.intDiscountScheduleCodeId, detail.intStorageScheduleRuleId, detail.strGrade, detail.intCreatedById,
	detail.dtmCreated, detail.intLastModifiedById, detail.dtmLastModified, detail.ysnUseFXPrice,cdm.dblConversionFactor, marketZone.strMarketZoneCode, item.strItemNo, cdm.strUOM, 
	measurement.strUnitMeasure strAdjustmentUOM,loc.strLocationName, freightTerms.strFreightTerm, shipVia.strShipVia, currency.strCurrency, freightRate.strOrigin + freightRate.strDest strOriginDest,
	railGrade.strRailGrade, pricingType.strPricingType, contractHeader.strContractOptDesc, discountType.strDiscountType, discountId.strDiscountId,
	cdm.strPriceUOM, REPLACE(futuresMonth.strFutureMonth, ' ', '(' + futuresMonth.strSymbol + ')') strFutureMonth, ctIndex.strIndex, contractStatus.strContractStatus,
	detail.dblBalance - ISNULL(detail.dblScheduleQty, 0) dblAvailableQty, detail.intContractStatusId intCurrentContractStatusId, cdm.intPriceFixationId,
	cdm.ysnSpreadAvailable, cdm.ysnFixationDetailAvailable, cdm.dblQuantityPriceFixed, cdm.dblPFQuantityUOMId, cdm.intTotalLots, cdm.intLotsFixed, cdm.strContractItemName,
	cdm.strNetWeightUOM, cdm.strOrigin, cdm.strMainCurrency, cdm.ysnSubCurrency, cdm.dblAppliedQty, cdm.dblExchangeRate,detail.intConcurrencyId
FROM tblCTContractDetail detail
	LEFT JOIN vyuCTContractDetailNotMapped cdm ON cdm.intContractDetailId = detail.intContractDetailId
	LEFT JOIN tblARMarketZone marketZone ON marketZone.intMarketZoneId = detail.intMarketZoneId
	LEFT JOIN tblICItem item ON item.intItemId = detail.intItemId
	LEFT JOIN tblICItemUOM itemUOMIndex ON itemUOMIndex.intItemUOMId = detail.intItemUOMId
	LEFT JOIN tblICUnitMeasure measurement ON measurement.intUnitMeasureId = itemUOMIndex.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = detail.intCompanyLocationId
	LEFT JOIN tblSMFreightTerms freightTerms ON freightTerms.intFreightTermId = detail.intFreightTermId
	LEFT JOIN tblSMShipVia shipVia ON shipVia.intEntityShipViaId = detail.intShipViaId
	LEFT JOIN tblSMCurrency currency ON currency.intCurrencyID = detail.intCurrencyId
	LEFT JOIN tblCTFreightRate freightRate ON freightRate.intFreightRateId = detail.intFreightRateId
	LEFT JOIN tblCTRailGrade railGrade ON railGrade.intRailGradeId = detail.intRailGradeId
	LEFT JOIN tblCTPricingType pricingType ON pricingType.intPricingTypeId = detail.intPricingTypeId
	LEFT JOIN tblRKFutureMarket futureMarket ON futureMarket.intFutureMarketId = detail.intFutureMarketId
	LEFT JOIN tblCTContractOptHeader contractHeader ON contractHeader.intContractOptHeaderId = detail.intContractOptHeaderId
	LEFT JOIN tblCTDiscountType discountType ON discountType.intDiscountTypeId = detail.intDiscountTypeId
	LEFT JOIN tblGRDiscountId discountId ON discountId.intDiscountId = detail.intDiscountId
	LEFT JOIN tblRKFuturesMonth futuresMonth ON futuresMonth.intFutureMonthId = detail.intFutureMonthId
	LEFT JOIN tblCTIndex ctIndex ON ctIndex.intIndexId = detail.intIndexId
	LEFT JOIN tblCTContractStatus contractStatus ON contractStatus.intContractStatusId = detail.intContractStatusId