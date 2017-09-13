CREATE PROCEDURE [dbo].[uspARSearchStatementsCustomer]
(
	 @strStatementFormat	NVARCHAR(50)  
	,@strAsOfDate			NVARCHAR(50) 
	,@strTransactionDate	NVARCHAR(50) 
	,@strCompanyLocation	NVARCHAR(100) = NULL
	,@strAccountCode		NVARCHAR(50) = NULL
	,@ysnDetailedFormat		BIT	= 0
	,@ysnEmailOnly			BIT = 0
	,@ysnIncludeBudget		BIT = 0
	,@ysnPrintCreditBalance BIT = 1
	,@ysnPrintOnlyPastDue	BIT = 0
	,@ysnPrintZeroBalance	BIT = 0
)
AS

DECLARE @strLocationNameLocal		AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal	AS NVARCHAR(MAX)	= NULL

SET @strAccountStatusCodeLocal	= NULLIF(@strAccountCode, '')
SET @strLocationNameLocal		= NULLIF(@strCompanyLocation, '')

IF @strStatementFormat = 'Balance Forward'
	BEGIN
		EXEC dbo.uspARCustomerStatementBalanceForwardReport 
			  @dtmDateTo				= @strAsOfDate
			, @ysnPrintZeroBalance		= @ysnPrintZeroBalance
			, @ysnPrintCreditBalance	= @ysnPrintCreditBalance
			, @ysnIncludeBudget			= @ysnIncludeBudget
			, @ysnPrintOnlyPastDue		= @ysnPrintOnlyPastDue
			, @ysnPrintFromCF			= 0
			, @ysnSearchOnly			= 1
			, @strAccountStatusCode		= @strAccountStatusCodeLocal
			, @strLocationName			= @strLocationNameLocal
	END
ELSE IF ISNULL(@strStatementFormat, 'Open Item') IN ('Open Item', 'Running Balance')
	BEGIN
		EXEC dbo.uspARCustomerStatementReport
		      @dtmDateTo				= @strAsOfDate
		    , @ysnPrintZeroBalance		= @ysnPrintZeroBalance
		    , @ysnPrintCreditBalance	= @ysnPrintCreditBalance
		    , @ysnIncludeBudget			= @ysnIncludeBudget
		    , @ysnPrintOnlyPastDue		= @ysnPrintOnlyPastDue
			, @ysnSearchOnly			= 1
		    , @strAccountStatusCode		= @strAccountStatusCodeLocal
		    , @strLocationName			= @strLocationNameLocal
		    , @strStatementFormat		= @strStatementFormat
	END
ELSE IF @strStatementFormat = 'Payment Activity'
	BEGIN
		EXEC dbo.uspARCustomerStatementPaymentActivityReport
			  @dtmDateTo				= @strAsOfDate
		    , @ysnPrintZeroBalance		= @ysnPrintZeroBalance
		    , @ysnPrintCreditBalance	= @ysnPrintCreditBalance
		    , @ysnIncludeBudget			= @ysnIncludeBudget
		    , @ysnPrintOnlyPastDue		= @ysnPrintOnlyPastDue
			, @ysnSearchOnly			= 1
		    , @strAccountStatusCode		= @strAccountStatusCodeLocal
		    , @strLocationName			= @strLocationNameLocal
	END

TRUNCATE TABLE tblARSearchStatementCustomer

