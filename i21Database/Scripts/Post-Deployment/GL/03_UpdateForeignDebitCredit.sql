GO

PRINT 'STARTED UPDATING GL ENTRIES FOREIGN DEBIT/CREDIT WITH EXCHANGE RATE OF 1'
GO

UPDATE [dbo].[tblGLDetail]
SET
	[dblDebitForeign] = dblDebit
WHERE [dblExchangeRate] = 1
	AND ISNULL([dblDebitForeign], 0) = 0 AND ISNULL([dblCreditForeign], 0) = 0
	AND LEN(FLOOR(ISNULL([dblDebit], 0))) <= 9
	AND [dblDebit] <> 0
GO

UPDATE [dbo].[tblGLDetail]
SET
	[dblCreditForeign] = dblCredit
WHERE [dblExchangeRate] = 1
	AND ISNULL([dblCreditForeign], 0) = 0 AND ISNULL([dblDebitForeign], 0) = 0
	AND LEN(FLOOR(ISNULL([dblCredit], 0))) <= 9
	AND [dblCredit] <> 0
GO

PRINT 'FINISHED UPDATING GL ENTRIES FOREIGN DEBIT/CREDIT WITH EXCHANGE RATE OF 1'
GO