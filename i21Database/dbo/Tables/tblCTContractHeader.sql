CREATE TABLE [dbo].[tblCTContractHeader](
	[intContractHeaderId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractTypeId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intContractPlanId] [int],
	[intCommodityId] [int] NULL,
	[dblQuantity] [numeric](24, 4) NOT NULL,
	[intCommodityUOMId] INT NULL, 
	[strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmContractDate] [datetime] NOT NULL,
	[strCustomerContract] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
	[dtmDeferPayDate] [datetime] NULL,
	[dblDeferPayRate] [numeric](5, 2) NULL,
	[intContractTextId] [int] NULL,
	[ysnSigned] [bit] NOT NULL CONSTRAINT [DF_tblCTContractHeader_ysnSigned]  DEFAULT ((0)),
	[ysnPrinted] [bit] NOT NULL CONSTRAINT [DF_tblCTContractHeader_ysnPrinted]  DEFAULT ((0)),
	[intSalespersonId] [int] NOT NULL,
	[intGradeId] [int] NULL,
	[intWeightId] [int] NULL,
	[intCropYearId] [int] NULL,
	[strInternalComment] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strPrintableRemarks] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[intAssociationId] INT NULL, 
    [intTermId] INT NOT NULL, 
    [intPricingTypeId] INT NULL , 

	[intApprovalBasisId] [INT] NULL,
	[intContractBasisId] [INT] NULL,
	[intPositionId] [INT] NULL,
	[intInsuranceById] [INT] NULL,
	[intInvoiceTypeId] [INT] NULL,
	[dblTolerancePct] NUMERIC(12, 4) NULL,
	[dblProvisionalInvoicePct] NUMERIC(12, 4) NULL,
    [ysnPrepaid] BIT NULL, 
    [ysnSubstituteItem] BIT NULL, 
    [ysnUnlimitedQuantity] BIT NULL, 
    [ysnMaxPrice] BIT NULL, 
    [intINCOLocationTypeId] INT NULL, 
    [intCountryId] INT NULL, 
    [intCompanyLocationPricingLevelId] INT NULL, 
    [ysnProvisional] BIT NULL, 
    [ysnLoad] BIT NULL, 
    [intNoOfLoad] INT NULL, 
    [dblQuantityPerLoad] NUMERIC(18, 4) NULL, 
    [intLoadUOMId] INT NULL, 
	[ysnCategory] BIT,

    [ysnMultiplePriceFixation] BIT NULL, 
	[intCategoryUnitMeasureId] INT NULL,
	[intLoadCategoryUnitMeasureId] INT NULL,
	[intArbitrationId] INT NULL,
    CONSTRAINT [PK_tblCTContractHeader_intContractHeaderId] PRIMARY KEY CLUSTERED ([intContractHeaderId] ASC), 	
	CONSTRAINT [UQ_tblCTContractHeader_intContractTypeId_intContractNumber] UNIQUE ([intContractTypeId], [strContractNumber]), 
	CONSTRAINT [FK_tblCTContractHeader_tblCTAssociation_intAssociationId] FOREIGN KEY ([intAssociationId]) REFERENCES [tblCTAssociation]([intAssociationId]),
	CONSTRAINT [FK_tblCTContractHeader_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID]),
	CONSTRAINT [FK_tblCTContractHeader_tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity] ([intEntityId]),
	CONSTRAINT [FK_tblCTContractHeader_tblARSalesperson_intSalespersonId] FOREIGN KEY([intSalespersonId])REFERENCES [tblARSalesperson] ([intEntitySalespersonId]),
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
	CONSTRAINT [FK_tblCTContractDetail_tblSMCity_intArbitrationId_intCityId] FOREIGN KEY ([intArbitrationId]) REFERENCES [tblSMCity]([intCityId])
)



