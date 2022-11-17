CREATE PROCEDURE [dbo].[uspARCustomerAgingDetailAsOfDateReport]
	  @dtmDateFrom				DATETIME = NULL
	, @dtmDateTo				DATETIME = NULL
    , @strSourceTransaction		NVARCHAR(100) = NULL	
	, @strCustomerIds			NVARCHAR(MAX) = NULL
	, @strSalespersonIds		NVARCHAR(MAX) = NULL
	, @strCompanyLocationIds	NVARCHAR(MAX) = NULL
	, @strAccountStatusIds		NVARCHAR(MAX) = NULL	
	, @intEntityUserId			INT = NULL
	, @ysnPaidInvoice			BIT = NULL
	, @ysnInclude120Days		BIT = 0
	, @ysnExcludeAccountStatus	BIT = 0
	, @intGracePeriod			INT = 0
	, @ysnOverrideCashFlow  	BIT = 0
	, @strReportLogId			NVARCHAR(MAX) = NULL
AS

SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  

DELETE FROM tblARCustomerAgingStagingTable WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
INSERT INTO tblARCustomerAgingStagingTable WITH (TABLOCK) (
	  strCustomerName
	, strCustomerNumber
	, strCustomerInfo
	, strInvoiceNumber
	, strRecordNumber
	, intInvoiceId
	, intPaymentId
	, strBOLNumber
	, intEntityCustomerId
	, intEntityUserId
	, dblCreditLimit
	, dblTotalAR
	, dblTotalCustomerAR
	, dblFuture
	, dbl0Days
	, dbl10Days
	, dbl30Days
	, dbl60Days
	, dbl90Days
	, dbl120Days
	, dbl121Days
	, dblTotalDue
	, dblAmountPaid
	, dblInvoiceTotal
	, dblCredits
	, dblPrepayments
	, dblPrepaids
	, dtmDate
	, dtmDueDate
	, dtmAsOfDate
	, strSalespersonName
	, intCompanyLocationId
	, strSourceTransaction
	, strType
	, strTransactionType
	, strCompanyName
	, strCompanyAddress
	, strAgingType
	, intCurrencyId
	, strCurrency
	, dblHistoricRate
	, dblHistoricAmount
	, dblEndOfMonthRate
	, dblEndOfMonthAmount
	, intAccountId
	, strReportLogId
)
SELECT *, NULLIF(@strReportLogId, CAST(NEWID() AS NVARCHAR(100)))
FROM [dbo].[fnARCustomerAgingDetail](
	 @dtmDateFrom
	,@dtmDateTo
	,@strSourceTransaction
	,@strCustomerIds
	,@strSalespersonIds
	,@strCompanyLocationIds
	,@strAccountStatusIds
	,@intEntityUserId
	,@ysnPaidInvoice
	,@ysnInclude120Days
	,@ysnExcludeAccountStatus
	,@intGracePeriod
	,@ysnOverrideCashFlow
) 