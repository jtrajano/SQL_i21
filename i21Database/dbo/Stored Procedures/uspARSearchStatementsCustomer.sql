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
	  , @dtmAsOfDate				AS DATETIME			= NULL

SET @strAccountStatusCodeLocal	= NULLIF(@strAccountCode, '')
SET @strLocationNameLocal		= NULLIF(@strCompanyLocation, '')
SET @dtmAsOfDate				= ISNULL(CONVERT(DATETIME, @strAsOfDate), GETDATE())

TRUNCATE TABLE tblARCustomerAgingStagingTable
INSERT INTO tblARCustomerAgingStagingTable (
	   strCustomerName
	 , strCustomerNumber
	 , intEntityCustomerId
	 , dblCreditLimit
	 , dblTotalAR
	 , dblFuture
	 , dbl0Days
	 , dbl10Days
	 , dbl30Days
	 , dbl60Days
	 , dbl90Days
	 , dbl91Days
	 , dblTotalDue
	 , dblAmountPaid
	 , dblCredits
	 , dblPrepayments
	 , dblPrepaids
	 , dtmAsOfDate
	 , strSalespersonName
	 , strSourceTransaction
	 , strCompanyName
	 , strCompanyAddress
)
EXEC dbo.uspARCustomerAgingAsOfDateReport @dtmDateTo = @dtmAsOfDate
										, @strCompanyLocation = @strCompanyLocation

TRUNCATE TABLE tblARSearchStatementCustomer
INSERT INTO tblARSearchStatementCustomer (
			  intEntityCustomerId
			, strCustomerNumber
			, strCustomerName
			, dblARBalance
			, dblTotalAmount
			, ysnHasEmailSetup
			, intConcurrencyId
		)
SELECT AGING.intEntityCustomerId
	 , AGING.strCustomerNumber
	 , AGING.strCustomerName
	 , AGING.dblTotalAR
	 , AGING.dblTotalAR
	 , ysnHasEmailSetup			= CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , 1
FROM tblARCustomerAgingStagingTable AGING WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
	FROM tblARCustomer WITH (NOLOCK)
	WHERE ISNULL(strStatementFormat, 'Open Item') = ISNULL(@strStatementFormat, 'Open Item')
) C ON AGING.intEntityCustomerId = C.intEntityCustomerId
OUTER APPLY (
	SELECT intEmailSetupCount = COUNT(*) 
	FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
	WHERE CC.intCustomerEntityId = AGING.intEntityCustomerId 
		AND ISNULL(CC.strEmail, '') <> '' 
		AND CC.strEmailDistributionOption LIKE '%Statements%'
) EMAILSETUP
WHERE ISNULL(AGING.dblTotalAR, 0) <> 0

IF @ysnEmailOnly = 1
	DELETE FROM tblARSearchStatementCustomer WHERE ysnHasEmailSetup = 0
ELSE
	DELETE FROM tblARSearchStatementCustomer WHERE ysnHasEmailSetup = 1

IF ISNULL(@strAccountStatusCodeLocal, '') <> ''
	BEGIN
		DELETE FROM tblARSearchStatementCustomer
		WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId 
										  FROM dbo.tblARCustomer WITH (NOLOCK) 
										  WHERE dbo.fnARGetCustomerAccountStatusCodes(intEntityCustomerId) LIKE '%' + @strAccountStatusCodeLocal + '%')
	END

IF @ysnDetailedFormat = 0
	BEGIN
		SELECT SSC.*
		FROM dbo.tblARSearchStatementCustomer SSC WITH (NOLOCK)
		INNER JOIN (SELECT intEntityCustomerId
					FROM dbo.tblARCustomer WITH (NOLOCK)
					WHERE ISNULL(strStatementFormat, 'Open Item') = @strStatementFormat
		) C ON SSC.intEntityCustomerId = C.intEntityCustomerId
		ORDER BY SSC.strCustomerName
	END
ELSE
	BEGIN
		SELECT SSC.*
		FROM dbo.tblARSearchStatementCustomer SSC WITH (NOLOCK)
		ORDER BY SSC.strCustomerName
	END