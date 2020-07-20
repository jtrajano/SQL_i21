CREATE TABLE [dbo].[tblCTContractDetail]
(
	intContractDetailId int IDENTITY(1,1) NOT NULL,
	intSplitFromId int,
	intParentDetailId int,
	ysnSlice BIT,
	intConcurrencyId int NOT NULL,
	intContractHeaderId int NOT NULL,
	intContractStatusId int NULL,
	strFinancialStatus nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
	intContractSeq int NOT NULL,
	intCompanyLocationId int NOT NULL,
	intShipToId INT,
	dtmStartDate datetime NOT NULL,
	dtmEndDate datetime NOT NULL,
	intFreightTermId int NULL,
	intShipViaId int NULL,	
	intItemContractId INT NULL,
	intItemBundleId INT NULL,
	intItemId int NULL,
	strItemSpecification nvarchar(MAX) COLLATE Latin1_General_CI_AS NULL,
	intCategoryId INT NULL,
	dblQuantity numeric(18, 6) NOT NULL,
	intItemUOMId int NULL,	
	dblOriginalQty NUMERIC(18, 6) NULL, 
    dblBalance NUMERIC(18, 6) NULL, 
    dblIntransitQty NUMERIC(18, 6) NULL, 
    dblScheduleQty NUMERIC(18, 6) NULL, 
	dblBalanceLoad	NUMERIC(18, 6) NULL, 
	dblScheduleLoad	NUMERIC(18, 6) NULL, 
    dblShippingInstructionQty NUMERIC(18, 6) NULL, 
	dblNetWeight NUMERIC(18, 6) NULL, 
	intNetWeightUOMId int NULL,	
	intUnitMeasureId int NULL,
	intCategoryUOMId INT NULL, 	
	intNoOfLoad INT NULL, 
	dblQuantityPerLoad NUMERIC(18, 6) NULL,     
	intIndexId INT NULL, 
	dblAdjustment NUMERIC(18, 6) NULL, 
	intAdjItemUOMId int NULL,    
	intPricingTypeId int NULL,
	intFutureMarketId int NULL,
	intFutureMonthId INT NULL,
	dblFutures numeric(18, 6) NULL,
	dblBasis numeric(18, 6) NULL,	
	dblOriginalBasis numeric(18, 6) NULL,
	dblConvertedBasis numeric(18, 6) NULL,
	intBasisCurrencyId INT,
	intBasisUOMId INT,
	dblFreightBasisBase numeric(18, 6) NULL,
	intFreightBasisBaseUOMId INT,
	dblFreightBasis numeric(18, 6) NULL,
	intFreightBasisUOMId INT,
	dblRatio NUMERIC(18,6),
	dblCashPrice numeric(18, 6) NULL,
	dblTotalCost numeric(18, 6) NULL,
	intCurrencyId int NULL,
	intPriceItemUOMId  INT NULL, 
	dblNoOfLots NUMERIC(18, 6) NULL,
	dtmLCDate DATETIME,
	dtmLastPricingDate DATETIME,
	dblConvertedPrice  NUMERIC(18, 6) NULL,
	intConvPriceCurrencyId INT,
	intConvPriceUOMId INT,	
	intMarketZoneId int NULL,
	intDiscountTypeId int NULL ,
	intDiscountId int NULL,
	intDiscountScheduleId int NULL,
	intDiscountScheduleCodeId int NULL,
	intStorageScheduleRuleId int NULL,
	intContractOptHeaderId int NULL,
	strBuyerSeller nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	intBillTo int NULL,
	intFreightRateId int NULL,
	strFobBasis nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	intRailGradeId int NULL,
	strRailRemark nvarchar(250) COLLATE Latin1_General_CI_AS NULL,
	strLoadingPointType nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    intLoadingPortId INT NULL, 
	strDestinationPointType nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    intDestinationPortId INT NULL, 
    strShippingTerm NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL, 
    intShippingLineId INT NULL, 
	strVessel NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL, 
    intDestinationCityId INT NULL, 
    intShipperId INT NULL, 
	strRemark NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	intSubLocationId INT,
	intStorageLocationId INT,
	intPurchasingGroupId INT,
	intFarmFieldId INT NULL,
	intSplitId INT NULL,
	strGrade NVARCHAR(128) COLLATE Latin1_General_CI_AS NULL,
	strGarden NVARCHAR(128) COLLATE Latin1_General_CI_AS NULL,
	strVendorLotID NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strInvoiceNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strReference NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strERPPONumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strERPItemNumber	NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	strERPBatchNumber	NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	intUnitsPerLayer INT NULL,
	intLayersPerPallet INT NULL,
	dtmEventStartDate datetime NULL,
	dtmPlannedAvailabilityDate datetime NULL,
	dtmUpdatedAvailabilityDate  datetime NULL,
	dtmM2MDate  datetime NULL,
	intBookId INT NULL,
	intSubBookId INT NULL,
	intContainerTypeId INT NULL,
	intNumberOfContainers INT NULL,
	intInvoiceCurrencyId int NULL,
	dtmFXValidFrom  datetime NULL,
	dtmFXValidTo  datetime NULL,
	dblRate numeric(18, 6) NULL,
	dblFXPrice numeric(18, 6) NULL,
	ysnUseFXPrice BIT,
	intFXPriceUOMId int NULL,
	strFXRemarks NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	dblAssumedFX numeric(18, 6) NULL,
	strFixationBy NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strPackingDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblYield NUMERIC(18, 6) NULL, 
	intCurrencyExchangeRateId INT NULL,
	intRateTypeId INT NULL,
    intCreatedById INT,
	dtmCreated DATETIME,
	intLastModifiedById INT,
	dtmLastModified DATETIME,
	ysnInvoice BIT NULL DEFAULT 0, 
	ysnProvisionalInvoice BIT NULL DEFAULT 0, 
	ysnQuantityFinal BIT NULL DEFAULT 0, 
	intProducerId INT NULL,
	ysnClaimsToProducer BIT,
	ysnRiskToProducer BIT,
	ysnBackToBack BIT,
    dblAllocatedQty NUMERIC(18, 6) NULL, 
    dblReservedQty NUMERIC(18, 6) NULL, 
    dblAllocationAdjQty NUMERIC(18, 6) NULL, 
    dblInvoicedQty NUMERIC(18, 6) NULL, 
	ysnPriceChanged BIT,
	intContractDetailRefId INT,
	ysnStockSale BIT,
	strCertifications NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    ysnSplit BIT,
    ysnProvisionalPNL BIT NOT NULL DEFAULT 0, 
    ysnFinalPNL BIT NOT NULL DEFAULT 0, 
    dtmProvisionalPNL DATETIME NULL,
    dtmFinalPNL DATETIME NULL,
	intPricingStatus INT,

    CONSTRAINT [PK_tblCTContractDetail_intContractDetailId] PRIMARY KEY CLUSTERED ([intContractDetailId] ASC),
	CONSTRAINT [UQ_tblCTContractDetail_intContractHeaderId_intContractSeq] UNIQUE ([intContractHeaderId],[intContractSeq]), 

	
	CONSTRAINT [FK_tblCTContractDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractDetail_tblCTContractDetail_intParentDetailId_intContractDetailId] FOREIGN KEY (intParentDetailId) REFERENCES tblCTContractDetail(intContractDetailId),

	CONSTRAINT [FK_tblCTContractDetail_tblARMarketZone_intMarketZoneId] FOREIGN KEY ([intMarketZoneId]) REFERENCES [tblARMarketZone]([intMarketZoneId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTContractStatus_intContractStatusId] FOREIGN KEY ([intContractStatusId]) REFERENCES [tblCTContractStatus]([intContractStatusId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTContractOptHeader_intContractOptHeaderId] FOREIGN KEY ([intContractOptHeaderId]) REFERENCES [tblCTContractOptHeader]([intContractOptHeaderId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTFreightRate_intFreightRateId] FOREIGN KEY ([intFreightRateId]) REFERENCES [tblCTFreightRate]([intFreightRateId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTPricingType_intPricingTypeId] FOREIGN KEY ([intPricingTypeId]) REFERENCES [tblCTPricingType]([intPricingTypeId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTRailGrade_intRailGradeId] FOREIGN KEY ([intRailGradeId]) REFERENCES [tblCTRailGrade]([intRailGradeId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemContract_intItemContractId] FOREIGN KEY ([intItemContractId]) REFERENCES [tblICItemContract]([intItemContractId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCurrency_intBasisCurrencyId_intCurrencyId] FOREIGN KEY (intBasisCurrencyId) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCurrency_intConvPriceCurrencyId_intCurrencyId] FOREIGN KEY (intConvPriceCurrencyId) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMFreightTerms_intFreightTermId] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]),
	CONSTRAINT [FK_tblCTContractDetail_tblEMEntity_intShipViaId_intEntityId] FOREIGN KEY ([intShipViaId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblCTContractDetail_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblCTContractDetail_tblEMEntity_intEntityId_intVendorId] FOREIGN KEY ([intBillTo]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblCTContractDetail_tblGRDiscountId_intDiscountId] FOREIGN KEY ([intDiscountId]) REFERENCES [tblGRDiscountId]([intDiscountId]),
	CONSTRAINT [FK_tblCTContractDetail_tblGRDiscountSchedule_intDiscountScheduleId] FOREIGN KEY ([intDiscountScheduleId]) REFERENCES [tblGRDiscountSchedule]([intDiscountScheduleId]),
	CONSTRAINT [FK_tblCTContractDetail_tblGRDiscountScheduleCode_intDiscountScheduleCodeId] FOREIGN KEY ([intDiscountScheduleCodeId]) REFERENCES [tblGRDiscountScheduleCode]([intDiscountScheduleCodeId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTDiscount_intDiscountTypeId] FOREIGN KEY ([intDiscountTypeId]) REFERENCES [tblCTDiscountType]([intDiscountTypeId]),
	CONSTRAINT [FK_tblCTContractDetail_tblGRStorageScheduleRule_intStorageScheduleRuleId] FOREIGN KEY ([intStorageScheduleRuleId]) REFERENCES [tblGRStorageScheduleRule]([intStorageScheduleRuleId]),

	CONSTRAINT [FK_tblCTContractDetail_tblSMCity_intLoadingPortId_intCityId] FOREIGN KEY ([intLoadingPortId]) REFERENCES [tblSMCity]([intCityId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCity_intDestinationPortId_intCityId] FOREIGN KEY ([intDestinationPortId]) REFERENCES [tblSMCity]([intCityId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCity_intDestinationCityId_intCityId] FOREIGN KEY ([intDestinationCityId]) REFERENCES [tblSMCity]([intCityId]),
	CONSTRAINT [FK_tblCTContractDetail_tblEMEntity_intShippingLineId_intEntityId] FOREIGN KEY ([intShippingLineId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblCTContractDetail_tblEMEntity_intShipperId_intEntityId] FOREIGN KEY ([intShipperId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblCTContractDetail_tblEMEntity_intProducerId_intEntityId] FOREIGN KEY (intProducerId) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblCTContractDetail_tblEMEntityLocation_intShipToId] FOREIGN KEY (intShipToId) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
	CONSTRAINT [FK_tblCTContractDetail_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),

	CONSTRAINT [FK_tblCTContractDetail_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId]),

	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intPriceItemUOMId_intItemUOMId] FOREIGN KEY ([intPriceItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intAdjItemUOMId_intItemUOMId] FOREIGN KEY ([intAdjItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intNetWeightUOMId_intItemUOMId] FOREIGN KEY ([intNetWeightUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intFXPriceUOMId_intItemUOMId] FOREIGN KEY (intFXPriceUOMId) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intBasisUOMId_intItemUOMId] FOREIGN KEY (intBasisUOMId) REFERENCES [tblICItemUOM]([intItemUOMId]),

	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intFreightBasisBaseUOMId_intItemUOMId] FOREIGN KEY (intFreightBasisBaseUOMId) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intFreightBasisUOMId_intItemUOMId] FOREIGN KEY (intFreightBasisUOMId) REFERENCES [tblICItemUOM]([intItemUOMId]),

	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intConvPriceUOMId_intItemUOMId] FOREIGN KEY (intConvPriceUOMId) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICCategoryUOM_intCategoryUOMId] FOREIGN KEY([intCategoryUOMId])REFERENCES [tblICCategoryUOM] ([intCategoryUOMId]),
	
	CONSTRAINT [FK_tblCTContractDetail_tblSMCurrency_intInvoiceCurrencyId_intCurrencyId] FOREIGN KEY ([intInvoiceCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTContractDetail_tblLGContainerType_intContainerTypeId] FOREIGN KEY ([intContainerTypeId]) REFERENCES [tblLGContainerType]([intContainerTypeId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICCategory_intCategoryId] FOREIGN KEY([intCategoryId])REFERENCES [tblICCategory] ([intCategoryId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTIndex_intIndexId] FOREIGN KEY ([intIndexId]) REFERENCES [tblCTIndex]([intIndexId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCurrencyExchangeRate_intCurrencyExchangeRateId] FOREIGN KEY ([intCurrencyExchangeRateId]) REFERENCES [tblSMCurrencyExchangeRate]([intCurrencyExchangeRateId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCurrencyExchangeRateType_intRateTypeId_intCurrencyExchangeRateId] FOREIGN KEY (intRateTypeId) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	--CONSTRAINT [FK_tblCTContractDetail_tblEMEntityFarm_intFarmFieldId] FOREIGN KEY ([intFarmFieldId]) REFERENCES [tblEMEntityFarm]([intFarmFieldId]),
	CONSTRAINT [FK_tblCTContractDetail_tblEMEntitySplit_intSplitId] FOREIGN KEY ([intSplitId]) REFERENCES [tblEMEntitySplit]([intSplitId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMPurchasingGroup_intPurchasingGroupId] FOREIGN KEY ([intPurchasingGroupId]) REFERENCES [tblSMPurchasingGroup]([intPurchasingGroupId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId_intSubLocationId] FOREIGN KEY (intSubLocationId) REFERENCES tblSMCompanyLocationSubLocation(intCompanyLocationSubLocationId),
	CONSTRAINT [FK_tblCTContractDetail_tblICStorageLocation_intStorageLocationId] FOREIGN KEY (intStorageLocationId) REFERENCES tblICStorageLocation(intStorageLocationId)
) 

GO

	CREATE NONCLUSTERED INDEX [IX_tblCTContractDetail_intContractHeaderId] 
	ON [dbo].[tblCTContractDetail](intContractHeaderId)
	INCLUDE (
		intContractDetailId
		,intCompanyLocationId
		,intItemId
		,intItemUOMId
		,intLoadingPortId
		,intDestinationPortId
		,intDestinationCityId
		,intContractStatusId
		,intContractSeq
		,dtmStartDate
		,dtmEndDate
		,dblQuantity
		,dblBalance
		,intUnitMeasureId
		,intNoOfLoad
		,dblQuantityPerLoad
		,intShippingLineId
		,strVessel
		,intContainerTypeId
		,intNumberOfContainers
		,strPackingDescription
		,intStorageScheduleRuleId
	);
GO
--CREATE NONCLUSTERED INDEX [_dta_index_tblCTContractDetail_11] ON [dbo].[tblCTContractDetail]
--(
--	[intContractHeaderId] ASC,
--	[intContractDetailId] ASC,
--	[intCompanyLocationId] ASC,
--	[intItemId] ASC,
--	[intItemUOMId] ASC,
--	[intLoadingPortId] ASC,
--	[intDestinationPortId] ASC,
--	[intDestinationCityId] ASC
--)
--INCLUDE ( 	[intContractStatusId],
--	[intContractSeq],
--	[dtmStartDate],
--	[dtmEndDate],
--	[dblQuantity],
--	[dblBalance],
--	[intUnitMeasureId],
--	[intNoOfLoad],
--	[dblQuantityPerLoad],
--	[intShippingLineId],
--	[strVessel],
--	[intContainerTypeId],
--	[intNumberOfContainers],
--	[strPackingDescription]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--GO

--[intStorageScheduleRuleId]

--	CREATE NONCLUSTERED INDEX [IX_tblCTContractDetail_intStorageScheduleRuleId] 
--	ON [dbo].[tblCTContractDetail](intStorageScheduleRuleId)
--	INCLUDE (intContractHeaderId, intContractDetailId);
--GO


--CREATE NONCLUSTERED INDEX [_dta_index_tblCTContractDetail_11] ON [dbo].[tblCTContractDetail]
--(
--	[intContractHeaderId] ASC,
--	[intContractDetailId] ASC,
--	[intCompanyLocationId] ASC,
--	[intItemId] ASC,
--	[intItemUOMId] ASC,
--	[intLoadingPortId] ASC,
--	[intDestinationPortId] ASC,
--	[intDestinationCityId] ASC
--)
--INCLUDE ( 	[intContractStatusId],
--	[intContractSeq],
--	[dtmStartDate],
--	[dtmEndDate],
--	[dblQuantity],
--	[dblBalance],
--	[intUnitMeasureId],
--	[intNoOfLoad],
--	[dblQuantityPerLoad],
--	[intShippingLineId],
--	[strVessel],
--	[intContainerTypeId],
--	[intNumberOfContainers],
--	[strPackingDescription]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--GO


CREATE NONCLUSTERED INDEX [IX_tblCTContractDetail_intContractHeaderId_intContractHeaderId] ON [dbo].[tblCTContractDetail](intContractHeaderId);
GO
CREATE STATISTICS [_dta_stat_2133894969_13_1] ON [dbo].[tblCTContractDetail]([intItemId], [intContractDetailId])
GO

CREATE STATISTICS [_dta_stat_2133894969_7_1_13_4] ON [dbo].[tblCTContractDetail]([intCompanyLocationId], [intContractDetailId], [intItemId], [intContractHeaderId])
GO

CREATE STATISTICS [_dta_stat_2133894969_55_57_61_1_7_13_4] ON [dbo].[tblCTContractDetail]([intLoadingPortId], [intDestinationPortId], [intDestinationCityId], [intContractDetailId], [intCompanyLocationId], [intItemId], [intContractHeaderId])
GO

CREATE STATISTICS [_dta_stat_2133894969_16_1_7_13_4_55_57_61] ON [dbo].[tblCTContractDetail]([intItemUOMId], [intContractDetailId], [intCompanyLocationId], [intItemId], [intContractHeaderId], [intLoadingPortId], [intDestinationPortId], [intDestinationCityId])
GO

CREATE STATISTICS [_dta_stat_2133894969_4_5] ON [dbo].[tblCTContractDetail]([intContractHeaderId], [intContractStatusId])
GO

CREATE STATISTICS [_dta_stat_2133894969_38_1_4] ON [dbo].[tblCTContractDetail]([intCurrencyId], [intContractDetailId], [intContractHeaderId])
GO

CREATE STATISTICS [_dta_stat_2133894969_13_5_1] ON [dbo].[tblCTContractDetail]([intItemId], [intContractStatusId], [intContractDetailId])
GO

CREATE STATISTICS [_dta_stat_2133894969_30_1_4_38] ON [dbo].[tblCTContractDetail]([intPricingTypeId], [intContractDetailId], [intContractHeaderId], [intCurrencyId])
GO

CREATE STATISTICS [_dta_stat_2133894969_39_1_4_30_38] ON [dbo].[tblCTContractDetail]([intPriceItemUOMId], [intContractDetailId], [intContractHeaderId], [intPricingTypeId], [intCurrencyId])
GO

CREATE STATISTICS [_dta_stat_2133894969_5_1_4_30_38] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intContractDetailId], [intContractHeaderId], [intPricingTypeId], [intCurrencyId])
GO

CREATE STATISTICS [_dta_stat_2133894969_22_21_4_13_5] ON [dbo].[tblCTContractDetail]([intNetWeightUOMId], [dblNetWeight], [intContractHeaderId], [intItemId], [intContractStatusId])
GO

CREATE STATISTICS [_dta_stat_2133894969_13_22_21_9_5_4] ON [dbo].[tblCTContractDetail]([intItemId], [intNetWeightUOMId], [dblNetWeight], [dtmEndDate], [intContractStatusId], [intContractHeaderId])
GO

CREATE STATISTICS [_dta_stat_2133894969_16_13_1_4_30_38] ON [dbo].[tblCTContractDetail]([intItemUOMId], [intItemId], [intContractDetailId], [intContractHeaderId], [intPricingTypeId], [intCurrencyId])
GO

CREATE STATISTICS [_dta_stat_2133894969_5_13_4_1_30_38_39] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intItemId], [intContractHeaderId], [intContractDetailId], [intPricingTypeId], [intCurrencyId], [intPriceItemUOMId])
GO

CREATE STATISTICS [_dta_stat_2133894969_1_30_38_39_22_21_4_13_5] ON [dbo].[tblCTContractDetail]([intContractDetailId], [intPricingTypeId], [intCurrencyId], [intPriceItemUOMId], [intNetWeightUOMId], [dblNetWeight], [intContractHeaderId], [intItemId], [intContractStatusId])
GO

CREATE STATISTICS [_dta_stat_2133894969_13_9_30_38_39_22_21_4_5] ON [dbo].[tblCTContractDetail]([intItemId], [dtmEndDate], [intPricingTypeId], [intCurrencyId], [intPriceItemUOMId], [intNetWeightUOMId], [dblNetWeight], [intContractHeaderId], [intContractStatusId])
GO

CREATE STATISTICS [_dta_stat_2133894969_4_13_1_30_38_39_16_5_22_21] ON [dbo].[tblCTContractDetail]([intContractHeaderId], [intItemId], [intContractDetailId], [intPricingTypeId], [intCurrencyId], [intPriceItemUOMId], [intItemUOMId], [intContractStatusId], [intNetWeightUOMId], [dblNetWeight])
GO

CREATE STATISTICS [_dta_stat_2133894969_1_4_13_16_9_30_38_39_22_21_5] ON [dbo].[tblCTContractDetail]([intContractDetailId], [intContractHeaderId], [intItemId], [intItemUOMId], [dtmEndDate], [intPricingTypeId], [intCurrencyId], [intPriceItemUOMId], [intNetWeightUOMId], [dblNetWeight], [intContractStatusId])
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblCTContractDetail_197_1518224759__K45_K7_K36_K35_K6_K19_K46_K15_K34_K9_K1_8_10_11_18_21_37_40_43_47_53_92_101] ON [dbo].[tblCTContractDetail]
(
       [intCurrencyId] ASC,
       [intContractStatusId] ASC,
       [intFutureMonthId] ASC,
       [intFutureMarketId] ASC,
       [intContractHeaderId] ASC,
       [intItemUOMId] ASC,
       [intPriceItemUOMId] ASC,
       [intItemId] ASC,
       [intPricingTypeId] ASC,
       [intCompanyLocationId] ASC,
       [intContractDetailId] ASC
)
INCLUDE (     [intContractSeq],
       [dtmStartDate],
       [dtmEndDate],
       [dblQuantity],
       [dblBalance],
       [dblFutures],
       [dblConvertedBasis],
       [dblCashPrice],
       [dblNoOfLots],
       [intMarketZoneId],
       [dtmPlannedAvailabilityDate],
       [dblRate]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_1518224759_19_46] ON [dbo].[tblCTContractDetail]([intItemUOMId], [intPriceItemUOMId])
go

CREATE STATISTICS [_dta_stat_1518224759_6_7_36] ON [dbo].[tblCTContractDetail]([intContractHeaderId], [intContractStatusId], [intFutureMonthId])
go

CREATE STATISTICS [_dta_stat_1518224759_7_6_19] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intContractHeaderId], [intItemUOMId])
go

CREATE STATISTICS [_dta_stat_1518224759_7_19_46_36_35] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intItemUOMId], [intPriceItemUOMId], [intFutureMonthId], [intFutureMarketId])
go

CREATE STATISTICS [_dta_stat_1518224759_6_19_46_7_36] ON [dbo].[tblCTContractDetail]([intContractHeaderId], [intItemUOMId], [intPriceItemUOMId], [intContractStatusId], [intFutureMonthId])
go

CREATE STATISTICS [_dta_stat_1518224759_15_7_36_35_6_19] ON [dbo].[tblCTContractDetail]([intItemId], [intContractStatusId], [intFutureMonthId], [intFutureMarketId], [intContractHeaderId], [intItemUOMId])
go

CREATE STATISTICS [_dta_stat_1518224759_34_7_36_35_6_19_46] ON [dbo].[tblCTContractDetail]([intPricingTypeId], [intContractStatusId], [intFutureMonthId], [intFutureMarketId], [intContractHeaderId], [intItemUOMId], [intPriceItemUOMId])
go

CREATE STATISTICS [_dta_stat_1518224759_7_9_36_35_6_19_46_15] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intCompanyLocationId], [intFutureMonthId], [intFutureMarketId], [intContractHeaderId], [intItemUOMId], [intPriceItemUOMId], [intItemId])
go

CREATE STATISTICS [_dta_stat_1518224759_7_45_36_35_6_19_46_15_34] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intCurrencyId], [intFutureMonthId], [intFutureMarketId], [intContractHeaderId], [intItemUOMId], [intPriceItemUOMId], [intItemId], [intPricingTypeId])
go

