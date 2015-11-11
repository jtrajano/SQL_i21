CREATE TABLE [dbo].[tblPATAdjustVolume]
(
	[intAdjustmentId] INT NOT NULL IDENTITY, 
	[intCustomerId] INT NULL,
    [dtmAdjustmentDate] DATETIME NULL, 
    [strAdjustmentNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATAdjustVolume] PRIMARY KEY ([intAdjustmentId]) 
)

GO

CREATE TRIGGER [dbo].[trgAdjustmentNo]
    ON [dbo].[tblPATAdjustVolume]
    AFTER INSERT
    AS
	DECLARE @inserted TABLE(intAdjustmentId INT)
	DECLARE @intAdjustmentId INT
	DECLARE @strAdjustmentNo NVARCHAR(50)
	DECLARE @intMaxCount INT = 0

	INSERT INTO @inserted
	SELECT intAdjustmentId FROM INSERTED ORDER BY intAdjustmentId
	WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
	BEGIN
		SELECT TOP 1 @intAdjustmentId = intAdjustmentId FROM @inserted

		EXEC uspSMGetStartingNumber 85, @strAdjustmentNo OUT

		IF(@strAdjustmentNo IS NOT NULL)
		BEGIN
			IF EXISTS (SELECT NULL FROM tblPATAdjustVolume WHERE strAdjustmentNo = @strAdjustmentNo)
				BEGIN
					SET @strAdjustmentNo = NULL
					SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strAdjustmentNo, 5, 10))) FROM tblPATAdjustVolume
					UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 85
					EXEC uspSMGetStartingNumber 85, @strAdjustmentNo OUT
				END
		
			UPDATE tblPATAdjustVolume
				SET tblPATAdjustVolume.strAdjustmentNo = @strAdjustmentNo
			FROM tblPATAdjustVolume A
			WHERE A.intAdjustmentId = @intAdjustmentId
		END

		DELETE FROM @inserted
		WHERE intAdjustmentId = @intAdjustmentId
	END