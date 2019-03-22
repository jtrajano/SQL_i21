CREATE TABLE [dbo].[tblSMCurrencyExchangeRate]
(
	[intCurrencyExchangeRateId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intFromCurrencyId] INT NOT NULL, 
    [intToCurrencyId] INT NOT NULL, 
    [intSort] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMCurrencyExchangeRate_tblSMCurrency_From] FOREIGN KEY (intFromCurrencyId) REFERENCES tblSMCurrency(intCurrencyID),
	CONSTRAINT [FK_tblSMCurrencyExchangeRate_tblSMCurrency_To] FOREIGN KEY (intToCurrencyId) REFERENCES tblSMCurrency(intCurrencyID), 
    CONSTRAINT [AK_tblSMCurrencyExchangeRate_FromToCurrencyId] UNIQUE ([intFromCurrencyId], [intToCurrencyId]) 
)
GO
CREATE NONCLUSTERED INDEX [IX_tblSMCurrencyExchangeRate_intFromCurrencyId] 
	ON [dbo].[tblSMCurrencyExchangeRate] ([intFromCurrencyId])
	INCLUDE([intCurrencyExchangeRateId], [intToCurrencyId]); 
GO

CREATE NONCLUSTERED INDEX [IX_tblSMCurrencyExchangeRate_intToCurrencyId] 
	ON [dbo].[tblSMCurrencyExchangeRate] ([intToCurrencyId])
	INCLUDE([intCurrencyExchangeRateId], [intFromCurrencyId]); 
GO