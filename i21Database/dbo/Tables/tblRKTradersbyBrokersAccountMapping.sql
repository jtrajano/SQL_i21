CREATE TABLE [dbo].[tblRKTradersbyBrokersAccountMapping]
(
	[intTradersbyBrokersAccountId] INT IDENTITY(1,1) NOT NULL,   
    [intConcurrencyId] INT NOT NULL, 
    [intBrokerageAccountId] INT NOT NULL, 
    [intSalespersonId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKTradersbyBrokersAccountMapping_intTradersbyBrokersAccountId] PRIMARY KEY ([intTradersbyBrokersAccountId]), 
    CONSTRAINT [FK_tblRKTradersbyBrokersAccountMapping_tblRKBrokerageAccount_intBrokerageAccountId] FOREIGN KEY ([intBrokerageAccountId]) REFERENCES [tblRKBrokerageAccount]([intBrokerageAccountId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKTradersbyBrokersAccountMapping_tblARSalesperson_intSalesersonId] FOREIGN KEY ([intSalespersonId]) REFERENCES [tblARSalesperson]([intEntitySalespersonId])
)