CREATE STATISTICS [_dta_stat_1518224759_35_7_36_6_19_46_15_34_9_45] ON [dbo].[tblCTContractDetail]([intFutureMarketId], [intContractStatusId], [intFutureMonthId], [intContractHeaderId], [intItemUOMId], [intPriceItemUOMId], [intItemId], [intPricingTypeId], [intCompanyLocationId], [intCurrencyId])
go

CREATE STATISTICS [_dta_stat_1518224759_36_35_6_19_46_15_34_9_45_1] ON [dbo].[tblCTContractDetail]([intFutureMonthId], [intFutureMarketId], [intContractHeaderId], [intItemUOMId], [intPriceItemUOMId], [intItemId], [intPricingTypeId], [intCompanyLocationId], [intCurrencyId], [intContractDetailId])
go

CREATE STATISTICS [_dta_stat_1518224759_7_1_36_35_6_19_46_15_34_9_45] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intContractDetailId], [intFutureMonthId], [intFutureMarketId], [intContractHeaderId], [intItemUOMId], [intPriceItemUOMId], [intItemId], [intPricingTypeId], [intCompanyLocationId], [intCurrencyId])
go

CREATE STATISTICS [_dta_stat_1518224759_6_18_7] ON [dbo].[tblCTContractDetail]([intContractHeaderId], [dblQuantity], [intContractStatusId])
go

