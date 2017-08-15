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

DECLARE @tmpstrStatementFormat	NVARCHAR(50)
		,@tmpDate				NVARCHAR(50)
		,@xmlParam				NVARCHAR(MAX) = NULL
		,@strQuery				NVARCHAR(MAX)
		,@strQuery1				NVARCHAR(MAX)
		,@tmpysnDetailedFormat	BIT
  
DECLARE @temp_aging_table TABLE(	
	 [strCustomerName]			NVARCHAR(100)
	,[strEntityNo]				NVARCHAR(100)
	,[intEntityCustomerId]		INT
	,[dblCreditLimit]			NUMERIC(18,6)
	,[dblTotalAR]				NUMERIC(18,6)
	,[dblFuture]				NUMERIC(18,6)
	,[dbl0Days]					NUMERIC(18,6)
	,[dbl10Days]				NUMERIC(18,6)
	,[dbl30Days]				NUMERIC(18,6)
	,[dbl60Days]				NUMERIC(18,6)
	,[dbl90Days]				NUMERIC(18,6)
	,[dbl91Days]				NUMERIC(18,6)
	,[dblTotalDue]				NUMERIC(18,6)
	,[dblAmountPaid]			NUMERIC(18,6)
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepayments]			NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmAsOfDate]				DATETIME
	,[strSalespersonName]		NVARCHAR(100)
	,[strSourceTransaction]		NVARCHAR(100)
)

INSERT INTO @temp_aging_table
EXEC dbo.uspARCustomerAgingAsOfDateReport NULL, @strAsOfDate, NULL, NULL, NULL, @strCompanyLocation, @ysnIncludeBudget, @ysnPrintCreditBalance

UPDATE @temp_aging_table SET dblTotalAR = dblTotalAR - dblFuture

IF @ysnPrintOnlyPastDue = 1
	UPDATE @temp_aging_table SET dblTotalAR = dblTotalAR - dbl0Days, dbl0Days = 0

IF @ysnPrintZeroBalance = 0
	DELETE FROM @temp_aging_table WHERE dblTotalAR = 0

IF @ysnPrintCreditBalance = 0
	DELETE FROM @temp_aging_table WHERE dblTotalAR < 0 

SET @tmpstrStatementFormat = @strStatementFormat

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
SELECT intEntityCustomerId		= AGING.intEntityCustomerId
	 , strCustomerNumber		= AGING.strEntityNo
	 , strCustomerName			= AGING.strCustomerName
	 , dblARBalance				= AGING.dblTotalAR
	 , strTransactionId			= NULL
	 , strTransactionDate		= NULL
	 , dblTotalAmount			= AGING.dblTotalAR
	 , ysnHasEmailSetup			= CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
	 , intConcurrencyId			= 1
FROM @temp_aging_table AGING
OUTER APPLY (
	SELECT intEmailSetupCount = COUNT(*) 
	FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
	WHERE CC.intCustomerEntityId = AGING.intEntityCustomerId 
		AND ISNULL(CC.strEmail, '') <> '' 
		AND CC.strEmailDistributionOption LIKE '%Statements%'
) EMAILSETUP

IF @ysnEmailOnly = 1
	DELETE FROM tblARSearchStatementCustomer WHERE ysnHasEmailSetup = 0
ELSE
	DELETE FROM tblARSearchStatementCustomer WHERE ysnHasEmailSetup = 1

IF ISNULL(@strAccountCode, '') <> ''
	BEGIN
		DELETE FROM tblARSearchStatementCustomer
		WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId 
										  FROM dbo.tblARCustomer WITH (NOLOCK) 
										  WHERE dbo.fnARGetCustomerAccountStatusCodes(intEntityCustomerId) LIKE '%' + @strAccountCode + '%')
	END

IF @ysnDetailedFormat = 0
	BEGIN
		SELECT SSC.*
		FROM dbo.tblARSearchStatementCustomer SSC WITH (NOLOCK)
		INNER JOIN (SELECT intEntityId
					FROM dbo.tblARCustomer WITH (NOLOCK)
					WHERE ISNULL(strStatementFormat, 'Open Item') = @strStatementFormat
		) C ON SSC.intEntityCustomerId = C.intEntityId
		ORDER BY SSC.strCustomerName
	END
ELSE
	BEGIN
		SELECT SSC.*
		FROM dbo.tblARSearchStatementCustomer SSC WITH (NOLOCK)
		ORDER BY SSC.strCustomerName
	END