CREATE TABLE [dbo].[tblFAFixedAsset] (
    [intAssetId]				INT IDENTITY (1, 1) NOT NULL,
	
	[strAssetId]				NVARCHAR (20) NOT NULL,
	[strAssetDescription]		NVARCHAR (MAX) NULL,
	[intCompanyLocationId]		INT NULL,
	[strSerialNumber]			NVARCHAR (20) NULL,
	[strNotes]					NVARCHAR (MAX) NULL,

	[dtmDateAcquired]			DATETIME NULL,			
	[dtmDateInService]			DATETIME NULL,

	[dblCost]					NUMERIC (18, 6) NULL DEFAULT ((0)),
	[intCurrencyId]				INT NULL,
	[dblMarketValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblInsuranceValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblSalvageValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),

	[strBasisDescription]		NVARCHAR (255) NULL,
	
	[dtmDispositionDate]		DATETIME NULL,	
	[intDispositionNumber]		INT NULL,
	[strDispositionNumber]		NVARCHAR (20) NOT NULL,
	[strDispositionComment]		NVARCHAR (255) NULL,
	[dblDispositionAmount]		NUMERIC (18, 6) NULL DEFAULT ((0)),

	[strPoolId]					NVARCHAR (50) NOT NULL,
	[intAccuitent]				INT NULL,

	[intAssetAccountId]			INT NULL,
	[intDepreciationAccountId]	INT NULL,
	[intAccumulatedAccountId]	INT NULL,

	[strManufacturerName]		NVARCHAR (100) NULL,
	[strModelNumber]			NVARCHAR (100) NULL,

	[ysnAcquired]				BIT NULL,
	[ysnDepreciated]			BIT NULL,
	[ysnDisposed]				BIT NULL,		

    [intConcurrencyId]          INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFAFixedAsset] PRIMARY KEY CLUSTERED ([intAssetId] ASC)
);

