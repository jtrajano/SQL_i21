CREATE TABLE [dbo].[tblPATCancelEquity]
(
	[intCancelId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [dtmCancelDate] DATETIME NULL, 
    [strCancelNo] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
    [intFromCustomerId] INT NULL, 
    [intToCustomerId] INT NULL, 
    [intFiscalYearId] INT NULL, 
    [strCancelBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblCancelByAmount] NUMERIC(18, 6) NULL, 
    [dblCancelLessAmount] NUMERIC(18, 6) NULL, 
    [intIncludeEquityReserve] INT NULL, 
	[ysnPosted] BIT NULL DEFAULT 0,
    [intConcurrencyId] INT NULL DEFAULT 0
)

GO

CREATE TRIGGER [dbo].[trgCancelNo]
ON [dbo].[tblPATCancelEquity]
AFTER INSERT
AS

DECLARE @inserted TABLE(intCancelId INT)
DECLARE @intCancelId INT
DECLARE @strCancelNo NVARCHAR(10)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intCancelId FROM INSERTED ORDER BY intCancelId
WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intCancelId = intCancelId FROM @inserted

	EXEC uspSMGetStartingNumber 89 , @strCancelNo OUT

	IF(@strCancelNo IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblPATCancelEquity WHERE strCancelNo = @strCancelNo)
			BEGIN
				SET @strCancelNo = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strCancelNo, 5, 10))) FROM tblPATCancelEquity
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 89
				EXEC uspSMGetStartingNumber 89, @strCancelNo OUT
			END
		
		UPDATE tblPATCancelEquity
			SET tblPATCancelEquity.strCancelNo = @strCancelNo
		FROM tblPATCancelEquity A
		WHERE A.intCancelId = @intCancelId
	END

	DELETE FROM @inserted
	WHERE intCancelId = @intCancelId
END