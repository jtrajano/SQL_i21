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
	[dblFunctionalCost]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblForexRate]				NUMERIC (18, 6) NULL DEFAULT ((1)),
	[intCurrencyId]				INT NULL,
	[intFunctionalCurrencyId]	INT NULL,
	[dblMarketValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblInsuranceValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblSalvageValue]			NUMERIC (18, 6) NULL DEFAULT ((0)),
	[dblFunctionalSalvageValue]	NUMERIC (18, 6) NULL DEFAULT ((0)),
	[strBasisDescription]		NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[dtmDispositionDate]		DATETIME NULL,	
	[intDispositionNumber]		INT NULL,
	[strDispositionNumber]		NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
	[strDispositionComment]		NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
	[dblDispositionAmount]		NUMERIC (18, 6) NULL DEFAULT ((0)),
	[strPoolId]					NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[intLegacyId]				INT NULL,
	[intAssetGroupId]			INT NULL,
	[intAssetAccountId]			INT NULL,
	[intExpenseAccountId]		INT NULL,
	[intDepreciationAccountId]	INT NULL,
	[intAccumulatedAccountId]	INT NULL,
	[intGainLossAccountId]		INT NULL,
	[intSalesOffsetAccountId]	INT NULL,
	[intDepreciationMethodId]	INT NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
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
	[intParentAssetId]			INT NULL,
	[dtmCreateAssetPostDate]	DATETIME NULL,
	[intAssetDepartmentId]		INT NULL,
	[intNewAssetAccountId]			INT NULL,
	[intNewExpenseAccountId]		INT NULL,
	[intNewDepreciationAccountId]	INT NULL,
	[intNewAccumulatedAccountId]	INT NULL,
	[intNewGainLossAccountId]		INT NULL,
	[intNewSalesOffsetAccountId]	INT NULL,
	[intPrevAssetAccountId]			INT NULL,
	[intPrevExpenseAccountId]		INT NULL,
	[intPrevDepreciationAccountId]	INT NULL,
	[intPrevAccumulatedAccountId]	INT NULL,
	[intPrevGainLossAccountId]		INT NULL,
	[intPrevSalesOffsetAccountId]	INT NULL,
	[ysnHasNewAccountPosted]		BIT DEFAULT (0) NOT NULL,
    [intConcurrencyId]          INT DEFAULT 1 NOT NULL,
	[intAssetTaxJurisdictionId]		INT NULL,
	[intFixedAssetJournalId] INT NULL,
    CONSTRAINT [PK_tblFAFixedAsset] PRIMARY KEY CLUSTERED ([intAssetId] ASC),
	CONSTRAINT [FK_tblFAFixedAsset_tblGLAccount1] FOREIGN KEY ([intAssetAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblGLAccount2] FOREIGN KEY ([intExpenseAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblGLAccount3] FOREIGN KEY ([intDepreciationAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblGLAccount4] FOREIGN KEY ([intAccumulatedAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblGLAccount5] FOREIGN KEY ([intSalesOffsetAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblGLAccount6] FOREIGN KEY ([intGainLossAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblFADepreciationMethod] FOREIGN KEY([intDepreciationMethodId]) REFERENCES [dbo].[tblFADepreciationMethod] ([intDepreciationMethodId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblFAFixedAssetGroup] FOREIGN KEY([intAssetGroupId]) REFERENCES [dbo].[tblFAFixedAssetGroup] ([intAssetGroupId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblSMCurrency] FOREIGN KEY([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblFAFixedAsset_tblSMCurrency2] FOREIGN KEY([intFunctionalCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblFAFixedAsset_tblSMCurrencyExchangeRateType] FOREIGN KEY([intCurrencyExchangeRateTypeId]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType] ([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblFAFixedAssetDepartment] FOREIGN KEY([intAssetDepartmentId]) REFERENCES [dbo].[tblFAFixedAssetDepartment] ([intAssetDepartmentId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblFAFixedAssetTaxJurisdiction] FOREIGN KEY([intAssetTaxJurisdictionId]) REFERENCES [dbo].[tblFAFixedAssetTaxJurisdiction] ([intAssetTaxJurisdictionId]),
	CONSTRAINT [FK_tblFAFixedAsset_tblFAFixedAssetJournal] FOREIGN KEY([intFixedAssetJournalId]) REFERENCES [dbo].[tblFAFixedAssetJournal] ([intFixedAssetJournalId])
);

