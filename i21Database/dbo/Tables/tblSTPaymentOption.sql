CREATE TABLE [dbo].[tblSTPaymentOption]
(
	[intPaymentOptionId] INT NOT NULL IDENTITY, 
    [intStoreId] INT NOT NULL, 
    [strPaymentOptionId] NVARCHAR(15) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
	[intItemId] INT NULL, 
    [intAccountId] INT NULL, 
    [strRegisterMop] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,  
	[ysnDepositable] BIT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTPaymentOption] PRIMARY KEY CLUSTERED ([intPaymentOptionId]), 
    CONSTRAINT [AK_tblSTPaymentOption_intStoreId_strPaymentOptionId] UNIQUE NONCLUSTERED ([intStoreId],[strPaymentOptionId]), 
	--CONSTRAINT [AK_tblSTPaymentOption_intStoreId_strRegisterMop] UNIQUE NONCLUSTERED ([intStoreId],[strRegisterMop]),
	CONSTRAINT [FK_tblSTPaymentOption_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTPaymentOption_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
	CONSTRAINT [FK_tblSTPaymentOption_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
 );
 
 GO

 CREATE UNIQUE NONCLUSTERED INDEX [UK_tblSTPaymentOption_intStoreId_strRegisterMop]
  ON dbo.tblSTPaymentOption
  (
	[intStoreId]
	,[strRegisterMop]
  )
  WHERE [strRegisterMop] IS NOT NULL
  AND [strRegisterMop] <> ''