﻿CREATE PROCEDURE [dbo].[uspARCustomerStatementBalanceForwardReport]
	  @dtmDateTo				AS DATETIME			= NULL
	, @dtmDateFrom				AS DATETIME			= NULL
	, @dtmBalanceForwardDate	AS DATETIME			= NULL
	, @ysnPrintZeroBalance		AS BIT				= 0
	, @ysnPrintCreditBalance	AS BIT				= 1
	, @ysnIncludeBudget			AS BIT				= 0
	, @ysnPrintOnlyPastDue		AS BIT				= 0
	, @ysnPrintFromCF			AS BIT				= 0
	, @strCustomerNumber		AS NVARCHAR(MAX)	= NULL
	, @strAccountStatusCode		AS NVARCHAR(MAX)	= NULL
	, @strLocationName			AS NVARCHAR(MAX)	= NULL	 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmDateToLocal				AS DATETIME			= NULL
	  , @dtmDateFromLocal			AS DATETIME			= NULL
	  , @dtmBalanceForwardDateLocal AS DATETIME			= NULL
	  , @ysnPrintZeroBalanceLocal	AS BIT				= 0
	  , @ysnPrintCreditBalanceLocal	AS BIT				= 1
	  , @ysnIncludeBudgetLocal		AS BIT				= 0
	  , @ysnPrintOnlyPastDueLocal	AS BIT				= 0
	  , @ysnPrintFromCFLocal		AS BIT				= 0
	  , @strCustomerNumberLocal		AS NVARCHAR(MAX)	= NULL
	  , @strAccountStatusCodeLocal	AS NVARCHAR(MAX)	= NULL
	  , @strLocationNameLocal		AS NVARCHAR(MAX)	= NULL 
	  , @strDateTo					AS NVARCHAR(50)
	  , @strDateFrom				AS NVARCHAR(50)
	  , @query						AS NVARCHAR(MAX)
	  , @queryBudget				AS NVARCHAR(MAX)
	  , @queryBalanceForward        AS NVARCHAR(MAX)
	  , @filter						AS NVARCHAR(MAX)	= ''
	  , @intEntityCustomerId		AS INT				= NULL

DECLARE @temp_aging_table TABLE(
     [strCustomerName]          NVARCHAR(100)
    ,[strEntityNo]              NVARCHAR(100)
    ,[intEntityCustomerId]      INT
    ,[dblCreditLimit]			NUMERIC(18,6)
    ,[dblTotalAR]               NUMERIC(18,6)
    ,[dblFuture]                NUMERIC(18,6)
    ,[dbl0Days]                 NUMERIC(18,6)
    ,[dbl10Days]                NUMERIC(18,6)
    ,[dbl30Days]                NUMERIC(18,6)
    ,[dbl60Days]                NUMERIC(18,6)
    ,[dbl90Days]                NUMERIC(18,6)
    ,[dbl91Days]                NUMERIC(18,6)
    ,[dblTotalDue]              NUMERIC(18,6)
    ,[dblAmountPaid]            NUMERIC(18,6)
    ,[dblCredits]               NUMERIC(18,6)
	,[dblPrepayments]			NUMERIC(18,6)
    ,[dblPrepaids]              NUMERIC(18,6)
    ,[dtmAsOfDate]              DATETIME
    ,[strSalespersonName]		NVARCHAR(100)
	,[strSourceTransaction]		NVARCHAR(100)
)

DECLARE @temp_balanceforward_table TABLE(
     [strCustomerName]          NVARCHAR(100)
    ,[strEntityNo]              NVARCHAR(100)
    ,[intEntityCustomerId]      INT
    ,[dblCreditLimit]			NUMERIC(18,6)
    ,[dblTotalAR]               NUMERIC(18,6)
    ,[dblFuture]                NUMERIC(18,6)
    ,[dbl0Days]                 NUMERIC(18,6)
    ,[dbl10Days]                NUMERIC(18,6)
    ,[dbl30Days]                NUMERIC(18,6)
    ,[dbl60Days]                NUMERIC(18,6)
    ,[dbl90Days]                NUMERIC(18,6)
    ,[dbl91Days]                NUMERIC(18,6)
    ,[dblTotalDue]              NUMERIC(18,6)
    ,[dblAmountPaid]            NUMERIC(18,6)
    ,[dblCredits]               NUMERIC(18,6)
	,[dblPrepayments]			NUMERIC(18,6)
    ,[dblPrepaids]              NUMERIC(18,6)
    ,[dtmAsOfDate]              DATETIME
    ,[strSalespersonName]		NVARCHAR(100)
	,[strSourceTransaction]		NVARCHAR(100)
)

