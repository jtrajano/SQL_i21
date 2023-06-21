Create VIEW [dbo].[vyuCTContractDetailImport]      
AS      
      
      
SELECT CD.intContractDetailImportId      
    ,CD.intContractDetailImportHeaderId      
    ,CD.strContractNumber      
    ,CD.intSequence      
    ,dtmStartDate = ISNULL(CD.dtmStartDate, CH.dtmPeriodStartDate)      
    ,dtmEndDate = ISNULL(CD.dtmEndDate, CH.dtmPeriodEndDate)      
    ,CD.dtmUpdatedAvailability      
    ,strLocationName = CD.strLocation      
    ,CH.intCompanyLocationId      
    ,CD.strBook      
    ,B.intBookId      
    ,CD.strSubBook      
    ,SB.intSubBookId      
    ,strItemNo = CD.strItem      
    ,IT.intItemId      
    ,CD.strPurchasingGroup      
    ,PG.intPurchasingGroupId      
    ,CD.strGrade      
    ,strGardenMark = CD.strGarden      
    ,GM.intGardenMarkId      
    ,CD.strVendorLotId      
    ,CD.strReference      
    ,CD.dblQuantity      
    ,CD.strQuantityUOM      
    ,QUOM.intUnitMeasureId      
    ,intItemUOMId = qIuom.intItemUOMId      
    ,CD.dblNetWeight      
    ,CD.strWeightUOM      
    ,intNetWeightUOMId = wIuom.intItemUOMId      
    ,CD.strContainerType      
    ,CT.intContainerTypeId      
    ,CD.strPricingType      
    ,PT.intPricingTypeId      
    ,CD.dblCashPrice      
    ,CD.strPriceUOM      
    ,intPriceItemUOMId = pIuom.intItemUOMId      
    ,CD.strPriceCurrency      
    ,PCUR.intCurrencyID      
    ,CD.strFreightTerms      
    ,FT.intFreightTermId      
    ,CD.strLoadingPoint      
    ,intLoadingPointId = LP.intCityId      
    ,CD.strDestinationPoint      
    ,intDestinationPointId = DP.intCityId      
    ,CD.strShippineLine      
 ,intShippingLineId = Ent.intEntityId  
    ,CD.strStorageLocation      
    ,intStorageLocationId = SL.intCompanyLocationSubLocationId      
    ,CD.dtmEtaPol      
    ,CD.dtmEtaPod      
    ,CD.guiUniqueId      
    ,null strMessage      
    ,null ysnImported      
    ,CD.intConcurrencyId      
    ,strLoadingPointType = CASE WHEN LP.ysnPort IS NULL THEN ''      
           WHEN LP.ysnPort = CAST(0 as BIT) THEN 'City'      
         ELSE 'Port' END      
    ,strDestinationPointType =  CASE WHEN DP.ysnPort IS NULL THEN ''      
            WHEN DP.ysnPort = CAST(0 as BIT) THEN 'City'      
          ELSE 'Port' END      
    ,CD.strMarketZone      
    ,MZ.intMarketZoneId      
    ,II.strOrigin      
 ,CH.intContractHeaderId    
 ,dblConversionFactor = CAST(ICF.dblUnitQty as numeric(18,10)) / CAST(ICT.dblUnitQty  as numeric(18,10))      
 ,dblTotalCost = CD.dblCashPrice * CD.dblQuantity    * CAST(ICF.dblUnitQty as numeric(18,10)) / CAST(ICT.dblUnitQty  as numeric(18,10))      
 ,dblRealQuantity = CD.dblQuantity  * (CAST(ICF.dblUnitQty as numeric(18,10)) / CAST(ICT.dblUnitQty  as numeric(18,10)) )  
 ,dtmCashFlowDate = ISNULL(CD.dtmEndDate, CH.dtmPeriodEndDate)  + ISNULL(SMT.intBalanceDue, 0)  
 , intGradeId = wg.intCommodityAttributeId    
