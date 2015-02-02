CREATE TABLE [dbo].[tblSTPaymentOption]
(
	[intPaymentOptionId] INT NOT NULL IDENTITY, 
    [strPaymentOption] NVARCHAR COLLATE Latin1_General_CI_AS NOT NULL, 
    [intStoreId] INT NOT NULL, 
    [strPaymentOptionId] NVARCHAR(15) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
    [intAccountId] INT NULL, 
    [intRegisterMop] INT NULL, 
	[ysnDepositable] BIT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTPaymentOption] PRIMARY KEY CLUSTERED ([intPaymentOptionId]), 
    CONSTRAINT [AK_tblSTPaymentOption_intStoreId_strPaymentOptionId] UNIQUE NONCLUSTERED ([intStoreId],[strPaymentOption],[strPaymentOptionId]), 
	CONSTRAINT [FK_tblSTPaymentOption_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]),
    CONSTRAINT [FK_tblSTPaymentOption_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
 );
