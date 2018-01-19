CREATE TABLE [dbo].[tblSTRetailAccount]
(
	[intRetailAccountId] INT NOT NULL IDENTITY,
    [intStoreId] INT NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [intRetailAccountNumber] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTRetailAccount] PRIMARY KEY CLUSTERED ([intRetailAccountId] ASC),
    CONSTRAINT [AK_tblSTRetailAccount_intStoreId_intEntityId_intRetailAccountNumber] UNIQUE NONCLUSTERED ([intStoreId],[intEntityId],[intRetailAccountNumber] ASC), 
    CONSTRAINT [FK_tblSTRetailAccount_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]),
	CONSTRAINT [FK_tblSTRetailAccount_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
);