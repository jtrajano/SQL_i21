CREATE TABLE [dbo].[tblFAFixedAsset] (
    [intAssetId]				INT IDENTITY (1, 1) NOT NULL,
	[strAssetId]				NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strAssetDescription]		NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[intCompanyLocationId]		INT NULL,
	[strSerialNumber]			NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[strNotes]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateAcquired]			DATETIME NULL,			
	[dtmDateInService]			DATETIME NULL,
	[dblCost]					NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblForexRate]				NUMERIC (18, 6) NULL DEFAULT ((1)),
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
	[intAssetGroupId]			INT NULL,
	[intAssetAccountId]			INT NULL,
	[intExpenseAccountId]		INT NULL,
	[intDepreciationAccountId]	INT NULL,
	[intAccumulatedAccountId]	INT NULL,
	[intGainLossAccountId]		INT NULL,
	[intDepreciationMethodId]	INT NULL,
	[strManufacturerName]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strModelNumber]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[ysnAcquired]				BIT NULL,
	[ysnDepreciated]			BIT NULL,
	[ysnTaxDepreciated]			BIT NULL,
	[ysnDisposed]				BIT NULL,	
	[ysnImported]				BIT NULL,
	[dtmImportedDepThru]		DATETIME NULL,
	[dblImportGAAPDepToDate]	DECIMAL(18,6) NULL,
	[dblImportTaxDepToDate]	DECIMAL(18,6) NULL,
	[dtmCreateAssetPostDate]	DATETIME NULL,
	[intAssetDepartmentId]		INT NULL,
    [intConcurrencyId]          INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFAFixedAsset] PRIMARY KEY CLUSTERED ([intAssetId] ASC),
	CONSTRAINT [FK_tblFRBudget_tblGLAccount1] FOREIGN KEY ([intAssetAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFRBudget_tblGLAccount2] FOREIGN KEY ([intExpenseAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFRBudget_tblGLAccount3] FOREIGN KEY ([intDepreciationAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFRBudget_tblGLAccount4] FOREIGN KEY ([intAccumulatedAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblFADepreciationMethod] FOREIGN KEY([intDepreciationMethodId]) REFERENCES [dbo].[tblFADepreciationMethod] ([intDepreciationMethodId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblFAFixedAssetGroup] FOREIGN KEY([intAssetGroupId]) REFERENCES [dbo].[tblFAFixedAssetGroup] ([intAssetGroupId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblFAFixedAssetDepartment] FOREIGN KEY([intAssetDepartmentId]) REFERENCES [dbo].[tblFAFixedAssetDepartment] ([intAssetDepartmentId])
);

