CREATE PROCEDURE [dbo].[uspARCustomerStatementReport]
	  @dtmDateTo					AS DATETIME			= NULL
	, @dtmDateFrom					AS DATETIME			= NULL
	, @ysnPrintZeroBalance			AS BIT				= 0
	, @ysnPrintCreditBalance		AS BIT				= 1
	, @ysnIncludeBudget				AS BIT				= 0
	, @ysnPrintOnlyPastDue			AS BIT				= 0
	, @ysnActiveCustomers			AS BIT				= 0
	, @strCustomerNumber			AS NVARCHAR(MAX)	= NULL
	, @strAccountStatusCode			AS NVARCHAR(MAX)	= NULL
	, @strLocationName				AS NVARCHAR(MAX)	= NULL
	, @strStatementFormat			AS NVARCHAR(MAX)	= 'Open Item'
	, @strCustomerName				AS NVARCHAR(MAX)	= NULL
	, @strCustomerIds				AS NVARCHAR(MAX)	= NULL
	, @ysnEmailOnly					AS BIT				= NULL
	, @ysnIncludeWriteOffPayment    AS BIT 				= 0
	, @intEntityUserId				AS INT				= NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmDateToLocal						AS DATETIME			= NULL
	  , @dtmDateFromLocal					AS DATETIME			= NULL
	  , @ysnPrintZeroBalanceLocal			AS BIT				= 0
	  , @ysnPrintCreditBalanceLocal			AS BIT				= 1
	  , @ysnIncludeBudgetLocal				AS BIT				= 0
	  , @ysnPrintOnlyPastDueLocal			AS BIT				= 0
	  , @ysnActiveCustomersLocal			AS BIT				= 0
	  , @ysnIncludeWriteOffPaymentLocal		AS BIT				= 0
	  , @strCustomerNumberLocal				AS NVARCHAR(MAX)	= NULL
	  , @strLocationNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal			AS NVARCHAR(MAX)	= NULL
	  , @strStatementFormatLocal			AS NVARCHAR(MAX)	= 'Open Item'
	  , @strCustomerNameLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCustomerIdsLocal				AS NVARCHAR(MAX)	= NULL
	  , @strCompanyLocationIdsLocal			AS NVARCHAR(MAX)	= NULL
	  , @strDateTo							AS NVARCHAR(50)
	  , @strDateFrom						AS NVARCHAR(50)
	  , @query								AS NVARCHAR(MAX)
	  , @queryBudget						AS NVARCHAR(MAX)
	  , @filter								AS NVARCHAR(MAX)	= ''
	  , @queryRunningBalance				AS NVARCHAR(MAX)	= ''
	  , @queryRunningBalanceBudget			AS NVARCHAR(MAX)	= ''
	  , @intWriteOffPaymentMethodId			AS INT				= NULL
	  , @intEntityUserIdLocal				AS INT				= NULL
	  , @ysnStretchLogo						AS BIT				= 0
	  , @blbLogo							AS VARBINARY(MAX)	= NULL
	  , @blbStretchedLogo					AS VARBINARY(MAX)	= NULL
	  , @strCompanyName						AS NVARCHAR(500)	= NULL
	  , @strCompanyAddress					AS NVARCHAR(500)	= NULL
	  , @dblTotalAR							NUMERIC(18,6)		= NULL

DECLARE @temp_statement_table TABLE(
	 [intTempId]					INT IDENTITY(1,1)		
	,[strReferenceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strTransactionType]			NVARCHAR(100)
	,[intEntityCustomerId]			INT
	,[dtmDueDate]					DATETIME
	,[dtmDate]						DATETIME
	,[intDaysDue]					INT
	,[dblTotalAmount]				NUMERIC(18,6)
	,[dblAmountPaid]				NUMERIC(18,6)
	,[dblAmountDue]					NUMERIC(18,6)
	,[dblPastDue]					NUMERIC(18,6)
	,[dblMonthlyBudget]				NUMERIC(18,6)
	,[dblRunningBalance]			NUMERIC(18,6)
	,[strCustomerNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strDisplayName]				NVARCHAR(100)
	,[strName]						NVARCHAR(100)
	,[strBOLNumber]					NVARCHAR(100)
	,[dblCreditLimit]				NUMERIC(18,6)
	,[strTicketNumbers]				NVARCHAR(MAX)
	,[strLocationName]				NVARCHAR(100)
	,[strFullAddress]				NVARCHAR(MAX)
	,[strStatementFooterComment]	NVARCHAR(MAX)		
	,[dblARBalance]					NUMERIC(18,6)
    ,[intPaymentId]					INT
)

