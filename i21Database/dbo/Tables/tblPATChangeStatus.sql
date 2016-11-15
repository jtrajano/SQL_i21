CREATE TABLE [dbo].[tblPATChangeStatus]
(
	[intChangeStatusId] INT NOT NULL IDENTITY, 
    [dtmUpdateDate] DATETIME NULL, 
    [strUpdateNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [dtmLastActivityDate] DATETIME NULL, 
    [strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATChangeStatus] PRIMARY KEY ([intChangeStatusId]) 
)

GO

CREATE TRIGGER [dbo].[trgUpdateNo]
ON [dbo].[tblPATChangeStatus]
AFTER INSERT
AS
DECLARE @inserted TABLE(intChangeStatusId INT)
DECLARE @intChangeStatusId INT
DECLARE @strUpdateNo NVARCHAR(10)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intChangeStatusId FROM INSERTED ORDER BY intChangeStatusId
WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intChangeStatusId = intChangeStatusId FROM @inserted

	EXEC uspSMGetStartingNumber 87, @strUpdateNo OUT

	IF(@strUpdateNo IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblPATChangeStatus WHERE strUpdateNo = @strUpdateNo)
			BEGIN
				SET @strUpdateNo = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(@strUpdateNo, 5, 10))) FROM tblPATTransfer
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 87
				EXEC uspSMGetStartingNumber 87, @strUpdateNo OUT
			END
		
		UPDATE tblPATChangeStatus
			SET tblPATChangeStatus.strUpdateNo = @strUpdateNo
		FROM tblPATChangeStatus A
		WHERE A.intChangeStatusId = @intChangeStatusId
	END

	DELETE FROM @inserted
	WHERE intChangeStatusId = @intChangeStatusId
END
