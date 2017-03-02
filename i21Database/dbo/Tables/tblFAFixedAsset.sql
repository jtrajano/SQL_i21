CREATE TABLE [dbo].[tblFAFixedAsset] (
    [intAssetId]				INT IDENTITY (1, 1) NOT NULL,
	
	[strAssetId]				NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strAssetDescription]		NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[intCompanyLocationId]		INT NULL,
	[strSerialNumber]			NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
	[strNotes]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,

	[dtmDateAcquired]			DATETIME NULL,			
	[dtmDateInService]			DATETIME NULL,

	[intDepreciationMethodId]	INT NULL,
	[dblCost]					NUMERIC (18, 6) NULL DEFAULT ((0)),
	[intCurrencyId]				INT NULL,
	[dblMarketValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblInsuranceValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblSalvageValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),

	[strBasisDescription]		NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	
	[dtmDispositionDate]		DATETIME NULL,	
	[intDispositionNumber]		INT NULL,
	[strDispositionNumber]		NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDispositionComment]		NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[dblDispositionAmount]		NUMERIC (18, 6) NULL DEFAULT ((0)),

	[strPoolId]					NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intAccuitent]				INT NULL,

	[intAssetAccountId]			INT NULL,
	[intExpenseAccountId]		INT NULL,
	[intDepreciationAccountId]	INT NULL,
	[intAccumulatedAccountId]	INT NULL,

	[strManufacturerName]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strModelNumber]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,

	[ysnAcquired]				BIT NULL,
	[ysnDepreciated]			BIT NULL,
	[ysnDisposed]				BIT NULL,		

    [intConcurrencyId]          INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFAFixedAsset] PRIMARY KEY CLUSTERED ([intAssetId] ASC)
);

