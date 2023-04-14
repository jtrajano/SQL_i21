Create PROCEDURE [dbo].[uspCTLoadContractDetailImport]  
 @intContractDetailImportHeaderId INT  
AS  
  
BEGIN TRY   
  
 Declare @ErrMsg Nvarchar(MAX)  
 Declare @ysnLocationLeadTime BIT  
  
 SET @ysnLocationLeadTime = (SELECT TOP 1 ysnLocationLeadTime from tblCTCompanyPreference)   
  
 SELECT *   
 into #tmpTable  
 FROM  vyuCTContractDetailImport  
 WHERE intContractDetailImportHeaderId = @intContractDetailImportHeaderId  
   
 IF @ysnLocationLeadTime = 1  
 BEGIN  
    
  SELECT  a.intContractDetailImportId, LeadTimeMaster.*  
  INTO #LeadTimeMaster  
  FROM #tmpTable a  
  Cross apply (  
   select  * from tblMFLocationLeadTime   
   WHERE strOrigin = a.strOrigin collate database_default      
    AND intBuyingCenterId = a.intCompanyLocationId  
    AND strReceivingStorageLocation = a.strStorageLocation collate database_default      
    AND intChannelId = a.intMarketZoneId  
    AND intPortOfDispatchId = a.intLoadingPointId  
  
  ) LeadTimeMaster  
  
  SELECT  a. intContractDetailImportId, LeadTimeMaster2.*  
  INTO #LeadTimeMaster2  
  FROM #tmpTable a  
  Cross apply (  
   select  * from tblMFLocationLeadTime   
   WHERE strOrigin = a.strOrigin collate database_default      
    AND intBuyingCenterId = a.intCompanyLocationId  
    AND strReceivingStorageLocation = a.strStorageLocation collate database_default      
    AND intChannelId = a.intMarketZoneId  
    AND intPortOfDispatchId = a.intLoadingPointId  
    AND intPortOfArrivalId = a.intDestinationPointId  
  
  ) LeadTimeMaster2  
  
  UPDATE #tmpTable  
  SET dtmEtaPol = Dateadd(d, CAST(a.dblPurchaseToShipment as INT), #tmpTable.dtmStartDate )  
  FROM #LeadTimeMaster a  
  WHERE #tmpTable.dtmEtaPol IS NULL   
   AND #tmpTable.intContractDetailImportId = a.intContractDetailImportId   
    
  
  UPDATE #tmpTable  
  SET dtmEtaPod = Dateadd(d, CAST(a.dblPortToPort as INT), #tmpTable.dtmEtaPol)  
  FROM #LeadTimeMaster2 a  
  WHERE #tmpTable.dtmEtaPod IS NULL   
   AND #tmpTable.intContractDetailImportId = a.intContractDetailImportId   
  
  UPDATE #tmpTable  
  SET dtmUpdatedAvailability = Dateadd(d, CAST(a.dblPortToMixingUnit as Int) + CAST(a.dblMUToAvailableForBlending as INT) , #tmpTable.dtmEtaPod)  
  FROM #LeadTimeMaster2 a  
  WHERE #tmpTable.dtmUpdatedAvailability IS NULL   
   AND #tmpTable.intContractDetailImportId = a.intContractDetailImportId   
  
     
 END  
  
 IF @ysnLocationLeadTime = 0  
 BEGIN  
  SELECT  a.intContractDetailImportId, originCity.*  
  INTO #originCity  
  FROM #tmpTable a  
  Cross apply (  
   select  * from tblSMCity   
   WHERE intCityId = a.intLoadingPointId  
  ) originCity  
  
  
  SELECT  a.intContractDetailImportId, destinationCity.*  
  INTO #destinationCity  
  FROM #tmpTable a  
  Cross apply (  
   select  * from tblSMCity   
   WHERE intCityId = a.intDestinationPointId  
  ) destinationCity  
  
  SELECT  a.intContractDetailImportId, freightMatrix.*  
  INTO #freightMatrix  
  FROM #tmpTable a  
  Cross apply (  
   select  * from tblLGFreightRateMatrix   
   WHERE intType = 2 and strOriginPort = a.strLoadingPoint  collate database_default and strDestinationCity = a.strDestinationPoint  collate database_default  
     
  ) freightMatrix  
  
  
  
  UPDATE #tmpTable  
  SET dtmEtaPol = Dateadd(d, a.intLeadTimeAtSource, #tmpTable.dtmStartDate)  
  FROM #originCity a  
  WHERE #tmpTable.dtmEtaPol IS NULL   
   AND #tmpTable.intContractDetailImportId = a.intContractDetailImportId   
  
  UPDATE #tmpTable  
  SET dtmEtaPod = Dateadd(d,  a.intLeadTime, #tmpTable.dtmEtaPol)  
  FROM #freightMatrix a  
  WHERE #tmpTable.dtmEtaPol IS NULL   
   AND #tmpTable.intContractDetailImportId = a.intContractDetailImportId   
  
  UPDATE #tmpTable  
  SET dtmUpdatedAvailability = Dateadd(d, a.intLeadTime, #tmpTable.dtmEtaPod)  
  FROM #destinationCity a  
  WHERE #tmpTable.dtmUpdatedAvailability IS NULL   
   AND #tmpTable.intContractDetailImportId = a.intContractDetailImportId   
  
    
 END  
   
 UPDATE #tmpTable
 SET dblNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId, intNetWeightUOMId, dblQuantity)
  
 DELETE FROM tblCTContractDetailImport WHERE intContractDetailImportHeaderId = @intContractDetailImportHeaderId  
  
 SELECT * FROM #tmpTable ORDER BY intContractDetailImportId  
  
  
END TRY  
BEGIN CATCH  
 SET @ErrMsg = ERROR_MESSAGE()    
 RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')     
END CATCH  
  