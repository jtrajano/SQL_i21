CREATE TABLE [dbo].[tblRKReconciliationBrokerStatementImport]
(
	[intReconciliationBrokerStatementImportId] INT IDENTITY(1,1) NOT NULL,
	[strName] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strAccountNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strFutMarketName] nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,	
	[strBuySell] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intNoOfContract] int,
	[strFutureMonth] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblPrice] decimal(24,10) ,	
	[dtmFilledDate] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] int,
	[strImportStatus] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strErrMessage] nvarchar(max) COLLATE Latin1_General_CI_AS NULL
)