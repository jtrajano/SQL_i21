CREATE TABLE [dbo].[tblTFTransactionDynamicIL]
(
	[intTransactionDynamicId] INT IDENTITY NOT NULL,
	[intTransactionId] INT NOT NULL,
	[strCustomerBillToAddress] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerBillToCity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerBillToState] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerBillToZipCode] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [FK_tblTFTransactionDynamicIL_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE, 
    CONSTRAINT [PK_tblTFTransactionDynamicIL] PRIMARY KEY ([intTransactionDynamicId])
)