FROM tblCTContractDetailImport    CD      
LEFT JOIN tblCTContractHeader    CH  ON CH.strContractNumber   = CD.strContractNumber collate database_default      
LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityId = CH.intCommodityId and CH.intCommodityUOMId = CUM.intCommodityUnitMeasureId    
LEFT JOIN tblSMCompanyLocation    CL  ON CL.strLocationName =  CD.strLocation  collate database_default    
LEFT JOIN tblCTBook       B  ON B.strBook     = CD.strBook    collate database_default      
LEFT JOIN tblCTSubBook      SB  ON SB.strSubBook    = CD.strSubBook   collate database_default AND SB.intBookId =B.intBookId       
LEFT JOIN tblICItem       IT  ON IT.strItemNo     = CD.strItem    collate database_default      
LEFT JOIN tblSMPurchasingGroup    PG  ON PG.strName     = CD.strPurchasingGroup collate database_default      
LEFT JOIN tblQMGardenMark     GM  ON GM.strGardenMark    = CD.strGarden   collate database_default      
LEFT JOIN tblICUnitMeasure     QUOM ON QUOM.strUnitMeasure   = CD.strQuantityUOM  collate database_default      
LEFT JOIN tblICItemUOM      qIuom ON qIuom.intItemId    = IT.intItemId   AND qIuom.intUnitMeasureId = QUOM.intUnitMeasureId      
LEFT JOIN tblICUnitMeasure     WUOM ON WUOM.strUnitMeasure   = CD.strWeightUOM   collate database_default      
LEFT JOIN tblICItemUOM      wIuom ON wIuom.intItemId    = IT.intItemId   AND wIuom.intUnitMeasureId = WUOM.intUnitMeasureId      
LEFT JOIN tblLGContainerType    CT  ON CT.strContainerType   = CD.strContainerType  collate database_default      
LEFT JOIN tblCTPricingType     PT  ON PT.strPricingType   = CD.strPricingType  collate database_default      
LEFT JOIN tblICUnitMeasure     PUOM ON PUOM.strUnitMeasure   = CD.strPriceUOM   collate database_default      
LEFT JOIN tblICItemUOM      pIuom ON pIuom.intItemId    = IT.intItemId   AND pIuom.intUnitMeasureId = PUOM.intUnitMeasureId      
LEFT JOIN tblSMCurrency      PCUR ON PCUR.strCurrency    = CD.strPriceCurrency  collate database_default      
LEFT JOIN tblSMFreightTerms     FT  ON FT.strFreightTerm   = CD.strFreightTerms  collate database_default      
LEFT JOIN tblSMCity       LP  ON LP.strCity     = CD.strLoadingPoint  collate database_default      
LEFT JOIN tblSMCity       DP  ON DP.strCity     = CD.strDestinationPoint  collate database_default      
LEFT JOIN tblSMCompanyLocationSubLocation SL  ON SL.strSubLocationName  = CD.strStorageLocation  collate database_default AND SL.intCompanyLocationId = CH.intCompanyLocationId      
LEFT JOIN tblARMarketZone     MZ  ON MZ.strMarketZoneCode   = CD.strMarketZone  collate database_default      
LEFT JOIN vyuCTInventoryItem    II  ON II.intItemId     = IT.intItemId AND II.intLocationId = CH.intCompanyLocationId      
LEFT JOIN vyuCTEntity Ent on Ent.strEntityType = 'Shipping Line' and Ent.ysnActive = 1 and CD.strShippineLine = Ent.strEntityName collate database_default  
 LEFT JOIN tblICItemUOM ICF on qIuom.intUnitMeasureId   = ICF.intUnitMeasureId and IT.intItemId   = ICF.intItemId      
 LEFT JOIN tblICItemUOM ICT on CUM.intUnitMeasureId = ICT.intUnitMeasureId and IT.intItemId = ICT.intItemId  
 LEFT JOIN tblSMTerm SMT on SMT.intTermID = CH.intTermId  
 LEFT JOIN (  
 select intCommodityAttributeId, intCommodityId, strDescription from [tblICCommodityAttribute] where strType = 'Grade'  
 ) wg on CH.intCommodityId = wg.intCommodityId and wg.strDescription = CD.strGrade  collate database_default
