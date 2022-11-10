﻿CREATE PROCEDURE uspQMSampleUpdate @strXml NVARCHAR(Max)  
AS  
BEGIN TRY  
 SET QUOTED_IDENTIFIER OFF  
 SET ANSI_NULLS ON  
 SET NOCOUNT ON  
 SET XACT_ABORT ON  
 SET ANSI_WARNINGS OFF  
  
 DECLARE @idoc INT  
 DECLARE @ErrMsg NVARCHAR(Max)  
  
 EXEC sp_xml_preparedocument @idoc OUTPUT  
  ,@strXml  
  
 DECLARE @intSampleId INT  
 DECLARE @strMarks NVARCHAR(100)  
 DECLARE @intPreviousSampleStatusId INT -- New Sample Status Id  
 DECLARE @intCurrentSampleStatusId INT  
 DECLARE @intShipperEntityId INT  
 DECLARE @ysnEnableParentLot BIT  
   ,@intCompanyLocationId INT  
   ,@intSampleTypeId INT  
  ,@dblSampleQty NUMERIC(18, 6)  
  ,@intLotId INT  
  ,@intProductTypeId INT  
  ,@intProductValueId INT  
  ,@intSeqNo INT  
  ,@dblQty NUMERIC(18, 6)  
  ,@intItemUOMId INT  
  ,@intStorageLocationId INT  
  ,@strLotNumber NVARCHAR(50)  
  ,@intSampleUOMId INT  
  ,@intItemId INT  
  ,@intSampleItemUOMId INT  
  ,@strReasonCode NVARCHAR(50)  
  ,@strSampleNumber NVARCHAR(50)  
  ,@dtmBusinessDate DATETIME  
  ,@ysnAdjustInventoryQtyBySampleQty Bit  
  ,@intLastModifiedUserId int  
  ,@dblOldSampleQty NUMERIC(18, 6)  
  ,@intConcurrencyId INT  
  ,@intCurrentConcurrencyId INT  
  ,@ysnImpactPricing BIT  
  ,@ysnOldImpactPricing BIT  
  ,@intContractDetailId INT  
  ,@strErrorSampleNumber NVARCHAR(50)  
  ,@strErrorMessage NVARCHAR(MAX)  
 DECLARE @intRepresentingUOMId INT  
  ,@dblRepresentingQty NUMERIC(18, 6)  
  ,@dblConvertedSampleQty NUMERIC(18, 6)  
  ,@intContractHeaderId INT  
  ,@ysnMultipleContractSeq BIT  
 DECLARE @intOrgSampleTypeId INT  
  ,@intOrgItemId INT  
  ,@intOrgCountryID INT  
  ,@intOrgCompanyLocationSubLocationId INT  
  ,@intRelatedSampleId INT  
  ,@intCurrentRelatedSampleId INT  
  
 SELECT @strErrorSampleNumber = NULL  
  
 SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)  
 FROM tblQMCompanyPreference  
  
 SELECT @intOrgSampleTypeId = intSampleTypeId  
  ,@intOrgItemId = intItemId  
  ,@intOrgCountryID = intCountryID  
  ,@intOrgCompanyLocationSubLocationId = intCompanyLocationSubLocationId  
  ,@intRelatedSampleId =  intRelatedSampleId  
 FROM OPENXML(@idoc, 'root', 2) WITH (  
   intSampleTypeId INT  
   ,intItemId INT  
   ,intCountryID INT  
   ,intCompanyLocationSubLocationId INT  
   ,intRelatedSampleId INT  
   )  
   
 SELECT @intSampleId = intSampleId
  ,@intCompanyLocationId = intCompanyLocationId
  ,@strMarks = strMarks  
  ,@intPreviousSampleStatusId = intSampleStatusId  
  ,@dblSampleQty = dblSampleQty  
  ,@intSampleUOMId = intSampleUOMId  
  ,@dblRepresentingQty = dblRepresentingQty  
  ,@intRepresentingUOMId = intRepresentingUOMId  
  ,@intItemId = intItemId  
  ,@intSampleTypeId = intSampleTypeId  
  ,@intContractHeaderId = intContractHeaderId  
  ,@intConcurrencyId = intConcurrencyId  
  ,@ysnImpactPricing = ysnImpactPricing  
  ,@intContractDetailId = intContractDetailId  
 FROM OPENXML(@idoc, 'root', 2) WITH (  
   intSampleId INT  
   ,intCompanyLocationId INT
   ,strMarks NVARCHAR(100)  
   ,intSampleStatusId INT  
   ,dblSampleQty NUMERIC(18, 6)  
   ,intSampleUOMId INT  
   ,dblRepresentingQty NUMERIC(18, 6)  
   ,intRepresentingUOMId INT  
   ,intItemId INT  
   ,intSampleTypeId INT  
   ,intContractHeaderId INT  
   ,intConcurrencyId INT  
   ,ysnImpactPricing BIT  
   ,intContractDetailId INT  
   )  
  
 IF NOT EXISTS (  
   SELECT *  
   FROM dbo.tblQMSample  
   WHERE intSampleId = @intSampleId  
   )  
 BEGIN  
  RAISERROR (  
    'Sample is already deleted by another user. '  
    ,16  
    ,1  
    )  
 END  
  
 -- Quantity Check  
 IF ISNULL(@intSampleUOMId, 0) > 0  
  AND ISNULL(@intRepresentingUOMId, 0) > 0  
 BEGIN  
  SELECT @dblConvertedSampleQty = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, @intSampleUOMId, @intRepresentingUOMId, @dblSampleQty)  
  
  IF @dblConvertedSampleQty > @dblRepresentingQty  
  BEGIN  
   RAISERROR (  
     'Sample Qty cannot be greater than Representing Qty. '  
     ,16  
     ,1  
     )  
  END  
 END  
  
 -- Shipper Entity Id  
 IF ISNULL(@strMarks, '') <> ''  
 BEGIN  
  DECLARE @strShipperCode NVARCHAR(MAX)  
  DECLARE @intFirstIndex INT  
  DECLARE @intSecondIndex INT  
  
  SELECT @intFirstIndex = ISNULL(CHARINDEX('/', @strMarks), 0)  
  
  SELECT @intSecondIndex = ISNULL(CHARINDEX('/', @strMarks, @intFirstIndex + 1), 0)  
  
  IF (  
    @intFirstIndex > 0  
    AND @intSecondIndex > 0  
    )  
  BEGIN  
   SELECT @strShipperCode = SUBSTRING(@strMarks, @intFirstIndex + 1, (@intSecondIndex - @intFirstIndex - 1))  
  
   SELECT TOP 1 @intShipperEntityId = intEntityId  
   FROM tblEMEntity  
   WHERE strEntityNo = @strShipperCode  
  END  
  ELSE  
  BEGIN  
   SELECT @intShipperEntityId = NULL  
  END  
 END  
  
 SELECT @ysnMultipleContractSeq = ysnMultipleContractSeq  
 FROM tblQMSampleType  
 WHERE intSampleTypeId = @intSampleTypeId  
  
 -- Contract Sequences check for Assign Contract to Multiple Sequences scenario  
 IF @ysnMultipleContractSeq = 1  
  AND ISNULL(@intContractHeaderId, 0) > 0  
 BEGIN  
  IF EXISTS (  
    SELECT 1  
    FROM OPENXML(@idoc, 'root/SampleContractSequence', 2) WITH (  
      intContractDetailId INT  
      ,strRowState NVARCHAR(50)  
      ) x  
    JOIN dbo.tblCTContractDetail CD ON CD.intContractDetailId = x.intContractDetailId  
     AND x.strRowState <> 'DELETE'  
    WHERE CD.intContractHeaderId <> @intContractHeaderId  
    )  
  BEGIN  
   RAISERROR (  
     'Assigned Sequences should belongs to the same Contract. '  
     ,16  
     ,1  
     )  
  END  
 END  
  
 -- Impact Pricing validation  
 IF @ysnImpactPricing = 1  
  AND ISNULL(@intContractDetailId, 0) > 0  
 BEGIN  
  SELECT TOP 1 @strErrorSampleNumber = strSampleNumber  
  FROM tblQMSample  
  WHERE intContractDetailId = @intContractDetailId  
   AND ysnImpactPricing = 1  
   AND intSampleId <> @intSampleId  
  
  IF ISNULL(@strErrorSampleNumber, '') <> ''  
  BEGIN  
   SELECT @strErrorMessage = 'Impact Pricing is already selected in sample ' + @strErrorSampleNumber + ' which belongs to the same contract sequence.'  
  
   RAISERROR (  
     @strErrorMessage  
     ,16  
     ,1  
     )  
  END  
 END  
  
 SELECT @dblOldSampleQty = dblSampleQty  
  ,@intCurrentConcurrencyId = intConcurrencyId  
  ,@ysnOldImpactPricing = ISNULL(ysnImpactPricing, 0)  
  ,@intCurrentSampleStatusId = intSampleStatusId  
  ,@intCurrentRelatedSampleId = intRelatedSampleId  
 FROM tblQMSample  
 WHERE intSampleId = @intSampleId  
  
 -- If sequence already has a voucher, do not allow user to uncheck Impact Pricing till the voucher is deleted  
 IF @ysnOldImpactPricing = 1  
  AND @ysnImpactPricing = 0  
  AND ISNULL(@intContractDetailId, 0) > 0  
 BEGIN  
  IF EXISTS (  
    SELECT 1  
    FROM dbo.tblAPBillDetail  
    WHERE ISNULL(intContractDetailId, 0) = @intContractDetailId  
    )  
  BEGIN  
   RAISERROR (  
     'Voucher is already created for the contract sequence so you cannot uncheck Impact Pricing. '  
     ,16  
     ,1  
     )  
  END  
 END  
  
 BEGIN TRAN  
  
 IF ISNULL(@intConcurrencyId, 0) < ISNULL(@intCurrentConcurrencyId, 0)  
 BEGIN  
  RAISERROR (  
    'Sample is already modified by other user. Please refresh.'  
    ,16  
    ,1  
    )  
 END  
  
 -- If it is not Inter Company then update SampleRefNo  
 IF NOT EXISTS (  
   SELECT TOP 1 1  
   FROM dbo.tblIPMultiCompany  
   )  
 BEGIN  
  UPDATE tblQMSample  
  SET strSampleRefNo = x.strSampleRefNo  
  FROM OPENXML(@idoc, 'root', 2) WITH (  
    strSampleRefNo NVARCHAR(30)  
    ,strRowState NVARCHAR(50)  
    ) x  
  WHERE dbo.tblQMSample.intSampleId = @intSampleId  
   AND x.strRowState = 'MODIFIED'  
 END  
  
  IF ISNULL( @intRelatedSampleId,0) <> 0   
   UPDATE tblQMSample set intRelatedSampleId = NULL WHERE  @intRelatedSampleId = intRelatedSampleId  
   OR @intRelatedSampleId = intSampleId  AND @intSampleId <> intSampleId  

  IF ISNULL(@intCurrentRelatedSampleId,0) <> 0   
    UPDATE tblQMSample SET intRelatedSampleId = NULL WHERE @intCurrentRelatedSampleId = intSampleId 
    OR @intCurrentRelatedSampleId = intRelatedSampleId AND @intSampleId <> intSampleId  
   
  IF ISNULL(@intCurrentRelatedSampleId,0) <> 0 and ISNULL(@intRelatedSampleId ,0) = 0  
    EXEC uspQMMirrorRelatedSample @intSampleId,@intCurrentRelatedSampleId,@intLastModifiedUserId, 'Unlink'  
     
 -- Sample Header Update  
 UPDATE tblQMSample  
 SET intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1  
  ,intSampleTypeId = x.intSampleTypeId  
  ,intCompanyLocationId = x.intCompanyLocationId  
  ,intProductTypeId = x.intProductTypeId  
  ,intProductValueId = x.intProductValueId  
  ,intSampleStatusId = x.intSampleStatusId  
  ,intItemId = x.intItemId  
  ,intItemContractId = x.intItemContractId  
  ,intContractHeaderId = x.intContractHeaderId  
  ,intContractDetailId = x.intContractDetailId  
  ,intRelatedSampleId = CASE WHEN x.intRelatedSampleId =0 THEN NULL ELSE x.intRelatedSampleId END  
  --,intShipmentBLContainerContractId = x.intShipmentBLContainerContractId  
  --,intShipmentId = x.intShipmentId  
  --,intShipmentContractQtyId = x.intShipmentContractQtyId  
  --,intShipmentBLContainerId = x.intShipmentBLContainerId  
  ,intLoadContainerId = x.intLoadContainerId  
  ,intLoadDetailContainerLinkId = x.intLoadDetailContainerLinkId  
  ,intLoadId = x.intLoadId  
  ,intLoadDetailId = x.intLoadDetailId  
  ,intCountryID = x.intCountryID  
  ,ysnIsContractCompleted = x.ysnIsContractCompleted  
  ,intLotStatusId = x.intLotStatusId  
  ,intStorageLocationId = x.intStorageLocationId  
  ,ysnAdjustInventoryQtyBySampleQty = x.ysnAdjustInventoryQtyBySampleQty  
  ,intEntityId = x.intEntityId  
  ,intBookId = x.intBookId  
  ,intSubBookId = x.intSubBookId  
  ,intShipperEntityId = @intShipperEntityId  
  ,strShipmentNumber = x.strShipmentNumber  
  ,strLotNumber = x.strLotNumber  
  ,strSampleNote = x.strSampleNote  
  ,dtmSampleReceivedDate = x.dtmSampleReceivedDate  
  --,dtmTestedOn = x.dtmTestedOn  
  --,intTestedById = x.intTestedById  
  ,dblSampleQty = x.dblSampleQty  
  ,intSampleUOMId = x.intSampleUOMId  
  ,dblRepresentingQty = x.dblRepresentingQty  
  ,intRepresentingUOMId = x.intRepresentingUOMId  
  ,strRefNo = x.strRefNo  
  ,dtmTestingStartDate = x.dtmTestingStartDate  
  ,dtmTestingEndDate = x.dtmTestingEndDate  
  ,dtmSamplingEndDate = x.dtmSamplingEndDate  
  ,dtmRequestedDate = CASE WHEN x.dtmRequestedDate = CAST('' AS DATETIME) THEN NULL ELSE x.dtmRequestedDate END  
  ,dtmSampleSentDate = CASE WHEN x.dtmSampleSentDate = CAST('' AS DATETIME) THEN NULL ELSE x.dtmSampleSentDate END  
  ,strSamplingMethod = x.strSamplingMethod  
  ,strContainerNumber = x.strContainerNumber  
  ,strMarks = x.strMarks  
  ,intCompanyLocationSubLocationId = x.intCompanyLocationSubLocationId  
  ,strCountry = x.strCountry  
  ,strComment = x.strComment  
  ,intItemBundleId = x.intItemBundleId  
  ,intWorkOrderId = x.intWorkOrderId  
  ,intInventoryReceiptId = x.intInventoryReceiptId  
  ,intInventoryShipmentId = x.intInventoryShipmentId  
  ,strChildLotNumber = x.strChildLotNumber  
  ,strCourier = x.strCourier  
  ,strCourierRef = x.strCourierRef  
  ,intForwardingAgentId = x.intForwardingAgentId  
  ,strForwardingAgentRef = x.strForwardingAgentRef  
  ,strSentBy = x.strSentBy  
  ,intSentById = x.intSentById  
  ,ysnImpactPricing = x.ysnImpactPricing  
  ,intSamplingCriteriaId = CASE x.intSamplingCriteriaId WHEN 0 THEN NULL ELSE x.intSamplingCriteriaId END  
  ,strSendSampleTo = x.strSendSampleTo  
  , intSaleYearId = x.intSaleYearId
  , strSaleYear = x.strSaleYear
  , strSaleNumber = x.strSaleNumber
  , dtmSaleDate = CASE WHEN x.dtmSaleDate = CAST('' AS DATETIME) THEN NULL ELSE x.dtmSaleDate END  
  , intCatalogueTypeId = x.intCatalogueTypeId
  , strCatalogueType = x.strCatalogueType
  , dtmPromptDate = CASE WHEN x.dtmPromptDate = CAST('' AS DATETIME) THEN NULL ELSE x.dtmPromptDate END  
  , strChopNumber = x.strChopNumber
  , intBrokerId = x.intBrokerId
  , strBroker = x.strBroker
  , intGradeId = x.intGradeId
  , strGrade = x.strGrade
  , intLeafCategoryId = x.intLeafCategoryId
  , strLeafCategory = x.strLeafCategory
  , intManufacturingLeafTypeId = x.intManufacturingLeafTypeId
  , strManufacturingLeafType = x.strManufacturingLeafType
  , intSeasonId = x.intSeasonId
  , strSeason = x.strSeason
  , intGardenMarkId = x.intGardenMarkId
  , strGardenMark = x.strGardenMark
  , dtmManufacturingDate = CASE WHEN x.dtmManufacturingDate = CAST('' AS DATETIME) THEN NULL ELSE x.dtmManufacturingDate END 
  , intTotalNumberOfPackageBreakups = x.intTotalNumberOfPackageBreakups
  , intNetWtPerPackagesUOMId = x.intNetWtPerPackagesUOMId
  , intNoOfPackages = x.intNoOfPackages
  , intNetWtSecondPackageBreakUOMId = x.intNetWtSecondPackageBreakUOMId
  , intNoOfPackagesSecondPackageBreak = x.intNoOfPackagesSecondPackageBreak
  , intNetWtThirdPackageBreakUOMId = x.intNetWtThirdPackageBreakUOMId
  , intNoOfPackagesThirdPackageBreak = x.intNoOfPackagesThirdPackageBreak
  , intProductLineId = x.intProductLineId
  , strProductLine = x.strProductLine
  , ysnOrganic = x.ysnOrganic
  , dblSupplierValuationPrice = x.dblSupplierValuationPrice
  , intProducerId = x.intProducerId
  , strProducer = x.strProducer
  , intPurchaseGroupId = x.intPurchaseGroupId
  , strPurchaseGroup = x.strPurchaseGroup
  , strERPRefNo = x.strERPRefNo
  , dblGrossWeight = x.dblGrossWeight
  , dblTareWeight = x.dblTareWeight
  , dblNetWeight = x.dblNetWeight
  , strBatchNo = x.strBatchNo
  , str3PLStatus = x.str3PLStatus
  , strAdditionalSupplierReference = x.strAdditionalSupplierReference
  , intAWBSampleReceived = x.intAWBSampleReceived
  , strAWBSampleReference = x.strAWBSampleReference
  , dblBasePrice = x.dblBasePrice
  , ysnBoughtAsReserve = x.ysnBoughtAsReserve
  , intCurrencyId = x.intCurrencyId
  , strCurrency = x.strCurrency
  , ysnEuropeanCompliantFlag = x.ysnEuropeanCompliantFlag
  , intEvaluatorsCodeAtTBOId = x.intEvaluatorsCodeAtTBOId
  , strEvaluatorsCodeAtTBO = x.strEvaluatorsCodeAtTBO
  , intFromLocationCodeId = x.intFromLocationCodeId
  , strFromLocationCode = x.strFromLocationCode
  , strSampleBoxNumber = x.strSampleBoxNumber
  , intBrandId = x.intBrandId
  , strBrandCode = x.strBrandCode
  , intValuationGroupId = x.intValuationGroupId
  , strValuationGroupName = x.strValuationGroupName
  , strMusterLot = x.strMusterLot
  , strMissingLot = x.strMissingLot
  , intMarketZoneId = x.intMarketZoneId
  , strMarketZoneCode = x.strMarketZoneCode
  , intDestinationStorageLocationId = x.intDestinationStorageLocationId
  , strDestinationStorageLocationName = x.strDestinationStorageLocationName
  , strComments2 = x.strComments2
  , strComments3 = x.strComments3
  , intBuyer1Id = x.intBuyer1Id
  --, strBuyer1 = x.strBuyer1
  , dblB1QtyBought = x.dblB1QtyBought
  , intB1QtyUOMId = x.intB1QtyUOMId
  --, strB1QtyUOM = x.strB1QtyUOM
  , dblB1Price = x.dblB1Price
  , intB1PriceUOMId = x.intB1PriceUOMId
  --, strB1PriceUOM = x.strB1PriceUOM
  , intBuyer2Id = x.intBuyer2Id
  --, strBuyer2 = x.strBuyer2
  , dblB2QtyBought = x.dblB2QtyBought
  , intB2QtyUOMId = x.intB2QtyUOMId
  --, strB2QtyUOM = x.strB2QtyUOM
  , dblB2Price = x.dblB2Price
  , intB2PriceUOMId = x.intB2PriceUOMId
  --, strB2PriceUOM = x.strB2PriceUOM
  , intBuyer3Id = x.intBuyer3Id
  --, strBuyer3 = x.strBuyer3
  , dblB3QtyBought = x.dblB3QtyBought
  , intB3QtyUOMId = x.intB3QtyUOMId
  --, strB3QtyUOM = x.strB3QtyUOM
  , dblB3Price = x.dblB3Price
  , intB3PriceUOMId = x.intB3PriceUOMId
  --, strB3PriceUOM = x.strB3PriceUOM
  , intBuyer4Id = x.intBuyer4Id
  --, strBuyer4 = x.strBuyer4
  , dblB4QtyBought = x.dblB4QtyBought
  , intB4QtyUOMId = x.intB4QtyUOMId
  --, strB4QtyUOM = x.strB4QtyUOM
  , dblB4Price = x.dblB4Price
  , intB4PriceUOMId = x.intB4PriceUOMId
  --, strB4PriceUOM = x.strB4PriceUOM
  , intBuyer5Id = x.intBuyer5Id
  --, strBuyer5 = x.strBuyer5
  , dblB5QtyBought = x.dblB5QtyBought
  , intB5QtyUOMId = x.intB5QtyUOMId
  --, strB5QtyUOM = x.strB5QtyUOM
  , dblB5Price = x.dblB5Price
  , intB5PriceUOMId = x.intB5PriceUOMId
  --, strB5PriceUOM = x.strB5PriceUOM
  ,strRepresentLotNumber = x.strRepresentLotNumber  
  ,intLastModifiedUserId = x.intLastModifiedUserId  
  ,dtmLastModified = x.dtmLastModified  
 FROM OPENXML(@idoc, 'root', 2) WITH (  
   intSampleTypeId INT  
   ,intCompanyLocationId INT  
   ,intProductTypeId INT  
   ,intProductValueId INT  
   ,intSampleStatusId INT  
   ,intItemId INT  
   ,intItemContractId INT  
   ,intContractHeaderId INT  
   ,intContractDetailId INT  
   ,intRelatedSampleId INT  
   --,intShipmentBLContainerId INT  
   --,intShipmentBLContainerContractId INT  
   --,intShipmentId INT  
   --,intShipmentContractQtyId INT  
   ,intLoadContainerId INT  
   ,intLoadDetailContainerLinkId INT  
   ,intLoadId INT  
   ,intLoadDetailId INT  
   ,intCountryID INT  
   ,ysnIsContractCompleted BIT  
   ,intLotStatusId INT  
   ,intStorageLocationId INT  
   ,ysnAdjustInventoryQtyBySampleQty BIT  
   ,intEntityId INT  
   ,intBookId INT  
   ,intSubBookId INT  
   ,strShipmentNumber NVARCHAR(30)  
   ,strLotNumber NVARCHAR(50)  
   ,strSampleNote NVARCHAR(512)  
   ,dtmSampleReceivedDate DATETIME  
   --,dtmTestedOn DATETIME  
   --,intTestedById INT  
   ,dblSampleQty NUMERIC(18, 6)  
   ,intSampleUOMId INT  
   ,dblRepresentingQty NUMERIC(18, 6)  
   ,intRepresentingUOMId INT  
   ,strRefNo NVARCHAR(100)  
   ,dtmTestingStartDate DATETIME  
   ,dtmTestingEndDate DATETIME  
   ,dtmSamplingEndDate DATETIME  
   ,dtmRequestedDate DATETIME  
   ,dtmSampleSentDate DATETIME  
   ,strSamplingMethod NVARCHAR(50)  
   ,strContainerNumber NVARCHAR(100)  
   ,strMarks NVARCHAR(100)  
   ,intCompanyLocationSubLocationId INT  
   ,strCountry NVARCHAR(100)  
   ,strComment NVARCHAR(MAX)  
   ,intItemBundleId INT  
   ,intWorkOrderId INT  
   ,intInventoryReceiptId INT  
   ,intInventoryShipmentId INT  
   ,strChildLotNumber NVARCHAR(50)  
   ,strCourier NVARCHAR(50)  
   ,strCourierRef NVARCHAR(50)  
   ,intForwardingAgentId INT  
   ,strForwardingAgentRef NVARCHAR(50)  
   ,strSentBy NVARCHAR(50)  
   ,intSentById INT  
   ,ysnImpactPricing BIT  
   ,intSamplingCriteriaId INT  
   ,strSendSampleTo NVARCHAR(50)  
   ,strRepresentLotNumber NVARCHAR(50)
   , intSaleYearId INT
   , strSaleYear NVARCHAR(50)
   , strSaleNumber NVARCHAR(50)
   , strChopNumber NVARCHAR(50)
   , dtmSaleDate DATETIME  
   , intCatalogueTypeId INT
   , strCatalogueType NVARCHAR(50)
   , dtmPromptDate DATETIME  
   , intBrokerId INT
   , strBroker NVARCHAR(50)
   , intGradeId INT
   , strGrade NVARCHAR(50)
   , intLeafCategoryId INT
   , strLeafCategory NVARCHAR(50)
   , intManufacturingLeafTypeId INT
   , strManufacturingLeafType NVARCHAR(50)
   , intSeasonId INT
   , strSeason NVARCHAR(50)
   , intGardenMarkId INT
   , strGardenMark NVARCHAR(50)
   , dtmManufacturingDate DATETIME  
   , intTotalNumberOfPackageBreakups INT
   , intNetWtPerPackagesUOMId INT
   , intNoOfPackages INT
   , intNetWtSecondPackageBreakUOMId INT
   , intNoOfPackagesSecondPackageBreak INT
   , intNetWtThirdPackageBreakUOMId INT
   , intNoOfPackagesThirdPackageBreak INT
   , intProductLineId INT
   , strProductLine NVARCHAR(50)
   , ysnOrganic BIT
   , dblSupplierValuationPrice NUMERIC(18, 6)
   , intProducerId INT
   , strProducer NVARCHAR(50)
   , intPurchaseGroupId INT
   , strPurchaseGroup NVARCHAR(50)
   , strERPRefNo NVARCHAR(50) 
   , dblGrossWeight NUMERIC(18, 6)
   , dblTareWeight NUMERIC(18, 6)
   , dblNetWeight NUMERIC(18, 6)
   , strBatchNo NVARCHAR(50) 
   , str3PLStatus NVARCHAR(50) 
   , strAdditionalSupplierReference NVARCHAR(50) 
   , intAWBSampleReceived INT
   , strAWBSampleReference NVARCHAR(50) 
   , dblBasePrice NUMERIC(18, 6)
   , ysnBoughtAsReserve BIT
   , intCurrencyId INT
   , strCurrency NVARCHAR(50)
   , ysnEuropeanCompliantFlag BIT
   , intEvaluatorsCodeAtTBOId INT
   , strEvaluatorsCodeAtTBO NVARCHAR(50)
   , intFromLocationCodeId INT
   , strFromLocationCode NVARCHAR(50)
   , strSampleBoxNumber NVARCHAR(50) 
   , intBrandId INT
   , strBrandCode NVARCHAR(50)
   , intValuationGroupId INT
   , strValuationGroupName NVARCHAR(50)
   , strMusterLot NVARCHAR(50) 
   , strMissingLot NVARCHAR(50) 
   , intMarketZoneId INT
   , strMarketZoneCode NVARCHAR(50)
   , intDestinationStorageLocationId INT
   , strDestinationStorageLocationName NVARCHAR(50)
   , strComments2 NVARCHAR(MAX) 
   , strComments3 NVARCHAR(MAX)   
   , intBuyer1Id INT
   --, strBuyer1 NVARCHAR(50)
   , dblB1QtyBought NUMERIC(18, 6)
   , intB1QtyUOMId INT
   --, strB1QtyUOM NVARCHAR(50)
   , dblB1Price NUMERIC(18, 6)
   , intB1PriceUOMId INT
   --, strB1PriceUOM NVARCHAR(50)
   , intBuyer2Id INT
   --, strBuyer2 NVARCHAR(50)
   , dblB2QtyBought NUMERIC(18, 6)
   , intB2QtyUOMId INT
   --, strB2QtyUOM NVARCHAR(50)
   , dblB2Price NUMERIC(18, 6)
   , intB2PriceUOMId INT
   --, strB2PriceUOM NVARCHAR(50)
   , intBuyer3Id INT
   --, strBuyer3 NVARCHAR(50)
   , dblB3QtyBought NUMERIC(18, 6)
   , intB3QtyUOMId INT
   --, strB3QtyUOM NVARCHAR(50)
   , dblB3Price NUMERIC(18, 6)
   , intB3PriceUOMId INT
   --, strB3PriceUOM NVARCHAR(50)
   , intBuyer4Id INT
   --, strBuyer4 NVARCHAR(50)
   , dblB4QtyBought NUMERIC(18, 6)
   , intB4QtyUOMId INT
   --, strB4QtyUOM NVARCHAR(50)
   , dblB4Price NUMERIC(18, 6)
   , intB4PriceUOMId INT
   --, strB4PriceUOM NVARCHAR(50)
   , intBuyer5Id INT
   --, strBuyer5 NVARCHAR(50)
   , dblB5QtyBought NUMERIC(18, 6)
   , intB5QtyUOMId INT
   --, strB5QtyUOM NVARCHAR(50)
   , dblB5Price NUMERIC(18, 6)
   , intB5PriceUOMId INT
   --, strB5PriceUOM NVARCHAR(50)
   ,intLastModifiedUserId INT  
   ,dtmLastModified DATETIME  
   ,strRowState NVARCHAR(50)
   ) x  
 WHERE dbo.tblQMSample.intSampleId = @intSampleId  
  AND x.strRowState = 'MODIFIED'  
  
 IF ISNULL(@intRelatedSampleId ,0) <> 0  
 BEGIN
	DECLARE @_strAction NVARCHAR(30) ='Updated'  
	 IF ISNULL(@intCurrentRelatedSampleId,0) <> @intRelatedSampleId
		SET  @_strAction = 'Establish Link'

	EXEC uspQMMirrorRelatedSample @intSampleId,@intRelatedSampleId,@intLastModifiedUserId, @_strAction  
 END
  
  
 -- If sample status is not in Approved and Rejected, then set the previous sample status  
 IF @intPreviousSampleStatusId <> 3 AND @intPreviousSampleStatusId <> 4  
 BEGIN  
  UPDATE tblQMSample  
  SET intPreviousSampleStatusId = @intPreviousSampleStatusId  
  WHERE intSampleId = @intSampleId  
  
  UPDATE tblQMSample  
  SET dtmTestedOn = NULL  
   ,intTestedById = NULL  
  WHERE intSampleId = @intSampleId  
 END  
  
 -- If current sample status is Approved / Rejected and new sample status is not Approved / Rejected, then it is reversal  
 -- Reverse the lot status  
 IF @intCurrentSampleStatusId IN (3, 4)  
  AND @intPreviousSampleStatusId NOT IN (3, 4)  
 BEGIN  
  UPDATE tblQMSample  
  SET intLotStatusId = 3 -- Quarantine  
  WHERE intSampleId = @intSampleId  
   AND intLotStatusId IS NOT NULL  
  
  EXEC uspQMSetLotStatus @intSampleId  
  
  SELECT @intProductTypeId = intProductTypeId  
   ,@intProductValueId = intProductValueId  
   ,@intLastModifiedUserId = intLastModifiedUserId  
  FROM tblQMSample  
  WHERE intSampleId = @intSampleId  
  
  -- Call IC SP to monitor the rejected samples at lot level  
  IF @intProductTypeId = 6  
   OR @intProductTypeId = 11  
  BEGIN  
   DECLARE @intLotLocationId INT  
   DECLARE @LotRecords TABLE (  
    intSeqNo INT IDENTITY(1, 1)  
    ,intLotId INT  
    ,strLotNumber NVARCHAR(50)  
    )  
  
   DELETE  
   FROM @LotRecords  
  
   IF @intProductTypeId = 11  
   BEGIN  
    INSERT INTO @LotRecords (  
     intLotId  
     ,strLotNumber  
     )  
    SELECT intLotId  
     ,strLotNumber  
    FROM tblICLot  
    WHERE intParentLotId = @intProductValueId  
     AND dblQty > 0  
   END  
   ELSE  
   BEGIN  
    SELECT @strLotNumber = strLotNumber  
     ,@intLotLocationId = intLocationId  
    FROM tblICLot  
    WHERE intLotId = @intProductValueId  
  
    INSERT INTO @LotRecords (  
     intLotId  
     ,strLotNumber  
     )  
    SELECT intLotId  
     ,strLotNumber  
    FROM tblICLot  
    WHERE strLotNumber = @strLotNumber  
     AND dblQty > 0  
     --AND intLocationId = @intLotLocationId  
   END  
  
   SELECT @intSeqNo = MIN(intSeqNo)  
   FROM @LotRecords  
  
   WHILE (@intSeqNo > 0)  
   BEGIN  
    SELECT @intLotId = NULL  
  
    SELECT @intLotId = intLotId  
    FROM @LotRecords  
    WHERE intSeqNo = @intSeqNo  
  
    EXEC uspICRejectLot @intLotId = @intLotId  
     ,@intEntityId = @intLastModifiedUserId  
     ,@ysnAdd = 0  
  
    SELECT @intSeqNo = MIN(intSeqNo)  
    FROM @LotRecords  
    WHERE intSeqNo > @intSeqNo  
   END  
  END  
 END  
  
 -- Sample Detail Create, Update, Delete  
 INSERT INTO dbo.tblQMSampleDetail (  
  intConcurrencyId  
  ,intSampleId  
  ,intAttributeId  
  ,strAttributeValue  
  ,ysnIsMandatory  
  ,intListItemId  
  ,intCreatedUserId  
  ,dtmCreated  
  ,intLastModifiedUserId  
  ,dtmLastModified  
  )  
 SELECT 1  
  ,@intSampleId  
  ,intAttributeId  
  ,strAttributeValue  
  ,ysnIsMandatory  
  ,intListItemId  
  ,intCreatedUserId  
  ,dtmCreated  
  ,intLastModifiedUserId  
  ,dtmLastModified  
 FROM OPENXML(@idoc, 'root/SampleDetail', 2) WITH (  
   intAttributeId INT  
   ,strAttributeValue NVARCHAR(50)  
   ,ysnIsMandatory BIT  
   ,intListItemId INT  
   ,intCreatedUserId INT  
   ,dtmCreated DATETIME  
   ,intLastModifiedUserId INT  
   ,dtmLastModified DATETIME  
   ,strRowState NVARCHAR(50)  
   ) x  
 WHERE x.strRowState = 'ADDED'  
  
 UPDATE dbo.tblQMSampleDetail  
 SET strAttributeValue = x.strAttributeValue  
  ,intListItemId = x.intListItemId  
  ,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1  
  ,intLastModifiedUserId = x.intLastModifiedUserId  
  ,dtmLastModified = x.dtmLastModified  
 FROM OPENXML(@idoc, 'root/SampleDetail', 2) WITH (  
   intSampleDetailId INT  
   ,strAttributeValue NVARCHAR(50)  
   ,intListItemId INT  
   ,intLastModifiedUserId INT  
   ,dtmLastModified DATETIME  
   ,strRowState NVARCHAR(50)  
   ) x  
 WHERE x.intSampleDetailId = dbo.tblQMSampleDetail.intSampleDetailId  
  AND x.strRowState = 'MODIFIED'  
  
 DELETE  
 FROM dbo.tblQMSampleDetail  
 WHERE intSampleId = @intSampleId  
  AND EXISTS (  
   SELECT *  
   FROM OPENXML(@idoc, 'root/SampleDetail', 2) WITH (  
     intSampleDetailId INT  
     ,strRowState NVARCHAR(50)  
     ) x  
   WHERE x.intSampleDetailId = dbo.tblQMSampleDetail.intSampleDetailId  
    AND x.strRowState = 'DELETE'  
   )  
  
 -- Sample Contract Sequences Create, Update, Delete  
 INSERT INTO dbo.tblQMSampleContractSequence (  
  intConcurrencyId  
  ,intSampleId  
  ,intContractDetailId  
  ,dblQuantity  
  ,intUnitMeasureId  
  ,intCreatedUserId  
  ,dtmCreated  
  ,intLastModifiedUserId  
  ,dtmLastModified  
  )  
 SELECT 1  
  ,@intSampleId  
  ,intContractDetailId  
  ,dblQuantity  
  ,intUnitMeasureId  
  ,intCreatedUserId  
  ,dtmCreated  
  ,intLastModifiedUserId  
  ,dtmLastModified  
 FROM OPENXML(@idoc, 'root/SampleContractSequence', 2) WITH (  
   intContractDetailId INT  
   ,dblQuantity NUMERIC(18, 6)  
   ,intUnitMeasureId INT  
   ,intCreatedUserId INT  
   ,dtmCreated DATETIME  
   ,intLastModifiedUserId INT  
   ,dtmLastModified DATETIME  
   ,strRowState NVARCHAR(50)  
   ) x  
 WHERE x.strRowState = 'ADDED'  
  
 UPDATE dbo.tblQMSampleContractSequence  
 SET intContractDetailId = x.intContractDetailId  
  ,dblQuantity = x.dblQuantity  
  ,intUnitMeasureId = x.intUnitMeasureId  
  ,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1  
  ,intLastModifiedUserId = x.intLastModifiedUserId  
  ,dtmLastModified = x.dtmLastModified  
 FROM OPENXML(@idoc, 'root/SampleContractSequence', 2) WITH (  
   intSampleContractSequenceId INT  
   ,intContractDetailId INT  
   ,dblQuantity NUMERIC(18, 6)  
   ,intUnitMeasureId INT  
   ,intLastModifiedUserId INT  
   ,dtmLastModified DATETIME  
   ,strRowState NVARCHAR(50)  
   ) x  
 WHERE x.intSampleContractSequenceId = dbo.tblQMSampleContractSequence.intSampleContractSequenceId  
  AND x.strRowState = 'MODIFIED'  
  
 DELETE  
 FROM dbo.tblQMSampleContractSequence  
 WHERE intSampleId = @intSampleId  
  AND EXISTS (  
   SELECT *  
   FROM OPENXML(@idoc, 'root/SampleContractSequence', 2) WITH (  
     intSampleContractSequenceId INT  
     ,strRowState NVARCHAR(50)  
     ) x  
   WHERE x.intSampleContractSequenceId = dbo.tblQMSampleContractSequence.intSampleContractSequenceId  
    AND x.strRowState = 'DELETE'  
   )  
  
 -- Test Result Create, Update, Delete  
 INSERT INTO dbo.tblQMTestResult (  
  intConcurrencyId  
  ,intSampleId  
  ,intProductId  
  ,intProductTypeId  
  ,intProductValueId  
  ,intTestId  
  ,intPropertyId  
  ,strPanelList  
  ,strPropertyValue  
  ,dtmCreateDate  
  ,strResult  
  ,ysnFinal  
  ,strComment  
  ,intSequenceNo  
  ,dtmValidFrom  
  ,dtmValidTo  
  ,strPropertyRangeText  
  ,dblMinValue  
  ,dblMaxValue  
  ,dblLowValue  
  ,dblHighValue  
  ,intUnitMeasureId  
  ,strFormulaParser  
  ,dblCrdrPrice  
  ,dblCrdrQty  
  ,intProductPropertyValidityPeriodId  
  ,intPropertyValidityPeriodId  
  ,intControlPointId  
  ,intParentPropertyId  
  ,intRepNo  
  ,strFormula  
  ,intListItemId  
  ,strIsMandatory  
  ,intPropertyItemId  
  ,dtmPropertyValueCreated  
  ,intCreatedUserId  
  ,dtmCreated  
  ,intLastModifiedUserId  
  ,dtmLastModified  
  )  
 SELECT 1  
  ,@intSampleId  
  ,intProductId  
  ,intProductTypeId  
  ,intProductValueId  
  ,intTestId  
  ,intPropertyId  
  ,strPanelList  
  ,strPropertyValue  
  ,dtmCreateDate  
  ,strResult  
  ,ysnFinal  
  ,strComment  
  ,intSequenceNo  
  ,dtmValidFrom  
  ,dtmValidTo  
  ,strPropertyRangeText  
  ,dblMinValue  
  ,dblMaxValue  
  ,dblLowValue  
  ,dblHighValue  
  ,intUnitMeasureId  
  ,strFormulaParser  
  ,dblCrdrPrice  
  ,dblCrdrQty  
  ,intProductPropertyValidityPeriodId  
  ,intPropertyValidityPeriodId  
  ,intControlPointId  
  ,intParentPropertyId  
  ,intRepNo  
  ,strFormula  
  ,intListItemId  
  ,strIsMandatory  
  ,intPropertyItemId  
  ,CASE   
   WHEN strPropertyValue <> ''  
    THEN GETDATE()  
   ELSE NULL  
   END AS dtmPropertyValueCreated  
  ,intCreatedUserId  
  ,dtmCreated  
  ,intLastModifiedUserId  
  ,dtmLastModified  
 FROM OPENXML(@idoc, 'root/TestResult', 2) WITH (  
   intProductId INT  
   ,intProductTypeId INT  
   ,intProductValueId INT  
   ,intTestId INT  
   ,intPropertyId INT  
   ,strPanelList NVARCHAR(50)  
   ,strPropertyValue NVARCHAR(MAX)  
   ,dtmCreateDate DATETIME  
   ,strResult NVARCHAR(20)  
   ,ysnFinal BIT  
   ,strComment NVARCHAR(MAX)  
   ,intSequenceNo INT  
   ,dtmValidFrom DATETIME  
   ,dtmValidTo DATETIME  
   ,strPropertyRangeText NVARCHAR(MAX)  
   ,dblMinValue NUMERIC(18, 6)  
   ,dblMaxValue NUMERIC(18, 6)  
   ,dblLowValue NUMERIC(18, 6)  
   ,dblHighValue NUMERIC(18, 6)  
   ,intUnitMeasureId INT  
   ,strFormulaParser NVARCHAR(MAX)  
   ,dblCrdrPrice NUMERIC(18, 6)  
   ,dblCrdrQty NUMERIC(18, 6)  
   ,intProductPropertyValidityPeriodId INT  
   ,intPropertyValidityPeriodId INT  
   ,intControlPointId INT  
   ,intParentPropertyId INT  
   ,intRepNo INT  
   ,strFormula NVARCHAR(MAX)  
   ,intListItemId INT  
   ,strIsMandatory NVARCHAR(20)  
   ,intPropertyItemId INT  
   ,intCreatedUserId INT  
   ,dtmCreated DATETIME  
   ,intLastModifiedUserId INT  
   ,dtmLastModified DATETIME  
   ,strRowState NVARCHAR(50)  
   ) x  
 WHERE x.strRowState = 'ADDED'  
  
 UPDATE dbo.tblQMTestResult  
 SET intProductTypeId = x.intProductTypeId  
  ,intProductValueId = x.intProductValueId  
  ,strPropertyValue = x.strPropertyValue  
  ,strResult = x.strResult  
  ,strComment = x.strComment  
  ,intSequenceNo = x.intSequenceNo  
  ,intControlPointId = x.intControlPointId  
  ,intListItemId = x.intListItemId  
  ,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1  
  ,intLastModifiedUserId = x.intLastModifiedUserId  
  ,dtmLastModified = x.dtmLastModified  
  ,dtmPropertyValueCreated = (  
   CASE   
    WHEN (  
      dtmPropertyValueCreated IS NULL  
      AND x.strPropertyValue <> ''  
      )  
     THEN GETDATE()  
    ELSE dtmPropertyValueCreated  
    END  
   )  
 FROM OPENXML(@idoc, 'root/TestResult', 2) WITH (  
   intTestResultId INT  
   ,intProductTypeId INT  
   ,intProductValueId INT  
   ,strPropertyValue NVARCHAR(MAX)  
   ,strResult NVARCHAR(20)  
   ,strComment NVARCHAR(MAX)  
   ,intSequenceNo INT  
   ,intControlPointId INT  
   ,intListItemId INT  
   ,intLastModifiedUserId INT  
   ,dtmLastModified DATETIME  
   ,strRowState NVARCHAR(50)  
   ) x  
 WHERE x.intTestResultId = dbo.tblQMTestResult.intTestResultId  
  AND x.strRowState = 'MODIFIED'  
  
 DELETE  
 FROM dbo.tblQMTestResult  
 WHERE intSampleId = @intSampleId  
  AND EXISTS (  
   SELECT *  
   FROM OPENXML(@idoc, 'root/TestResult', 2) WITH (  
     intTestResultId INT  
     ,strRowState NVARCHAR(50)  
     ) x  
   WHERE x.intTestResultId = dbo.tblQMTestResult.intTestResultId  
    AND x.strRowState = 'DELETE'  
   )  
  
 EXEC sp_xml_removedocument @idoc  
 SET @idoc = 0  
  
 SELECT @intSampleTypeId = intSampleTypeId  
  ,@dblSampleQty = dblSampleQty  
  ,@strLotNumber = strLotNumber  
  ,@intStorageLocationId = intStorageLocationId  
  ,@intItemId = intItemId  
  ,@intSampleUOMId = intSampleUOMId  
  ,@strSampleNumber = strSampleNumber  
  ,@ysnAdjustInventoryQtyBySampleQty=IsNULL(ysnAdjustInventoryQtyBySampleQty,0)  
  ,@intLastModifiedUserId=intLastModifiedUserId  
  ,@ysnImpactPricing = ISNULL(ysnImpactPricing, 0)  
  ,@intContractDetailId = intContractDetailId  
 FROM tblQMSample  
 WHERE intSampleId = @intSampleId  
  
 -- Impact Pricing is selected  
 IF @ysnImpactPricing = 1  
  AND ISNULL(@intContractDetailId, 0) > 0  
 BEGIN  
  EXEC uspCTSaveContractSamplePremium @intContractDetailId = @intContractDetailId  
   ,@intSampleId = @intSampleId  
   ,@intUserId = @intLastModifiedUserId  
   ,@ysnImpactPricing = 1  
 END  
  
 -- Impact Pricing is reversed  
 IF @ysnOldImpactPricing = 1  
  AND @ysnImpactPricing = 0  
  AND ISNULL(@intContractDetailId, 0) > 0  
 BEGIN  
  EXEC uspCTSaveContractSamplePremium @intContractDetailId = @intContractDetailId  
   ,@intSampleId = @intSampleId  
   ,@intUserId = @intLastModifiedUserId  
   ,@ysnImpactPricing = 0  
 END  
  
 IF @ysnAdjustInventoryQtyBySampleQty=1  
  AND ISNULL(@dblSampleQty, 0) > 0  
  AND @ysnEnableParentLot = 0 AND ISNULL(@strLotNumber, '') <> '' -- Lot  
 BEGIN  
  IF @intStorageLocationId IS NULL  
  BEGIN  
   RAISERROR (  
     'Storage Unit cannot be empty. '  
     ,16  
     ,1  
     )  
  END  
  
  SELECT @intLotId = NULL  
  
  SELECT @intLotId = intLotId  
   ,@dblQty = dblQty  
   ,@intItemUOMId = intItemUOMId  
  FROM tblICLot  
  WHERE strLotNumber = @strLotNumber  
   AND intStorageLocationId = @intStorageLocationId  
  
  SELECT @intSampleItemUOMId = intItemUOMId  
  FROM tblICItemUOM  
  WHERE intItemId = @intItemId  
   AND intUnitMeasureId = @intSampleUOMId  
  
  IF @intSampleItemUOMId IS NULL  
  BEGIN  
   RAISERROR (  
     'Sample quantity UOM is not configured for the selected item. '  
     ,16  
     ,1  
     )  
  END  
  
  SELECT @dblSampleQty = dbo.fnMFConvertQuantityToTargetItemUOM(@intSampleItemUOMId, @intItemUOMId, @dblSampleQty)  
  
  IF @dblSampleQty > @dblQty  
  BEGIN  
   RAISERROR (  
     'Sample quantity cannot be greater than lot / pallet quantity. '  
     ,16  
     ,1  
     )  
  END  
  
  SELECT @dblQty = @dblQty - (@dblSampleQty-@dblOldSampleQty)  
  
  SELECT @strReasonCode = 'Sample Quantity - ' + @strSampleNumber  
  
  EXEC [uspMFLotAdjustQty] @intLotId = @intLotId  
   ,@dblNewLotQty = @dblQty  
   ,@intAdjustItemUOMId = @intItemUOMId  
   ,@intUserId = @intLastModifiedUserId  
   ,@strReasonCode = @strReasonCode  
   ,@blnValidateLotReservation = 0  
   ,@strNotes = NULL  
   ,@dtmDate = @dtmBusinessDate  
   ,@ysnBulkChange = 0  
 END  
  
 EXEC uspQMInterCompanyPreStageSample @intSampleId  
  
 EXEC uspQMPreStageSample @intSampleId  
  ,'Modified'  
  ,@strSampleNumber  
  ,@intOrgSampleTypeId  
  ,@intOrgItemId  
  ,@intOrgCountryID  
  ,@intOrgCompanyLocationSubLocationId  
   
 -- Update parent sample if the sample being updated is a cupping sample  
 DECLARE @intTypeId INT  
 SELECT @intTypeId = intTypeId FROM tblQMSample WHERE intSampleId = @intSampleId  
   
 IF(@intTypeId = 2)  
 BEGIN  
  EXEC uspQMCuppingSessionUpdateParentSample  
   @intCuppingSampleId = @intSampleId,  
   @intUserEntityId = @intLastModifiedUserId  
 END  
  
 COMMIT TRAN  
END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0  
  AND @@TRANCOUNT > 0  
  ROLLBACK TRANSACTION  
  
 SET @ErrMsg = ERROR_MESSAGE()  
  
 IF @idoc <> 0  
  EXEC sp_xml_removedocument @idoc  
  
 RAISERROR (  
   @ErrMsg  
   ,16  
   ,1  
   ,'WITH NOWAIT'  
   )  
END CATCH