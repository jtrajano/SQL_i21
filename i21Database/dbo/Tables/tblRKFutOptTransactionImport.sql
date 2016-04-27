
CREATE TABLE [dbo].[tblRKFutOptTransactionImport]
(
	[intFutOptTransactionId] INT IDENTITY(1,1) NOT NULL,
	[dtmTransactionDate] DATETIME  NULL, 
    [intEntityId] INT  NULL, 
    [intBrokerageAccountId] INT  NULL, 
    [intFutureMarketId] INT  NULL, 
    [intInstrumentTypeId] INT NULL, 
    [intCommodityId] INT  NULL, 
    [intLocationId] INT  NULL, 
    [intTraderId] INT  NULL, 
    [intCurrencyId] INT  NULL, 
    [strInternalTradeNo] NVARCHAR(10) COLLATE Latin1_General_CI_AS  NULL, 
    [strBrokerTradeNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strBuySell] NVARCHAR(10) COLLATE Latin1_General_CI_AS  NULL, 
    [intNoOfContract] INT  NULL, 
    [intFutureMonthId] int NULL, 
	[intOptionMonthId] int NULL, 
    [strOptionType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [dblStrike] NUMERIC(18, 6) NULL, 
    [dblPrice] NUMERIC(18, 6)  NULL, 
    [strReference] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strStatus] NVARCHAR(250) COLLATE Latin1_General_CI_AS  NULL, 
    [dtmFilledDate] DATETIME NULL, 
    [strReserveForFix] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intBookId] INT NULL, 
    [intSubBookId] INT NULL, 
    [ysnOffset] BIT NULL,
	[intContractDetailId] INT NULL,
	[intConcurrencyId] int 
)