CREATE STATISTICS [_dta_stat_1518224759_34_18_7] ON [dbo].[tblCTContractDetail]([intPricingTypeId], [dblQuantity], [intContractStatusId])
go

CREATE STATISTICS [_dta_stat_1518224759_45_18_7] ON [dbo].[tblCTContractDetail]([intCurrencyId], [dblQuantity], [intContractStatusId])
go

CREATE STATISTICS [_dta_stat_1518224759_15_18_7] ON [dbo].[tblCTContractDetail]([intItemId], [dblQuantity], [intContractStatusId])
go

CREATE STATISTICS [_dta_stat_1518224759_18_7_124_1] ON [dbo].[tblCTContractDetail]([dblQuantity], [intContractStatusId], [dblInvoicedQty], [intContractDetailId])
go

CREATE STATISTICS [_dta_stat_1518224759_18_7_124_46] ON [dbo].[tblCTContractDetail]([dblQuantity], [intContractStatusId], [dblInvoicedQty], [intPriceItemUOMId])
go

CREATE STATISTICS [_dta_stat_1518224759_1_6_18_7] ON [dbo].[tblCTContractDetail]([intContractDetailId], [intContractHeaderId], [dblQuantity], [intContractStatusId])
go

CREATE STATISTICS [_dta_stat_1518224759_18_7_124_45_1] ON [dbo].[tblCTContractDetail]([dblQuantity], [intContractStatusId], [dblInvoicedQty], [intCurrencyId], [intContractDetailId])
go

