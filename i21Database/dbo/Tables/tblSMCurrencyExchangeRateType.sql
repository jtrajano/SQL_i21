CREATE TABLE [dbo].[tblSMCurrencyExchangeRateType]
(
	[intCurrencyExchangeRateTypeId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strCurrencyExchangeRateType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
