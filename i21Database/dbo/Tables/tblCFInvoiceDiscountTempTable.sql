﻿CREATE TABLE [dbo].[tblCFInvoiceDiscountTempTable] (
    [intSalesPersonId]            INT             NULL,
    [intTermID]                   INT             NULL,
    [intBalanceDue]               INT             NULL,
    [intDiscountDay]              INT             NULL,
    [intDayofMonthDue]            INT             NULL,
    [intDueNextMonth]             INT             NULL,
    [intSort]                     INT             NULL,
    [strTerm]                     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTermType]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTermCode]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDiscountDate]             DATETIME        NULL,
    [dtmDueDate]                  DATETIME        NULL,
    [dtmInvoiceDate]              DATETIME        NULL,
    [dblDiscountRate]             NUMERIC (18, 6) NULL,
    [dblDiscount]                 NUMERIC (18, 6) NULL,
    [dblAccountTotalAmount]       NUMERIC (18, 6) NULL,
    [dblAccountTotalDiscount]     NUMERIC (18, 6) NULL,
    [dblAccountTotalLessDiscount] NUMERIC (18, 6) NULL,
    [dblDiscountEP]               NUMERIC (18, 6) NULL,
    [dblAPR]                      NUMERIC (18, 6) NULL,
    [intAccountId]                INT             NULL,
    [intTransactionId]            INT             NULL,
    [dblEligableGallon]           NUMERIC (18, 6) NULL,
    [strDiscountSchedule]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnShowOnCFInvoice]          BIT             NULL
);



