CREATE TABLE [dbo].[tblFABasisAdjustment]
(
	[intBasisAdjustmentId] INT IDENTITY(1,1) NOT NULL,
	[intAssetId] INT NULL,
	[intBookId] INT NULL,
	[intCurrencyId] INT NULL,
	[intFunctionalCurrencyId] INT NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[dblRate] NUMERIC(18, 6) NULL,
	[dblAdjustment] NUMERIC(18, 6) NOT NULL,
	[dblFunctionalAdjustment] NUMERIC(18, 6) NULL,
	[dtmDate] DATETIME NOT NULL,
	[dtmDateEntered] DATETIME NOT NULL,
	[ysnAddToBasis] BIT NOT NULL DEFAULT(0),
	[strReason] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL ,
	[strAdjustmentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL,

	CONSTRAINT [PK_tblFABasisAdjustment] PRIMARY KEY CLUSTERED ([intBasisAdjustmentId] ASC),
	CONSTRAINT [FK_tblFABasisAdjustment_tblFAFixedAsset] FOREIGN KEY([intAssetId]) REFERENCES [dbo].[tblFAFixedAsset]([intAssetId]), 
	CONSTRAINT [FK_tblFABasisAdjustment_tblSMCurrencyExchangeRateType] FOREIGN KEY([intCurrencyExchangeRateTypeId]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]), 
	CONSTRAINT [FK_tblFABasisAdjustment_tblSMCurrency] FOREIGN KEY([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency]([intCurrencyID]), 
	CONSTRAINT [FK_tblFABasisAdjustment_tblSMCurrencyFunctional] FOREIGN KEY([intFunctionalCurrencyId]) REFERENCES [dbo].[tblSMCurrency]([intCurrencyID]) 
)
