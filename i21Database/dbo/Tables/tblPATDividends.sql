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
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATDividends] PRIMARY KEY ([intDividendId]) 
)