﻿CREATE TABLE [dbo].[tblQMSample]
(
	[intSampleId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMSample_intConcurrencyId] DEFAULT 0, 
	intCompanyId INT NULL,
	[intSampleTypeId] INT NOT NULL, 
	[strSampleNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intCompanyLocationId] INT, 
	[intParentSampleId] INT, 
	[strSampleRefNo] NVARCHAR(30) COLLATE Latin1_General_CI_AS, 
	[intProductTypeId] INT NOT NULL, -- Transaction Type Id
	[intProductValueId] INT, -- Transaction Object Id
	[intSampleStatusId] INT NOT NULL, 
	intPreviousSampleStatusId INT,
	[intItemId] INT, -- Inventory Item
	[intItemContractId] INT, -- Contract Item
	[intContractHeaderId] INT, 
	[intContractDetailId] INT, 
	[intShipmentBLContainerId] INT, -- Need to remove later
	[intShipmentBLContainerContractId] INT,  -- Need to remove later
	[intShipmentId] INT,  -- Need to remove later
	[intShipmentContractQtyId] INT,  -- Need to remove later
	[intCountryID] INT, -- Origin Id
	[ysnIsContractCompleted] BIT NOT NULL CONSTRAINT [DF_tblQMSample_ysnIsContractCompleted] DEFAULT 0, 
	[intLotStatusId] INT, 
	[intEntityId] INT, -- Party Id
	[intShipperEntityId] INT, -- Shipper Id
	[strShipmentNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[strSampleNote] NVARCHAR(512) COLLATE Latin1_General_CI_AS, 
	[dtmSampleReceivedDate] DATETIME, 
	[dtmTestedOn] DATETIME, 
	[intTestedById] INT, -- User Security ID
	[dblSampleQty] NUMERIC(18, 6), 
	[intSampleUOMId] INT, 
	[dblRepresentingQty] NUMERIC(18, 6), 
	[intRepresentingUOMId] INT, 
	[strRefNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[dtmTestingStartDate] DATETIME CONSTRAINT [DF_tblQMSample_dtmTestingStartDate] DEFAULT GetDate(),
	[dtmTestingEndDate] DATETIME CONSTRAINT [DF_tblQMSample_dtmTestingEndDate] DEFAULT GetDate(), 
	[dtmSamplingEndDate] DATETIME CONSTRAINT [DF_tblQMSample_dtmSamplingEndDate] DEFAULT GetDate(), 
	[strSamplingMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strContainerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strMarks] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[intCompanyLocationSubLocationId] INT, 
	[strCountry] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[intItemBundleId] INT, -- Bundle Item
	[intLoadContainerId] INT, 
	[intLoadDetailContainerLinkId] INT, 
	[intLoadId] INT, 
	[intLoadDetailId] INT, 
	[dtmBusinessDate] DATETIME, 
	[intShiftId] INT, 
	[intLocationId] INT, 
	[intInventoryReceiptId] INT, 
	intInventoryShipmentId INT, 
	[intWorkOrderId] INT, 
	[strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 
	ysnAdjustInventoryQtyBySampleQty BIT CONSTRAINT [DF_tblQMSample_ysnAdjustInventoryQtyBySampleQty] DEFAULT 0,
	intStorageLocationId INT,
	intBookId INT,
	intSubBookId INT,
	strChildLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strCourier NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strCourierRef NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intForwardingAgentId INT,
	strForwardingAgentRef NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSentBy NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intSentById INT,
	intSampleRefId INT,
	ysnParent BIT CONSTRAINT [DF_tblQMSample_ysnParent] DEFAULT 1,
	ysnIgnoreContract BIT CONSTRAINT [DF_tblQMSample_ysnIgnoreContract] DEFAULT 0,
	ysnImpactPricing BIT CONSTRAINT [DF_tblQMSample_ysnImpactPricing] DEFAULT 0,
	dtmRequestedDate DATETIME NULL,
	dtmSampleSentDate DATETIME NULL,
	intSamplingCriteriaId INT NULL,
	strSendSampleTo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strRepresentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intRelatedSampleId INT NULL,
	intTypeId INT NOT NULL DEFAULT (1), -- 1 = Regular Sample, 2 = Cupping Session Sample
	intCuppingSessionDetailId INT NULL,

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMSample_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMSample_dtmLastModified] DEFAULT GetDate(),

	-- Auction
	[intSaleYearId] INT, 
	[strSaleNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmSaleDate] DATETIME NULL, 
	[intCatalogueTypeId] INT NULL, 
	[dtmPromptDate] DATETIME NULL, 
	[strChopNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intBrokerId] INT NULL, 
	[intGradeId] INT NULL, 
	[intLeafCategoryId] INT NULL, 
	[intManufacturingLeafTypeId] INT NULL,
	[intSeasonId] INT NULL, 
	[intGardenMarkId] INT NULL,
	[dtmManufacturingDate] DATETIME NULL, 
	[intTotalNumberOfPackageBreakups] BIGINT NULL,
	[intNetWtPerPackagesUOMId] INT NULL,
	[intNoOfPackages] BIGINT NULL,
	[intNetWtSecondPackageBreakUOMId] INT NULL,
	[intNoOfPackagesSecondPackageBreak] BIGINT NULL,
	[intNetWtThirdPackageBreakUOMId] INT NULL,
	[intNoOfPackagesThirdPackageBreak] BIGINT NULL,
	[intProductLineId] INT NULL,
	[ysnOrganic] BIT DEFAULT 0,
	[dblSupplierValuationPrice] NUMERIC(18, 6) NULL,
	[intProducerId] INT NULL,
	[intPurchaseGroupId] INT NULL,
	[strERPRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblGrossWeight] NUMERIC(18, 6) NULL,
	[dblTareWeight] NUMERIC(18, 6) NULL,
	[dblNetWeight] NUMERIC(18, 6) NULL,
	[strBatchNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[str3PLStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strAdditionalSupplierReference] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intAWBSampleReceived] BIGINT NULL,
	[strAWBSampleReference] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblBasePrice] NUMERIC(18, 6) NULL,
	[ysnBoughtAsReserve] BIT DEFAULT 0,
	[intCurrencyId] INT NULL,
	[ysnEuropeanCompliantFlag] BIT DEFAULT 0,
	[intEvaluatorsCodeAtTBOId] INT NULL,
	[intFromLocationCodeId] INT NULL,
	[strSampleBoxNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intBrandId] INT NULL,
	[intValuationGroupId] INT NULL,
	[strMusterLot] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMissingLot] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intMarketZoneId] INT NULL,
	[intDestinationStorageLocationId] INT NULL,
	[strComments2] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strComments3] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strBuyingOrderNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intTINClearanceId] INT NULL,
	-- Initial Buy
	[intBuyer1Id] INT NULL, 
    [dblB1QtyBought] NUMERIC(18, 6) NULL, 
    [intB1QtyUOMId] INT NULL, 
    [dblB1Price] NUMERIC(18, 6) NULL, 
    [intB1PriceUOMId] INT NULL,    
	[intBuyer2Id] INT NULL, 
    [dblB2QtyBought] NUMERIC(18, 6) NULL, 
    [intB2QtyUOMId] INT NULL, 
    [dblB2Price] NUMERIC(18, 6) NULL, 
    [intB2PriceUOMId] INT NULL,
    [intBuyer3Id] INT NULL, 
    [dblB3QtyBought] NUMERIC(18, 6) NULL, 
    [intB3QtyUOMId] INT NULL,  
    [dblB3Price] NUMERIC(18, 6) NULL, 
    [intB3PriceUOMId] INT NULL,
    [intBuyer4Id] INT NULL, 
    [dblB4QtyBought] NUMERIC(18, 6) NULL, 
    [intB4QtyUOMId] INT NULL, 
    [dblB4Price] NUMERIC(18, 6) NULL, 
    [intB4PriceUOMId] INT NULL,
    [intBuyer5Id] INT NULL, 
    [dblB5QtyBought] NUMERIC(18, 6) NULL, 
    [intB5QtyUOMId] INT NULL, 
    [dblB5Price] NUMERIC(18, 6) NULL, 
    [intB5PriceUOMId] INT NULL,
	[strB5PriceUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[ysnBought] BIT NULL,
		
	CONSTRAINT [PK_tblQMSample] PRIMARY KEY ([intSampleId]), 
	CONSTRAINT [AK_tblQMSample_strSampleNumber] UNIQUE ([strSampleNumber]), 
	CONSTRAINT [FK_tblQMSample_tblQMSample] FOREIGN KEY ([intParentSampleId]) REFERENCES [tblQMSample]([intSampleId]), 
	CONSTRAINT [FK_tblQMSample_tblQMSampleType] FOREIGN KEY ([intSampleTypeId]) REFERENCES [tblQMSampleType]([intSampleTypeId]), 
	CONSTRAINT [FK_tblQMSample_tblQMProductType] FOREIGN KEY ([intProductTypeId]) REFERENCES [tblQMProductType]([intProductTypeId]), 
	CONSTRAINT [FK_tblQMSample_tblQMSampleStatus] FOREIGN KEY ([intSampleStatusId]) REFERENCES [tblQMSampleStatus]([intSampleStatusId]), 
	CONSTRAINT [FK_tblQMSample_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
	CONSTRAINT [FK_tblQMSample_tblICItemContract] FOREIGN KEY ([intItemContractId]) REFERENCES [tblICItemContract]([intItemContractId]), 
	CONSTRAINT [FK_tblQMSample_tblCTContractHeader] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]), 
	CONSTRAINT [FK_tblQMSample_tblCTContractDetail] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]), 
	CONSTRAINT [FK_tblQMSample_tblLGShipmentBLContainer] FOREIGN KEY ([intShipmentBLContainerId]) REFERENCES [tblLGShipmentBLContainer]([intShipmentBLContainerId]), 
	CONSTRAINT [FK_tblQMSample_tblLGShipmentBLContainerContract] FOREIGN KEY ([intShipmentBLContainerContractId]) REFERENCES [tblLGShipmentBLContainerContract]([intShipmentBLContainerContractId]), 
	CONSTRAINT [FK_tblQMSample_tblLGShipment] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]), 
	CONSTRAINT [FK_tblQMSample_tblLGShipmentContractQty] FOREIGN KEY ([intShipmentContractQtyId]) REFERENCES [tblLGShipmentContractQty]([intShipmentContractQtyId]),	
	CONSTRAINT [FK_tblQMSample_tblICUnitMeasure_intSampleUOMId] FOREIGN KEY ([intSampleUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
	CONSTRAINT [FK_tblQMSample_tblICUnitMeasure_intRepresentingUOMId] FOREIGN KEY ([intRepresentingUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
	CONSTRAINT [FK_tblQMSample_tblICLotStatus] FOREIGN KEY ([intLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]), 
	CONSTRAINT [FK_tblQMSample_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]), 
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intShipperEntityId] FOREIGN KEY ([intShipperEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblQMSample_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblQMSample_tblICItem_intItemBundleId] FOREIGN KEY ([intItemBundleId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblQMSample_tblLGLoadContainer] FOREIGN KEY ([intLoadContainerId]) REFERENCES [tblLGLoadContainer]([intLoadContainerId]), 
	CONSTRAINT [FK_tblQMSample_tblLGLoadDetailContainerLink] FOREIGN KEY ([intLoadDetailContainerLinkId]) REFERENCES [tblLGLoadDetailContainerLink]([intLoadDetailContainerLinkId]), 
	CONSTRAINT [FK_tblQMSample_tblLGLoad] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]), 
	CONSTRAINT [FK_tblQMSample_tblLGLoadDetail] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId]),
	CONSTRAINT [FK_tblQMSample_tblMFShift] FOREIGN KEY ([intShiftId]) REFERENCES tblMFShift([intShiftId]),
	CONSTRAINT [FK_tblQMSample_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES tblSMCompanyLocation([intCompanyLocationId]),
	CONSTRAINT [FK_tblQMSample_tblICStorageLocation] FOREIGN KEY([intStorageLocationId]) REFERENCES tblICStorageLocation ([intStorageLocationId]),
	CONSTRAINT [FK_tblQMSample_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblQMSample_tblICInventoryShipment] FOREIGN KEY ([intInventoryShipmentId]) REFERENCES [tblICInventoryShipment]([intInventoryShipmentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblQMSample_tblMFWorkOrder] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblQMSample_tblQMSamplingCriteria] FOREIGN KEY ([intSamplingCriteriaId]) REFERENCES [tblQMSamplingCriteria]([intSamplingCriteriaId]),
	CONSTRAINT [FK_tblQMSample_tblQMCuppingSessionDetail] FOREIGN KEY ([intCuppingSessionDetailId]) REFERENCES [tblQMCuppingSessionDetail]([intCuppingSessionDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblQMSample_tblQMCatalogueType_intCatalogueTypeId] FOREIGN KEY ([intCatalogueTypeId]) REFERENCES [dbo].[tblQMCatalogueType]([intCatalogueTypeId]),
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intBrokerId] FOREIGN KEY ([intBrokerId]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblQMSample_tblICCommodityAttribute2_intLeafCategoryId] FOREIGN KEY ([intLeafCategoryId]) REFERENCES [dbo].[tblICCommodityAttribute2]([intCommodityAttributeId2]),
	CONSTRAINT [FK_tblQMSample_tblICCommodityAttribute_intManufacturingLeafTypeId] FOREIGN KEY ([intManufacturingLeafTypeId]) REFERENCES [dbo].[tblICCommodityAttribute]([intCommodityAttributeId]), 
	CONSTRAINT [FK_tblQMSample_tblICCommodityProductLine_intProductLineId] FOREIGN KEY ([intProductLineId]) REFERENCES [dbo].[tblICCommodityProductLine]([intCommodityProductLineId]),
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intProducerId] FOREIGN KEY ([intProducerId]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),  
	CONSTRAINT [FK_tblQMSample_tblSMPurchasingGroup_intPurchaseGroupId] FOREIGN KEY ([intPurchaseGroupId]) REFERENCES [dbo].[tblSMPurchasingGroup]([intPurchasingGroupId]),  
	CONSTRAINT [FK_tblQMSample_tblSMCurrency_intCurrencyId] FOREIGN KEY (intCurrencyId) REFERENCES [dbo].[tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intEvaluatorsCodeAtTBOId] FOREIGN KEY ([intEvaluatorsCodeAtTBOId]) REFERENCES [dbo].[tblEMEntity]([intEntityId]), 
	CONSTRAINT [FK_tblQMSample_tblSMCity_intFromLocationCodeId] FOREIGN KEY ([intFromLocationCodeId]) REFERENCES [dbo].[tblSMCity]([intCityId]),
	CONSTRAINT [FK_tblQMSample_tblICCommodityAttribute_intSeasonId] FOREIGN KEY ([intSeasonId]) REFERENCES [dbo].[tblICCommodityAttribute]([intCommodityAttributeId]), 
	CONSTRAINT [FK_tblQMSample_tblCTValuationGroup_intValuationGroupId] FOREIGN KEY ([intValuationGroupId]) REFERENCES [dbo].[tblCTValuationGroup]([intValuationGroupId]), 
	CONSTRAINT [FK_tblQMSample_tblARMarketZone_intMarketZoneId] FOREIGN KEY ([intMarketZoneId]) REFERENCES [dbo].[tblARMarketZone]([intMarketZoneId]),
	CONSTRAINT [FK_tblQMSample_tblICStorageLocation_intDestinationStorageLocationId] FOREIGN KEY ([intDestinationStorageLocationId]) REFERENCES [dbo].[tblICStorageLocation]([intStorageLocationId]),
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intBuyer1Id] FOREIGN KEY ([intBuyer1Id]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intBuyer2Id] FOREIGN KEY ([intBuyer2Id]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intBuyer3Id] FOREIGN KEY ([intBuyer3Id]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intBuyer4Id] FOREIGN KEY ([intBuyer4Id]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intBuyer5Id] FOREIGN KEY ([intBuyer5Id]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblQMSample_tblQMTINClearance_intTINClearanceId] FOREIGN KEY ([intTINClearanceId]) REFERENCES [dbo].[tblQMTINClearance]([intTINClearanceId])

)
GO
CREATE STATISTICS [_dta_stat_1863273993_4_11_1] ON [dbo].[tblQMSample]([strSampleNumber], [intContractDetailId], [intSampleId])
GO
CREATE NONCLUSTERED INDEX [IX_tblQMSample_intProductValueId] ON [dbo].[tblQMSample](intProductValueId);
GO
CREATE NONCLUSTERED INDEX [IX_tblQMSample_strContainerNumber] ON [dbo].[tblQMSample](strContainerNumber)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMSample_intRelatedSampleId] ON [dbo].[tblQMSample](intRelatedSampleId)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMSample_intCuppingSessionDetailId] ON [dbo].[tblQMSample](intCuppingSessionDetailId)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMSample_strBatchNo] ON [dbo].[tblQMSample](strBatchNo)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMSample_intMarketZoneId] ON [dbo].[tblQMSample](intMarketZoneId)
GO