CREATE STATISTICS [_dta_stat_1518224759_18_7_124_34_1_36] ON [dbo].[tblCTContractDetail]([dblQuantity], [intContractStatusId], [dblInvoicedQty], [intPricingTypeId], [intContractDetailId], [intFutureMonthId])
go

CREATE STATISTICS [_dta_stat_1518224759_36_18_7_124_1_45_34] ON [dbo].[tblCTContractDetail]([intFutureMonthId], [dblQuantity], [intContractStatusId], [dblInvoicedQty], [intContractDetailId], [intCurrencyId], [intPricingTypeId])
go

CREATE STATISTICS [_dta_stat_1518224759_7_1_36_45_34_35_9_18] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intContractDetailId], [intFutureMonthId], [intCurrencyId], [intPricingTypeId], [intFutureMarketId], [intCompanyLocationId], [dblQuantity])
go

CREATE STATISTICS [_dta_stat_1518224759_9_18_7_124_1_36_45_34] ON [dbo].[tblCTContractDetail]([intCompanyLocationId], [dblQuantity], [intContractStatusId], [dblInvoicedQty], [intContractDetailId], [intFutureMonthId], [intCurrencyId], [intPricingTypeId])
go

CREATE STATISTICS [_dta_stat_1518224759_124_1_36_45_34_35_9_7] ON [dbo].[tblCTContractDetail]([dblInvoicedQty], [intContractDetailId], [intFutureMonthId], [intCurrencyId], [intPricingTypeId], [intFutureMarketId], [intCompanyLocationId], [intContractStatusId])
go