DECLARE @temp_statement_table TABLE(
     [intEntityCustomerId]			INT
    ,[strCustomerNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strCustomerName]				NVARCHAR(100)
    ,[dblCreditLimit]				NUMERIC(18,6)
    ,[intInvoiceId]					INT
    ,[strInvoiceNumber]				NVARCHAR(100) COLLATE Latin1_General_CI_AS
    ,[strBOLNumber]					NVARCHAR(100)
    ,[dtmDate]						DATETIME
    ,[dtmDueDate]					DATETIME
    ,[dtmShipDate]					DATETIME
    ,[dblInvoiceTotal]				NUMERIC(18,6)
    ,[intPaymentId]					INT
    ,[strRecordNumber]				NVARCHAR(100)
	,[strTransactionType]			NVARCHAR(100)
    ,[strPaymentInfo]				NVARCHAR(100)
    ,[dtmDatePaid]					DATETIME
    ,[dblPayment]					NUMERIC(18,6)
    ,[dblBalance]					NUMERIC(18,6)	
    ,[strSalespersonName]			NVARCHAR(100)
	,[strAccountStatusCode]			NVARCHAR(50)	
	,[strLocationName]				NVARCHAR(100)
    ,[strFullAddress]				NVARCHAR(MAX)
	,[strStatementFooterComment]	NVARCHAR(MAX)
    ,[strCompanyName]				NVARCHAR(MAX)
    ,[strCompanyAddress]			NVARCHAR(MAX)
	,[dblARBalance]					NUMERIC(18,6)
	,[strType]						NVARCHAR(100)
)

