CREATE TABLE [dbo].[tblCTContractDetail]
(
	[intContractDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intSplitFromId] [int],
	[intParentDetailId] [int],
	[ysnSlice] BIT,
	[intConcurrencyId] [int] NOT NULL,
	[intContractHeaderId] [int] NOT NULL,
	[intContractStatusId] [int] NULL,
	[intContractSeq] [int] NOT NULL,
	[intCompanyLocationId] [int] NOT NULL,
	[dtmStartDate] [datetime] NOT NULL,
	[dtmEndDate] [datetime] NOT NULL,
	[intFreightTermId] [int] NULL,
	[intShipViaId] [int] NULL,
	
	[intItemContractId] INT NULL,
	[intItemId] [int] NULL,
	[intCategoryId] INT NULL,
	[dblQuantity] [numeric](18, 6) NOT NULL,
	[intItemUOMId] [int] NULL,	
	[dblOriginalQty] NUMERIC(18, 6) NULL, 
    [dblBalance] NUMERIC(18, 6) NULL, 
    [dblIntransitQty] NUMERIC(18, 6) NULL, 
    [dblScheduleQty] NUMERIC(18, 6) NULL, 
	[dblNetWeight] NUMERIC(18, 6) NULL, 
	[intNetWeightUOMId] [int] NULL,	
	[intUnitMeasureId] [int] NULL,
	[intCategoryUOMId] INT NULL, 
	
	[intNoOfLoad] INT NULL, 
	[dblQuantityPerLoad] NUMERIC(18, 6) NULL, 
    
	[intIndexId] INT NULL, 
	[dblAdjustment] NUMERIC(18, 6) NULL, 
	[intAdjItemUOMId] [int] NULL,
    
	[intPricingTypeId] [int] NULL,
	[intFutureMarketId] [int] NULL,
	[intFutureMonthId] INT NULL,
	[dblFutures] [numeric](18, 6) NULL,
	[dblBasis] [numeric](18, 6) NULL,	
	[dblOriginalBasis] [numeric](18, 6) NULL,
	[dblCashPrice] [numeric](18, 6) NULL,
	[dblTotalCost] [numeric](18, 6) NULL,
	[intCurrencyId] [int] NULL,
	[intPriceItemUOMId]  INT NULL, 
	[dblNoOfLots] NUMERIC(18, 6) NULL,
		
	[intMarketZoneId] [int] NULL,
	[intDiscountTypeId] [int] NULL ,
	[intDiscountId] [int] NULL,
	[intDiscountScheduleId] [int] NULL,
	[intDiscountScheduleCodeId] [int] NULL,
	[intStorageScheduleRuleId] [int] NULL,
	[intContractOptHeaderId] [int] NULL,
	[strBuyerSeller] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intBillTo] [int] NULL,
	[intFreightRateId] [int] NULL,
	[strFobBasis] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intRailGradeId] [int] NULL,
	[strRailRemark] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	

	[strLoadingPointType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
    [intLoadingPortId] INT NULL, 
	[strDestinationPointType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
    [intDestinationPortId] INT NULL, 
    [strShippingTerm] NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL, 
    [intShippingLineId] INT NULL, 
	[strVessel] NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL, 
    [intDestinationCityId] INT NULL, 
    [intShipperId] INT NULL, 
	[strRemark] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[intSubLocationId] INT,
	[intStorageLocationId] INT,

	[intPurchasingGroupId] INT,
	[intFarmFieldId] INT NULL,
	[intSplitId] INT NULL,
	[strGrade] NVARCHAR(128) COLLATE Latin1_General_CI_AS NULL,
	[strGarden] NVARCHAR(128) COLLATE Latin1_General_CI_AS NULL,
	[strVendorLotID] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strReference] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strERPPONumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strERPItemNumber	NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	strERPBatchNumber	NVARCHAR (100)  COLLATE Latin1_General_CI_AS,

	[intUnitsPerLayer] INT NULL,
	[intLayersPerPallet] INT NULL,
	[dtmEventStartDate] [datetime] NULL,
	[dtmPlannedAvailabilityDate] [datetime] NULL,
	[dtmUpdatedAvailabilityDate]  [datetime] NULL,
	[intBookId] INT NULL,
	[intSubBookId] INT NULL,

	[intContainerTypeId] INT NULL,
	[intNumberOfContainers] INT NULL,
	[intInvoiceCurrencyId] [int] NULL,
	[dtmFXValidFrom]  [datetime] NULL,
	[dtmFXValidTo]  [datetime] NULL,
	[dblRate] [numeric](18, 6) NULL,
	[ysnUseFXPrice] BIT,
	[intFXPriceUOMId] [int] NULL,
	[strFXRemarks] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[dblAssumedFX] [numeric](18, 6) NULL,
	[strFixationBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPackingDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyExchangeRateId] INT NULL,
	[intRateTypeId] INT NULL,
    intCreatedById INT,
	dtmCreated DATETIME,
	intLastModifiedById INT,
	dtmLastModified DATETIME,
	[ysnInvoice] BIT NULL DEFAULT 0, 
	[ysnProvisionalInvoice] BIT NULL DEFAULT 0, 
	[ysnQuantityFinal] BIT NULL DEFAULT 0, 
	[intProducerId] INT NULL,
	[ysnClaimsToProducer] BIT,
	[ysnRiskToProducer] BIT,

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
	CONSTRAINT [FK_tblCTContractDetail_tblSMFreightTerms_intFreightTermId] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMShipVia_intShipViaId] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia]([intEntityShipViaId]),
	CONSTRAINT [FK_tblCTContractDetail_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblCTContractDetail_tblAPVendor_intVendorId] FOREIGN KEY ([intBillTo]) REFERENCES [tblAPVendor]([intEntityVendorId]),
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
	CONSTRAINT [FK_tblCTContractDetail_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),

	CONSTRAINT [FK_tblCTContractDetail_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId]),

	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intPriceItemUOMId_intItemUOMId] FOREIGN KEY ([intPriceItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intAdjItemUOMId_intItemUOMId] FOREIGN KEY ([intAdjItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICItemUOM_intNetWeightUOMId_intItemUOMId] FOREIGN KEY ([intNetWeightUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICCategoryUOM_intCategoryUOMId] FOREIGN KEY([intCategoryUOMId])REFERENCES [tblICCategoryUOM] ([intCategoryUOMId]),
	
	CONSTRAINT [FK_tblCTContractDetail_tblSMCurrency_intInvoiceCurrencyId_intCurrencyId] FOREIGN KEY ([intInvoiceCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTContractDetail_tblLGContainerType_intContainerTypeId] FOREIGN KEY ([intContainerTypeId]) REFERENCES [tblLGContainerType]([intContainerTypeId]),
	CONSTRAINT [FK_tblCTContractDetail_tblICCategory_intCategoryId] FOREIGN KEY([intCategoryId])REFERENCES [tblICCategory] ([intCategoryId]),
	CONSTRAINT [FK_tblCTContractDetail_tblCTIndex_intIndexId] FOREIGN KEY ([intIndexId]) REFERENCES [tblCTIndex]([intIndexId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCurrencyExchangeRate_intCurrencyExchangeRateId] FOREIGN KEY ([intCurrencyExchangeRateId]) REFERENCES [tblSMCurrencyExchangeRate]([intCurrencyExchangeRateId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMCurrencyExchangeRateType_intRateTypeId_intCurrencyExchangeRateId] FOREIGN KEY (intRateTypeId) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblCTContractDetail_tblEMEntityFarm_intFarmFieldId] FOREIGN KEY ([intFarmFieldId]) REFERENCES [tblEMEntityFarm]([intFarmFieldId]),
	CONSTRAINT [FK_tblCTContractDetail_tblEMEntitySplit_intSplitId] FOREIGN KEY ([intSplitId]) REFERENCES [tblEMEntitySplit]([intSplitId]),
	CONSTRAINT [FK_tblCTContractDetail_tblSMPurchasingGroup_intPurchasingGroupId] FOREIGN KEY ([intPurchasingGroupId]) REFERENCES [tblSMPurchasingGroup]([intPurchasingGroupId])
) 

GO
CREATE NONCLUSTERED INDEX [IX_tblCTContractDetail_intContractDetailId] ON [dbo].[tblCTContractDetail]([intContractDetailId] ASC);
GO


CREATE NONCLUSTERED INDEX [_dta_index_tblCTContractDetail_11] ON [dbo].[tblCTContractDetail]
(
	[intContractHeaderId] ASC,
	[intContractDetailId] ASC,
	[intCompanyLocationId] ASC,
	[intItemId] ASC,
	[intItemUOMId] ASC,
	[intLoadingPortId] ASC,
	[intDestinationPortId] ASC,
	[intDestinationCityId] ASC
)
INCLUDE ( 	[intContractStatusId],
	[intContractSeq],
	[dtmStartDate],
	[dtmEndDate],
	[dblQuantity],
	[dblBalance],
	[intUnitMeasureId],
	[intNoOfLoad],
	[dblQuantityPerLoad],
	[intShippingLineId],
	[strVessel],
	[intContainerTypeId],
	[intNumberOfContainers],
	[strPackingDescription]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
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