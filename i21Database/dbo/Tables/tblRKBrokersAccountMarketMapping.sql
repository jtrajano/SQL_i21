CREATE TABLE [dbo].[tblRKBrokersAccountMarketMapping]
(
	[intBrokersAccountMarketMapId] INT IDENTITY(1,1) NOT NULL, 
    [intBrokerageAccountId] INT NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKBrokersAccountMarketMapping_intBrokersAccountMarketMapId] PRIMARY KEY ([intBrokersAccountMarketMapId]), 
    CONSTRAINT [FK_tblRKBrokersAccountMarketMapping_tblRKBrokerageAccount_intBrokerageAccountId] FOREIGN KEY ([intBrokerageAccountId]) REFERENCES [tblRKBrokerageAccount]([intBrokerageAccountId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKBrokersAccountMarketMapping_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId])
)
