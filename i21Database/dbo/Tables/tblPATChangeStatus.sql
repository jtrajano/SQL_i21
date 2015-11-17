CREATE TABLE [dbo].[tblPATChangeStatus]
(
	[intUpdateId] INT NOT NULL IDENTITY, 
    [dtmUpdateDate] DATETIME NULL, 
    [strUpdateNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [dtmLastActivityDate] DATETIME NULL, 
    [strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL, 
	[ysnPosted] BIT NULL DEFAULT 0,
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATChangeStatus] PRIMARY KEY ([intUpdateId]) 
)

GO

CREATE TRIGGER [dbo].[trgUpdateNo]
    ON [dbo].[tblPATChangeStatus]
    AFTER INSERT
	AS
	DECLARE @inserted TABLE(intUpdateId INT)
	DECLARE @intUpdateId INT
	DECLARE @strUpdateNo NVARCHAR(10)
	DECLARE @intMaxCount INT = 0

    INSERT INTO @inserted
	SELECT intUpdateId FROM INSERTED ORDER BY intUpdateId
	WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
	BEGIN
		SELECT TOP 1 @intUpdateId = intUpdateId FROM @inserted

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
			WHERE A.intUpdateId = @intUpdateId
		END

		DELETE FROM @inserted
		WHERE intUpdateId = @intUpdateId
	END
