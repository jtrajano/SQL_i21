CREATE TABLE [dbo].[tblPATDividends]
(
	[intDividendId] INT NOT NULL IDENTITY, 
    [intFiscalYearId] INT NULL, 
    [dtmProcessDate] DATETIME NULL, 
    [dtmProcessingFrom] DATETIME NULL, 
    [dtmProcessingTo] DATETIME NULL, 
    [dblProcessedDays] NUMERIC(18, 6) NULL, 
    [dblDividendNo] NUMERIC(18, 6) NULL, 
    [dblMinimumDividend] NUMERIC(18, 6) NULL, 
    [ysnProrateDividend] BIT NULL, 
    [dtmCutoffDate] DATETIME NULL, 
    [dblFederalTaxWithholding] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATDividends] PRIMARY KEY ([intDividendId]) 
)

GO

CREATE TRIGGER [dbo].[trgDividendNo]
ON [dbo].[tblPATDividends]
AFTER INSERT
AS

DECLARE @inserted TABLE(intDividendId INT)
DECLARE @intDividendId INT
DECLARE @dblDividendNo NUMERIC(18,6)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intDividendId FROM INSERTED ORDER BY intDividendId
WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intDividendId = intDividendId FROM @inserted

	EXEC uspSMGetStartingNumber 82, @dblDividendNo OUT

	IF(@dblDividendNo IS NOT NULL)
	BEGIN
		
		UPDATE tblPATDividends
			SET tblPATDividends.dblDividendNo = @dblDividendNo
		FROM tblPATDividends A
		WHERE A.intDividendId = @intDividendId
	END

	DELETE FROM @inserted
	WHERE intDividendId = @intDividendId
END