PRINT N'***** BEGIN Create Static Table for Transfer Types (Patronage) *****'
GO
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATTransferType')
BEGIN
	CREATE TABLE [dbo].[tblPATTransferType]
	(
		[intTransferTypeId] INT NOT NULL IDENTITY,
		[intTransferType] INT NULL,
		[strTransferType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		CONSTRAINT [PK_intTransferTypeId] PRIMARY KEY ([intTransferTypeId])
	)
END
GO
PRINT N'***** END Create Static Table for Transfer Types (Patronage) *****'