DECLARE @temp_cf_table TABLE(
	 [intInvoiceId]				INT
	,[strInvoiceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strInvoiceReportNumber]	NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[dtmInvoiceDate]			DATETIME
)

IF(OBJECT_ID('tempdb..#CUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #CUSTOMERS
END

IF(OBJECT_ID('tempdb..#GLACCOUNTS') IS NOT NULL)
BEGIN
	DROP TABLE #GLACCOUNTS
END

SELECT intEntityCustomerId			= intEntityId
	 , strCustomerNumber			= CAST(strCustomerNumber COLLATE Latin1_General_CI_AS AS NVARCHAR(200))
	 , strCustomerName				= CAST('' COLLATE Latin1_General_CI_AS AS NVARCHAR(200))
	 , strStatementFormat			= CAST(strStatementFormat COLLATE Latin1_General_CI_AS AS NVARCHAR(100))
	 , strFullAddress				= CAST('' COLLATE Latin1_General_CI_AS AS NVARCHAR(MAX))
	 , strStatementFooterComment	= CAST('' COLLATE Latin1_General_CI_AS AS NVARCHAR(MAX))
	 , dblCreditLimit				= dblCreditLimit
	 , dblARBalance					= dblARBalance
	 , ysnStatementCreditLimit		= ISNULL(ysnStatementCreditLimit, CAST(0 AS BIT))
INTO #CUSTOMERS
FROM tblARCustomer
WHERE 1 = 0

SET @dtmDateToLocal						= ISNULL(@dtmDateTo, GETDATE())
SET	@dtmDateFromLocal					= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET @ysnPrintZeroBalanceLocal			= ISNULL(@ysnPrintZeroBalance, 0)
SET @ysnPrintCreditBalanceLocal			= ISNULL(@ysnPrintCreditBalance, 1)
SET @ysnIncludeBudgetLocal				= ISNULL(@ysnIncludeBudget, 0)
SET @ysnPrintOnlyPastDueLocal			= ISNULL(@ysnPrintOnlyPastDue, 0)
SET @ysnActiveCustomersLocal			= ISNULL(@ysnActiveCustomers, 0)
SET @ysnIncludeWriteOffPaymentLocal		= ISNULL(@ysnIncludeWriteOffPayment, 0)
SET @strCustomerNumberLocal				= NULLIF(@strCustomerNumber, '')
SET @strAccountStatusCodeLocal			= NULLIF(@strAccountStatusCode, '')
SET @strLocationNameLocal				= NULLIF(@strLocationName, '')
SET @strStatementFormatLocal			= ISNULL(@strStatementFormat, 'Open Item')
SET @strCustomerNameLocal				= NULLIF(@strCustomerName, '')
SET @strCustomerIdsLocal				= NULLIF(@strCustomerIds, '')
SET @strDateTo							= ''''+ CONVERT(NVARCHAR(50),@dtmDateToLocal, 110) + ''''
SET @strDateFrom						= ''''+ CONVERT(NVARCHAR(50),@dtmDateFromLocal, 110) + ''''
SET @intEntityUserIdLocal				= NULLIF(@intEntityUserId, 0)

SELECT TOP 1 @ysnStretchLogo = ysnStretchLogo
FROM tblARCompanyPreference WITH (NOLOCK)

SELECT @blbLogo = dbo.fnSMGetCompanyLogo('Header')
SELECT @blbStretchedLogo = dbo.fnSMGetCompanyLogo('Stretched Header')

SELECT TOP 1 @strCompanyName = strCompanyName
		   , @strCompanyAddress = dbo.[fnARFormatCustomerAddress](strPhone, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
FROM dbo.tblSMCompanySetup WITH (NOLOCK)

IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT TOP 1 intEntityCustomerId    	= C.intEntityId 
				   , strCustomerNumber      	= C.strCustomerNumber
				   , strCustomerName        	= EC.strName
				   , strStatementFormat			= ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item')
				   , dblCreditLimit         	= C.dblCreditLimit
				   , dblARBalance           	= C.dblARBalance
				   , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
					, strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE strEntityNo = @strCustomerNumberLocal
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 )) OR @ysnActiveCustomersLocal = 0)
		  	AND ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item') = @strStatementFormatLocal
	END
ELSE IF @strCustomerIdsLocal IS NOT NULL
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId  	= C.intEntityId 
		     , strCustomerNumber    	= C.strCustomerNumber
		     , strCustomerName      	= EC.strName
		     , strStatementFormat		= ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item')
		     , dblCreditLimit       	= C.dblCreditLimit
		     , dblARBalance         	= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intID
			FROM dbo.fnGetRowsFromDelimitedValues(@strCustomerIdsLocal)
		) CUSTOMERS ON C.intEntityId = CUSTOMERS.intID
		INNER JOIN (
			SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)			
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item') = @strStatementFormatLocal
	END
