CREATE TABLE [dbo].[tblRKMarketExchange]
(
	[intMarketExchangeId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    [strMarketSymbol] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [strExtchangeCode] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblRKMarketExchange] PRIMARY KEY ([intMarketExchangeId]) 
)
