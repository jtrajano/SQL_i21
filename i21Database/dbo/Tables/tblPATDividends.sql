CREATE TABLE [dbo].[tblPATDividends]
(
	[intDividendId] INT NOT NULL IDENTITY, 
    [intFiscalYearId] INT NULL, 
    [dtmProcessDate] DATETIME NULL, 
    [dtmProcessingFrom] DATETIME NULL, 
    [dtmProcessingTo] DATETIME NULL, 
    [dblProcessedDays] NUMERIC(18, 6) NULL, 
    [strDividendNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblMinimumDividend] NUMERIC(18, 6) NULL, 
    [ysnProrateDividend] BIT NULL, 
    [dtmCutoffDate] DATETIME NULL, 
    [dblFederalTaxWithholding] NUMERIC(18, 6) NULL, 
	[ysnPosted] BIT NULL DEFAULT 0,
	[ysnVoucherProcessed] BIT NULL DEFAULT 0,
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
DECLARE @strDividendNo NVARCHAR(50)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intDividendId FROM INSERTED ORDER BY intDividendId
WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intDividendId = intDividendId FROM @inserted

	EXEC uspSMGetStartingNumber 82, @strDividendNo OUT

	IF(@strDividendNo IS NOT NULL)
	BEGIN
		
		UPDATE tblPATDividends
			SET tblPATDividends.[strDividendNo] = @strDividendNo
		FROM tblPATDividends A
		WHERE A.intDividendId = @intDividendId
	END

	DELETE FROM @inserted
	WHERE intDividendId = @intDividendId
END