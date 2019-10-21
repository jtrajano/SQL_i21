CREATE TABLE [dbo].[tblRKReconciliationBrokerStatementHeader]
(
	[intReconciliationBrokerStatementHeaderId] INT IDENTITY(1,1) NOT NULL,
    [intConcurrencyId] INT NOT NULL, 
	[dtmReconciliationDate] DATETIME NOT NULL, 
	[dtmFilledDate] DATETIME NOT NULL, 
    [intEntityId] INT  NULL, 
	[intBrokerageAccountId] INT NULL,
    [intFutureMarketId] INT  NULL, 
    [intCommodityId] INT  NULL, 
	[strImportStatus]  NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strComments]  NVARCHAR(Max) COLLATE Latin1_General_CI_AS NULL, 
	[ysnFreezed] BIT NULL, 
    CONSTRAINT [PK_tblRKReconciliationBrokerStatementHeader_intReconciliationBrokerStatementHeaderId] PRIMARY KEY (intReconciliationBrokerStatementHeaderId),	
    CONSTRAINT [FK_tblRKReconciliationBrokerStatementHeader_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblRKReconciliationBrokerStatementHeader_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblRKReconciliationBrokerStatementHeader_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId])
)