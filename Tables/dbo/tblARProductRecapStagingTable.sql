CREATE TABLE [dbo].[tblARProductRecapStagingTable]
(
	[intEntityCustomerId]		INT NULL,
	[intCompanyLocationId]		INT NULL,
	[intItemId]					INT NULL,
	[intTaxCodeId]				INT NULL,
	[intSortNo]					INT NULL,
	[intEntityUserId]			INT NULL,
    [strCustomerName]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strLocationNumber]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strProductNo]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strDescription]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strType]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFormattingOptions]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[dblUnits]					NUMERIC(18, 6) NULL,
	[dblAmounts]				NUMERIC(18, 6) NULL
)
