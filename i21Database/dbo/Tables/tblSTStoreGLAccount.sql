CREATE TABLE [dbo].[tblSTStoreGLAccount]
(
	[intStoreGLAccountId] INT NOT NULL IDENTITY, 
    [intStoreId] INT NOT NULL, 
    [strAccountDescription] NCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intAccountId] INT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblSTStoreGLAccount] PRIMARY KEY CLUSTERED ([intStoreGLAccountId] ASC),
	CONSTRAINT [FK_tblSTStoreGLAccount_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]), 
	CONSTRAINT [AK_tblSTStoreGLAccount_intStoreId_strAccountDescription] UNIQUE NONCLUSTERED ([intStoreId],[strAccountDescription] ASC), 
	CONSTRAINT [FK_tblSTStoreGLAccount_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
);
