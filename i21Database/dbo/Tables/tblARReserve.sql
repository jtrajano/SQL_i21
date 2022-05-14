CREATE TABLE [dbo].[tblARReserve]
( 
    [intReserveId]	                INT	IDENTITY (1, 1) NOT NULL,
    [intFiscalYearId]	            INT NOT NULL,
    [intGLFiscalYearPeriodId]       INT NOT NULL,
    [dtmPostDate]                   DATETIME NOT NULL,
    [dblReserveBucket30Percentage]	NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblReserveBucket60Percentage]	NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblReserveBucket90Percentage]	NUMERIC(18, 6) NOT NULL DEFAULT(0),
	[dblReserveBucket120Percentage]	NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [intConcurrencyId]	INT	NOT NULL CONSTRAINT [DF_tblARReserve_intConcurrencyId] DEFAULT ((1)),
);

GO