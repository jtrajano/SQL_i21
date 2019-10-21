﻿CREATE TABLE [dbo].[tblARCustomerStatementStagingTable] (
    [intRowId]                     INT             NULL,
    [intEntityCustomerId]          INT             NULL,
    [intInvoiceId]                 INT             NULL,
    [intInvoiceDetailId]           INT             NULL,
    [intPaymentId]                 INT             NULL,
    [intDaysDue]                   INT             NULL,
    [intEntityUserId]              INT             NULL,
    [intCustomerNumberNumeric]	   INT             NULL,
    [dtmDate]                      DATETIME        NULL,
    [dtmDueDate]                   DATETIME        NULL,
    [dtmShipDate]                  DATETIME        NULL,
    [dtmDatePaid]                  DATETIME        NULL,
    [dtmAsOfDate]                  DATETIME        NULL,
    [strCustomerNumber]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCustomerName]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strAccountNumber]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDisplayName]               NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceNumber]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strReferenceNumber]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strBOLNumber]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPONumber]                  NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strRecordNumber]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPaymentInfo]               NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSalespersonName]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strAccountStatusCode]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strLocationName]              NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFullAddress]               NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strStatementFooterComment]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strContact]                   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPaid]                      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPaymentMethod]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTicketNumbers]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCompanyName]               NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCompanyAddress]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strUserId]                    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strStatementFormat]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strItemNo]                    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strItemDescription]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerNumberAlpha]       NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dblTotalAmount]               NUMERIC (18, 6) NULL,
    [dblAmountPaid]                NUMERIC (18, 6) NULL,
    [dblAmountDue]                 NUMERIC (18, 6) NULL,
    [dblAmountApplied]             NUMERIC (18, 6) NULL,
    [dblPastDue]                   NUMERIC (18, 6) NULL,
    [dblMonthlyBudget]             NUMERIC (18, 6) NULL,
	[dblBudgetPastDue]			   NUMERIC (18, 6) NULL,
	[dblBudgetNowDue]			   NUMERIC (18, 6) NULL,
    [dblRunningBalance]            NUMERIC (18, 6) NULL,
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
    [dblUnappliedAmount]           NUMERIC (18, 6) NULL,
    [dblQuantity]                  NUMERIC (18, 6) NULL,
    [dblInvoiceDetailTotal]        NUMERIC (18, 6) NULL,
    [ysnPrintFromCardFueling]      BIT             NULL,
    [intCFAccountId]               INT             NULL,
    [dblCFDiscount]                NUMERIC (18, 6) NULL,
    [dblCFEligableGallon]          NUMERIC (18, 6) NULL,
    [strCFGroupDiscoount]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intCFDiscountDay]             INT             NULL,
    [strCFTermType]                NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [dtmCFInvoiceDate]             DATETIME        NULL,
    [dblCFTotalBalance]            NUMERIC (18, 6) NULL,
    [intCFTermID]                  INT             NULL,
    [dblCFAccountTotalAmount]      NUMERIC (18, 6) NULL,
    [dblCFAccountTotalDiscount]    NUMERIC (18, 6) NULL,
    [dblCFFeeTotalAmount]          NUMERIC (18, 6) NULL,
    [dblCFInvoiceTotal]            NUMERIC (18, 6) NULL,
    [dblCFTotalQuantity]           NUMERIC (18, 6) NULL,
    [dblCFTotalFuelExpensed]       NUMERIC (18, 6) NULL,
    [strCFTempInvoiceReportNumber] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCFEmailDistributionOption] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCFEmail]                   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnCFShowDiscountOnInvoice]   BIT             NULL,
    [ysnStatementCreditLimit]      BIT             NULL,
    [ysnStretchLogo]               BIT             NULL,
    [blbLogo]                      VARBINARY (MAX) NULL,
    [strCFTerm]                    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCFTermCode]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strComment]                   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
);

