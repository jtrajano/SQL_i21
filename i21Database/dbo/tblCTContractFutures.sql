CREATE TABLE [dbo].[tblCTContractFutures]
(
	[intContractFuturesId] INT IDENTITY(1,1) NOT NULL,
	[intContractDetailId] INT NOT NULL,	
	[intFutOptTransactionId] INT NULL, 
    [intFutureMarketId] INT NULL, 
	[dblNoOfLots] NUMERIC(18, 6) NULL, 
    [dblQuantity] NUMERIC(18, 6) NULL,
	[dblHedgeNoOfLots] NUMERIC(18, 6) NULL, 
	[dblHedgePrice] NUMERIC(18, 6) NULL, 
    [intHedgeFutureMonthId] INT NULL,     
	[intBrokerId] INT NULL, 
    [intBrokerageAccountId] INT NULL, 
	[ysnAA] BIT NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCTContractFutures] PRIMARY KEY ([intContractFuturesId]),
	CONSTRAINT [FK_tblCTContractFutures_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId])   
)