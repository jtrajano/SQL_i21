CREATE TABLE [dbo].[tblARCustomerAgingStagingTable]
(
	[intInvoiceId]				INT NULL,
	[intPaymentId]				INT NULL,
    [intEntityCustomerId]		INT NULL, 
    [intCompanyLocationId]		INT NULL,
	[intEntityUserId]			INT NULL,
    [dtmDate]					DATETIME NULL, 
    [dtmDueDate]				DATETIME NULL, 
    [dtmAsOfDate]				DATETIME NULL, 
    [strCustomerName]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strCustomerNumber]			NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
	[strCustomerInfo]			NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceNumber]			NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strRecordNumber]			NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strBOLNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strSalespersonName]		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strSourceTransaction]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strType]					NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType]		NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[strCompanyName]            NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strCompanyAddress]         NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strAgingType]				NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[strEntityNo]				NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL,
    [dblCreditLimit]			NUMERIC(18, 6) NULL, 
    [dblTotalAR]				NUMERIC(18, 6) NULL, 
    [dblFuture]					NUMERIC(18, 6) NULL, 
    [dbl0Days]					NUMERIC(18, 6) NULL, 
    [dbl10Days]					NUMERIC(18, 6) NULL, 
    [dbl30Days]					NUMERIC(18, 6) NULL, 
    [dbl60Days]					NUMERIC(18, 6) NULL, 
    [dbl90Days]					NUMERIC(18, 6) NULL,
	[dbl91Days]					NUMERIC(18, 6) NULL,
	[dbl120Days]				NUMERIC(18, 6) NULL,
	[dbl121Days]				NUMERIC(18, 6) NULL,
    [dblTotalDue]				NUMERIC(18, 6) NULL, 
    [dblAmountPaid]				NUMERIC(18, 6) NULL, 
    [dblInvoiceTotal]			NUMERIC(18, 6) NULL, 
    [dblCredits]				NUMERIC(18, 6) NULL, 
    [dblPrepayments]			NUMERIC(18, 6) NULL,
    [dblPrepaids]				NUMERIC(18, 6) NULL,
    [dblTotalCustomerAR]        NUMERIC(18, 6) NULL,
    [strReportLogId]			NVARCHAR(MAX),
    [strCurrency]               NVARCHAR(40),
    [dblHistoricRate]			NUMERIC(18, 6) NULL,
    [dblHistoricAmount]			NUMERIC(18, 6) NULL,
    [dblEndOfMonthRate]			NUMERIC(18, 6) NULL,
    [dblEndOfMonthAmount]		NUMERIC(18, 6) NULL
);

GO
CREATE NONCLUSTERED INDEX [NC_Index_tblARCustomerAgingStagingTable]
ON [dbo].[tblARCustomerAgingStagingTable]([intEntityUserId]) INCLUDE ([intEntityCustomerId], [strAgingType], [dbl0Days], [dbl10Days], [dbl30Days], [dbl60Days], [dbl90Days], [dbl91Days], [dbl120Days], [dbl121Days], [dblCredits], [dblPrepayments]);
GO
CREATE NONCLUSTERED INDEX [NC_Index_tblARCustomerAgingStagingTable_AgingSummary]
ON [dbo].[tblARCustomerAgingStagingTable] ([intEntityUserId],[strAgingType])
GO