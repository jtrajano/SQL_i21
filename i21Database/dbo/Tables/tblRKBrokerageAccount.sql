CREATE TABLE [dbo].[tblRKBrokerageAccount]
(
	[intBrokerageAccountId] INT IDENTITY(1,1) NOT NULL, 
    [intBrokerId] INT NOT NULL, 
    [strAccountNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NOT NULL, 
    [intInstrumentTypeId] INT NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKBrokerageAccount_intBrokerageAccountId] PRIMARY KEY ([intBrokerageAccountId]), 
    CONSTRAINT [UK_tblRKBrokerageAccount_intBrokerId_strAccountNumber] UNIQUE ([intBrokerId], [strAccountNumber])
)
