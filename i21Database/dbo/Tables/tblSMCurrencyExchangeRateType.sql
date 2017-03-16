CREATE TABLE [dbo].[tblSMCurrencyExchangeRateType]
(
	[intCurrencyExchangeRateTypeId] INT IDENTITY (1, 1) NOT NULL,
    [strCurrencyExchangeRateType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
	CONSTRAINT [PK_tblSMCurrencyExchangeRateType] PRIMARY KEY ([intCurrencyExchangeRateTypeId]), 
    CONSTRAINT [AK_tblSMCurrencyExchangeRateType_strCurrencyExchangeRateType] UNIQUE ([strCurrencyExchangeRateType])
)
