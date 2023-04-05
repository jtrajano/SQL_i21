CREATE PROCEDURE [dbo].[uspARSearchStatementsCustomer]
(
	 @strStatementFormat			NVARCHAR(50)  
	,@strAsOfDate					NVARCHAR(50) 
	,@strTransactionDate			NVARCHAR(50) 
	,@strCompanyLocation			NVARCHAR(100) = NULL
	,@strAccountCode				NVARCHAR(50) = NULL
	,@ysnDetailedFormat				BIT	= 0
	,@ysnIncludeBudget				BIT = 0
	,@ysnPrintCreditBalance 		BIT = 1
	,@ysnPrintOnlyPastDue			BIT = 0
	,@ysnPrintZeroBalance			BIT = 0
	,@ysnIncludeWriteOffPayment    	BIT = 0
	,@intEntityUserId				INT = NULL 
	,@strAsOfDateFrom				NVARCHAR(50) = ''
)
AS

DECLARE @strLocationNameLocal		AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal	AS NVARCHAR(MAX)	= NULL
	  , @strCompanyLocationIdsLocal	AS NVARCHAR(MAX)	= NULL
	  , @dtmAsOfDate				AS DATETIME			= NULL
	  , @dtmAsOfDateFrom			AS DATETIME			= NULL
	  , @ysnDetailedFormatLocal		AS BIT				= 0
	  , @ysnPrintCreditBalanceLocal AS BIT				= 1
	  , @ysnIncludeWriteOffLocal    AS BIT              = 0
	  , @ysnIncludeBudgetLocal		AS BIT 				= 0

SET @strAccountStatusCodeLocal	= NULLIF(@strAccountCode, '')
SET @strLocationNameLocal		= NULLIF(@strCompanyLocation, '')
SET @dtmAsOfDate				= ISNULL(CONVERT(DATETIME, @strAsOfDate), GETDATE())
SET @ysnDetailedFormatLocal		= ISNULL(@ysnDetailedFormat, 0)
SET @ysnPrintCreditBalanceLocal = ISNULL(@ysnPrintCreditBalance, 1)
SET @ysnIncludeWriteOffLocal    = ISNULL(@ysnIncludeWriteOffPayment, 0)
SET @ysnIncludeBudgetLocal    	= ISNULL(@ysnIncludeBudget, 0)

IF @strAsOfDateFrom <> ''
	SET @dtmAsOfDateFrom		= ISNULL(CONVERT(DATETIME, @strAsOfDateFrom), GETDATE())

SET @intEntityUserId			= NULLIF(@intEntityUserId, 0)

IF @dtmAsOfDateFrom = @dtmAsOfDate
BEGIN
	set @dtmAsOfDate = dateadd(SECOND,-1,dateadd(day,1, @dtmAsOfDate))
END

IF @strLocationNameLocal IS NOT NULL
	BEGIN
		SELECT @strCompanyLocationIdsLocal = LEFT(intCompanyLocationId, LEN(intCompanyLocationId) - 1)
		FROM (
			SELECT DISTINCT CAST(intCompanyLocationId AS VARCHAR(MAX))  + ', '
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strLocationNameLocal
			FOR XML PATH ('')
		) C (intCompanyLocationId)
	END

IF @strStatementFormat <> 'Balance Forward'
BEGIN
	EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateTo 					= @dtmAsOfDate
											, @intEntityUserId 				= @intEntityUserId
											, @strCompanyLocationIds		= @strCompanyLocationIdsLocal
											, @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffLocal
END
ELSE
BEGIN
	EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateTo 					= @dtmAsOfDate
											, @dtmBalanceForwardDate	    = @dtmAsOfDateFrom
											, @intEntityUserId 				= @intEntityUserId
											, @strCompanyLocationIds		= @strCompanyLocationIdsLocal
											, @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffLocal
										
END

DELETE FROM  tblARCustomerAgingStagingTable WHERE dblFuture <> 0 and ISNULL(@strStatementFormat, 'Open Item') = 'Open Item'

