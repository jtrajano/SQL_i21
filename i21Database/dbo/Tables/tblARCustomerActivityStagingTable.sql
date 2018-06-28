﻿CREATE TABLE [dbo].[tblARCustomerActivityStagingTable]
(
	[intEntityCustomerId]		INT NULL,
	[intInvoiceDetailId]		INT NULL,
	[intTransactionId]			INT NULL,
	[intItemId]					INT NULL,
	[intInvoiceDetailTaxId]		INT NULL,
	[intEntityUserId]			INT NULL,
	[strReportDateRange]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerNumber]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerAddress]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCompanyName]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCompanyAddress]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionNumber]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceNumber]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strActivityType]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strUnitMeasure]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTaxGroup]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strNotes]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFormattingOptions]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastPaymentDate]		DATETIME NULL,
	[dtmTransactionDate]		DATETIME NULL,
	[dtmAsOfDate]				DATETIME NULL,
	[dblLastPayment]			NUMERIC(18, 6) NULL,
	[dblPayment]				NUMERIC(18, 6) NULL,
	[dblInvoiceTotal]			NUMERIC(18, 6) NULL,
	[dblInvoiceSubtotal]		NUMERIC(18, 6) NULL,
	[dblInvoiceLineTotal]		NUMERIC(18, 6) NULL,
	[dblDiscount]				NUMERIC(18, 6) NULL,
	[dblInterest]				NUMERIC(18, 6) NULL,
	[dblQtyShipped]				NUMERIC(18, 6) NULL,
	[dblTax]					NUMERIC(18, 6) NULL,
	[dblAdjustedTax]			NUMERIC(18, 6) NULL,
	[dblCreditLimit]			NUMERIC(18, 6) NULL,
	[dblTotalAR]				NUMERIC(18, 6) NULL,
	[dblFuture]					NUMERIC(18, 6) NULL,
	[dbl0Days]					NUMERIC(18, 6) NULL,
	[dbl10Days]					NUMERIC(18, 6) NULL,
	[dbl30Days]					NUMERIC(18, 6) NULL,
	[dbl60Days]					NUMERIC(18, 6) NULL,
	[dbl90Days]					NUMERIC(18, 6) NULL,
	[dbl91Days]					NUMERIC(18, 6) NULL,
	[dblTotalDue]				NUMERIC(18, 6) NULL,
	[dblAmountPaid]				NUMERIC(18, 6) NULL,
	[dblCredits]				NUMERIC(18, 6) NULL,
	[dblPrepayments]			NUMERIC(18, 6) NULL,
	[dblPrepaids]				NUMERIC(18, 6) NULL,	
	[ysnPrintDetail]			BIT NULL,
	[ysnPrintRecap]				BIT NULL,
	[dtmFilterFrom]				DATETIME NULL,
	[dtmFilterTo]				DATETIME NULL
)
