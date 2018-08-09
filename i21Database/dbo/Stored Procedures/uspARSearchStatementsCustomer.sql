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
	  , @dtmAsOfDate				AS DATETIME			= NULL
	  , @dtmAsOfDateFrom			AS DATETIME			= NULL
	  , @ysnDetailedFormatLocal		AS BIT				= 0
	  , @ysnPrintCreditBalanceLocal AS BIT				= 1
	  , @ysnIncludeWriteOffLocal    AS BIT              = 0

SET @strAccountStatusCodeLocal	= NULLIF(@strAccountCode, '')
SET @strLocationNameLocal		= NULLIF(@strCompanyLocation, '')
SET @dtmAsOfDate				= ISNULL(CONVERT(DATETIME, @strAsOfDate), GETDATE())
SET @ysnDetailedFormatLocal		= ISNULL(@ysnDetailedFormat, 0)
SET @ysnPrintCreditBalanceLocal = ISNULL(@ysnPrintCreditBalance, 1)
SET @ysnIncludeWriteOffLocal    = ISNULL(@ysnIncludeWriteOffPayment, 0)

IF @strAsOfDateFrom <> ''
	SET @dtmAsOfDateFrom		= ISNULL(CONVERT(DATETIME, @strAsOfDateFrom), GETDATE())

SET @intEntityUserId			= NULLIF(@intEntityUserId, 0)

IF @dtmAsOfDateFrom = @dtmAsOfDate
BEGIN
	set @dtmAsOfDate = dateadd(SECOND,-1,dateadd(day,1, @dtmAsOfDate))
END

EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateTo 					= @dtmAsOfDate
										, @strCompanyLocation 			= @strCompanyLocation
										, @intEntityUserId 				= @intEntityUserId										
										, @ysnIncludeCredits 			= @ysnPrintCreditBalanceLocal
                                        , @ysnIncludeWriteOffPayment    = @ysnIncludeWriteOffLocal

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
SELECT AGING.intEntityCustomerId
	 , AGING.strCustomerNumber
	 , AGING.strCustomerName
	 , AGING.dblTotalAR
	 , AGING.dblTotalAR
	 , ysnHasEmailSetup			= CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , 1
	 , @intEntityUserId
FROM tblARCustomerAgingStagingTable AGING WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityId
	FROM tblARCustomer WITH (NOLOCK)
	WHERE (@ysnDetailedFormatLocal = 0 AND ISNULL(strStatementFormat, 'Open Item') = ISNULL(@strStatementFormat, 'Open Item')) OR @ysnDetailedFormatLocal = 1
) C ON AGING.intEntityCustomerId = C.intEntityId
OUTER APPLY (
	SELECT intEmailSetupCount = COUNT(*) 
	FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
	WHERE CC.intCustomerEntityId = AGING.intEntityCustomerId 
		AND ISNULL(CC.strEmail, '') <> '' 
		AND CC.strEmailDistributionOption LIKE '%Statements%'
) EMAILSETUP
WHERE ISNULL(AGING.dblTotalAR, 0) <> 0
AND AGING.intEntityUserId = @intEntityUserId
AND AGING.strAgingType = 'Summary'

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
		ORDER BY SSC.strCustomerName
	END
ELSE
	BEGIN
		SELECT SSC.*
		FROM dbo.tblARSearchStatementCustomer SSC WITH (NOLOCK)
		WHERE intEntityUserId = @intEntityUserId
		ORDER BY SSC.strCustomerName
	END