DECLARE @temp_cf_table TABLE(
	 [intInvoiceId]				INT
	,[strInvoiceNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[strInvoiceReportNumber]	NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,[dtmInvoiceDate]			DATETIME
)

SET @dtmDateToLocal				= ISNULL(@dtmDateTo, GETDATE())
SET	@dtmDateFromLocal			= ISNULL(@dtmDateFrom, CAST(-53690 AS DATETIME))
SET @dtmBalanceForwardDateLocal = ISNULL(@dtmBalanceForwardDate, @dtmDateFromLocal)
SET @ysnPrintZeroBalanceLocal	= ISNULL(@ysnPrintZeroBalance, 0)
SET @ysnPrintCreditBalanceLocal	= ISNULL(@ysnPrintCreditBalance, 1)
SET @ysnIncludeBudgetLocal		= ISNULL(@ysnIncludeBudget, 0)
SET @ysnPrintOnlyPastDueLocal	= ISNULL(@ysnPrintOnlyPastDue, 0)
SET @ysnPrintFromCFLocal		= ISNULL(@ysnPrintFromCF, 0)
SET @strCustomerNumberLocal		= NULLIF(@strCustomerNumber, '')
SET @strAccountStatusCodeLocal	= NULLIF(@strAccountStatusCode, '')
SET @strLocationNameLocal		= NULLIF(@strLocationName, '')

IF @ysnPrintFromCFLocal = 1
	BEGIN
		--SET @dtmBalanceForwardDateLocal = DATEADD(DAYOFYEAR, 1, @dtmBalanceForwardDateLocal)
		SET @dtmDateFromLocal = DATEADD(DAYOFYEAR, 1, @dtmBalanceForwardDateLocal)
	END

SET @strDateTo					= ''''+ CONVERT(NVARCHAR(50),@dtmDateToLocal, 110) + ''''
SET @strDateFrom				= ''''+ CONVERT(NVARCHAR(50),@dtmDateFromLocal, 110) + ''''

IF @strCustomerNumberLocal IS NOT NULL
	BEGIN
		SET @filter = 'strCustomerNumber = ''' + @strCustomerNumberLocal + ''''

		SELECT TOP 1 @intEntityCustomerId = intEntityCustomerId 
		FROM vyuARCustomerSearch WITH (NOLOCK)
		WHERE strCustomerNumber = @strCustomerNumberLocal
	END

IF @strAccountStatusCodeLocal IS NOT NULL
	SET @filter = CASE WHEN ISNULL(@filter, '') <> '' THEN @filter + ' AND ' ELSE @filter + '' END + 'strAccountStatusCode LIKE (%''' + @strAccountStatusCodeLocal + '''%)'

IF @strLocationNameLocal IS NOT NULL
	SET @filter = CASE WHEN ISNULL(@filter, '') <> '' THEN @filter + ' AND ' ELSE @filter + '' END + 'strLocationName = ''' + @strLocationNameLocal + ''''

INSERT INTO @temp_aging_table
EXEC dbo.[uspARCustomerAgingAsOfDateReport] NULL, @dtmDateToLocal, NULL, @intEntityCustomerId, NULL, @strLocationNameLocal, @ysnIncludeBudgetLocal, 1

INSERT INTO @temp_balanceforward_table
EXEC dbo.[uspARCustomerAgingAsOfDateReport] NULL, @dtmBalanceForwardDateLocal, NULL, @intEntityCustomerId, NULL, @strLocationNameLocal, @ysnIncludeBudgetLocal, @ysnPrintCreditBalanceLocal

SET @query = CAST('' AS NVARCHAR(MAX)) + 'SELECT * FROM
(SELECT intEntityCustomerId	= C.intEntityCustomerId
	  , C.strCustomerNumber
	  , strCustomerName		= C.strName
	  , C.dblCreditLimit
	  , intInvoiceId		= TRANSACTIONS.intInvoiceId
	  , strInvoiceNumber	= TRANSACTIONS.strInvoiceNumber
	  , strBOLNumber		= CASE WHEN TRANSACTIONS.strTransactionType = ''Customer Prepayment'' THEN ''Prepayment: '' + ISNULL(TRANSACTIONS.strPaymentInfo, '''') ELSE ''BOL# '' + TRANSACTIONS.strBOLNumber END
      , dtmDate				= TRANSACTIONS.dtmDate
      , dtmDueDate			= TRANSACTIONS.dtmDueDate
	  , dtmShipDate			= TRANSACTIONS.dtmShipDate
	  , dblInvoiceTotal		= TRANSACTIONS.dblInvoiceTotal
	  , intPaymentId		= TRANSACTIONS.intPaymentId
	  , strRecordNumber		= TRANSACTIONS.strRecordNumber
	  , strTransactionType  = TRANSACTIONS.strTransactionType
	  , strPaymentInfo	    = TRANSACTIONS.strPaymentInfo
	  , dtmDatePaid			= ISNULL(TRANSACTIONS.dtmDatePaid, ''01/02/1900'')
	  , dblPayment			= ISNULL(TRANSACTIONS.dblPayment, 0)
	  , dblBalance			= TRANSACTIONS.dblBalance
	  , strSalespersonName  = C.strSalesPersonName
	  , strAccountStatusCode = STATUSCODES.strAccountStatusCode
	  , strLocationName		= CL.strLocationName
	  , strFullAddress		= dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL, NULL)
	  , strStatementFooterComment = dbo.fnARGetFooterComment(NULL, TRANSACTIONS.intEntityCustomerId, ''Statement Footer'')
	  , strCompanyName		= COMPANY.strCompanyName
	  , strCompanyAddress	= COMPANY.strCompanyAddress
	  , dblARBalance		= C.dblARBalance
	  , strType				= TRANSACTIONS.strType
