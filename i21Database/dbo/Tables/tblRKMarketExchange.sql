CREATE TABLE [dbo].[tblRKMarketExchange]
(
	[intMarketExchangeId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strMarketSymbol] NVARCHAR(20) NOT NULL, 
    [strExchangeCode] NVARCHAR(5) NOT NULL, 
    CONSTRAINT [PK_tblRKMarketExchange_intMarketExchangeId] PRIMARY KEY ([intMarketExchangeId]) 
)
