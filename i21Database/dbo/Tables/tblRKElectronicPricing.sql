CREATE TABLE [dbo].[tblRKElectronicPricing]
(
	[intElectronicPricingId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
    [intNumberofForwardPeriods] INT NOT NULL DEFAULT 0, 
    [intReturnCurrency] INT NULL, 
    [intConvertCurrency] INT NULL, 
    [strSymbolPrefix] NVARCHAR(5) NOT NULL, 
    [intMarketExchangeId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKElectronicPricing_intElectronicPricingId] PRIMARY KEY ([intElectronicPricingId]), 
    CONSTRAINT [FK_tblRKElectronicPricing_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY (intFutureMarketId) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKElectronicPricing_tblRKMarketExchange_intMarketExchangeId] FOREIGN KEY ([intMarketExchangeId]) REFERENCES [tblRKMarketExchange]([intMarketExchangeId]) 
)