CREATE STATISTICS [_dta_stat_1518224759_18_7_124_15_1_36_45_34_35] ON [dbo].[tblCTContractDetail]([dblQuantity], [intContractStatusId], [dblInvoicedQty], [intItemId], [intContractDetailId], [intFutureMonthId], [intCurrencyId], [intPricingTypeId], [intFutureMarketId])
go

CREATE STATISTICS [_dta_stat_1518224759_18_7_124_6_1_36_45_34_35_9] ON [dbo].[tblCTContractDetail]([dblQuantity], [intContractStatusId], [dblInvoicedQty], [intContractHeaderId], [intContractDetailId], [intFutureMonthId], [intCurrencyId], [intPricingTypeId], [intFutureMarketId], [intCompanyLocationId])
go

CREATE STATISTICS [_dta_stat_1518224759_46_19_18_7_124_1_36_45_34_35_9_15] ON [dbo].[tblCTContractDetail]([intPriceItemUOMId], [intItemUOMId], [dblQuantity], [intContractStatusId], [dblInvoicedQty], [intContractDetailId], [intFutureMonthId], [intCurrencyId], [intPricingTypeId], [intFutureMarketId], [intCompanyLocationId], [intItemId])
go

CREATE STATISTICS [_dta_stat_1518224759_1_36_45_34_35_9_18_124_15_6_46_19] ON [dbo].[tblCTContractDetail]([intContractDetailId], [intFutureMonthId], [intCurrencyId], [intPricingTypeId], [intFutureMarketId], [intCompanyLocationId], [dblQuantity], [dblInvoicedQty], [intItemId], [intContractHeaderId], [intPriceItemUOMId], [intItemUOMId])
go