DELETE FROM tblARSearchStatementCustomer WHERE intEntityUserId = @intEntityUserId
INSERT INTO tblARSearchStatementCustomer (
	  intEntityCustomerId
	, strCustomerNumber
	, strCustomerName
	, dblARBalance
	, dblTotalAmount
	, ysnHasEmailSetup
	, intConcurrencyId
	, intEntityUserId
)
SELECT intEntityCustomerId	= CUS.intEntityId
	, strCustomerNumber		= CUS.strCustomerNumber
	, strCustomerName		= E.strName
	, dblTotalAR			= CASE WHEN ISNULL(@strStatementFormat, 'Open Item') = 'Full Details - No Card Lock' THEN ISNULL(AGING.dblTotalAR, 0) - ISNULL(dblFuture, 0) ELSE ISNULL(AGING.dblTotalAR, 0) + ISNULL(BUDGET.dblAmountDue, 0) END
	, dblTotalAR			= CASE WHEN ISNULL(@strStatementFormat, 'Open Item') = 'Full Details - No Card Lock' THEN ISNULL(AGING.dblTotalAR, 0) - ISNULL(dblFuture, 0) ELSE ISNULL(AGING.dblTotalAR, 0) + ISNULL(BUDGET.dblAmountDue, 0)END
	, ysnHasEmailSetup		= CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	, intConcurrencyId		= 1
	, intEntityUserId		= @intEntityUserId
FROM tblARCustomer CUS
INNER JOIN tblEMEntity E ON CUS.intEntityId = E.intEntityId
LEFT JOIN tblARCustomerAgingStagingTable AGING WITH (NOLOCK) ON CUS.intEntityId = AGING.intEntityCustomerId
														    AND AGING.intEntityUserId = @intEntityUserId
															AND AGING.strAgingType = 'Summary'
LEFT JOIN (
	SELECT intEntityCustomerId	= CB.intEntityCustomerId
	     , dblBudgetAmount		= SUM(dblBudgetAmount)
		 , dblAmountPaid		= SUM(dblAmountPaid)
		 , dblAmountDue			= SUM(dblBudgetAmount) - SUM(dblAmountPaid)
	FROM tblARCustomerBudget CB
	WHERE CB.dtmBudgetDate BETWEEN @dtmAsOfDateFrom AND @dtmAsOfDate
	  AND CB.dblAmountPaid < CB.dblBudgetAmount
	  AND @ysnIncludeBudgetLocal = 1
	GROUP BY CB.intEntityCustomerId
) BUDGET ON CUS.intEntityId = BUDGET.intEntityCustomerId
OUTER APPLY (
	SELECT intEmailSetupCount = COUNT(*) 
	FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
	WHERE CC.intCustomerEntityId = CUS.intEntityId 
		AND ISNULL(CC.strEmail, '') <> '' 
		AND CC.strEmailDistributionOption LIKE '%Statements%'
) EMAILSETUP
WHERE (@ysnPrintZeroBalance = 1 OR (@ysnPrintZeroBalance = 0 AND ISNULL(AGING.dblTotalAR, 0) + ISNULL(BUDGET.dblAmountDue, 0) <> 0 ))
  AND (@ysnPrintCreditBalanceLocal = 1 OR (@ysnPrintCreditBalanceLocal = 0 AND ISNULL(AGING.dblTotalAR, 0) + ISNULL(BUDGET.dblAmountDue, 0) > 0))
  AND (@ysnDetailedFormatLocal = 0 AND ISNULL(NULLIF(strStatementFormat, ''), 'Open Item') = ISNULL(@strStatementFormat, 'Open Item')) OR @ysnDetailedFormatLocal = 1
  
IF ISNULL(@strAccountStatusCodeLocal, '') <> ''
	BEGIN
		DELETE FROM tblARSearchStatementCustomer
		WHERE intEntityUserId = @intEntityUserId
		  AND intEntityCustomerId NOT IN (SELECT intEntityId FROM dbo.tblARCustomer WITH (NOLOCK) 
										  WHERE dbo.fnARGetCustomerAccountStatusCodes(intEntityCustomerId) LIKE '%' + @strAccountStatusCodeLocal + '%')
	END

IF @ysnDetailedFormatLocal = 0
	BEGIN
		SELECT SSC.*
		FROM dbo.tblARSearchStatementCustomer SSC WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
			FROM dbo.tblARCustomer WITH (NOLOCK)
			WHERE ISNULL(NULLIF(strStatementFormat, ''), 'Open Item') = @strStatementFormat
		) C ON SSC.intEntityCustomerId = C.intEntityId
		WHERE intEntityUserId = @intEntityUserId
		AND Cast(SSC.dblARBalance as varchar) != CASE WHEN @ysnPrintZeroBalance = 0 THEN '0.000000' ELSE '' END
		ORDER BY SSC.strCustomerName
	END
ELSE
	BEGIN
		SELECT SSC.*
		FROM dbo.tblARSearchStatementCustomer SSC WITH (NOLOCK)
		WHERE intEntityUserId = @intEntityUserId
		AND Cast(SSC.dblARBalance as varchar) != CASE WHEN @ysnPrintZeroBalance = 0 THEN '0.000000' ELSE '' END
		ORDER BY SSC.strCustomerName
	END
