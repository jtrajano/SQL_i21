CREATE TABLE [dbo].[tblSTPaidOut]
(
	[intPaidOutId] INT NOT NULL IDENTITY,
    [intStoreId] INT NOT NULL, 
    [strPaidOutId] NCHAR(15) NOT NULL, 
    [strDescription] NCHAR(40) NULL, 
    [intAccountId] INT NOT NULL, 
    [intPaymentMethodId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTPaidOut_intPaidoutId] PRIMARY KEY CLUSTERED ([intPaidOutId] ASC), 
    CONSTRAINT [AK_tblSTPaidOut_strPaidoutId] UNIQUE NONCLUSTERED ([intStoreId],[strPaidOutId] ASC), 
    CONSTRAINT [FK_tblSTPaidOut_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]), 
    CONSTRAINT [FK_tblSTPaidOut_tblSTPaymentMethod] FOREIGN KEY ([intPaymentMethodId]) REFERENCES [tblSTPaymentMethod]([intPaymentMethodId]), 
    CONSTRAINT [FK_tblSTPaidOut_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]) 
);