FROM vyuARCustomerSearch C
	LEFT JOIN (
		SELECT intInvoiceId			= I.intInvoiceId
			 , intEntityCustomerId	= I.intEntityCustomerId
			 , intPaymentId			= PCREDITS.intPaymentId
			 , intCompanyLocationId	= I.intCompanyLocationId
			 , intTermId			= I.intTermId
			 , strInvoiceNumber		= I.strInvoiceNumber
			 , strRecordNumber		= PCREDITS.strRecordNumber
			 , strInvoiceOriginId   = I.strInvoiceOriginId
			 , strBOLNumber			= I.strBOLNumber
			 , strPaymentInfo		= PCREDITS.strPaymentInfo
			 , strTransactionType	= I.strTransactionType
			 , dblInvoiceTotal		= CASE WHEN strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Customer Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END
			 , dblBalance			= CASE WHEN strTransactionType IN (''Credit Memo'', ''Overpayment'', ''Customer Prepayment'') THEN I.dblInvoiceTotal * -1 ELSE I.dblInvoiceTotal END - ISNULL(TOTALPAYMENT.dblPayment, 0)
			 , dblPayment			= 0.00
			 , dtmDate				= I.dtmDate
			 , dtmDueDate			= I.dtmDueDate
			 , dtmShipDate			= I.dtmShipDate
			 , dtmDatePaid			= PCREDITS.dtmDatePaid
			 , strType				= I.strType
		FROM dbo.tblARInvoice I WITH (NOLOCK)
		LEFT JOIN (
			SELECT dblPayment = SUM(dblPayment) + SUM(dblDiscount) - SUM(dblInterest)
				 , intInvoiceId 
			FROM tblARPaymentDetail PD WITH (NOLOCK) 
			INNER JOIN (SELECT intPaymentId
						FROM dbo.tblARPayment WITH (NOLOCK)
						WHERE ysnPosted = 1
							AND ysnInvoicePrepayment = 0 
							AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= '+ @strDateTo +'
			) P ON PD.intPaymentId = P.intPaymentId
			GROUP BY intInvoiceId
		) TOTALPAYMENT ON I.intInvoiceId = TOTALPAYMENT.intInvoiceId
		LEFT JOIN (
			SELECT intPaymentId
				 , strPaymentInfo
				 , strRecordNumber
				 , dtmDatePaid
			FROM dbo.tblARPayment WITH (NOLOCK)
			WHERE ysnPosted = 1
				AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
		) PCREDITS ON I.intPaymentId = PCREDITS.intPaymentId
		WHERE ysnPosted = 1
			AND ((I.strType = ''Service Charge'' AND I.ysnForgiven = 0) OR ((I.strType <> ''Service Charge'' AND I.ysnForgiven = 1) OR (I.strType <> ''Service Charge'' AND I.ysnForgiven = 0)))		
			AND I.dtmDate BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
			AND I.strType <> ''CF Tran''
			AND (CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), I.dtmPostDate))) <= '+ @strDateTo +'
				AND ((I.ysnPaid = 0 OR I.intInvoiceId IN (SELECT intInvoiceId 
															FROM dbo.tblARPaymentDetail PD WITH (NOLOCK) 
															INNER JOIN (
																SELECT intPaymentId
																FROM dbo.tblARPayment WITH (NOLOCK)
																WHERE ysnPosted = 1
																	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) <= '+ @strDateTo +'
															) P ON PD.intPaymentId = P.intPaymentId))
				OR (I.ysnPaid = 1 AND I.intInvoiceId IN (SELECT intInvoiceId 
															FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
															INNER JOIN (
																SELECT intPaymentId
																FROM dbo.tblARPayment WITH (NOLOCK)
																WHERE ysnPosted = 1
																	AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) > '+ @strDateTo +'
															) P ON PD.intPaymentId = P.intPaymentId))))
		AND I.intAccountId IN (SELECT intAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN (''AR Account'', ''Customer Prepayments''))

		UNION ALL

		SELECT intInvoiceId			= NULL
			 , intEntityCustomerId	= P.intEntityCustomerId
			 , intPaymentId			= P.intPaymentId
			 , intCompanyLocationId	= P.intLocationId
			 , intTermId			= NULL
			 , strInvoiceNumber		= NULL
			 , strRecordNumber		= P.strRecordNumber
			 , strInvoiceOriginId   = NULL
			 , strBOLNumber			= NULL
			 , strPaymentInfo		= ''PAYMENT REF: '' + ISNULL(P.strPaymentInfo, '''')
			 , strTransactionType	= ''Payment''
			 , dblInvoiceTotal		= 0.00
			 , dblBalance			= 0.00
			 , dblPayment			= P.dblAmountPaid
			 , dtmDate				= P.dtmDatePaid
			 , dtmDueDate			= NULL
			 , dtmShipDate			= NULL
			 , dtmDatePaid			= P.dtmDatePaid
			 , strType				= NULL
		FROM dbo.tblARPayment P WITH (NOLOCK)
		INNER JOIN (
			SELECT intPaymentId
			FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
			INNER JOIN (
				SELECT intInvoiceId
				FROM dbo.tblARInvoice WITH (NOLOCK)
				WHERE ysnPosted = 1
				  AND strType <> ''CF Tran''
			) I ON I.intInvoiceId = PD.intInvoiceId
		) PD ON P.intPaymentId = PD.intPaymentId
		WHERE ysnInvoicePrepayment = 0
			AND ysnPosted = 1
			AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDatePaid))) BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
		GROUP BY P.intPaymentId, intEntityCustomerId, intLocationId, strRecordNumber, strPaymentInfo, dblAmountPaid, dtmDatePaid
	) TRANSACTIONS ON TRANSACTIONS.intEntityCustomerId = C.intEntityId
	
	LEFT JOIN (
		SELECT intTermID
			 , strTerm
		FROM dbo.tblSMTerm WITH (NOLOCK)
	) T ON TRANSACTIONS.intTermId = T.intTermID	
	LEFT JOIN (
		SELECT intCompanyLocationId
			 , strLocationName
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK) 
	) CL ON TRANSACTIONS.intCompanyLocationId = CL.intCompanyLocationId
	OUTER APPLY (
		SELECT TOP 1 strCompanyName
				   , strCompanyAddress = dbo.[fnARFormatCustomerAddress](strPhone, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL) 
		FROM dbo.tblSMCompanySetup WITH (NOLOCK)
	) COMPANY
	OUTER APPLY (
		SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1)
		FROM (
			SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + '', ''
			FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
			INNER JOIN (
				SELECT intAccountStatusId
					 , strAccountStatusCode
				FROM dbo.tblARAccountStatus WITH (NOLOCK)
			) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
			WHERE CAS.intEntityCustomerId = C.intEntityCustomerId
			FOR XML PATH ('''')
		) SC (strAccountStatusCode)
	) STATUSCODES
) MainQuery'

