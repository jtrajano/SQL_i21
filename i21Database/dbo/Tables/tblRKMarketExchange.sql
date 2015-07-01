CREATE TABLE [dbo].[tblRKMarketExchange]
(
	[intMarketExchangeId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strMarketExchange] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strExchangeInterfaceCode] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
    CONSTRAINT [PK_tblRKMarketExchange_intMarketExchangeId] PRIMARY KEY ([intMarketExchangeId]),
    CONSTRAINT [UK_tblRKMarketExchange_strMarketExchange_strExchangeInterfaceCode] UNIQUE ([strMarketExchange],[strExchangeInterfaceCode]) 
)
