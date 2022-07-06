CREATE VIEW vyuIPContractDetailView
AS
SELECT CD.intContractDetailId
	,CD.intContractSeq
	,CD.intCompanyLocationId
	,CD.dtmStartDate
	,CD.dtmEndDate
	,CD.dblQuantity AS dblDetailQuantity
	,CD.dblFutures
	,CD.dblBasis
	,CD.dblCashPrice
	,CD.dblRate
	,CD.strBuyerSeller
	,CD.strFobBasis
	,CD.strRemark
	,CD.dblOriginalQty
	,CD.dblBalance
	,CD.dblIntransitQty
	,CD.dblScheduleQty
	,CD.strPackingDescription
	,CD.strShippingTerm
	,CD.strVessel
	,CD.strVendorLotID
	,CD.strInvoiceNo
	,CD.dblNoOfLots
	,CD.intUnitsPerLayer
	,CD.intLayersPerPallet
	,CD.dtmEventStartDate
	,CD.dtmPlannedAvailabilityDate
	,CD.dtmUpdatedAvailabilityDate
	,CD.intContainerTypeId
	,CD.intNumberOfContainers
	,CD.dtmFXValidFrom
	,CD.dtmFXValidTo
	,CD.strFXRemarks
	,CD.dblAssumedFX
	,CD.strFixationBy
	,CD.intIndexId
	,CD.dblAdjustment
	,CD.dblOriginalBasis
	,CD.dblConvertedBasis 
	,CD.strLoadingPointType
	,CD.strDestinationPointType
	,CD.intNoOfLoad
	,CD.dblQuantityPerLoad
	,CD.strReference
	,CD.dblNetWeight
	,CD.ysnUseFXPrice
	,CD.strItemSpecification
	,IM.strItemNo
	,FT.strFreightTerm
	,IM.strDescription AS strItemDescription
	,SV.strName AS strShipVia
	,PT.strPricingType
	,U1.strUnitMeasure AS strItemUOM
	,FM.strFutMarketName
	,MO.strFutureMonth
	,U2.strUnitMeasure AS strPriceUOM
	,CL.strLocationName
	,LP.strCity AS strLoadingPoint
	,SR.strScheduleDescription
	,IM.strShortName
	,DP.strCity AS strDestinationPoint
	,DC.strCity AS strDestinationCity
	,IC.strContractItemName
	,CU.strCurrency
	,U7.strUnitMeasure AS strNetWeightUOM
	,BK.strBook
	,SO.strSubBook
	,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, CD.intNetWeightUOMId, ISNULL(CD.dblBalance, 0) - ISNULL(CD.dblScheduleQty, 0)) AS dblAvailableNetWeight
	,CS.strContractStatus
	,RT.strCurrencyExchangeRateType
	,CD.intContractHeaderId
	,Shipper.strName AS strShipper
	,ShippingLine.strName AS strShippingLine
	,CLSL.strSubLocationName AS strVesselSubLocationName
	,SL1.strName AS strVesselStorageLocationName
	,CD.dblYield
	,P.strName AS strShipToName
	,EL.strLocationName AS strShipToLocationName
	,PG.strName AS strPurchasingGroupName
	,CD.strGarden
	,CD.strGrade AS strItemGrade
	,C.strCurrency AS strInvoiceCurrency
	,UM.strUnitMeasure AS strFXPriceUOM
	,FC.strCurrency AS strFromCurrency
	,TC.strCurrency AS strToCurrency
	,Producer.strName AS strProducer
	,CD.ysnInvoice
	,CD.ysnProvisionalInvoice
	,CD.ysnQuantityFinal
	,CD.ysnClaimsToProducer
	,CD.ysnRiskToProducer
	,CD.ysnBackToBack
	,BI.strItemNo AS strItemBundleNo
	,BCU.strCurrency AS strBasisCurrency
	,BUM.strUnitMeasure AS strBasisUnitMeasure
	,FBUM.strUnitMeasure AS strFreightBasisUnitMeasure
	,FBBUM.strUnitMeasure AS strFreightBasisBaseUnitMeasure
	,CPCU.strCurrency AS strConvPriceCurrency
	,CD.dtmHistoricalDate
	,CD.dblHistoricalRate
	,CD.intHistoricalRateTypeId
FROM tblCTContractDetail CD
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
LEFT JOIN tblCTIndex IX ON IX.intIndexId = CD.intIndexId
LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId
LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = CD.intNetWeightUOMId
LEFT JOIN tblICUnitMeasure U7 ON U7.intUnitMeasureId = WU.intUnitMeasureId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
LEFT JOIN tblSMCountry CG ON CG.intCountryID = IC.intCountryId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CD.intFreightTermId
LEFT JOIN tblEMEntity SV ON SV.[intEntityId] = CD.intShipViaId
LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblICItemLocation IL ON IL.intItemId = IM.intItemId
	AND IL.intLocationId = CD.intCompanyLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = IL.intStorageLocationId
LEFT JOIN tblSMCity LP ON LP.intCityId = CD.intLoadingPortId
LEFT JOIN tblSMCity DP ON DP.intCityId = CD.intDestinationPortId
LEFT JOIN tblSMCity DC ON DC.intCityId = CD.intDestinationCityId
LEFT JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId = CD.intStorageScheduleRuleId
LEFT JOIN tblCTBook BK ON BK.intBookId = CD.intBookId
LEFT JOIN tblCTSubBook SO ON SO.intSubBookId = CD.intSubBookId
LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = CD.intRateTypeId
LEFT JOIN tblEMEntity Shipper ON Shipper.intEntityId = CD.intShipperId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = CD.intShippingLineId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = CD.intStorageLocationId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = CD.intShipToId
LEFT JOIN tblEMEntity P ON P.intEntityId = EL.intEntityId
LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = CD.intInvoiceCurrencyId
LEFT JOIN tblICItemUOM FXIU ON FXIU.intItemUOMId = CD.intFXPriceUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = FXIU.intUnitMeasureId
LEFT JOIN tblSMCurrencyExchangeRate CER ON CER.intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId
LEFT JOIN tblSMCurrency FC ON FC.intCurrencyID = CER.intFromCurrencyId
LEFT JOIN tblSMCurrency TC ON TC.intCurrencyID = CER.intToCurrencyId
LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = CD.intProducerId
LEFT JOIN tblICItem BI ON BI.intItemId = CD.intItemBundleId
LEFT JOIN tblSMCurrency BCU ON BCU.intCurrencyID = CD.intBasisCurrencyId
LEFT JOIN tblICItemUOM BIU ON BIU.intItemUOMId = CD.intBasisUOMId
LEFT JOIN tblICUnitMeasure BUM ON BUM.intUnitMeasureId = BIU.intUnitMeasureId
LEFT JOIN tblICItemUOM FBIU ON FBIU.intItemUOMId = CD.intFreightBasisUOMId
LEFT JOIN tblICUnitMeasure FBUM ON FBUM.intUnitMeasureId = FBIU.intUnitMeasureId
LEFT JOIN tblICItemUOM FBBIU ON FBBIU.intItemUOMId = CD.intFreightBasisBaseUOMId
LEFT JOIN tblICUnitMeasure FBBUM ON FBBUM.intUnitMeasureId = FBBIU.intUnitMeasureId
LEFT JOIN tblSMCurrency CPCU ON CPCU.intCurrencyID = CD.intConvPriceCurrencyId
