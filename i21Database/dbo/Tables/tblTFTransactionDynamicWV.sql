CREATE TABLE [dbo].[tblTFTransactionDynamicWV]
(
	[intTransactionDynamicId] INT IDENTITY NOT NULL, 
    [intTransactionId] INT NOT NULL, 
    [strWVLegalCustomerName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTransactionDynamicWV] PRIMARY KEY ([intTransactionDynamicId]) 
)