IF ISNULL(@filter, '') != ''
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

INSERT INTO @temp_statement_table
EXEC sp_executesql @query

IF @ysnIncludeBudget = 1
    BEGIN
        SET @queryBudget = CAST('' AS NVARCHAR(MAX)) + 
            'SELECT intEntityCustomerId         = C.intEntityCustomerId 
			      , strCustomerNumber           = C.strCustomerNumber
				  , strCustomerName             = C.strName
				  , dblCreditLimit              = C.dblCreditLimit
				  , intInvoiceId				= CB.intCustomerBudgetId
			      , strInvoiceNumber			= ''Budget for: '' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101) 
				  , strBOLNumber                = NULL
				  , dtmDate						= dtmBudgetDate
				  , dtmDueDate					= DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate))
				  , dtmShipDate					= NULL
				  , dblInvoiceTotal				= dblBudgetAmount
				  , intPaymentId				= CB.intCustomerBudgetId
				  , strRecordNumber				= ''Budget for: '' + + CONVERT(NVARCHAR(50), CB.dtmBudgetDate, 101)
				  , strTransactionType			= ''Customer Budget''
				  , strPaymentInfo				= NULL
				  , dtmDatePaid					= NULL
				  , dblPayment					= dblAmountPaid
				  , dblBalance					= dblBudgetAmount - dblAmountPaid
				  , strSalespersonName			= NULL
				  , strAccountStatusCode		= STATUSCODES.strAccountStatusCode
				  , strLocationName				= NULL
				  , strFullAddress				= NULL
				  , strStatementFooterComment	= dbo.fnARGetFooterComment(NULL, CB.intEntityCustomerId, ''Statement Footer'')
				  , strCompanyName				= NULL
				  , strCompanyAddress			= NULL
				  , dblARBalance				= CUST.dblARBalance
				  , strType						= NULL
            FROM tblARCustomerBudget CB
                INNER JOIN vyuARCustomer C ON CB.intEntityCustomerId = C.intEntityCustomerId
                INNER JOIN tblARCustomer CUST ON C.intEntityCustomerId = CUST.intEntityCustomerId
				OUTER APPLY (
					SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1)
					FROM (
						SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + '', ''
						FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
						INNER JOIN (
							SELECT intAccountStatusId
								 , strAccountStatusCode
							FROM dbo.tblARAccountStatus WITH (NOLOCK)
						) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
						WHERE CAS.intEntityCustomerId = CB.intEntityCustomerId
						FOR XML PATH ('''')
					) SC (strAccountStatusCode)
				) STATUSCODES    
            WHERE CB.dtmBudgetDate BETWEEN '+ @strDateFrom +' AND '+ @strDateTo +'
              AND CB.dblAmountPaid < CB.dblBudgetAmount'
        
        IF ISNULL(@filter,'') != ''
        BEGIN
            SET @queryBudget = @queryBudget + ' WHERE ' + @filter
        END    

        INSERT INTO @temp_statement_table
        EXEC sp_executesql @queryBudget
    END

IF @ysnPrintFromCFLocal = 1
	BEGIN
		UPDATE @temp_balanceforward_table SET dblTotalAR = dblTotalAR - dblFuture

		UPDATE BALANCEFORWARD
		SET BALANCEFORWARD.dblTotalAR = BALANCEFORWARD.dblTotalAR + ISNULL(CF.dblTotalFuture, 0)
		  , BALANCEFORWARD.dblFuture = CF.dblTotalFuture
		FROM @temp_balanceforward_table BALANCEFORWARD
		INNER JOIN (
			SELECT intEntityCustomerId
				 , dblTotalFuture = SUM(dblAmountDue)
			FROM tblARInvoice WITH (NOLOCK)
			WHERE strType = 'CF Tran'
			AND dtmPostDate <= @dtmDateFromLocal
			AND ysnPaid = 0
			AND ysnPosted = 1
			GROUP BY intEntityCustomerId
		) CF ON BALANCEFORWARD.intEntityCustomerId = CF.intEntityCustomerId

		UPDATE AGINGREPORT
		SET AGINGREPORT.dbl0Days = AGINGREPORT.dbl0Days + ISNULL(CF.dblTotalFuture, 0)
		  , AGINGREPORT.dblFuture = AGINGREPORT.dblFuture - ISNULL(CF.dblTotalFuture, 0)
		FROM @temp_aging_table AGINGREPORT
		INNER JOIN (
			SELECT intEntityCustomerId
				 , dblTotalFuture = SUM(dblAmountDue)
			FROM tblARInvoice WITH (NOLOCK)
			WHERE strType = 'CF Tran'
			AND dtmPostDate BETWEEN @dtmDateFromLocal AND @dtmDateToLocal
			AND ysnPaid = 0
			AND ysnPosted = 1
			GROUP BY intEntityCustomerId
		) CF ON AGINGREPORT.intEntityCustomerId = CF.intEntityCustomerId
	END

INSERT INTO @temp_statement_table(
	  intEntityCustomerId
	, strCustomerName
	, strCustomerNumber
	, strTransactionType
	, dblCreditLimit
	, dtmDate
	, dtmDatePaid
	, intInvoiceId
	, dblBalance
	, dblPayment
	, strFullAddress
	, strStatementFooterComment
	, strCompanyAddress
	, strCompanyName
)
SELECT DISTINCT
	  ISNULL(BALANCEFORWARD.intEntityCustomerId, STATEMENTFORWARD.intEntityCustomerId)
	, ISNULL(BALANCEFORWARD.strCustomerName, STATEMENTFORWARD.strCustomerName)
	, ISNULL(BALANCEFORWARD.strEntityNo, STATEMENTFORWARD.strCustomerNumber)
	, 'Balance Forward'
	, ISNULL(BALANCEFORWARD.dblCreditLimit, STATEMENTFORWARD.dblCreditLimit)
	, @dtmBalanceForwardDateLocal
	, '01/01/1900'
	, 1
	, ISNULL(BALANCEFORWARD.dblTotalAR, 0)
	, 0
	, STATEMENTFORWARD.strFullAddress
	, STATEMENTFORWARD.strStatementFooterComment
	, STATEMENTFORWARD.strCompanyAddress
	, STATEMENTFORWARD.strCompanyName
FROM @temp_statement_table STATEMENTFORWARD
    LEFT JOIN @temp_balanceforward_table BALANCEFORWARD ON STATEMENTFORWARD.intEntityCustomerId = BALANCEFORWARD.intEntityCustomerId    

MERGE INTO tblARStatementOfAccount AS Target
USING (SELECT strCustomerNumber, @dtmDateToLocal, SUM(ISNULL(dblBalance, 0))
FROM @temp_statement_table GROUP BY strCustomerNumber
)
AS Source (strCustomerNumber, dtmLastStatementDate, dblLastStatement)
ON Target.strEntityNo = Source.strCustomerNumber

WHEN MATCHED THEN
UPDATE SET dtmLastStatementDate = Source.dtmLastStatementDate, dblLastStatement = Source.dblLastStatement

WHEN NOT MATCHED BY TARGET THEN
INSERT (strEntityNo, dtmLastStatementDate, dblLastStatement)
VALUES (strCustomerNumber, dtmLastStatementDate, dblLastStatement);

IF @ysnPrintOnlyPastDueLocal = 1
    BEGIN
        DELETE FROM @temp_statement_table WHERE DATEDIFF(DAYOFYEAR, dtmDueDate, @dtmDateToLocal) > 0 AND strTransactionType <> 'Balance Forward'
        UPDATE @temp_aging_table SET dblTotalAR = dblTotalAR - dbl0Days , dbl0Days = 0
    END

IF @ysnPrintZeroBalanceLocal = 0
    BEGIN
        DELETE FROM @temp_statement_table WHERE ISNULL(dblBalance, 0) = 0 AND ISNULL(strTransactionType, '') <> 'Balance Forward'
        DELETE FROM @temp_aging_table WHERE dblTotalAR = 0
    END

IF @ysnPrintCreditBalanceLocal = 0
	BEGIN
		DELETE FROM @temp_statement_table WHERE strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')
		DELETE FROM @temp_aging_table WHERE dblTotalAR < 0
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
) cfTable ON statementTable.intInvoiceId = cfTable.intInvoiceId

DELETE FROM @temp_statement_table WHERE strTransactionType IS NULL

DELETE FROM @temp_statement_table
WHERE intInvoiceId IN (SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK) WHERE strType = 'CF Tran' AND strTransactionType NOT IN ('Debit Memo'))

IF @ysnPrintFromCFLocal = 1
	BEGIN
		DELETE FROM @temp_statement_table WHERE strTransactionType = 'Overpayment'
		DELETE FROM @temp_statement_table WHERE strTransactionType = 'Payment' AND dblPayment = 0
		UPDATE @temp_statement_table SET strTransactionType = 'Payment' WHERE strTransactionType = 'Customer Prepayment' AND strType <> 'CF Tran'
		UPDATE @temp_statement_table SET strTransactionType = 'Invoice' WHERE strTransactionType = 'Debit Memo' AND strType <> 'CF Tran'
	END

TRUNCATE TABLE tblARCustomerStatementStagingTable
INSERT INTO tblARCustomerStatementStagingTable (
	  intEntityCustomerId
	, intInvoiceId
	, intPaymentId
	, dtmDate
	, dtmDueDate
	, dtmShipDate
	, dtmDatePaid
	, dtmAsOfDate
	, strCustomerNumber
	, strCustomerName
	, strInvoiceNumber		
	, strBOLNumber
	, strRecordNumber
	, strTransactionType
	, strPaymentInfo
	, strSalespersonName
	, strAccountStatusCode
	, strLocationName
	, strFullAddress
	, strStatementFooterComment
	, strCompanyName
	, strCompanyAddress
	, dblCreditLimit
	, dblInvoiceTotal
	, dblPayment
	, dblBalance
	, dblTotalAR
	, dblCreditAvailable
	, dblFuture
	, dbl0Days
	, dbl10Days
	, dbl30Days
	, dbl60Days
	, dbl90Days
	, dbl91Days
	, dblCredits
	, dblPrepayments)
SELECT intEntityCustomerId		= MAINREPORT.intEntityCustomerId
	, intInvoiceId				= MAINREPORT.intInvoiceId
	, intPaymentId				= MAINREPORT.intPaymentId
	, dtmDate					= MAINREPORT.dtmDate
	, dtmDueDate				= MAINREPORT.dtmDueDate
	, dtmShipDate				= MAINREPORT.dtmShipDate
	, dtmDatePaid				= MAINREPORT.dtmDatePaid
	, dtmAsOfDate				= @dtmDateToLocal
	, strCustomerNumber			= MAINREPORT.strCustomerNumber
	, strCustomerName			= MAINREPORT.strCustomerName
	, strInvoiceNumber			= MAINREPORT.strInvoiceNumber
	, strBOLNumber				= MAINREPORT.strBOLNumber
	, strRecordNumber			= MAINREPORT.strRecordNumber
	, strTransactionType		= MAINREPORT.strTransactionType
	, strPaymentInfo			= MAINREPORT.strPaymentInfo
	, strSalespersonName		= MAINREPORT.strSalespersonName
	, strAccountStatusCode		= MAINREPORT.strAccountStatusCode
	, strLocationName			= MAINREPORT.strLocationName
	, strFullAddress			= MAINREPORT.strFullAddress
	, strStatementFooterComment	= MAINREPORT.strStatementFooterComment
	, strCompanyName			= MAINREPORT.strCompanyName
	, strCompanyAddress			= MAINREPORT.strCompanyAddress
	, dblCreditLimit			= MAINREPORT.dblCreditLimit
	, dblInvoiceTotal			= MAINREPORT.dblInvoiceTotal
	, dblPayment				= MAINREPORT.dblPayment
	, dblBalance				= MAINREPORT.dblBalance
	, dblTotalAR				= ISNULL(AGINGREPORT.dblTotalAR, 0)
	, dblCreditAvailable		= MAINREPORT.dblCreditLimit - ISNULL(AGINGREPORT.dblTotalAR, 0)
	, dblFuture					= ISNULL(AGINGREPORT.dblFuture, 0)
	, dbl0Days					= ISNULL(AGINGREPORT.dbl0Days, 0)
	, dbl10Days					= ISNULL(AGINGREPORT.dbl10Days, 0)
	, dbl30Days					= ISNULL(AGINGREPORT.dbl30Days, 0)
	, dbl60Days					= ISNULL(AGINGREPORT.dbl60Days, 0)
	, dbl90Days					= ISNULL(AGINGREPORT.dbl90Days, 0)
	, dbl91Days					= ISNULL(AGINGREPORT.dbl91Days, 0)
	, dblCredits				= ISNULL(AGINGREPORT.dblCredits, 0)
	, dblPrepayments			= ISNULL(AGINGREPORT.dblPrepayments, 0)	
FROM (
	--- Without CF Report
	SELECT intEntityCustomerId					= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber					= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName						= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit						= STATEMENTREPORT.dblCreditLimit
		 , intInvoiceId							= STATEMENTREPORT.intInvoiceId   
		 , strInvoiceNumber
		 , strBOLNumber
		 , dtmDate
		 , dtmDueDate
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strTransactionType					= STATEMENTREPORT.strTransactionType
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName					= STATEMENTREPORT.strSalespersonName
		 , strAccountStatusCode
		 , strLocationName
		 , strFullAddress
		 , strStatementFooterComment			= STATEMENTREPORT.strStatementFooterComment
		 , strCompanyName
		 , strCompanyAddress		 
	FROM @temp_statement_table AS STATEMENTREPORT	
	WHERE STATEMENTREPORT.intInvoiceId NOT IN (SELECT intInvoiceId FROM @temp_cf_table)

	UNION ALL

	--- With CF Report
	SELECT intEntityCustomerId					= STATEMENTREPORT.intEntityCustomerId
		 , strCustomerNumber					= STATEMENTREPORT.strCustomerNumber
		 , strCustomerName						= STATEMENTREPORT.strCustomerName
		 , dblCreditLimit						= STATEMENTREPORT.dblCreditLimit
		 , intInvoiceId							= CFReportTable.intInvoiceId	 
		 , strInvoiceNumber						= CFReportTable.strInvoiceReportNumber
		 , strBOLNumber
		 , dtmDate								= CFReportTable.dtmInvoiceDate     
		 , dtmDueDate							= CFReportTable.dtmInvoiceDate  
		 , dtmShipDate
		 , dblInvoiceTotal
		 , intPaymentId
		 , strRecordNumber
		 , strTransactionType
		 , strPaymentInfo
		 , dtmDatePaid
		 , dblPayment
		 , dblBalance
		 , strSalespersonName					= STATEMENTREPORT.strSalespersonName
		 , strAccountStatusCode
		 , strLocationName   
		 , strFullAddress
		 , strStatementFooterComment			= STATEMENTREPORT.strStatementFooterComment
		 , strCompanyName
		 , strCompanyAddress		 
	FROM @temp_statement_table AS STATEMENTREPORT
	INNER JOIN (SELECT intInvoiceId
					, strInvoiceNumber
					, strInvoiceReportNumber
					, dtmInvoiceDate 
				FROM @temp_cf_table
	) CFReportTable ON STATEMENTREPORT.intInvoiceId = CFReportTable.intInvoiceId
) MAINREPORT
INNER JOIN @temp_aging_table AS AGINGREPORT
	ON MAINREPORT.intEntityCustomerId = AGINGREPORT.intEntityCustomerId
INNER JOIN (
	SELECT intEntityCustomerId
	FROM dbo.tblARCustomer WITH (NOLOCK)
	WHERE strStatementFormat = 'Balance Forward'
) CUSTOMER ON MAINREPORT.intEntityCustomerId = CUSTOMER.intEntityCustomerId
ORDER BY MAINREPORT.dtmDate