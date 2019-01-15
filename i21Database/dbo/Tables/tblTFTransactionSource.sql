CREATE TABLE [dbo].[tblTFTransactionSource]
(
	[intTransactionSourceId] INT IDENTITY(1,1) NOT NULL,
	[strTransactionSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
	[intMasterId] INT NULL,
	CONSTRAINT [PK_tblTFTransactionSource] PRIMARY KEY ([intTransactionSourceId])
)