CREATE STATISTICS [_dta_stat_1518224759_35_18_7_124_1_36_45_34_9_15_6_46_19] ON [dbo].[tblCTContractDetail]([intFutureMarketId], [dblQuantity], [intContractStatusId], [dblInvoicedQty], [intContractDetailId], [intFutureMonthId], [intCurrencyId], [intPricingTypeId], [intCompanyLocationId], [intItemId], [intContractHeaderId], [intPriceItemUOMId], [intItemUOMId])
go

CREATE NONCLUSTERED INDEX [_dta_index_tblCTContractDetail_197_1518224759__K35_K1_K36_K15_K19_K6_K34_K7_8_9_10_18_21_47] ON [dbo].[tblCTContractDetail]
(
	[intFutureMarketId] ASC,
	[intContractDetailId] ASC,
	[intFutureMonthId] ASC,
	[intItemId] ASC,
	[intItemUOMId] ASC,
	[intContractHeaderId] ASC,
	[intPricingTypeId] ASC,
	[intContractStatusId] ASC
)
INCLUDE ( 	[intContractSeq],
	[intCompanyLocationId],
	[dtmStartDate],
	[dblQuantity],
	[dblBalance],
	[dblNoOfLots]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_1518224759_19_15_35_1_34] ON [dbo].[tblCTContractDetail]([intItemUOMId], [intItemId], [intFutureMarketId], [intContractDetailId], [intPricingTypeId])
go

