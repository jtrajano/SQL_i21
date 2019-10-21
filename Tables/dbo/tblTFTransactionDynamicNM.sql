CREATE TABLE [dbo].[tblTFTransactionDynamicNM]
(
	[intTransactionId] INT NOT NULL , 
    [intTransactionDynamicId] INT IDENTITY NOT NULL, 
    [strNMCounty] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strNMLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTransactionDynamicNM] PRIMARY KEY ([intTransactionDynamicId]) 
)
