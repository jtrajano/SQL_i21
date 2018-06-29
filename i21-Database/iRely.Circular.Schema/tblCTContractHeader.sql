CREATE TABLE [dbo].[tblCTContractHeader](
	[intContractHeaderId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractTypeId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intBookId]	INT,
	[intSubBookId] INT,
	[intCounterPartyId] [int] NULL,
	[intEntityContactId] [int] NULL,
	[intContractPlanId] [int],
	[intCommodityId] [int] NULL,
	[dblQuantity] [numeric](18, 6) NOT NULL,
	[intCommodityUOMId] INT NULL, 
	[strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmContractDate] [datetime] NOT NULL,
	[strCustomerContract] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
	[strCPContract] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
	[dtmDeferPayDate] [datetime] NULL,
	[dblDeferPayRate] [numeric](18, 6) NULL,
	[intContractTextId] [int] NULL,
	[ysnSigned] [bit] NOT NULL CONSTRAINT [DF_tblCTContractHeader_ysnSigned]  DEFAULT ((0)),
	[dtmSigned] DATETIME,
	[ysnPrinted] [bit] NOT NULL CONSTRAINT [DF_tblCTContractHeader_ysnPrinted]  DEFAULT ((0)),
	[intSalespersonId] [int] NOT NULL,
	[intGradeId] [int] NULL,
	[intWeightId] [int] NULL,
	[intCropYearId] [int] NULL,
	[strInternalComment] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strPrintableRemarks] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intAssociationId] INT NULL, 
    [intTermId] INT NULL, 
    [intPricingTypeId] INT NULL , 

	[intApprovalBasisId] [INT] NULL,
	[intContractBasisId] [INT] NULL,
	[intPositionId] [INT] NULL,
	[intInsuranceById] [INT] NULL,
	[intInvoiceTypeId] [INT] NULL,
	[dblTolerancePct] NUMERIC(18, 6) NULL,
	[dblProvisionalInvoicePct] NUMERIC(18, 6) NULL,
    
    [ysnSubstituteItem] BIT NULL, 
    [ysnUnlimitedQuantity] BIT NULL, 
    [ysnMaxPrice] BIT NULL, 
    [intINCOLocationTypeId] INT NULL, 
	[intWarehouseId] INT NULL, 
    [intCountryId] INT NULL, 
    [intCompanyLocationPricingLevelId] INT NULL, 
    [ysnProvisional] BIT NULL, 
    [ysnLoad] BIT NULL, 
    [intNoOfLoad] INT NULL, 
    [dblQuantityPerLoad] NUMERIC(18, 6) NULL, 
    [intLoadUOMId] INT NULL, 
	[ysnCategory] BIT,

	[ysnMultiplePriceFixation] BIT NULL, 
	[intFutureMarketId] INT,
	[intFutureMonthId] INT,
	[dblFutures] NUMERIC(18, 6) NULL,
	[dblNoOfLots] NUMERIC(18, 6) NULL,
    
	[intCategoryUnitMeasureId] INT NULL,
	[intLoadCategoryUnitMeasureId] INT NULL,
	[intArbitrationId] INT NULL,
	[intProducerId] INT NULL,
	[ysnClaimsToProducer] BIT,
	[ysnRiskToProducer] BIT,
	[ysnExported] BIT NULL,
	[dtmExported] DATETIME NULL,
	intCreatedById INT,
	dtmCreated DATETIME,
	intLastModifiedById INT,
	dtmLastModified DATETIME,
	ysnMailSent BIT,
	strAmendmentLog  [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	ysnBrokerage BIT,
	ysnBestPriceOnly BIT,
	intCompanyId INT,
	intContractHeaderRefId INT,

    CONSTRAINT [PK_tblCTContractHeader_intContractHeaderId] PRIMARY KEY CLUSTERED ([intContractHeaderId] ASC), 	
	CONSTRAINT [UQ_tblCTContractHeader_intContractTypeId_intContractNumber] UNIQUE ([intContractTypeId], [strContractNumber],[intEntityId],[intCommodityId]), 
	CONSTRAINT [FK_tblCTContractHeader_tblCTAssociation_intAssociationId] FOREIGN KEY ([intAssociationId]) REFERENCES [tblCTAssociation]([intAssociationId]),
	CONSTRAINT [FK_tblCTContractHeader_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID]),
	CONSTRAINT [FK_tblCTContractHeader_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCTContractHeader_tblEMEntity_intProducerId] FOREIGN KEY ([intProducerId]) REFERENCES tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCTContractHeader_tblEMEntity_intCounterPartyId] FOREIGN KEY (intCounterPartyId) REFERENCES tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCTContractHeader_tblEMEntity_intEntityId_intEntityContactId] FOREIGN KEY ([intEntityContactId]) REFERENCES tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCTContractHeader_tblEMEntity_intSalespersonId] FOREIGN KEY([intSalespersonId])REFERENCES tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTContractText_intContractTextId] FOREIGN KEY([intContractTextId])REFERENCES [tblCTContractText] ([intContractTextId]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTCropYear_intCropYearId] FOREIGN KEY([intCropYearId])REFERENCES [tblCTCropYear] ([intCropYearId]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTWeightGrade_intWeightGradeId_intGradeId] FOREIGN KEY([intGradeId])REFERENCES [tblCTWeightGrade] ([intWeightGradeId]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTWeightGrade_intWeightGradeId_intWeightId] FOREIGN KEY([intWeightId])REFERENCES [tblCTWeightGrade] ([intWeightGradeId]),
	CONSTRAINT [FK_tblCTContractHeader_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [tblICCommodity] ([intCommodityId]),
	
	CONSTRAINT [FK_tblCTContractHeader_tblCTPricingType_intPricingTypeId] FOREIGN KEY ([intPricingTypeId]) REFERENCES [tblCTPricingType]([intPricingTypeId]),

	CONSTRAINT [FK_tblCTContractHeader_tblCTApprovalBasis_intApprovalBasisId] FOREIGN KEY ([intApprovalBasisId]) REFERENCES [tblCTApprovalBasis]([intApprovalBasisId]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTContractBasis_intContractBasisId] FOREIGN KEY ([intContractBasisId]) REFERENCES [tblCTContractBasis]([intContractBasisId]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTPosition_intPositionId] FOREIGN KEY ([intPositionId]) REFERENCES [tblCTPosition]([intPositionId]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTInsuranceBy_intInsuranceById] FOREIGN KEY ([intInsuranceById]) REFERENCES [tblCTInsuranceBy]([intInsuranceById]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTInvoiceType_intInvoiceTypeId] FOREIGN KEY ([intInvoiceTypeId]) REFERENCES [tblCTInvoiceType]([intInvoiceTypeId]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTContractType_intContractTypeId] FOREIGN KEY ([intContractTypeId]) REFERENCES [tblCTContractType]([intContractTypeId]),
	CONSTRAINT [FK_tblCTContractHeader_tblSMCompanyLocationPricingLevel_intCompanyLocationPricingLevelId] FOREIGN KEY ([intCompanyLocationPricingLevelId]) REFERENCES [tblSMCompanyLocationPricingLevel]([intCompanyLocationPricingLevelId]),

	CONSTRAINT [FK_tblCTContractHeader_tblICCommodityUnitMeasure_intCommodityUOMId_intCommodityUnitMeasureId] FOREIGN KEY([intCommodityUOMId])REFERENCES [tblICCommodityUnitMeasure] ([intCommodityUnitMeasureId]),
	CONSTRAINT [FK_tblCTContractHeader_tblICCommodityUnitMeasure_intLoadUOMId_intCommodityUnitMeasureId] FOREIGN KEY([intLoadUOMId])REFERENCES [tblICCommodityUnitMeasure] ([intCommodityUnitMeasureId]),
	CONSTRAINT [FK_tblCTContractHeader_tblICUnitMeasure_intCategoryUnitMeasureId_intUnitMeasureId] FOREIGN KEY([intCategoryUnitMeasureId])REFERENCES [tblICUnitMeasure] ([intUnitMeasureId]),
	CONSTRAINT [FK_tblCTContractHeader_tblICUnitMeasure_intLoadCategoryUnitMeasureId_intUnitMeasureId] FOREIGN KEY([intLoadCategoryUnitMeasureId])REFERENCES [tblICUnitMeasure] ([intUnitMeasureId]),
	CONSTRAINT [FK_tblCTContractHeader_tblCTContractPlan_intContractPlanId] FOREIGN KEY([intContractPlanId])REFERENCES [tblCTContractPlan] ([intContractPlanId]),
	CONSTRAINT [FK_tblCTContractHeader_tblSMCity_intArbitrationId_intCityId] FOREIGN KEY ([intArbitrationId]) REFERENCES [tblSMCity]([intCityId]),

	CONSTRAINT [FK_tblCTContractHeader_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY (intFutureMarketId) REFERENCES tblRKFutureMarket(intFutureMarketId),
	CONSTRAINT [FK_tblCTContractHeader_tblRKFutureMonth_intFutureMonthId] FOREIGN KEY (intFutureMonthId) REFERENCES tblRKFuturesMonth(intFutureMonthId),
	CONSTRAINT [FK_tblCTContractHeader_tblSMCountry_intCountryId] FOREIGN KEY (intCountryId) REFERENCES tblSMCountry(intCountryID)
)

GO
CREATE NONCLUSTERED INDEX [IX_tblCTContractHeader_intContractHeaderId] ON [dbo].[tblCTContractHeader]([intContractHeaderId] ASC);
GO

CREATE STATISTICS [_dta_stat_34411492_4_3] ON [dbo].[tblCTContractHeader]([intEntityId], [intContractTypeId])
GO

CREATE STATISTICS [_dta_stat_34411492_3_1] ON [dbo].[tblCTContractHeader]([intContractTypeId], [intContractHeaderId])
GO

CREATE STATISTICS [_dta_stat_34411492_1_4_3] ON [dbo].[tblCTContractHeader]([intContractHeaderId], [intEntityId], [intContractTypeId])
GO

CREATE STATISTICS [_dta_stat_34411492_30] ON [dbo].[tblCTContractHeader]([intPositionId])
GO

CREATE STATISTICS [_dta_stat_34411492_4_30] ON [dbo].[tblCTContractHeader]([intEntityId], [intPositionId])
GO

CREATE STATISTICS [_dta_stat_34411492_1_30_29] ON [dbo].[tblCTContractHeader]([intContractHeaderId], [intPositionId], [intContractBasisId])
GO

CREATE STATISTICS [_dta_stat_34411492_29_30_4_1] ON [dbo].[tblCTContractHeader]([intContractBasisId], [intPositionId], [intEntityId], [intContractHeaderId])
GO

CREATE NONCLUSTERED INDEX [IX_tblCTContractHeader_intEntityId] ON [dbo].[tblCTContractHeader]
(
	[intEntityId] ASC
)
INCLUDE ( 	
	intContractHeaderId
	,intContractTypeId
	,strContractNumber
	,dtmContractDate
	,intSalespersonId
	,ysnLoad
) 
GO 

CREATE NONCLUSTERED INDEX [_dta_index_tblCTContractHeader_197_752721734__K1_K32_K4_K3_K8_10_11_12_31_49_53] ON [dbo].[tblCTContractHeader]
(
       [intContractHeaderId] ASC,
       [intPositionId] ASC,
       [intEntityId] ASC,
       [intContractTypeId] ASC,
       [intCommodityId] ASC
)
INCLUDE (     [intCommodityUOMId],
       [strContractNumber],
       [dtmContractDate],
       [intContractBasisId],
       [ysnMultiplePriceFixation],
       [dblNoOfLots]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_752721734_3_32_4] ON [dbo].[tblCTContractHeader]([intContractTypeId], [intPositionId], [intEntityId])
go

CREATE STATISTICS [_dta_stat_752721734_4_1_32_3] ON [dbo].[tblCTContractHeader]([intEntityId], [intContractHeaderId], [intPositionId], [intContractTypeId])
go

CREATE STATISTICS [_dta_stat_752721734_8_32_4_3_1] ON [dbo].[tblCTContractHeader]([intCommodityId], [intPositionId], [intEntityId], [intContractTypeId], [intContractHeaderId])
go

CREATE STATISTICS [_dta_stat_752721734_32_12] ON [dbo].[tblCTContractHeader]([intPositionId], [dtmContractDate])
go

CREATE STATISTICS [_dta_stat_752721734_4_12] ON [dbo].[tblCTContractHeader]([intEntityId], [dtmContractDate])
go

CREATE STATISTICS [_dta_stat_752721734_8_32_1] ON [dbo].[tblCTContractHeader]([intCommodityId], [intPositionId], [intContractHeaderId])
go

CREATE STATISTICS [_dta_stat_752721734_8_12_32] ON [dbo].[tblCTContractHeader]([intCommodityId], [dtmContractDate], [intPositionId])
go

CREATE STATISTICS [_dta_stat_752721734_3_12_8_32] ON [dbo].[tblCTContractHeader]([intContractTypeId], [dtmContractDate], [intCommodityId], [intPositionId])
go

CREATE STATISTICS [_dta_stat_752721734_1_12_8_32_3] ON [dbo].[tblCTContractHeader]([intContractHeaderId], [dtmContractDate], [intCommodityId], [intPositionId], [intContractTypeId])
go

CREATE STATISTICS [_dta_stat_752721734_12_8_4_32_1_3] ON [dbo].[tblCTContractHeader]([dtmContractDate], [intCommodityId], [intEntityId], [intPositionId], [intContractHeaderId], [intContractTypeId])
go

CREATE NONCLUSTERED INDEX [_dta_index_tblCTContractHeader_197_752721734__K8_K3_K4_K1_11_49_53] ON [dbo].[tblCTContractHeader]
(
	[intCommodityId] ASC,
	[intContractTypeId] ASC,
	[intEntityId] ASC,
	[intContractHeaderId] ASC
)
INCLUDE ( 	[strContractNumber],
	[ysnMultiplePriceFixation],
	[dblNoOfLots]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_752721734_1_8_3] ON [dbo].[tblCTContractHeader]([intContractHeaderId], [intCommodityId], [intContractTypeId])

GO