ELSE
	BEGIN
		INSERT INTO #CUSTOMERS (intEntityCustomerId, strCustomerNumber, strCustomerName, strStatementFormat, dblCreditLimit, dblARBalance, ysnStatementCreditLimit)
		SELECT intEntityCustomerId  	= C.intEntityId 
			 , strCustomerNumber		= C.strCustomerNumber
			 , strCustomerName      	= EC.strName
			 , strStatementFormat		= ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item')
			 , dblCreditLimit       	= C.dblCreditLimit
			 , dblARBalance         	= C.dblARBalance
			 , ysnStatementCreditLimit	= C.ysnStatementCreditLimit
		FROM tblARCustomer C WITH (NOLOCK)
		INNER JOIN (
			SELECT intEntityId
					, strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
			WHERE (@strCustomerNameLocal IS NULL OR strName = @strCustomerNameLocal)
		) EC ON C.intEntityId = EC.intEntityId
		WHERE ((@ysnActiveCustomersLocal = 1 AND (C.ysnActive = 1 or C.dblARBalance <> 0 ) ) OR @ysnActiveCustomersLocal = 0)
			AND ISNULL(NULLIF(C.strStatementFormat, ''), 'Open Item') = @strStatementFormatLocal
END

--#GLACCOUNTS
SELECT intAccountId
	 , strAccountCategory
INTO #GLACCOUNTS
FROM vyuGLAccountDetail
WHERE strAccountCategory IN ('AR Account', 'Customer Prepayments')

IF @strAccountStatusCodeLocal IS NOT NULL
    BEGIN
        DELETE FROM #CUSTOMERS
        WHERE intEntityCustomerId NOT IN (
            SELECT DISTINCT intEntityCustomerId
            FROM dbo.tblARCustomerAccountStatus CAS WITH (NOLOCK)
            INNER JOIN tblARAccountStatus AAS WITH (NOLOCK) ON CAS.intAccountStatusId = AAS.intAccountStatusId
            WHERE AAS.strAccountStatusCode = @strAccountStatusCodeLocal
        )
    END

