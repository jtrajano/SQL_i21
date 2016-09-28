﻿PRINT N'***** BEGIN CREATE STATIC TABLE FOR TRANSFER TYPES (PATRONAGE) *****'
GO
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATTransferType')
BEGIN
	CREATE TABLE [dbo].[tblPATTransferType]
	(
		[intTransferTypeId] INT NOT NULL IDENTITY,
		[intTransferType] INT NOT NULL,
		[strTransferType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		CONSTRAINT [PK_intTransferTypeId] PRIMARY KEY ([intTransferTypeId])
	)
END
GO
PRINT N'***** END CREATE STATIC TABLE FOR TRANSFER TYPES (PATRONAGE) *****'