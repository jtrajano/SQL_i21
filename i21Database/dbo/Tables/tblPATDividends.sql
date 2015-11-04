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
