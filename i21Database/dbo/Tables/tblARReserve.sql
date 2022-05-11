CREATE TABLE [dbo].[tblARReserve]
( 
    [intReserveId]	    INT	IDENTITY (1, 1) NOT NULL,
    [intInvoiceId]	    INT NOT NULL,
    [dblNewReserve]     NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [intConcurrencyId]	INT	NOT NULL CONSTRAINT [DF_tblARReserve_intConcurrencyId] DEFAULT ((1)),
);

GO