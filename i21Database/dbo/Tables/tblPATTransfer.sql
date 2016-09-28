CREATE TABLE [dbo].[tblPATTransfer]
(
	[intTransferId] INT NOT NULL IDENTITY,
	[intTransferType] INT NULL,
	[strTransferNo] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTransferDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [dtmTransferDate] DATETIME NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATTransfer] PRIMARY KEY ([intTransferId]) 
)

GO

CREATE TRIGGER [dbo].[trgTransferNo]
ON [dbo].[tblPATTransfer]
AFTER INSERT
AS

DECLARE @inserted TABLE(intTransferId INT)
DECLARE @intTransferId INT
DECLARE @strTransferNo NVARCHAR(10)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intTransferId FROM INSERTED ORDER BY intTransferId
WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intTransferId = intTransferId FROM @inserted

	EXEC uspSMGetStartingNumber 80, @strTransferNo OUT

	IF(@strTransferNo IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblPATTransfer WHERE strTransferNo = @strTransferNo)
			BEGIN
				SET @strTransferNo = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strTransferNo, 5, 10))) FROM tblPATTransfer
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 80
				EXEC uspSMGetStartingNumber 80, @strTransferNo OUT
			END
		
		UPDATE tblPATTransfer
			SET tblPATTransfer.strTransferNo = @strTransferNo
		FROM tblPATTransfer A
		WHERE A.intTransferId = @intTransferId
	END

	DELETE FROM @inserted
	WHERE intTransferId = @intTransferId
END