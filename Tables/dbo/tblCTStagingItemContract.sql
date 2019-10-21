CREATE TABLE [dbo].[tblCTStagingItemContract](
	[intStagingItemId]					[int] IDENTITY(1,1) NOT NULL,

	[intContractPlanId]					[int] NULL,
	[intContractTypeId]					[int] NULL,
	[strContractCategoryId]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId]						[int] NULL,
	[intCurrencyId]						[int] NULL,

	[intCompanyLocationId]				[int] NULL, 
	[dtmContractDate]					[datetime] NULL,
	[dtmExpirationDate]					[datetime] NULL,
	[strEntryContract]					[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCPContract]						[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,

	[intFreightTermId]					[int] NULL,	
    [intCountryId]						[int] NULL, 
	[intTermId]							[int] NULL,
	[ysnPrepaid]						[bit] NULL, 

	[strContractNumber]					[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intSalespersonId]					[int] NULL,
	[intContractTextId]					[int] NULL,
	[ysnSigned]							[bit] NULL DEFAULT ((0)),
	[dtmSigned]							[datetime] NULL,
	[ysnPrinted]						[bit] NULL DEFAULT ((0)),

	[intOpportunityId]					[int] NULL,
	[intLineOfBusinessId]				[int] NULL,
	[dtmDueDate]						[datetime] NULL,

	[ysnMailSent]						[bit] NULL DEFAULT ((0)),	

    CONSTRAINT PK_tblCTStagingItemContract_intStagingItemId PRIMARY KEY (intStagingItemId)
)

GO