IF @strLocationNameLocal IS NOT NULL
	SET @filter = CASE WHEN ISNULL(@filter, '') <> '' THEN @filter + ' AND ' ELSE @filter + '' END + 'strLocationName = ''' + @strLocationNameLocal + ''''

IF (@@version NOT LIKE '%2008%')
	BEGIN
		SET @queryRunningBalance = ' ORDER BY I.dtmPostDate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'
		SET @queryRunningBalanceBudget = ' ORDER BY intCustomerBudgetId ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'
	END
ELSE  
	BEGIN
		SET @queryRunningBalance = ' , I.intInvoiceId '
	END

IF @ysnEmailOnly IS NOT NULL
	BEGIN
		DELETE C
		FROM #CUSTOMERS C
		OUTER APPLY (
			SELECT intEmailSetupCount = COUNT(*) 
			FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
			WHERE CC.intCustomerEntityId = C.intEntityCustomerId 
				AND ISNULL(CC.strEmail, '') <> '' 
				AND CC.strEmailDistributionOption LIKE '%Statements%'
		) EMAILSETUP
		WHERE CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END <> @ysnEmailOnly
	END

SELECT @strCustomerIdsLocal = LEFT(intEntityCustomerId, LEN(intEntityCustomerId) - 1)
FROM (
	SELECT DISTINCT CAST(intEntityCustomerId AS VARCHAR(MAX))  + ', '
	FROM #CUSTOMERS
	FOR XML PATH ('')
) C (intEntityCustomerId)

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

IF @ysnIncludeWriteOffPaymentLocal = 1
	BEGIN
		SELECT TOP 1 @intWriteOffPaymentMethodId = intPaymentMethodID 
		FROM dbo.tblSMPaymentMethod WITH (NOLOCK) 
		WHERE UPPER(strPaymentMethod) = 'WRITE OFF'
	END

EXEC dbo.[uspARCustomerAgingAsOfDateReport] @dtmDateFrom				= @dtmDateFromLocal
										  , @dtmDateTo					= @dtmDateToLocal
										  , @intEntityUserId			= @intEntityUserIdLocal
										  , @strCustomerIds				= @strCustomerIdsLocal
										  , @strCompanyLocationIds		= @strCompanyLocationIdsLocal
										  , @ysnIncludeWriteOffPayment	= @ysnIncludeWriteOffPaymentLocal										  

UPDATE C
SET strFullAddress				= dbo.fnARFormatCustomerAddress(NULL, NULL, CASE WHEN C.strStatementFormat <> 'Running Balance' THEN CS.strBillToLocationName ELSE NULL END, CS.strBillToAddress, CS.strBillToCity, CS.strBillToState, CS.strBillToZipCode, CS.strBillToCountry, NULL, NULL)
  , strStatementFooterComment	= dbo.fnARGetDefaultComment(NULL, C.intEntityCustomerId, 'Statement Report', NULL, 'Footer', NULL, 1)
FROM #CUSTOMERS C
INNER JOIN vyuARCustomerSearch CS ON C.intEntityCustomerId = CS.intEntityCustomerId

SET @query = CAST('' AS NVARCHAR(MAX)) + '
SELECT * 
FROM (
	SELECT strReferenceNumber			= CASE WHEN ISNULL(I.ysnImportedFromOrigin, 0) = 0 THEN I.strInvoiceNumber ELSE ISNULL(I.strInvoiceOriginId, I.strInvoiceNumber) END
		 , strTransactionType			= CASE WHEN I.strType = ''Service Charge'' THEN ''Service Charge'' ELSE I.strTransactionType END
		 , intEntityCustomerId			= C.intEntityId
		 , dtmDueDate					= CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Credit Memo'', ''Debit Memo'') THEN NULL ELSE I.dtmDueDate END
		 , dtmDate						= I.dtmDate
		 , intDaysDue					= DATEDIFF(DAY, I.[dtmDueDate], '+ @strDateTo +')
		 , dblTotalAmount				= CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
		 , dblAmountPaid				= CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN ISNULL(TOTALPAYMENT.dblPayment, 0) * -1 ELSE ISNULL(TOTALPAYMENT.dblPayment, 0) END
		 , dblAmountDue					= CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
		 , dblPastDue					= CASE WHEN '+ @strDateTo +' > I.[dtmDueDate] AND I.strTransactionType IN (''Invoice'', ''Debit Memo'')
												 THEN I.dblInvoiceTotal - ISNULL(TOTALPAYMENT.dblPayment, 0)
											   ELSE 0
										  END
		 , dblMonthlyBudget				= ISNULL([dbo].[fnARGetCustomerBudget](C.intEntityId, I.dtmDate), 0)
		 , dblRunningBalance			= SUM(CASE WHEN I.strTransactionType NOT IN (''Invoice'', ''Debit Memo'') THEN I.dblInvoiceTotal * -1 ELSE (CASE WHEN I.strType = ''CF Tran'' THEN 0 ELSE I.dblInvoiceTotal END) END - ISNULL(TOTALPAYMENT.dblPayment, 0)) OVER (PARTITION BY I.intEntityCustomerId'+ @queryRunningBalance +')
		 , strCustomerNumber			= C.strCustomerNumber
		 , strDisplayName				= CASE WHEN C.strStatementFormat <> ''Running Balance'' THEN C.strName ELSE ISNULL(NULLIF(C.strCheckPayeeName, ''''), C.strName) END
		 , strName						= C.strName
		 , strBOLNumber					= I.strBOLNumber
		 , dblCreditLimit				= C.dblCreditLimit		 
		 , strTicketNumbers				= I.strTicketNumbers
		 , strLocationName				= CL.strLocationName
		 , strFullAddress				= CUST.strFullAddress 
		 , strStatementFooterComment	= CUST.strStatementFooterComment
		 , dblARBalance					= C.dblARBalance
		 , intPaymentId 				= PCREDITS.intPaymentId
	FROM vyuARCustomerSearch C WITH (NOLOCK)
	INNER JOIN #CUSTOMERS CUST ON C.intEntityCustomerId = CUST.intEntityCustomerId
	LEFT JOIN (
		SELECT intEntityCustomerId
			 , intInvoiceId
			 , intPaymentId
			 , intTermId
			 , intCompanyLocationId
			 , strTransactionType
			 , strType
			 , strInvoiceNumber
			 , strInvoiceOriginId
			 , strBOLNumber
			 , dblInvoiceTotal
			 , dtmDate
			 , dtmPostDate
			 , dtmDueDate
			 , ysnImportedFromOrigin
			 , strTicketNumbers	= SCALETICKETS.strTicketNumbers
		FROM dbo.tblARInvoice I WITH (NOLOCK)
		INNER JOIN #GLACCOUNTS GL ON I.intAccountId = GL.intAccountId
		OUTER APPLY (
			SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1)
			FROM (
				SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + '', ''
				FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
				INNER JOIN (
					SELECT intTicketId
						 , strTicketNumber 
					FROM dbo.tblSCTicket WITH(NOLOCK)
				) T ON ID.intTicketId = T.intTicketId
				WHERE ID.intInvoiceId = I.intInvoiceId
				GROUP BY ID.intInvoiceId, ID.intTicketId, T.strTicketNumber
				FOR XML PATH ('''')
			) INV (strTicketNumber)
		) SCALETICKETS
		WHERE ysnPosted  = 1		
		  AND ysnCancelled = 0
		  AND ((strType = ''Service Charge'' AND ysnForgiven = 0) OR ((strType <> ''Service Charge'' AND ysnForgiven = 1) OR (strType <> ''Service Charge'' AND ysnForgiven = 0)))
		  AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate)))  BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +')				
	) I ON I.intEntityCustomerId = C.intEntityId		
	LEFT JOIN (
		SELECT intPaymentId	
		FROM dbo.tblARPayment WITH (NOLOCK)
		WHERE ysnPosted = 1 
		  AND ISNULL(ysnProcessedToNSF, 0) = 0
		  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
		  ' + CASE WHEN @ysnIncludeWriteOffPaymentLocal = 1 THEN 'AND intPaymentMethodId <> ' + CAST(@intWriteOffPaymentMethodId AS NVARCHAR(10)) + '' ELSE ' ' END + '
	) PCREDITS ON I.intPaymentId = PCREDITS.intPaymentId
	LEFT JOIN (
		SELECT dblPayment = SUM(dblPayment) + SUM(dblDiscount) + SUM(dblWriteOffAmount) - SUM(dblInterest)
			 , intInvoiceId
		FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
		INNER JOIN (
			SELECT intPaymentId
			FROM dbo.tblARPayment WITH (NOLOCK) 
			WHERE ysnPosted = 1
			  AND ysnInvoicePrepayment = 0
			  AND ISNULL(ysnProcessedToNSF, 0) = 0
			  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= '+ @strDateTo +'
			  ' + CASE WHEN @ysnIncludeWriteOffPaymentLocal = 1 THEN 'AND intPaymentMethodId <> ' + CAST(@intWriteOffPaymentMethodId AS NVARCHAR(10)) + '' ELSE ' ' END + '
		) P ON PD.intPaymentId = P.intPaymentId
		GROUP BY intInvoiceId
	) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
	LEFT JOIN (
		SELECT intPrepaymentId
			 , dblAppliedInvoiceAmount = SUM(dblAppliedInvoiceAmount)
		FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
		WHERE ysnApplied = 1
		GROUP BY intPrepaymentId
	) PC ON I.intInvoiceId = PC.intPrepaymentId
	LEFT JOIN (
		SELECT intTermID
			 , strTerm
		FROM dbo.tblSMTerm WITH (NOLOCK)
	) T ON I.intTermId = T.intTermID	
	LEFT JOIN (
		SELECT intCompanyLocationId
			 , strLocationName
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
	) CL ON I.intCompanyLocationId = CL.intCompanyLocationId
	WHERE I.dblInvoiceTotal - ABS(ISNULL(TOTALPAYMENT.dblPayment, 0)) <> 0
) MainQuery'
 
IF ISNULL(@filter,'') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter	
END

print @query
INSERT INTO @temp_statement_table
EXEC sp_executesql @query

IF @ysnIncludeBudgetLocal = 1
	BEGIN
		SET @queryBudget = CAST('' AS NVARCHAR(MAX)) + 
			'SELECT strReferenceNumber			= ''Budget due for: '' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) 
				  , strTransactionType			= ''Customer Budget''
				  , intEntityCustomerId			= C.intEntityCustomerId
				  , dtmDueDate					= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
				  , dtmDate						= dtmBudgetDate
				  , intDaysDue					= DATEDIFF(DAY, DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)), '+ @strDateTo +')
				  , dblTotalAmount				= dblBudgetAmount
				  , dblAmountPaid				= dblAmountPaid
				  , dblAmountDue				= 0.00
				  , dblPastDue					= 0.00
				  , dblMonthlyBudget			= dblBudgetAmount
				  , dblRunningBalance			= 0.00
				  , strCustomerNumber			= C.strCustomerNumber
				  , strDisplayName				= CASE WHEN C.strStatementFormat <> ''Running Balance'' THEN C.strCustomerName ELSE ISNULL(CUST.strCheckPayeeName, C.strCustomerName) END
				  , strName						= C.strCustomerName
				  , strBOLNumber				= NULL
				  , dblCreditLimit				= C.dblCreditLimit
				  , strTicketNumbers			= NULL
				  , strLocationName				= NULL
				  , strFullAddress				= C.strFullAddress
				  , strStatementFooterComment	= C.strStatementFooterComment
				  , dblARBalance				= C.dblARBalance
				  , intPaymentId				= NULL
			FROM tblARCustomerBudget CB
				INNER JOIN #CUSTOMERS C ON CB.intEntityCustomerId = C.intEntityCustomerId
				INNER JOIN (
					SELECT intEntityCustomerId
						 , strCheckPayeeName
						 , strName
					FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
				) CUST ON CB.intEntityCustomerId = CUST.intEntityCustomerId
			WHERE CB.dtmBudgetDate BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
			  AND CB.dblAmountPaid < CB.dblBudgetAmount'
		
		IF ISNULL(@filter,'') != ''
		BEGIN
			SET @queryBudget = @queryBudget + ' WHERE ' + @filter
		END	

		INSERT INTO @temp_statement_table
		EXEC sp_executesql @queryBudget

		IF EXISTS(SELECT TOP 1 NULL FROM @temp_statement_table WHERE strTransactionType = 'Customer Budget')
			BEGIN
				UPDATE STATEMENTS
				SET strLocationName				= COMPLETESTATEMENTS.strLocationName
				FROM @temp_statement_table STATEMENTS
				OUTER APPLY (
					SELECT TOP 1 strLocationName
					FROM @temp_statement_table
					WHERE intEntityCustomerId = STATEMENTS.intEntityCustomerId					  
				) COMPLETESTATEMENTS
				WHERE strTransactionType = 'Customer Budget'
			END
	END

IF @ysnPrintOnlyPastDueLocal = 1
	BEGIN
		DELETE FROM @temp_statement_table WHERE strTransactionType = 'Invoice' AND dblPastDue <= 0

		UPDATE tblARCustomerAgingStagingTable
		SET dbl0Days = 0
		WHERE intEntityUserId = @intEntityUserIdLocal
		  AND strAgingType = 'Summary'
	END


SELECT @dblTotalAR = SUM(dblTotalAR) FROM tblARCustomerAgingStagingTable

IF @ysnPrintZeroBalanceLocal = 0
	BEGIN
		IF @dblTotalAR = 0 
		BEGIN
		DELETE FROM @temp_statement_table WHERE ((((ABS(dblAmountDue) * 10000) - CONVERT(FLOAT, (ABS(dblAmountDue) * 10000))) <> 0) OR ISNULL(dblAmountDue, 0) <= 0) AND strTransactionType <> 'Customer Budget'
		DELETE FROM tblARCustomerAgingStagingTable WHERE ((((ABS(dblTotalAR) * 10000) - CONVERT(FLOAT, (ABS(dblTotalAR) * 10000))) <> 0) OR ISNULL(dblTotalAR, 0) <= 0) AND intEntityUserId = @intEntityUserIdLocal AND strAgingType = 'Summary'

		DELETE from #CUSTOMERS 
			WHERE intEntityCustomerId not in (
					select intEntityCustomerId from 
						tblARCustomerAgingStagingTable 
							where  intEntityUserId = @intEntityUserIdLocal 
								AND strAgingType = 'Summary')
		END
	END

INSERT INTO @temp_cf_table (
	  intInvoiceId
	, strInvoiceNumber
	, strInvoiceReportNumber
	, dtmInvoiceDate
)
SELECT cfTable.intInvoiceId
	 , cfTable.strInvoiceNumber
	 , cfTable.strInvoiceReportNumber
	 , cfTable.dtmInvoiceDate
FROM @temp_statement_table statementTable
INNER JOIN (
	SELECT ARI.intInvoiceId 
		 , ARI.strInvoiceNumber
		 , CFT.strInvoiceReportNumber
		 , CFT.dtmInvoiceDate
	FROM (
		SELECT intInvoiceId
			 , strInvoiceNumber
		FROM dbo.tblARInvoice WITH (NOLOCK)
		WHERE strType NOT IN ('CF Tran')
	) ARI
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceReportNumber
			 , dtmInvoiceDate 
		FROM dbo.tblCFTransaction WITH (NOLOCK)
		WHERE ISNULL(strInvoiceReportNumber,'') <> ''
	) CFT ON ARI.intInvoiceId = CFT.intInvoiceId
) cfTable ON statementTable.strReferenceNumber = cfTable.strInvoiceNumber

DELETE FROM @temp_statement_table
WHERE strReferenceNumber IN (SELECT strInvoiceNumber FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateTo, SUM(ISNULL(dblAmountDue, 0))
FROM @temp_statement_table GROUP BY strCustomerNumber
)
AS Source (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = Source.strCustomerNumber

WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = Source.dtmLastStatementDate, dblLastStatement = Source.dblLastStatement

WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

IF (@@version  LIKE '%2008%')
BEGIN

    UPDATE STATEMENTREPORT
    SET dblRunningBalance = STATEMENTREPORT2.dblRunningBalance
    FROM @temp_statement_table STATEMENTREPORT
        INNER JOIN
        (
            SELECT STATEMENTREPORT.intTempId,
                   SUM(STATEMENTREPORT2.dblRunningBalance) [dblRunningBalance]
            FROM @temp_statement_table AS STATEMENTREPORT
                INNER JOIN @temp_statement_table AS STATEMENTREPORT2
                 ON STATEMENTREPORT2.intTempId <= STATEMENTREPORT.intTempId
            WHERE STATEMENTREPORT.strReferenceNumber NOT IN (SELECT strInvoiceNumber FROM @temp_cf_table )
            GROUP BY STATEMENTREPORT.intTempId
        ) STATEMENTREPORT2 ON STATEMENTREPORT2.intTempId = STATEMENTREPORT.intTempId;
END;

DELETE FROM tblARCustomerStatementStagingTable WHERE intEntityUserId = @intEntityUserIdLocal AND strStatementFormat = @strStatementFormatLocal
INSERT INTO tblARCustomerStatementStagingTable (
	  strReferenceNumber
	, intEntityCustomerId
	, strTransactionType
	, dtmDueDate
	, dtmDate
	, intDaysDue
	, dblTotalAmount
	, dblAmountPaid
	, dblAmountDue
	, dblPastDue
	, dblMonthlyBudget
	, dblRunningBalance
	, strCustomerNumber
	, strDisplayName
	, strCustomerName
	, strBOLNumber
	, dblCreditLimit
	, strFullAddress
	, strStatementFooterComment
	, strTicketNumbers
	, dblCreditAvailable
	, dblFuture
	, dbl0Days
	, dbl10Days
	, dbl30Days
	, dbl60Days
	, dbl90Days
	, dbl91Days
	, dblCredits
	, dblPrepayments
	, dtmAsOfDate	
	, intEntityUserId
	, strStatementFormat
	, ysnStatementCreditLimit
)
SELECT MAINREPORT.* 
	 , dblCreditAvailable	= CASE WHEN (MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)) < 0 THEN 0 ELSE MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0) END
	 , dblFuture			= ISNULL(AGINGREPORT.dblFuture, 0)
	 , dbl0Days				= ISNULL(AGINGREPORT.dbl0Days, 0)
	 , dbl10Days			= ISNULL(AGINGREPORT.dbl10Days, 0)
	 , dbl30Days			= ISNULL(AGINGREPORT.dbl30Days, 0)
	 , dbl60Days			= ISNULL(AGINGREPORT.dbl60Days, 0)
	 , dbl90Days			= ISNULL(AGINGREPORT.dbl90Days, 0)
	 , dbl91Days			= ISNULL(AGINGREPORT.dbl91Days, 0)
	 , dblCredits			= ISNULL(AGINGREPORT.dblCredits, 0)
	 , dblPrepayments		= ISNULL(AGINGREPORT.dblPrepayments, 0)
	 , dtmAsOfDate			= @dtmDateToLocal
	 , intEntityUserId		= @intEntityUserIdLocal
	 , strStatementFormat	= @strStatementFormatLocal
	 , ysnStatementCreditLimit	= CUSTOMER.ysnStatementCreditLimit
FROM (
	SELECT STATEMENTREPORT.strReferenceNumber
		 , STATEMENTREPORT.intEntityCustomerId
		 , STATEMENTREPORT.strTransactionType
		 , STATEMENTREPORT.dtmDueDate
		 , STATEMENTREPORT.dtmDate
		 , STATEMENTREPORT.intDaysDue
		 , STATEMENTREPORT.dblTotalAmount
		 , STATEMENTREPORT.dblAmountPaid
		 , STATEMENTREPORT.dblAmountDue
		 , STATEMENTREPORT.dblPastDue
		 , STATEMENTREPORT.dblMonthlyBudget
		 , STATEMENTREPORT.dblRunningBalance
		 , STATEMENTREPORT.strCustomerNumber
		 , STATEMENTREPORT.strDisplayName
		 , STATEMENTREPORT.strName
		 , STATEMENTREPORT.strBOLNumber
		 , STATEMENTREPORT.dblCreditLimit	  
		 , STATEMENTREPORT.strFullAddress
		 , STATEMENTREPORT.strStatementFooterComment	  
		 , STATEMENTREPORT.strTicketNumbers
	FROM @temp_statement_table AS STATEMENTREPORT
	WHERE strReferenceNumber NOT IN (SELECT strInvoiceNumber FROM @temp_cf_table)

	UNION ALL

	--- With CF Report
	SELECT strReferenceNumber						= CFReportTable.strInvoiceReportNumber
		 , STATEMENTREPORT.intEntityCustomerId
		 , STATEMENTREPORT.strTransactionType
		 , dtmDueDate								= CFReportTable.dtmInvoiceDate
		 , dtmDate									= CFReportTable.dtmInvoiceDate
		 , intDaysDue								= (SELECT TOP 1 intDaysDue FROM @temp_statement_table ORDER BY intDaysDue DESC)
		 , dblTotalAmount							= SUM(STATEMENTREPORT.dblTotalAmount)
		 , dblAmountPaid							= SUM(STATEMENTREPORT.dblAmountPaid)
		 , dblAmountDue								= SUM(STATEMENTREPORT.dblAmountDue)
		 , dblPastDue								= SUM(STATEMENTREPORT.dblPastDue)
		 , dblMonthlyBudget							= SUM(STATEMENTREPORT.dblMonthlyBudget)
		 , dblRunningBalance						= SUM(STATEMENTREPORT.dblRunningBalance)
		 , STATEMENTREPORT.strCustomerNumber
		 , STATEMENTREPORT.strDisplayName
		 , STATEMENTREPORT.strName
		 , STATEMENTREPORT.strBOLNumber
		 , STATEMENTREPORT.dblCreditLimit	  
		 , STATEMENTREPORT.strFullAddress
		 , STATEMENTREPORT.strStatementFooterComment	  
		 , STATEMENTREPORT.strTicketNumbers
	FROM @temp_statement_table AS STATEMENTREPORT
	INNER JOIN (
		SELECT intInvoiceId
			 , strInvoiceNumber
			 , strInvoiceReportNumber
			 , dtmInvoiceDate 
		FROM @temp_cf_table
	) CFReportTable ON STATEMENTREPORT.strReferenceNumber = CFReportTable.strInvoiceNumber
	GROUP BY CFReportTable.strInvoiceReportNumber
			, CFReportTable.dtmInvoiceDate
			, STATEMENTREPORT.strTransactionType	  
			, STATEMENTREPORT.strCustomerNumber
			, STATEMENTREPORT.strDisplayName
			, STATEMENTREPORT.strName
			, STATEMENTREPORT.strBOLNumber
			, STATEMENTREPORT.dblCreditLimit	  
			, STATEMENTREPORT.strFullAddress
			, STATEMENTREPORT.strStatementFooterComment
			, STATEMENTREPORT.intEntityCustomerId
			, STATEMENTREPORT.strTicketNumbers
) MAINREPORT
LEFT JOIN tblARCustomerAgingStagingTable AS AGINGREPORT
	ON MAINREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
	AND AGINGREPORT.intEntityUserId = @intEntityUserIdLocal
	AND AGINGREPORT.strAgingType = 'Summary'
INNER JOIN #CUSTOMERS CUSTOMER ON MAINREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId


UPDATE tblARCustomerStatementStagingTable
SET strComment			= dbo.fnEMEntityMessage(intEntityCustomerId, 'Statement')
  , blbLogo				= CASE WHEN ISNULL(@ysnStretchLogo, 0) = 1 THEN ISNULL(@blbStretchedLogo, @blbLogo) ELSE @blbLogo END
  , strCompanyName		= @strCompanyName
  , strCompanyAddress	= @strCompanyAddress
  , ysnStretchLogo 		= ISNULL(@ysnStretchLogo, 0)
WHERE intEntityUserId = @intEntityUserIdLocal
  AND ISNULL(NULLIF(strStatementFormat, ''), 'Open Item') = @strStatementFormatLocal

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM tblARCustomerStatementStagingTable 
		WHERE intEntityUserId = @intEntityUserIdLocal 
		  AND strStatementFormat = @strStatementFormatLocal
		  AND intEntityCustomerId IN (
			  SELECT DISTINCT intEntityCustomerId
			  FROM tblARCustomerAgingStagingTable AGINGREPORT
			  WHERE AGINGREPORT.intEntityUserId = @intEntityUserIdLocal
				AND AGINGREPORT.strAgingType = 'Summary'
				AND ISNULL(AGINGREPORT.dblTotalAR, 0) < 0
		  )
	END

