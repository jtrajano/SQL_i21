CREATE TABLE [dbo].[tblTFTransactionDynamicTX]
(
	[intTransactionDynamicId] INT NOT NULL IDENTITY, 
    [intTransactionId] INT NOT NULL, 
    [strTXPurchaserSignedStatementNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTransactionDynamicTX] PRIMARY KEY ([intTransactionDynamicId]), 
    CONSTRAINT [FK_tblTFTransactionDynamicTX_tblTFTransaction] FOREIGN KEY (intTransactionId) REFERENCES [tblTFTransaction]([intTransactionId])  ON DELETE CASCADE
)
