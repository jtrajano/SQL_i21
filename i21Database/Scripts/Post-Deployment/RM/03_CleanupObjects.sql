PRINT 'Begin Risk Clean up Objects - Drop obsolete objects'
GO

IF OBJECT_ID('vyuRKGetMoneyMarket','v') IS NOT NULL
	DROP VIEW vyuRKGetMoneyMarket;
GO

IF OBJECT_ID('vyuRKGetBankBalance','v') IS NOT NULL
	DROP VIEW vyuRKGetBankBalance;
GO

PRINT 'End Risk Clean up Objects - Drop obsolete objects'
GO
