CREATE TABLE [dbo].[tblRKElectronicPricing]
(
	[intElectronicPricingId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
    [intMarketExchangeId] INT NOT NULL, 
    [strSybmolPrefix] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intNumberofForwardPeriods] INT NOT NULL DEFAULT 0, 
    [intReturnCurrency] INT NULL, 
    [intConvertCurrency] INT NULL, 
    [strMarketSymbolCode] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
    [dblConversionRate] NUMERIC(18, 6) NULL, 
    CONSTRAINT [PK_tblRKElectronicPricing_intElectronicPricingId] PRIMARY KEY ([intElectronicPricingId]), 
    CONSTRAINT [FK_tblRKElectronicPricing_tblRKFutureMarket] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKElectronicPricing_tblRKMarketExchange] FOREIGN KEY ([intMarketExchangeId]) REFERENCES [tblRKMarketExchange]([intMarketExchangeId]) 
)
