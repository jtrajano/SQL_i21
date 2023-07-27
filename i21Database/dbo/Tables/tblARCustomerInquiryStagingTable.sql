CREATE TABLE [dbo].[tblARCustomerInquiryStagingTable]
(
	  intEntityCustomerId			INT	NOT NULL
	, intEntityId					INT NULL
	, intTermsId					INT NULL
	, strCustomerName				NVARCHAR(300)   COLLATE Latin1_General_CI_AS    NULL
	, strTerm						NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
	, strCustomerNumber				NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
	, strAddress					NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
	, strZipCode					NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strCity						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strState						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strCountry					NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strEmail						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strPhone1						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strPhone2						NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBusinessLocation			NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strInternalNotes				NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
	, strBudgetStatus				NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBillToAddress				NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBillToCity					NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBillToState				NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
	, strBillToZipCode				NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
    , strContact                    NVARCHAR(500)   COLLATE Latin1_General_CI_AS    NULL
    , strCompanyAddress             NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
	, dblYTDSales					NUMERIC(18, 6) NULL
	, dblYDTServiceCharge			NUMERIC(18, 6) NULL
	, dblHighestAR					NUMERIC(18, 6) NULL
	, dblHighestDueAR				NUMERIC(18, 6) NULL
	, dblLastPayment				NUMERIC(18, 6) NULL
	, dblLastYearSales				NUMERIC(18, 6) NULL
	, dblLastStatement				NUMERIC(18, 6) NULL
	, dblPendingInvoice				NUMERIC(18, 6) NULL
	, dblPendingPayment				NUMERIC(18, 6) NULL
	, dblCreditLimit				NUMERIC(18, 6) NULL
	, dblFuture						NUMERIC(18, 6) NULL
	, dbl0Days						NUMERIC(18, 6) NULL
	, dbl10Days						NUMERIC(18, 6) NULL
	, dbl30Days						NUMERIC(18, 6) NULL
	, dbl60Days						NUMERIC(18, 6) NULL
	, dbl90Days						NUMERIC(18, 6) NULL
	, dbl91Days						NUMERIC(18, 6) NULL
	, dblUnappliedCredits			NUMERIC(18, 6) NULL
	, dblPrepaids					NUMERIC(18, 6) NULL
	, dblTotalDue					NUMERIC(18, 6) NULL
	, dblBudgetAmount				NUMERIC(18, 6) NULL
	, dblThru						NUMERIC(18, 6) NULL
	, dblNextPaymentAmount			NUMERIC(18, 6) NULL
	, dblAmountPastDue				NUMERIC(18, 6) NULL
	, dbl31DaysAmountDue			NUMERIC(18, 6) NULL
	, intRemainingBudgetPeriods		INT NULL
	, intAveragePaymentDays			INT NULL
	, dtmNextPaymentDate			DATETIME NULL
	, dtmLastPaymentDate			DATETIME NULL
	, dtmLastStatementDate			DATETIME NULL
	, dtmBudgetMonth				DATETIME NULL
	, dtmHighestARDate				DATETIME NULL
	, dtmHighestDueARDate			DATETIME NULL
    , intRowId                      INT NULL
);