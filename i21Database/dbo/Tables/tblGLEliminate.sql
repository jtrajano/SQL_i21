CREATE TABLE [dbo].[tblGLEliminate]
( 
    [intEliminateId]	        INT	IDENTITY (1, 1) NOT NULL,
    [intFiscalYearId]	        INT NOT NULL,
    [intGLFiscalYearPeriodId]   INT NOT NULL,
    [intLedgerId]               INT NOT NULL,
    [dtmPostDate]               DATETIME NOT NULL,
    [dtmReverseDate]            DATETIME NOT NULL,
    [intConcurrencyId]	        INT	NOT NULL DEFAULT ((1))
);

GO