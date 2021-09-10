CREATE TABLE [dbo].[tblCTItemContractHeader](
	[intItemContractHeaderId]			[int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId]					[int] NOT NULL,

	[intContractPlanId]					[int] NULL,
	[intContractTypeId]					[int] NOT NULL,
	[strContractCategoryId]				[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId]						[int] NOT NULL,
	[intCurrencyId]						[int] NOT NULL,

	[intCompanyLocationId]				[int] NULL, 
	[dtmContractDate]					[datetime] NULL,
	[dtmExpirationDate]					[datetime] NULL,
	[strEntryContract]					[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCPContract]						[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,

	[intFreightTermId]					[int] NULL,	
    [intCountryId]						[int] NULL, 
	[intTermId]							[int] NULL,

	[strContractNumber]					[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSalespersonId]					[int] NOT NULL,
	[intContractTextId]					[int] NULL,
	[ysnSigned]							[bit] NOT NULL DEFAULT ((0)),
	[dtmSigned]							[datetime] NULL,
	[ysnPrinted]						[bit] NOT NULL DEFAULT ((0)),

	[intOpportunityId]					[int] NULL,
	[intLineOfBusinessId]				[int] NULL,
	[dtmDueDate]						[datetime] NULL,


	[ysnMailSent]						[bit] NOT NULL DEFAULT ((0)),

	[intShipToLocationId]				[int] NULL, 
	[dblDollarValue]					[numeric](18, 6) NULL,
	[dblAppliedDollarValue]				[numeric](18, 6) NULL,
	[dblRemainingDollarValue]			[numeric](18, 6) NULL,
	guiApiUniqueId UNIQUEIDENTIFIER NULL,
	intApiRowNumber INT NULL,

	--[strShipToLocationName]				[nvarchar](50) NULL,
	--[strShipToAddress]					[nvarchar](MAX) NULL,
	--[strShipToCity]						[nvarchar](MAX) NULL,
	--[strShipToState]					[nvarchar](MAX) NULL,
	--[strShipToZipCode]					[nvarchar](MAX) NULL,
	--[strShipToCountry]					[nvarchar](MAX) NULL,
	--[intBillToLocationId]				[int] NULL,
	--[strBillToLocationName]				[nvarchar](50) NULL,
	--[strBillToAddress]					[nvarchar](MAX) NULL,
	--[strBillToCity]						[nvarchar](MAX) NULL,
	--[strBillToState]					[nvarchar](MAX) NULL,
	--[strBillToZipCode]					[nvarchar](MAX) NULL,
	--[strBillToCountry]					[nvarchar](MAX) NULL,

	--[dblUnitOnHand]						[numeric](18, 6) NULL,
	--[dblItemCommitted]					[numeric](18, 6) NULL,
	--[dblOnHand]							[numeric](18, 6) NULL,
	--[intItemTermId]							[int] NOT NULL,
	--[intOpportunityName]				[int] NOT NULL,
	--[intLineOfBusiness]					[int] NOT NULL,
	--[dblOnOrder]						[numeric](18, 6) NULL,
	--[dblBackOrder]						[numeric](18, 6) NULL,
	--[dtmDueDate]						[datetime],

	--[dblInvoiceSubtotal]				[numeric](18, 6) NULL,
	--[dblBaseInvoiceSubtotal]			[numeric](18, 6) NULL,
	--[dblShipping]						[numeric](18, 6) NULL,
	--[dblBaseShipping]					[numeric](18, 6) NULL,
	--[dblTax]							[numeric](18, 6) NULL,
	--[dblBaseTax]						[numeric](18, 6) NULL,
	--[dblInvoiceTotal]					[numeric](18, 6) NULL,
	--[dblBaseInvoiceTotal]				[numeric](18, 6) NULL,
	--[dblDiscount]						[numeric](18, 6) NULL,
	--[dblBaseDiscount]					[numeric](18, 6) NULL,
	--[dblDiscountAvailable]				[numeric](18, 6) NULL,
	--[dblBaseDiscountAvailable]			[numeric](18, 6) NULL,
	--[dblTotalTermDiscount]				[numeric](18, 6) NULL,
	--[dblBaseTotalTermDiscount]			[numeric](18, 6) NULL,
	--[dblTotalTermDiscountExemption]		[numeric](18, 6) NULL,
	--[dblBaseTotalTermDiscountExemption] [numeric](18, 6) NULL,


    CONSTRAINT [PK_tblCTItemContractHeader_intItemContractHeaderId] PRIMARY KEY CLUSTERED ([intItemContractHeaderId] ASC), 		
	CONSTRAINT [FK_tblCTItemContractHeader_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID]),
	CONSTRAINT [FK_tblCTItemContractHeader_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity ([intEntityId]),	
	CONSTRAINT [FK_tblCTItemContractHeader_tblEMEntity_intSalespersonId] FOREIGN KEY([intSalespersonId])REFERENCES tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCTItemContractHeader_tblCTContractText_intContractTextId] FOREIGN KEY([intContractTextId])REFERENCES [tblCTContractText] ([intContractTextId]),
	
	CONSTRAINT [FK_tblCTItemContractHeader_tblSMFreightTerms_intFreightTermId] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]),	
	CONSTRAINT [FK_tblCTItemContractHeader_tblCTContractType_intContractTypeId] FOREIGN KEY ([intContractTypeId]) REFERENCES [tblCTContractType]([intContractTypeId]),
	
	CONSTRAINT [FK_tblCTItemContractHeader_tblCTContractPlan_intContractPlanId] FOREIGN KEY([intContractPlanId])REFERENCES [tblCTContractPlan] ([intContractPlanId]),	
	CONSTRAINT [FK_tblCTItemContractHeader_tblSMCountry_intCountryId] FOREIGN KEY (intCountryId) REFERENCES tblSMCountry(intCountryID)
)

