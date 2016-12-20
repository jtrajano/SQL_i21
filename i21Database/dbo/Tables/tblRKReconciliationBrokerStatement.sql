CREATE TABLE [dbo].[tblRKReconciliationBrokerStatement]
(
	[intReconciliationBrokerStatementId] INT IDENTITY(1,1) NOT NULL,
	[intReconciliationBrokerStatementHeaderId] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL, 
	[strName] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strAccountNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strFutMarketName] nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strBuySell] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intNoOfContract] int,
	[strFutureMonth] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,	
	[dblPrice] decimal(24,10) ,
	[strReference] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strStatus] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmFilledDate] DATETIME NULL,
	[strErrMessage] nvarchar(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intFutOptTrancationId] int NULL 

	CONSTRAINT [PK_tblRKReconciliationBrokerStatement_intReconciliationBrokerStatementId] PRIMARY KEY (intReconciliationBrokerStatementId),	
    CONSTRAINT [FK_tblRKReconciliationBrokerStatement_tblRKReconciliationBrokerStatementHeader_intReconciliationBrokerStatementHeaderId] FOREIGN KEY (intReconciliationBrokerStatementHeaderId) REFERENCES [tblRKReconciliationBrokerStatementHeader](intReconciliationBrokerStatementHeaderId) ON DELETE CASCADE,
)