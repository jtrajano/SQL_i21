﻿CREATE TABLE [dbo].[tblRKElectonicPricing]
(
	[intElectronicPricingId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
    [intNumberofForwardPeriods] INT NOT NULL DEFAULT 0, 
    [intReturnCurrency] INT NULL, 
    [intConvertCurrency] INT NULL, 
    [strSymbolPrefix] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strMarketSymbol] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    CONSTRAINT [PK_tblRKElectonicPricing_intElectronicPricingId] PRIMARY KEY ([intElectronicPricingId]), 
    CONSTRAINT [FK_tblRKElectonicPricing_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY (intFutureMarketId) REFERENCES [tblRKFutureMarket]([intFutureMarketId]) 
)