IF @strStatementFormat IN ('Balance Forward', 'Payment Activity')
	BEGIN
		TRUNCATE TABLE tblARSearchStatementCustomer
		INSERT INTO tblARSearchStatementCustomer (
			  intEntityCustomerId
			, strCustomerNumber
			, strCustomerName
			, dblARBalance
			, strTransactionId
			, strTransactionDate
			, dblTotalAmount
			, ysnHasEmailSetup
			, intConcurrencyId
		)
		SELECT intEntityCustomerId		= STAGING.intEntityCustomerId
			 , strCustomerNumber		= STAGING.strCustomerNumber
			 , strCustomerName			= STAGING.strCustomerName
			 , dblARBalance				= STAGING.dblTotalBalance
			 , strTransactionId			= NULL
			 , strTransactionDate		= NULL
			 , dblTotalAmount			= STAGING.dblTotalBalance
			 , ysnHasEmailSetup			= CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
			 , intConcurrencyId			= 1
		FROM (
			SELECT intEntityCustomerId
				 , strCustomerNumber
				 , strCustomerName
				 , dblTotalBalance = SUM(ISNULL(dblBalance, 0))
			FROM dbo.tblARCustomerStatementStagingTable WITH (NOLOCK)
			GROUP BY intEntityCustomerId, strCustomerName, strCustomerNumber
		) STAGING		
		OUTER APPLY (
			SELECT intEmailSetupCount = COUNT(*) 
			FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
			WHERE CC.intCustomerEntityId = STAGING.intEntityCustomerId 
				AND ISNULL(CC.strEmail, '') <> '' 
				AND CC.strEmailDistributionOption LIKE '%Statements%'
		) EMAILSETUP
	END
ELSE
	BEGIN
		TRUNCATE TABLE tblARSearchStatementCustomer
		INSERT INTO tblARSearchStatementCustomer (
			  intEntityCustomerId
			, strCustomerNumber
			, strCustomerName
			, dblARBalance
			, strTransactionId
			, strTransactionDate
			, dblTotalAmount
			, ysnHasEmailSetup
			, intConcurrencyId
		)
		SELECT intEntityCustomerId		= STAGING.intEntityCustomerId
			 , strCustomerNumber		= STAGING.strCustomerNumber
			 , strCustomerName			= STAGING.strCustomerName
			 , dblARBalance				= STAGING.dblTotalBalance
			 , strTransactionId			= NULL
			 , strTransactionDate		= NULL
			 , dblTotalAmount			= STAGING.dblTotalBalance
			 , ysnHasEmailSetup			= CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
			 , intConcurrencyId			= 1
		FROM (
			SELECT intEntityCustomerId
				 , strCustomerNumber
				 , strCustomerName
				 , dblTotalBalance = SUM(ISNULL(dblAmountDue, 0))
			FROM dbo.tblARCustomerStatementStagingTable WITH (NOLOCK)
			GROUP BY intEntityCustomerId, strCustomerName, strCustomerNumber
		) STAGING		
		OUTER APPLY (
			SELECT intEmailSetupCount = COUNT(*) 
			FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
			WHERE CC.intCustomerEntityId = STAGING.intEntityCustomerId 
				AND ISNULL(CC.strEmail, '') <> '' 
				AND CC.strEmailDistributionOption LIKE '%Statements%'
		) EMAILSETUP
	END

IF @ysnEmailOnly = 1
	DELETE FROM tblARSearchStatementCustomer WHERE ysnHasEmailSetup = 0
ELSE
	DELETE FROM tblARSearchStatementCustomer WHERE ysnHasEmailSetup = 1

IF ISNULL(@strAccountStatusCodeLocal, '') <> ''
	BEGIN
		DELETE FROM tblARSearchStatementCustomer
		WHERE intEntityCustomerId NOT IN (SELECT intEntityId 
										  FROM dbo.tblARCustomer WITH (NOLOCK) 
										  WHERE dbo.fnARGetCustomerAccountStatusCodes(intEntityCustomerId) LIKE '%' + @strAccountStatusCodeLocal + '%')
	END

IF @ysnDetailedFormat = 0
	BEGIN
		SELECT SSC.*
		FROM dbo.tblARSearchStatementCustomer SSC WITH (NOLOCK)
		INNER JOIN (SELECT intEntityId
					FROM dbo.tblARCustomer WITH (NOLOCK)
					WHERE ISNULL(NULLIF(strStatementFormat, ''), 'Open Item') = @strStatementFormat
		) C ON SSC.intEntityCustomerId = C.intEntityId
		ORDER BY SSC.strCustomerName
	END
ELSE
	BEGIN
		SELECT SSC.*
		FROM dbo.tblARSearchStatementCustomer SSC WITH (NOLOCK)
		ORDER BY SSC.strCustomerName
	END
