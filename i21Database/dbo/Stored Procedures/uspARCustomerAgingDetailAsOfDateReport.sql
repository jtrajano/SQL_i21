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

--PARAMETER SNIFFING
DECLARE @dtmDateFromLocal				DATETIME = NULL
	  , @dtmDateToLocal					DATETIME = NULL
      , @strSourceTransactionLocal		NVARCHAR(100) = NULL	
	  , @strCustomerIdsLocal			NVARCHAR(MAX) = NULL
	  , @strSalespersonIdsLocal			NVARCHAR(MAX) = NULL
	  , @strCompanyLocationIdsLocal		NVARCHAR(MAX) = NULL
	  , @strAccountStatusIdsLocal		NVARCHAR(MAX) = NULL	
	  , @intEntityUserIdLocal			INT = NULL
	  , @ysnPaidInvoiceLocal			BIT = NULL
	  , @ysnInclude120DaysLocal			BIT = 0
	  , @ysnExcludeAccountStatusLocal	BIT = 0
	  , @intGracePeriodLocal			INT = 0
	  , @ysnOverrideCashFlowLocal  		BIT = 0
	
SET @dtmDateFromLocal				= ISNULL(@dtmDateFrom, CAST('01/01/1900' AS DATE))
SET @dtmDateToLocal					= ISNULL(@dtmDateTo, CAST(GETDATE() AS DATE))
SET @strSourceTransactionLocal		= NULLIF(@strSourceTransaction, '')	
SET @strCustomerIdsLocal			= NULLIF(@strCustomerIds, '')	
SET @strSalespersonIdsLocal			= NULLIF(@strSalespersonIds, '')	
SET @strCompanyLocationIdsLocal		= NULLIF(@strCompanyLocationIds, '')	
SET @strAccountStatusIdsLocal		= NULLIF(@strAccountStatusIds, '')		
SET @intEntityUserIdLocal			= NULLIF(@intEntityUserId, 0)
SET @ysnPaidInvoiceLocal			= ISNULL(@ysnPaidInvoice, 1)
SET @ysnInclude120DaysLocal			= ISNULL(@ysnInclude120Days, 0)
SET @ysnExcludeAccountStatusLocal	= ISNULL(@ysnExcludeAccountStatus, 0)
SET @intGracePeriodLocal			= NULLIF(@intGracePeriod, 0)
SET @ysnOverrideCashFlowLocal  		= ISNULL(@ysnOverrideCashFlow, 0)

IF(OBJECT_ID('tempdb..#TEMPAGINGDETAILS') IS NOT NULL) DROP TABLE #TEMPAGINGDETAILS

SELECT *
     , strReportLogId	= NULLIF(@strReportLogId, CAST(NEWID() AS NVARCHAR(100)))
INTO #TEMPAGINGDETAILS
FROM [dbo].[fnARCustomerAgingDetail] (
	 @dtmDateFromLocal
	,@dtmDateToLocal
	,@strSourceTransactionLocal
	,@strCustomerIdsLocal
	,@strSalespersonIdsLocal
	,@strCompanyLocationIdsLocal
	,@strAccountStatusIdsLocal
	,@intEntityUserIdLocal
	,@ysnPaidInvoiceLocal
	,@ysnInclude120DaysLocal
	,@ysnExcludeAccountStatusLocal
	,@intGracePeriodLocal
	,@ysnOverrideCashFlowLocal
) 

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
	, intAge	
	, strLogoType
	, blbLogo
	, blbFooterLogo
	, strReportLogId	
)
SELECT * 
FROM #TEMPAGINGDETAILS