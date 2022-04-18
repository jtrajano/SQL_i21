CREATE TABLE [dbo].[tblQMCuppingSession]
(
	[intCuppingSessionId] 		INT IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] 			INT NULL DEFAULT ((1)),
    [strCuppingSessionNumber] 	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dtmCuppingDate] 			DATETIME NULL,
	[dtmCuppingTime] 			DATETIME NULL,

	CONSTRAINT [PK_tblQMCuppingSession] PRIMARY KEY ([intCuppingSessionId])
)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMCuppingSession_strCuppingSessionNumber] ON [dbo].[tblQMCuppingSession](strCuppingSessionNumber)
GO
CREATE TRIGGER trgCuppingSessionNumber
	ON dbo.tblQMCuppingSession
AFTER INSERT
AS

DECLARE @inserted TABLE(intCuppingSessionId INT)
DECLARE @count INT = 0
DECLARE @intCuppingSessionId INT
DECLARE @strCuppingSessionNumber NVARCHAR(50)
DECLARE @intMaxCount INT = 0
DECLARE @intStartingNumberId INT = (SELECT TOP 1 intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType = 'Cupping Session')

INSERT INTO @inserted
SELECT intCuppingSessionId FROM INSERTED WHERE strCuppingSessionNumber IS NULL ORDER BY intCuppingSessionId

WHILE EXISTS (SELECT TOP 1 NULL FROM @inserted) AND ISNULL(@intStartingNumberId, 0) > 0
	BEGIN
		SELECT TOP 1 @intCuppingSessionId = intCuppingSessionId FROM @inserted
		SET @strCuppingSessionNumber = NULL

		EXEC dbo.uspSMGetStartingNumber @intStartingNumberId, @strCuppingSessionNumber OUT, NULL

		IF(@strCuppingSessionNumber IS NOT NULL)
			BEGIN
				IF EXISTS (SELECT NULL FROM tblQMCuppingSession WHERE strCuppingSessionNumber = @strCuppingSessionNumber)
					BEGIN
						SET @strCuppingSessionNumber = NULL
				
						UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
						EXEC uspSMGetStartingNumber @intStartingNumberId, @strCuppingSessionNumber OUT, NULL			
					END

				UPDATE tblQMCuppingSession
				SET strCuppingSessionNumber = @strCuppingSessionNumber
				WHERE intCuppingSessionId = @intCuppingSessionId
			END

			DELETE FROM @inserted
			WHERE intCuppingSessionId = @intCuppingSessionId
	END
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_tblQMCuppingSession_strCuppingSessionNumber]
	ON dbo.tblQMCuppingSession(strCuppingSessionNumber)
	WHERE strCuppingSessionNumber IS NOT NULL;
GO