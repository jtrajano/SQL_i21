CREATE TABLE [dbo].[tblSMCurrencyExchangeRateDetail]
(
	[intCurrencyExchangeRateDetailId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intCurrencyExchangeRateId] INT NOT NULL, 
    [numRate] NUMERIC(18, 6) NOT NULL, 
    [intRateTypeId] INT NOT NULL, 
    [dtmValidFromDate] DATETIME NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMCurrencyExchangeRateDetail_tblSMCurrencyExchangeRate] FOREIGN KEY (intCurrencyExchangeRateId) REFERENCES tblSMCurrencyExchangeRate(intCurrencyExchangeRateId) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMCurrencyExchangeRateDetail_tblSMCurrencyExchangeRateType] FOREIGN KEY (intRateTypeId) REFERENCES tblSMCurrencyExchangeRateType(intCurrencyExchangeRateTypeId)
)
