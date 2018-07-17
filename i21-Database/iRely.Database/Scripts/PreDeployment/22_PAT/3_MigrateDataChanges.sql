PRINT N'***** BEGIN  Change Transfer Type from string to int (Patronage) *****'

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tblPATTransfer')
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tblPATTransfer' AND [COLUMN_NAME] = N'intTransferType')
	BEGIN
		EXEC('ALTER TABLE [dbo].[tblPATTransfer] ADD [intTransferType] INT NULL')
		
		EXEC('UPDATE A SET intTransferType = B.intTransferType FROM tblPATTransfer A JOIN tblPATTransferType B on A.strTransferType = B.strTransferType')
		
		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = N'tblPATTransfer' AND [COLUMN_NAME] = N'strTransferType')
			EXEC('ALTER TABLE [dbo].[tblPATTransfer] DROP COLUMN [strTransferType]')
	END
END

PRINT N'***** END Change Transfer Type from string to int (Patronage) *****'