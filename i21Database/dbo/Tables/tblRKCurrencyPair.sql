CREATE TABLE [dbo].[tblRKCurrencyPair](
	intCurrencyPairId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	intConcurrencyId INT NOT NULL,
	intFromCurrencyId INT NULL,
	intToCurrencyId INT NULL,
	dtmCreateDateTime DATETIME NULL DEFAULT(GETDATE()),
	CONSTRAINT [FK_tblRKCurrencyPair_tblSMCurrency_intFromCurrencyId] FOREIGN KEY ([intFromCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblRKCurrencyPair_tblSMCurrency_intToCurrencyId] FOREIGN KEY ([intToCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
)