CREATE STATISTICS [_dta_stat_1518224759_36_15_19_6_1] ON [dbo].[tblCTContractDetail]([intFutureMonthId], [intItemId], [intItemUOMId], [intContractHeaderId], [intContractDetailId])
go

CREATE STATISTICS [_dta_stat_1518224759_6_15_35_1_34] ON [dbo].[tblCTContractDetail]([intContractHeaderId], [intItemId], [intFutureMarketId], [intContractDetailId], [intPricingTypeId])
go

CREATE STATISTICS [_dta_stat_1518224759_36_15_35_1_34] ON [dbo].[tblCTContractDetail]([intFutureMonthId], [intItemId], [intFutureMarketId], [intContractDetailId], [intPricingTypeId])
go

CREATE STATISTICS [_dta_stat_1518224759_15_35_1_34_7_19] ON [dbo].[tblCTContractDetail]([intItemId], [intFutureMarketId], [intContractDetailId], [intPricingTypeId], [intContractStatusId], [intItemUOMId])
go

CREATE STATISTICS [_dta_stat_1518224759_7_1_36_15_19_6_35] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intContractDetailId], [intFutureMonthId], [intItemId], [intItemUOMId], [intContractHeaderId], [intFutureMarketId])
go

CREATE STATISTICS [_dta_stat_1518224759_34_1_36_15_19_6_35] ON [dbo].[tblCTContractDetail]([intPricingTypeId], [intContractDetailId], [intFutureMonthId], [intItemId], [intItemUOMId], [intContractHeaderId], [intFutureMarketId])
go

CREATE STATISTICS [_dta_stat_1518224759_15_35_1_34_7_6_36] ON [dbo].[tblCTContractDetail]([intItemId], [intFutureMarketId], [intContractDetailId], [intPricingTypeId], [intContractStatusId], [intContractHeaderId], [intFutureMonthId])
go

CREATE STATISTICS [_dta_stat_1518224759_1_15_35_34_7_36_19_6] ON [dbo].[tblCTContractDetail]([intContractDetailId], [intItemId], [intFutureMarketId], [intPricingTypeId], [intContractStatusId], [intFutureMonthId], [intItemUOMId], [intContractHeaderId])
go

CREATE STATISTICS [_dta_stat_1518224759_36_1] ON [dbo].[tblCTContractDetail]([intFutureMonthId], [intContractDetailId])
go

CREATE STATISTICS [_dta_stat_1518224759_35_1_7] ON [dbo].[tblCTContractDetail]([intFutureMarketId], [intContractDetailId], [intContractStatusId])
go

CREATE STATISTICS [_dta_stat_1518224759_19_1_7_36] ON [dbo].[tblCTContractDetail]([intItemUOMId], [intContractDetailId], [intContractStatusId], [intFutureMonthId])
go

CREATE STATISTICS [_dta_stat_1518224759_36_35_19_6_1] ON [dbo].[tblCTContractDetail]([intFutureMonthId], [intFutureMarketId], [intItemUOMId], [intContractHeaderId], [intContractDetailId])
go

CREATE STATISTICS [_dta_stat_1518224759_7_36_1_35_19] ON [dbo].[tblCTContractDetail]([intContractStatusId], [intFutureMonthId], [intContractDetailId], [intFutureMarketId], [intItemUOMId])
go

CREATE STATISTICS [_dta_stat_1518224759_1_7_6_36_35_19] ON [dbo].[tblCTContractDetail]([intContractDetailId], [intContractStatusId], [intContractHeaderId], [intFutureMonthId], [intFutureMarketId], [intItemUOMId])
go


