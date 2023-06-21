  
Create PROCEDURE [dbo].[uspCTProcessContractDetailImport]  
 @intUserId INT,  
 @strFileName NVARCHAR(100),  
 @guiUniqueId UNIQUEIDENTIFIER  
AS  
  
BEGIN  
  
 DECLARE @strContractNumber varchar(50)  
  
 INSERT INTO tblCTContractDetailImportHeader(intUserId, dtmImportDate, guiUniqueId, strFileName)  
 SELECT @intUserId, GETDATE(), @guiUniqueId, @strFileName  
  
 DECLARE @intContractDetailImportHeaderId INT  
  
 SET @intContractDetailImportHeaderId = SCOPE_IDENTITY()  
  
 UPDATE tblCTContractDetailImport  
 SET intContractDetailImportHeaderId = @intContractDetailImportHeaderId  
 WHERE guiUniqueId = @guiUniqueId  
  
 SELECT top 1 @strContractNumber = strContractNumber from tblCTContractDetailImport  
 WHERE guiUniqueId = @guiUniqueId  
  
 UPDATE tblCTContractDetailImportHeader  
 SET strContractNumber = @strContractNumber  
 WHERE guiUniqueId = @guiUniqueId  
  
 IF ISNULL(@intContractDetailImportHeaderId, 0) <> 0  
 BEGIN  
    
  
  SELECT intContractDetailImportId  
   , ci.intContractDetailImportHeaderId  
   , ci.strContractNumber  
   , ci.intSequence  
   , cs.intContractStatusId  
   , ci.strStatus  
   , ci.dtmStartDate  
   , ci.dtmEndDate  
   , ci.dtmM2MDate  
   , ci.dtmPlannedAvailability  
   , ci.dtmEventStartDate  
   , ci.dtmUpdatedAvailability  
   , intCHLocationId = ch.intCompanyLocationId  
   , intLocationId = cl.intCompanyLocationId  
   , ci.strLocation  
   , bk.intBookId  
   , ci.strBook  
   , sbk.intSubBookId  
   , ci.strSubBook  
   , ci.strContractItem  
   , it.intItemId  
   , ci.strItem  
   , ci.strItemSpecification  
   , pg.intPurchasingGroupId  
   , ci.strPurchasingGroup  
   , ci.strFarmNo  
   , gm.intGardenMarkId  
   , ci.strGarden  
   , ci.strVendorLotId  
   , ci.dblQuantity  
   , intQuantityUOMId = qIuom.intItemUOMId  
   , ci.strQuantityUOM  
   , ci.dblNetWeight  
   , intWeightUOMId = wIuom.intItemUOMId  
   , ci.strWeightUOM  
   , ci.strPackingDescription  
   , ci.dblEstYieldPercent  
   , ci.dblUnitPerLayer  
   , ci.dblLayerPerPallet  
   , ci.intNoOfLots  
   , conType.intContainerTypeId  
   , ci.strContainerType  
   , ci.intNoOfContainers  
   , mz.intMarketZoneId  
   , ci.strMarketZone  
   , ci.strDiscount  
   , ci.strDiscountTable  
   , ci.strScheduleCode  
   , ci.strOption  
   , ci.strSplit  
   , ci.strFixationBy  
   , pt.intPricingTypeId  
   , ci.strPricingType  
   , fMar.intFutureMarketId  
   , ci.strFuturesMarket  
   , fMon.intFutureMonthId  
   , ci.strFutureMonth  
   , ci.dblFutures  
   , intBasisUOMId = bIuom.intItemUOMId  
   , ci.strBasisUOM  
   , intBasisCurrencyId = bCur.intCurrencyID  
   , ci.strBasisCurrency  
   , ci.dblBasis  
   , ci.dblCashPrice  
   , intPriceUOMId = pIuom.intItemUOMId  
   , ci.strPriceUOM  
   , intPriceCurrencyId = pCur.intCurrencyID  
   , ci.strPriceCurrency  
   , ci.dblTotalCost  
   , ci.strERPPONo  
   , ci.strERPItemNo  
   , ci.strERPBatchNo  
   , intInvoiceCurrencyId = iCur.intCurrencyID  
   , ci.strInvoiceCurrency  
   , ci.dtmFXValidFrom  
   , ci.dtmFXValidTo  
   , ci.strCurrencyPair  
   , ci.dblForexRate  
   , ci.dblFXPrice  
   , ci.ysnPrice  
   , ci.strRateType  
   , intFXUOMId = fxIuom.intItemUOMId  
   , ci.strFXPriceUOM  
   , ci.strRemarks  
   , ft.intFreightTermId  
   , ci.strFreightTerms  
   , intShipViaId = sv.intEntityId  
   , ci.strShipVia  
   , ci.strFarmInvoiceNo  
   , ci.strProducer  
   , ci.ysnClaimsToProducer  
   , ci.ysnFronting  
   , ci.ysnInvoice  
   , ci.ysnProvisionalInvoice  
   , ci.ysnQuantityFinal  
   , ci.ysnBackToBack  
   , ci.ysnFinalPnL  
   , ci.ysnProvisionalPnL  
   , ci.strBuyerSellerName  
   , ci.strBillTo  
   , ci.strOriginDestination  
   , ci.strFOBBasis  
   , ci.strRailGrade  
   , ci.strRailRemarks  
   , ci.strLoadingPointType  
   , intLoadintPointId = lp.intCityId  
   , ci.strLoadingPoint  
   , ci.strDestinationPointType  
   , intDestinationPointId = dp.intCityId  
   , ci.strDestinationPoint  
   , intDestinationCityId = dc.intCityId  
   , ci.strDestinationCity  
   , ci.strShippingTerms  
   , ci.strShippineLine  
   , intShippingLineId = Ent.intEntityId  
   , ci.strVessel  
   , ci.strShipper  
   , intStorageLocationId = sl.intCompanyLocationSubLocationId  
   , ci.strStorageLocation  
   , ci.strStorageUnit  
   , ci.strPrintRemarks  
   , ci.guiUniqueId  
   , ci.ysnImported  
   , ci.strMessage  
   , ci.strGrade  
   , intWeightGradeId = wg.intCommodityAttributeId  
   , ch.strContractBase
  INTO #tmpList  
  FROM tblCTContractDetailImport ci  
  LEFT JOIN tblCTContractHeader ch on ch.strContractNumber = ci.strContractNumber collate database_default  
  LEFT JOIN tblCTContractStatus cs ON cs.strContractStatus = ci.strStatus collate database_default  
  LEFT JOIN tblSMCompanyLocation cl ON cl.strLocationName = ci.strLocation collate database_default  
  LEFT JOIN tblCTBook bk ON bk.strBook = ci.strBook collate database_default  
  LEFT JOIN tblCTSubBook sbk ON sbk.strSubBook = ci.strSubBook  collate database_default AND bk.intBookId =sbk.intBookId   
  -- Contract Item  
  LEFT JOIN tblICItem it ON it.strItemNo = ci.strItem  collate database_default  
  LEFT JOIN tblSMPurchasingGroup pg ON pg.strName = ci.strPurchasingGroup  collate database_default  
  -- Farm No  
  LEFT JOIN tblICUnitMeasure quom ON upper(quom.strUnitMeasure) = upper(ci.strQuantityUOM)  collate database_default  
  LEFT JOIN tblICItemUOM qIuom ON qIuom.intItemId = it.intItemId AND qIuom.intUnitMeasureId = quom.intUnitMeasureId  
  LEFT JOIN tblICUnitMeasure wuom ON wuom.strUnitMeasure = ci.strWeightUOM  collate database_default  
  LEFT JOIN tblICItemUOM wIuom ON wIuom.intItemId = it.intItemId AND wIuom.intUnitMeasureId = wuom.intUnitMeasureId  
  LEFT JOIN tblICUnitMeasure puom ON puom.strUnitMeasure = ci.strPriceUOM  collate database_default  
  LEFT JOIN tblICItemUOM pIuom ON pIuom.intItemId = it.intItemId AND pIuom.intUnitMeasureId = puom.intUnitMeasureId  
  LEFT JOIN tblLGContainerType conType ON conType.strContainerType = ci.strContainerType  collate database_default  
  LEFT JOIN tblARMarketZone mz ON mz.strMarketZoneCode = ci.strMarketZone  collate database_default  
   --ci.strDiscount  
   --, ci.strDiscountTable  
   --, ci.strScheduleCode  
   --, ci.strOption  
   --, ci.strSplit  
  LEFT JOIN tblCTPricingType pt ON pt.strPricingType = ci.strPricingType  collate database_default  
  LEFT JOIN tblRKFutureMarket fMar ON fMar.strFutMarketName = ci.strFuturesMarket  collate database_default  
  LEFT JOIN tblRKFuturesMonth fMon ON fMon.strFutureMonth = ci.strFutureMonth collate database_default  
  LEFT JOIN tblICUnitMeasure buom ON buom.strUnitMeasure = ci.strBasisUOM collate database_default  
  LEFT JOIN tblICItemUOM bIuom ON bIuom.intItemId = it.intItemId AND bIuom.intUnitMeasureId = buom.intUnitMeasureId  
  LEFT JOIN tblSMCurrency bCur ON bCur.strCurrency = ci.strBasisCurrency  collate database_default  
  LEFT JOIN tblSMCurrency pCur ON pCur.strCurrency = ci.strPriceCurrency  collate database_default  
  LEFT JOIN tblSMCurrency iCur ON iCur.strCurrency = ci.strInvoiceCurrency collate database_default  
  
   --, ci.strCurrencyPair  
   --, ci.strRateType  
  
  LEFT JOIN tblICUnitMeasure fxuom ON fxuom.strUnitMeasure = ci.strFXPriceUOM  collate database_default  
  LEFT JOIN tblICItemUOM fxIuom ON fxIuom.intItemId = it.intItemId AND fxIuom.intUnitMeasureId = fxuom.intUnitMeasureId  
  LEFT JOIN tblSMFreightTerms ft ON ft.strFreightTerm = ci.strFreightTerms  collate database_default  
  LEFT JOIN tblSMShipVia sv ON sv.strShipVia = ci.strShipVia  collate database_default  
   --, ci.strProducer  
   --, ci.strBillTo  
   --, ci.strOriginDestination  
   --, ci.strRailGrade  
  LEFT JOIN tblSMCity lp ON lp.strCity = ci.strLoadingPoint  collate database_default  
  LEFT JOIN tblSMCity dp ON dp.strCity = ci.strDestinationPoint  collate database_default  
  LEFT JOIN tblSMCity dc ON dc.strCity = ci.strDestinationCity  collate database_default  
  --ci.strShippineLine  
   --, ci.strShipper  
  LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.strSubLocationName = ci.strStorageLocation   collate database_default AND sl.intCompanyLocationId = ch.intCompanyLocationId  
  -- Storage Unit  
  
  --Garden  
  LEFT JOIN tblQMGardenMark gm on gm.strGardenMark = ci.strGarden collate database_default  
   --Grade  
   LEFT JOIN (  
   select intCommodityAttributeId, intCommodityId, strDescription from [tblICCommodityAttribute] where strType = 'Grade'  
   ) wg on ch.intCommodityId = wg.intCommodityId and wg.strDescription = ci.strGrade  collate database_default     
   
  --Shipping Line  
  LEFT JOIN vyuCTEntity Ent on Ent.strEntityType = 'Shipping Line' and Ent.ysnActive = 1 and ci.strShippineLine = Ent.strEntityName collate database_default  
    
  where ci.guiUniqueId = @guiUniqueId  
  
  Declare @ysnCompanyLocationInContractHeader as BIT  
  select @ysnCompanyLocationInContractHeader = ysnCompanyLocationInContractHeader from tblCTCompanyPreference  
  
  
  INSERT INTO tblCTErrorImportLogs  
		SELECT guiUniqueId  
        ,'Start date and End Date fields are required.'  
        ,strContractNumber  
        ,intSequence  
        ,'Fail'  
        ,1  
		FROM #tmpList   
		WHERE guiUniqueId = @guiUniqueId AND   strContractBase = 'Quantity' AND (dtmStartDate IS NULL or dtmEndDate IS NULL)

  IF @ysnCompanyLocationInContractHeader = CAST(1  as BIT)  
  BEGIN  

 
   IF EXISTS(SELECT TOP 1 1 FROM #tmpList WHERE ISNULL(intCHLocationId,0) <> ISNULL(intLocationId,0))   
   BEGIN  
    
    INSERT INTO tblCTErrorImportLogs  
    SELECT guiUniqueId  
        ,'TBO in the sequence doesn''t match with the TBO in the header'  
        ,strContractNumber  
        ,intSequence  
        ,'Fail'  
        ,1  
    FROM #tmpList   
    WHERE guiUniqueId = @guiUniqueId AND  strLocation <> '' and  ISNULL(intCHLocationId,0) <> ISNULL(intLocationId,0)  
  
     
   END  
  END  
  ELSE  
  BEGIN  
   IF EXISTS(SELECT TOP 1 1 FROM #tmpList WHERE ISNULL(intLocationId, 0) = 0)   
   BEGIN  
    
    INSERT INTO tblCTErrorImportLogs  
    SELECT guiUniqueId  
        ,'Invalid TBO'  
        ,strContractNumber  
        ,intSequence  
        ,'Fail'  
        ,1  
    FROM #tmpList   
    WHERE guiUniqueId = @guiUniqueId AND  strLocation <> ''  
  
     
   END  
  END  
    
  
  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList WHERE ISNULL(intItemId, 0) = 0)   
  BEGIN  
    
   INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid TeaLingo'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intItemId, 0) = 0  
  
     
  END  
    
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intQuantityUOMId,0) = 0 and isnull(intItemId,0) <> 0)  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Quantity UOM'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intQuantityUOMId, 0) = 0 and isnull(intItemId,0) <> 0  
  END  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intPriceCurrencyId,0) = 0)  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Price Currency'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intPriceCurrencyId, 0) = 0  
  END  
  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intPriceUOMId,0) = 0 and isnull(intItemId,0) <> 0)  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Price UOM'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intPriceUOMId, 0) = 0 and isnull(intItemId,0) <> 0  
  END  
  
    
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intWeightUOMId,0) = 0 and isnull(intItemId,0) <> 0)  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Weight UOM'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intWeightUOMId, 0) = 0 and isnull(intItemId,0) <> 0  
  END  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intPricingTypeId,0) = 0)  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Pricing Type'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND  ISNULL(intPricingTypeId, 0) = 0  
  END  
  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intBookId,0) = 0 and strBook <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Mixing Unit'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intBookId,0) = 0 and strBook <> ''  
  END  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intSubBookId,0) = 0 and strSubBook <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Strategy'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intSubBookId,0) = 0 and strSubBook <> ''  
  END  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intPurchasingGroupId,0) = 0 and strPurchasingGroup <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Company Code'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intPurchasingGroupId,0) = 0 and strPurchasingGroup <> ''  
  END  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intGardenMarkId,0) = 0 and strGarden <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Garden'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intGardenMarkId,0) = 0 and strGarden <> ''  
  END  
  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intWeightGradeId,0) = 0 and strGrade <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Grade'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intWeightGradeId,0) = 0 and strGrade <> ''  
  END  
  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intFreightTermId,0) = 0 and strFreightTerms <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Freight Term'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intFreightTermId,0) = 0 and strFreightTerms <> ''  
  END  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intLoadintPointId,0) = 0 and strLoadingPoint <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Port of Shipping'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intLoadintPointId,0) = 0 and strLoadingPoint <> ''  
  END  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intDestinationPointId,0) = 0 and strDestinationPoint <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Port of Arrival'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intDestinationPointId,0) = 0 and strDestinationPoint <> ''  
  END  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intStorageLocationId,0) = 0 and strStorageLocation <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Storage Location'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intStorageLocationId,0) = 0 and strStorageLocation <> ''  
  END  
  
  
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intMarketZoneId,0) = 0 and strMarketZone <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Channel'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intMarketZoneId,0) = 0 and strMarketZone <> ''  
  END  
  
    
  IF EXISTS(SELECT TOP 1 1 FROM #tmpList where isnull(intShippingLineId,0) = 0 and strShippineLine <> '')  
  BEGIN  
  INSERT INTO tblCTErrorImportLogs  
   SELECT guiUniqueId  
       ,'Invalid Shipping Line'  
       ,strContractNumber  
       ,intSequence  
       ,'Fail'  
       ,1  
   FROM #tmpList   
   WHERE guiUniqueId = @guiUniqueId AND isnull(intShippingLineId,0) = 0 and strShippineLine <> ''  
  END  
  
  
  SELECT * FROM #tmpList  
  
  
  DROP TABLE #tmpList  
  
 END  
END