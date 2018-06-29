CREATE TABLE [dbo].[tblCTCleanCostOtherExpense]
(
	[intOtherExpenseId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
	[intCleanCostId] INT,
	[intExpenseTypeId] INT,
	[dblValueInCCCurrency] NUMERIC(18,6),
	[intCCCurrencyId] INT,
	[dblQuantity] NUMERIC(18,6),
	[intQuantityUOMId] INT,
	[dblValueInOtherCurrency] NUMERIC(18,6),
	[intOtherCurrencyId] INT,
	[dblFX] NUMERIC(18,6),
	
	CONSTRAINT [PK_tblCTCleanCostOtherExpense_intOtherExpenseId] PRIMARY KEY CLUSTERED ([intOtherExpenseId] ASC),
	CONSTRAINT [FK_tblCTCleanCostOtherExpense_tblCTCleanCost_intCleanCostId] FOREIGN KEY ([intCleanCostId]) REFERENCES [tblCTCleanCost]([intCleanCostId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTCleanCostOtherExpense_tblCTCleanCostExpenseType_intExpenseTypeId] FOREIGN KEY ([intExpenseTypeId]) REFERENCES [tblCTCleanCostExpenseType]([intExpenseTypeId]),
	CONSTRAINT [FK_tblCTCleanCostOtherExpense_tblSMCurrency_intCCCurrencyId] FOREIGN KEY ([intCCCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTCleanCostOtherExpense_tblSMCurrency_intOtherCurrencyId] FOREIGN KEY ([intOtherCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTCleanCostOtherExpense_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intQuantityUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])

)