CREATE NONCLUSTERED INDEX [_dta_index_tblCTContractDetail_197_1518224759__K1_K7_K19_K36_K35_K6_8_9_10_15_18_21_34_47] ON [dbo].[tblCTContractDetail]
(
	[intContractDetailId] ASC,
	[intContractStatusId] ASC,
	[intItemUOMId] ASC,
	[intFutureMonthId] ASC,
	[intFutureMarketId] ASC,
	[intContractHeaderId] ASC
)
INCLUDE ( 	[intContractSeq],
	[intCompanyLocationId],
	[dtmStartDate],
	[intItemId],
	[dblQuantity],
	[dblBalance],
	[intPricingTypeId],
	[dblNoOfLots]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [IX_tblCTContractDetail_intSplitFromId] 
ON [dbo].[tblCTContractDetail](intSplitFromId);
GO

CREATE TRIGGER [dbo].[trgCTContractDetail]
    ON [dbo].[tblCTContractDetail]
    FOR INSERT,UPDATE
    AS

	declare @intActiveContractDetailId int = 0;
	declare @intPricingTypeId int = 0;
	declare @dblSequenceQuantity numeric(18,6) = 0.00;
	declare @intPricingStatus int = 0;
	declare @dblPricedQuantity numeric(18,6) = 0.00;
	
	declare @intActiveId int = 0;
	declare @dblCommulativeAppliedAndPrice numeric(18,6) = 0;
	declare @dblActivelAppliedQuantity numeric(18,6);
	declare @dblRemainingAppliedQuantity numeric(18,6) = 0;
	declare @ysnLoad bit;
	declare @ErrMsg nvarchar(max);

	begin try

		select @intActiveContractDetailId = i.intContractDetailId, @intPricingTypeId = i.intPricingTypeId, @dblSequenceQuantity = i.dblQuantity from inserted i;

		if (@intPricingTypeId = 1)
		begin
			set @intPricingStatus = 2;
		end
		else
		begin
			select @dblPricedQuantity = isnull(sum(pfd.dblQuantity),0.00) from tblCTPriceFixation pf, tblCTPriceFixationDetail pfd where pf.intContractDetailId = @intActiveContractDetailId and pfd.intPriceFixationId = pf.intPriceFixationId
			
			if (@dblPricedQuantity = 0)
			begin
				set @intPricingStatus = 0;
			end
			else
			begin
				if (@dblSequenceQuantity > @dblPricedQuantity)
				begin
					set @intPricingStatus = 1;
				end
				else
				begin
					set @intPricingStatus = 2;
				end
			end
		end

		update tblCTContractDetail set intPricingStatus = @intPricingStatus where intContractDetailId = @intActiveContractDetailId;


		declare @Pricing table (
			intId int
			,intContractHeaderId int
			,ysnLoad bit
			,intContractDetailId int
			,dblSequenceQuantity numeric(18,6)
			,dblBalance numeric(18,6)
			,dblAppliedQuantity numeric(18,6)
			,intNoOfLoad int null
			,dblBalanceLoad numeric(18,6)
			,dblAppliedLoad numeric(18,6)
			,intPriceFixationId int
			,intPriceFixationDetailId int
			,intPricingNumber int
			,intNumber int
			,dblPricedQuantity numeric(18,6)
			,dblQuantityAppliedAndPriced numeric(18,6)
			,dblLoadPriced numeric(18,6)
			,dblLoadAppliedAndPriced numeric(18,6)
			,dblCorrectAppliedAndPriced numeric(18,6) null
		)

		insert into @Pricing
		select
			intId = convert(int,ROW_NUMBER() over (order by pfd.intPriceFixationDetailId))
			,ch.intContractHeaderId
			,ch.ysnLoad
			,cd.intContractDetailId
			,dblSequenceQuantity = cd.dblQuantity
			,cd.dblBalance
			,dblAppliedQuantity = cd.dblQuantity - cd.dblBalance
			,cd.intNoOfLoad
			,cd.dblBalanceLoad
			,dblAppliedLoad = cd.intNoOfLoad - cd.dblBalanceLoad
			,pf.intPriceFixationId
			,pfd.intPriceFixationDetailId
			,intPricingNumber = ROW_NUMBER() over (partition by pf.intPriceFixationId order by pfd.intPriceFixationDetailId)
			,pfd.intNumber
			,dblPricedQuantity = isnull(invoiced.dblQtyShipped, pfd.dblQuantity)
			,pfd.dblQuantityAppliedAndPriced
			,pfd.dblLoadPriced
			,pfd.dblLoadAppliedAndPriced
			,dblCorrectAppliedAndPriced = null
		from tblCTPriceFixation pf
		join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
		join tblCTContractDetail cd on cd.intContractDetailId = pf.intContractDetailId
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		left join (
			select 
				ar.intPriceFixationDetailId, dblQtyShipped = sum(di.dblQtyShipped)
			from
				tblCTPriceFixationDetailAPAR ar
				join tblARInvoiceDetail di on di.intInvoiceDetailId = ar.intInvoiceDetailId
			group by
				ar.intPriceFixationDetailId
		) invoiced on invoiced.intPriceFixationDetailId = pfd.intPriceFixationDetailId
		where pf.intContractDetailId = @intActiveContractDetailId
		order by pfd.intPriceFixationDetailId

		select @intActiveId = min(intId) from @Pricing
		while (@intActiveId is not null)
		begin
			select
				@dblActivelAppliedQuantity = (case when ysnLoad = 1 then dblAppliedLoad else dblAppliedQuantity end)
				,@dblPricedQuantity = (case when ysnLoad = 1 then dblLoadPriced else dblPricedQuantity end)
				,@ysnLoad = isnull(ysnLoad,0)
			from
				@Pricing
			where
				intId = @intActiveId;

			set @dblCommulativeAppliedAndPrice += @dblPricedQuantity;
			if (@dblRemainingAppliedQuantity = 0)
			begin
				set @dblRemainingAppliedQuantity = @dblActivelAppliedQuantity;
			end

			if (@dblCommulativeAppliedAndPrice < @dblActivelAppliedQuantity)
			begin
				update @Pricing
				set dblCorrectAppliedAndPriced = @dblPricedQuantity
				where intId = @intActiveId

				set @dblRemainingAppliedQuantity -= @dblPricedQuantity;
			end
			else
			begin
				update @Pricing
				set dblCorrectAppliedAndPriced = @dblRemainingAppliedQuantity
				where intId = @intActiveId

				set @dblRemainingAppliedQuantity -= @dblRemainingAppliedQuantity;
			end



			select @intActiveId = min(intId) from @Pricing where intId > @intActiveId;
		end

		update
			b
		set
			b.intNumber = (case when b.intNumber <> a.intPricingNumber then a.intPricingNumber else b.intNumber end)
			,b.dblQuantityAppliedAndPriced = (case when b.dblQuantityAppliedAndPriced <> a.dblCorrectAppliedAndPriced then a.dblCorrectAppliedAndPriced else b.dblQuantityAppliedAndPriced end)
			,b.dblLoadAppliedAndPriced = (case when @ysnLoad = 1 then a.dblCorrectAppliedAndPriced else null end)
		from
			@Pricing a
			,tblCTPriceFixationDetail b
		where
			(
				a.intNumber <> a.intPricingNumber
				or a.dblCorrectAppliedAndPriced <> (
					case
					when a.ysnLoad = 1
					then a.dblLoadAppliedAndPriced
					else a.dblQuantityAppliedAndPriced
					end
				)
			 )
			and b.intPriceFixationDetailId = a.intPriceFixationDetailId

	end try
	begin catch
		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 
	end catch