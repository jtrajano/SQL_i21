CREATE TABLE [dbo].[tblCTCleanCostBillExpense]
(
	[intBillExpenseId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
	[intCleanCostId] INT,
	[intExpenseId] INT,
	[intItemId] INT,
	[dblValueInCCCurrency] NUMERIC(18,6),
	[dblQuantity] NUMERIC(18,6),
	[intQuantityUOMId] INT,
	[intCCCurrencyId] INT,
	[dblValueInOtherCurrency] NUMERIC(18,6),
	[intOtherCurrencyId] INT,
	[dblFX] NUMERIC(18,6),
	[ysnValueEnable] BIT,
	[ysnQuantityEnable] BIT,
	[ysnOtherCurrencyEnable] BIT,

	CONSTRAINT [PK_tblCTCleanCostBillExpense_intBillExpenseId] PRIMARY KEY CLUSTERED ([intBillExpenseId] ASC),
	CONSTRAINT [FK_tblCTCleanCostBillExpense_tblCTCleanCost_intCleanCostId] FOREIGN KEY ([intCleanCostId]) REFERENCES [tblCTCleanCost]([intCleanCostId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTCleanCostBillExpense_tblSMCurrency_intCCCurrencyId] FOREIGN KEY ([intCCCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTCleanCostBillExpense_tblSMCurrency_intOtherCurrencyId] FOREIGN KEY ([intOtherCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTCleanCostBillExpense_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
