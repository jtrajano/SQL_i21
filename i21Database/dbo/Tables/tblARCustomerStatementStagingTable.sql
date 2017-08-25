﻿CREATE TABLE [dbo].[tblARCustomerStatementStagingTable] (
    [intEntityCustomerId]          INT             NULL,
    [intInvoiceId]                 INT             NULL,
    [intPaymentId]                 INT             NULL,
    [dtmDate]                      DATETIME        NULL,
    [dtmDueDate]                   DATETIME        NULL,
    [dtmShipDate]                  DATETIME        NULL,
    [dtmDatePaid]                  DATETIME        NULL,
    [dtmAsOfDate]                  DATETIME        NULL,
    [strCustomerNumber]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCustomerName]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceNumber]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strBOLNumber]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strRecordNumber]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPaymentInfo]               NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSalespersonName]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strAccountStatusCode]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strLocationName]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFullAddress]               NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strStatementFooterComment]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCompanyName]               NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCompanyAddress]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblCreditLimit]               NUMERIC (18, 6) NULL,
    [dblInvoiceTotal]              NUMERIC (18, 6) NULL,
    [dblPayment]                   NUMERIC (18, 6) NULL,
    [dblBalance]                   NUMERIC (18, 6) NULL,
    [dblTotalAR]                   NUMERIC (18, 6) NULL,
    [dblCreditAvailable]           NUMERIC (18, 6) NULL,
    [dblFuture]                    NUMERIC (18, 6) NULL,
    [dbl0Days]                     NUMERIC (18, 6) NULL,
    [dbl10Days]                    NUMERIC (18, 6) NULL,
    [dbl30Days]                    NUMERIC (18, 6) NULL,
    [dbl60Days]                    NUMERIC (18, 6) NULL,
    [dbl90Days]                    NUMERIC (18, 6) NULL,
    [dbl91Days]                    NUMERIC (18, 6) NULL,
    [dblCredits]                   NUMERIC (18, 6) NULL,
    [dblPrepayments]               NUMERIC (18, 6) NULL,
    [ysnPrintFromCardFueling]      BIT             NULL,
    [intCFAccountId]               INT             NULL,
    [dblCFDiscount]                NUMERIC (18, 6) NULL,
    [dblCFEligableGallon]          NUMERIC (18, 6) NULL,
    [strCFGroupDiscoount]          NVARCHAR (100)  NULL,
    [intCFDiscountDay]             INT             NULL,
    [strCFTermType]                NVARCHAR (150)  NULL,
    [dtmCFInvoiceDate]             DATETIME        NULL,
    [dblCFTotalBalance]            NUMERIC (18, 6) NULL,
    [intCFTermID]                  INT             NULL,
    [dblCFAccountTotalAmount]      NUMERIC (18, 6) NULL,
    [dblCFAccountTotalDiscount]    NUMERIC (18, 6) NULL,
    [dblCFFeeTotalAmount]          NUMERIC (18, 6) NULL,
    [dblCFInvoiceTotal]            NUMERIC (18, 6) NULL,
    [dblCFTotalQuantity]           NUMERIC (18, 6) NULL,
    [strCFTempInvoiceReportNumber] NVARCHAR (MAX)  NULL,
    [strCFEmailDistributionOption] NVARCHAR (MAX)  NULL,
    [strCFEmail]                   NVARCHAR (MAX)  NULL,
	[ysnCFShowDiscountOnInvoice]   BIT             NULL
);

