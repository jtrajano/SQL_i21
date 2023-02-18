﻿CREATE TABLE [dbo].[tblARReserveDetail]
( 
    [intReserveDetailId]    INT	IDENTITY (1, 1) NOT NULL,
    [intReserveId]	        INT	NOT NULL,
    [intInvoiceId]	        INT NOT NULL,
    [strCustomerName]	    NVARCHAR(100) NOT NULL,
    [dblCreditLimit]        NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [strInvoiceNumber]	    NVARCHAR(100) NOT NULL,
    [strGLLocation]	        NVARCHAR(100) NOT NULL,
    [strGLLineOfBusiness]   NVARCHAR(100) NOT NULL,
    [dbl30Days]             NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [dbl60Days]             NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [dbl90Days]             NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [dbl120Days]           NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [dbl30DaysReserve]      NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [dbl60DaysReserve]      NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [dbl90DaysReserve]      NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [dbl120DaysReserve]    NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [dblTotalReserve]       NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [dblNewReserve]         NUMERIC(18, 6) NOT NULL DEFAULT(0),
    [intConcurrencyId]	    INT	NOT NULL CONSTRAINT [DF_tblARReserveDetail_intConcurrencyId] DEFAULT ((1)),
);

GO