GO
CREATE NONCLUSTERED INDEX [IX_tblCTItemContractHeader_intItemContractHeaderId] ON [dbo].[tblCTItemContractHeader]([intItemContractHeaderId] ASC);
GO

CREATE STATISTICS [CT_STAT_1] ON [dbo].[tblCTItemContractHeader]([intEntityId], [intContractTypeId])
GO

CREATE STATISTICS [CT_STAT_2] ON [dbo].[tblCTItemContractHeader]([intContractTypeId], [intItemContractHeaderId])
GO

CREATE STATISTICS [CT_STAT_3] ON [dbo].[tblCTItemContractHeader]([intItemContractHeaderId], [intEntityId], [intContractTypeId])
GO

CREATE STATISTICS [CT_STAT_4] ON [dbo].[tblCTItemContractHeader]([intEntityId])
GO

CREATE STATISTICS [CT_STAT_5] ON [dbo].[tblCTItemContractHeader]([intItemContractHeaderId])
GO

CREATE STATISTICS [CT_STAT_6] ON [dbo].[tblCTItemContractHeader]([intEntityId], [intItemContractHeaderId])
GO

CREATE NONCLUSTERED INDEX [IX_tblCTItemContractHeader_intEntityId] ON [dbo].[tblCTItemContractHeader]
(
	[intEntityId] ASC
)
INCLUDE ( 	
	intItemContractHeaderId
	,intContractTypeId
	,strContractNumber
	,dtmContractDate
	,intSalespersonId
) 
GO 

CREATE NONCLUSTERED INDEX [CT_INDEX_1] ON [dbo].[tblCTItemContractHeader]
(
       [intItemContractHeaderId] ASC,
       [intEntityId] ASC,
       [intContractTypeId] ASC
)
INCLUDE (
       [strContractNumber],
       [dtmContractDate]
) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [CT_STAT_7] ON [dbo].[tblCTItemContractHeader]([intContractTypeId], [intEntityId])
go

CREATE STATISTICS [CT_STAT_8] ON [dbo].[tblCTItemContractHeader]([dtmContractDate], [intEntityId], [intItemContractHeaderId], [intContractTypeId])
go

CREATE STATISTICS [CT_STAT_9] ON [dbo].[tblCTItemContractHeader]([intEntityId], [intItemContractHeaderId], [intContractTypeId])
go

CREATE STATISTICS [CT_STAT_10] ON [dbo].[tblCTItemContractHeader]([intEntityId], [intContractTypeId], [intItemContractHeaderId])
go

CREATE STATISTICS [CT_STAT_11] ON [dbo].[tblCTItemContractHeader]([intEntityId], [dtmContractDate])
go

CREATE STATISTICS [CT_STAT_12] ON [dbo].[tblCTItemContractHeader]([intItemContractHeaderId])
go

CREATE STATISTICS [CT_STAT_13] ON [dbo].[tblCTItemContractHeader]([dtmContractDate])
go

CREATE STATISTICS [CT_STAT_14] ON [dbo].[tblCTItemContractHeader]([intContractTypeId], [dtmContractDate])
go

CREATE STATISTICS [CT_STAT_15] ON [dbo].[tblCTItemContractHeader]([intItemContractHeaderId], [dtmContractDate], [intContractTypeId])
go

CREATE STATISTICS [CT_STAT_16] ON [dbo].[tblCTItemContractHeader]([dtmContractDate])
go


CREATE NONCLUSTERED INDEX [CT_INDEX_2] ON [dbo].[tblCTItemContractHeader] 
(
	[intContractTypeId] ASC,
	[intEntityId] ASC,
	[intItemContractHeaderId] ASC
)
INCLUDE ( 	
	[strContractNumber]
) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [CT_STAT_17] ON [dbo].[tblCTItemContractHeader]([intItemContractHeaderId], [intContractTypeId])

GO