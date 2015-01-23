CREATE PROCEDURE [dbo].[uspARPostInvoice]
	@batchId			AS NVARCHAR(20)		= NULL,
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= NULL,
	@userId				AS INT				= 1,
	@beginDate			AS DATE				= NULL,
	@endDate			AS DATE				= NULL,
	@beginTransaction	AS NVARCHAR(50)		= NULL,
	@endTransaction		AS NVARCHAR(50)		= NULL,
	@exclude			AS NVARCHAR(MAX)	= NULL,
	@successfulCount	AS INT				= 0 OUTPUT,
	@invalidCount		AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@batchIdUsed		AS NVARCHAR(20)		= NULL OUTPUT,
	@recapId			AS NVARCHAR(250)	= NEWID OUTPUT,
	@transType			AS NVARCHAR(25)		= 'all'
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
-- Start the transaction 
BEGIN TRANSACTION

--DECLARE @success BIT
--DECLARE @successfulCount INT
--EXEC uspPostInvoice '', '', 1, 0, 12, 1, @success OUTPUT, @successfulCount OUTPUT

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpPostInvoiceData (
	intInvoiceId int PRIMARY KEY,
	UNIQUE (intInvoiceId)
);

CREATE TABLE #tmpInvalidInvoiceData (
	strError NVARCHAR(100),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	strBatchNumber NVARCHAR(50),
	intTransactionId INT
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId

--DECLARRE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'

DECLARE @UserEntityID int
SET @UserEntityID = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @userId),@userId)

SET @recapId = '1'
--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (@transType IS NULL OR RTRIM(LTRIM(@transType)) = '')
	SET @transType = 'all'

IF (@param IS NOT NULL) 
BEGIN
	IF(@param = 'all')
	BEGIN
		INSERT INTO #tmpPostInvoiceData SELECT intInvoiceId FROM tblARInvoice WHERE ysnPosted = 0 AND (strTransactionType = @transType OR @transType = 'all')
	END
	ELSE
	BEGIN
		INSERT INTO #tmpPostInvoiceData SELECT intID FROM fnGetRowsFromDelimitedValues(@param)
	END
END


--IF (@InvoiceBatchId IS NOT NULL)
--BEGIN
--	INSERT INTO #tmpPostInvoiceData
--	SELECT B.intInvoiceId FROM tblARInvoiceBatch A
--			LEFT JOIN tblARInvoice B	
--				ON A.intInvoiceBatchId = B.intInvoiceBatchId
--	WHERE A.intInvoiceBatchId = @InvoiceBatchId
--END
	
IF(@beginDate IS NOT NULL)
BEGIN
	INSERT INTO #tmpPostInvoiceData
	SELECT intInvoiceId FROM tblARInvoice
	WHERE DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) BETWEEN @beginDate AND @endDate AND ysnPosted = 0
	AND (strTransactionType = @transType OR @transType = 'all')
END

IF(@beginTransaction IS NOT NULL)
BEGIN
	INSERT INTO #tmpPostInvoiceData
	SELECT intInvoiceId FROM tblARInvoice
	WHERE intInvoiceId BETWEEN @beginTransaction AND @endTransaction AND ysnPosted = 0
	AND (strTransactionType = @transType OR @transType = 'all')
END

--Removed excluded Invoices to post/unpost
IF(@exclude IS NOT NULL)
BEGIN
	SELECT intID INTO #tmpInvoicesExclude FROM fnGetRowsFromDelimitedValues(@exclude)
	DELETE FROM A
	FROM #tmpPostInvoiceData A
	WHERE EXISTS(SELECT * FROM #tmpInvoicesExclude B WHERE A.intInvoiceId = B.intID)
END

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	--POSTING VALIDATIONS
	IF(ISNULL(@post,0) = 1)
	BEGIN

		--Fiscal Year
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			A.strTransactionType,
			A.strInvoiceNumber,
			@batchId,
			A.intInvoiceId
		FROM
			tblARInvoice A 
		INNER JOIN 
			#tmpPostInvoiceData B
				ON A.intInvoiceId = B.intInvoiceId
		WHERE  
			ISNULL(dbo.isOpenAccountingDate(A.dtmDate), 0) = 0

		--zero amount
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'You cannot post a ' + A.strTransactionType + ' with zero amount.',
			A.strTransactionType,
			A.strInvoiceNumber,
			@batchId,
			A.intInvoiceId
		FROM 
			tblARInvoice A 
		INNER JOIN 
			#tmpPostInvoiceData B
				ON A.intInvoiceId = B.intInvoiceId
		WHERE  
			A.dblInvoiceTotal = 0

		--No Terms specified
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'No terms has been specified.',
			A.strTransactionType,
			A.strInvoiceNumber,
			@batchId,
			A.intInvoiceId
		FROM 
			tblARInvoice A 
		INNER JOIN 
			#tmpPostInvoiceData B
				ON A.intInvoiceId = B.intInvoiceId
		WHERE  
			0 = A.intTermId

		--NOT BALANCE
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'The debit and credit amounts are not balanced.',
			A.strTransactionType,
			A.strInvoiceNumber,
			@batchId,
			A.intInvoiceId
		FROM 
			tblARInvoice A 
		INNER JOIN 
			#tmpPostInvoiceData B
				ON A.intInvoiceId = B.intInvoiceId
		WHERE  
			A.dblInvoiceTotal <> ((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = A.intInvoiceId) + ISNULL(A.dblShipping,0.0) + ISNULL(A.dblTax,0.0))

		--ALREADY POSTED
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'The transaction is already posted.',
			A.strTransactionType,
			A.strInvoiceNumber,
			@batchId,
			A.intInvoiceId
		FROM 
			tblARInvoice A 
		INNER JOIN 
			#tmpPostInvoiceData B
				ON A.intInvoiceId = B.intInvoiceId
		WHERE  
			A.ysnPosted = 1

		--Header Account ID
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT
			'The AR account is not specified.',
			A.strTransactionType,
			A.strInvoiceNumber,
			@batchId,
			A.intInvoiceId
		FROM 
			tblARInvoice A 
		INNER JOIN 
			#tmpPostInvoiceData B
				ON A.intInvoiceId = B.intInvoiceId
		WHERE  
			A.intAccountId IS NULL 
			AND A.intAccountId = 0
			
		--Company Location
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'Company location of ' + A.strInvoiceNumber + ' was not set.'
			,A.strTransactionType
			,A.strInvoiceNumber
			,@batchId
			,A.intInvoiceId
		FROM
			tblARInvoice A
		INNER JOIN
			#tmpPostInvoiceData P
				ON A.intInvoiceId = P.intInvoiceId						 
		LEFT OUTER JOIN
			tblSMCompanyLocation L
				ON A.intCompanyLocationId = L.intCompanyLocationId
		WHERE L.intCompanyLocationId IS NULL
		
		--Freight Expenses Account
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'The Freight Income account of Company Location ' + L.strLocationName + ' was not set.'
			,A.strTransactionType
			,A.strInvoiceNumber
			,@batchId
			,A.intInvoiceId
		FROM
			tblARInvoice A
		INNER JOIN
			#tmpPostInvoiceData P
				ON A.intInvoiceId = P.intInvoiceId						 
		INNER JOIN
			tblSMCompanyLocation L
				ON A.intCompanyLocationId = L.intCompanyLocationId
		LEFT OUTER JOIN
			tblGLAccount G
				ON L.intFreightIncome = G.intAccountId						
		WHERE
			G.intAccountId IS NULL	
			AND A.dblShipping <> 0.0	

		--Sales Account Account
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'The Sales Account account of Company Location ' + L.strLocationName + ' was not set.'
			,A.strTransactionType
			,A.strInvoiceNumber
			,@batchId
			,A.intInvoiceId
		FROM
			tblARInvoice A
		INNER JOIN
			#tmpPostInvoiceData P
				ON A.intInvoiceId = P.intInvoiceId						 
		INNER JOIN
			tblSMCompanyLocation L
				ON A.intCompanyLocationId = L.intCompanyLocationId
		LEFT OUTER JOIN
			tblGLAccount G
				ON L.intSalesAccount = G.intAccountId						
		WHERE
			G.intAccountId IS NULL
			AND A.dblTax <> 0.0					

		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT
			'The account id on one of the details is not specified.',
			A.strTransactionType,
			A.strInvoiceNumber,
			@batchId,
			A.intInvoiceId
		FROM 
			tblARInvoice A 
		INNER JOIN 
			#tmpPostInvoiceData B
				ON A.intInvoiceId = B.intInvoiceId
		WHERE  
			EXISTS(	SELECT null FROM tblARInvoiceDetail  
					WHERE 
						intInvoiceId = B.intInvoiceId
						AND (intAccountId IS NULL OR intAccountId = 0))

	END 

	--UNPOSTING VALIDATIONS
	IF(ISNULL(@post,0) = 0)
	BEGIN
		--ALREADY HAVE PAYMENTS
		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT
			A.strRecordNumber + ' payment was already made on this ' + C.strTransactionType + '.',
			C.strTransactionType,
			C.strInvoiceNumber,
			@batchId,
			C.intInvoiceId
		FROM
			tblARPayment A
		INNER JOIN 
			tblARPaymentDetail B 
				ON A.intPaymentId = B.intPaymentId
		INNER JOIN 
			tblARInvoice C
				ON B.intInvoiceId = C.intInvoiceId
		INNER JOIN 
			#tmpPostInvoiceData D
				ON C.intInvoiceId = D.intInvoiceId

		INSERT INTO #tmpInvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			'Unable to find an open fiscal year period to match the transaction date.',
			A.strTransactionType,
			A.strInvoiceNumber,
			@batchId,
			A.intInvoiceId
		FROM 
			tblARInvoice A 
		INNER JOIN 
			#tmpPostInvoiceData B
				ON A.intInvoiceId = B.intInvoiceId
		WHERE
			ISNULL(dbo.isOpenAccountingDate(A.dtmDate), 0) = 0

	END

	DECLARE @totalInvalid INT = 0
	SELECT @totalInvalid = COUNT(*) FROM #tmpInvalidInvoiceData

	IF(@totalInvalid > 0)
	BEGIN

		--Insert Invalid Post transaction result
		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 	
			strError
			,strTransactionType
			,strTransactionId
			,strBatchNumber
			,intTransactionId
		FROM
			#tmpInvalidInvoiceData

		SET @invalidCount = @totalInvalid

		--DELETE Invalid Transaction From temp table
		DELETE #tmpPostInvoiceData
			FROM #tmpPostInvoiceData A
				INNER JOIN #tmpInvalidInvoiceData
					ON A.intInvoiceId = #tmpInvalidInvoiceData.intTransactionId

	END


	DECLARE @totalRecords INT
	SELECT @totalRecords = COUNT(*) FROM #tmpPostInvoiceData

	COMMIT TRANSACTION --COMMIT inserted invalid transaction

	IF(@totalRecords = 0)  
	BEGIN
		SET @success = 0
		GOTO Post_Exit
	END

	BEGIN TRANSACTION
END
--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@recap, 0) = 0
BEGIN
	--INSERT GL ENTRIES
	CREATE TABLE #tmpGLDetail(
		dtmDate                   DATETIME         NOT NULL,
		intAccountId              INT              NULL,
		dblDebit                  NUMERIC (18, 6)  NULL,
		dblCredit                 NUMERIC (18, 6)  NULL,
		dblDebitUnit              NUMERIC (18, 6)  NULL,
		dblCreditUnit             NUMERIC (18, 6)  NULL,
	);

	WITH Units
	AS
	(
		SELECT	
			A.dblLbsPerUnit
			,B.intAccountId
		FROM
			tblGLAccountUnit A 
		INNER JOIN 
			tblGLAccount B 
				ON A.intAccountUnitId = B.intAccountUnitId
	)
	
	INSERT INTO tblGLDetail (
			strTransactionId, 
			intTransactionId, 
			intAccountId,
			strDescription,
			strReference,
			dtmTransactionDate,
			dblDebit,
			dblCredit,
			dblDebitUnit,
			dblCreditUnit,
			dtmDate,
			ysnIsUnposted,
			intConcurrencyId,
			dblExchangeRate,
			intUserId,
			intEntityId,
			dtmDateEntered,
			strBatchId,
			strCode,
			strModuleName,
			strTransactionForm,
			strTransactionType
		)
	OUTPUT INSERTED.dtmDate, INSERTED.intAccountId, INSERTED.dblDebit, INSERTED.dblCredit, INSERTED.dblDebitUnit, INSERTED.dblCreditUnit  INTO #tmpGLDetail
	
	--DEBIT COGS
	SELECT	
		strTransactionId = A.strInvoiceNumber, 
		intTransactionId = A.intInvoiceId, 
		intAccountId = B.intCOGSAccountId,
		strDescription = A.strComments,
		strReference = C.strCustomerNumber,
		dtmTransactionDate = A.dtmDate,
		dblDebit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN  ISNULL(IP.dblStandardCost, B.dblTotal) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN  ISNULL(IP.dblStandardCost, B.dblTotal) ELSE 0 END) END, --Invoice Detail
		dblCredit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE  ISNULL(IP.dblStandardCost, B.dblTotal) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE  ISNULL(IP.dblStandardCost, B.dblTotal) END) END, -- Invoice
		dblDebitUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN  ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0)  ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN  ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0)  ELSE 0 END) END,
		dblCreditUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0)  END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0)  END) END,
		dtmDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		ysnIsUnposted = CASE WHEN @post = 1 THEN 0 ELSE 1 END,
		intConcurrencyId = 1,
		dblExchangeRate		= 1,
		intUserId			= @userId,
		intEntityId			= @UserEntityID,
		dtmDateEntered		= GETDATE(),
		strBatchID			= @batchId,
		strCode				= 'AR',
		strModuleName		= @MODULE_NAME,
		strTransactionForm = @SCREEN_NAME,
		strTransactionType = A.strTransactionType
	FROM
		tblARInvoice A 
	LEFT JOIN
		tblARInvoiceDetail B
			ON A.intInvoiceId = B.intInvoiceId
	LEFT JOIN 
		tblARCustomer C
			ON A.intCustomerId = C.intCustomerId
	LEFT JOIN Units U
			ON A.intAccountId = U.intAccountId
	LEFT JOIN
		tblICItemPricing IP
			ON B.intItemId = IP.intItemId  AND B.intCompanyLocationId = IP.intLocationId		
	INNER JOIN 
		#tmpPostInvoiceData	P
			ON A.intInvoiceId = P.intInvoiceId
	WHERE B.intItemId IS NOT NULL OR B.intItemId <> 0
		
	--CREDIT INVENTORY
	UNION ALL 
	SELECT	
		strTransactionId = A.strInvoiceNumber, 
		intTransactionId = A.intInvoiceId, 
		intAccountId = B.intInventoryAccountId,
		strDescription = A.strComments,
		strReference = C.strCustomerNumber,
		dtmTransactionDate = A.dtmDate,
		dblDebit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(IP.dblStandardCost, B.dblTotal) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(IP.dblStandardCost, B.dblTotal) END) END, --Invoice Detail
		dblCredit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(IP.dblStandardCost, B.dblTotal) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(IP.dblStandardCost, B.dblTotal) ELSE 0 END) END, -- Invoice
		dblDebitUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) END,
		dblCreditUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
		dtmDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		ysnIsUnposted = CASE WHEN @post = 1 THEN 0 ELSE 1 END,
		intConcurrencyId = 1,
		dblExchangeRate		= 1,
		intUserId			= @userId,
		intEntityId			= @UserEntityID,
		dtmDateEntered		= GETDATE(),
		strBatchID			= @batchId,
		strCode				= 'AR',
		strModuleName		= @MODULE_NAME,
		strTransactionForm = @SCREEN_NAME,
		strTransactionType = A.strTransactionType
	FROM
		tblARInvoice A 
	LEFT JOIN
		tblARInvoiceDetail B
			ON A.intInvoiceId = B.intInvoiceId
	LEFT JOIN 
		tblARCustomer C
			ON A.intCustomerId = C.intCustomerId
	LEFT JOIN Units U
			ON A.intAccountId = U.intAccountId 
	LEFT JOIN
		tblICItemPricing IP
			ON B.intItemId = IP.intItemId AND B.intCompanyLocationId = IP.intLocationId						
	INNER JOIN 
		#tmpPostInvoiceData	P
			ON A.intInvoiceId = P.intInvoiceId
	WHERE B.intItemId IS NOT NULL AND B.intItemId <> 0
	
	--DEBIT AR
	UNION ALL 
	SELECT	
		strTransactionId = A.strInvoiceNumber, 
		intTransactionId = A.intInvoiceId, 
		intAccountId = A.intAccountId,
		strDescription = A.strComments,
		strReference = C.strCustomerNumber,
		dtmTransactionDate = A.dtmDate,
		dblDebit				= CASE WHEN A.strTransactionType = 'Invoice' THEN  (CASE WHEN @post = 1 THEN A.dblInvoiceTotal ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN A.dblInvoiceTotal ELSE 0 END) END,
		dblCredit				= CASE WHEN A.strTransactionType = 'Invoice' THEN  (CASE WHEN @post = 1 THEN 0 ELSE A.dblInvoiceTotal END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE A.dblInvoiceTotal END) END,
		dblDebitUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN  (CASE WHEN @post = 1 THEN ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
		dblCreditUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN  (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) END) END,
		dtmDate			= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		ysnIsUnposted = CASE WHEN @post = 1 THEN 0 ELSE 1 END,
		intConcurrencyId = 1,
		dblExchangeRate		= 1,
		intUserId			= @userId,
		intEntityId			= @UserEntityID,
		dtmDateEntered		= GETDATE(),
		strBatchID			= @batchId,
		strCode				= 'AR',
		strModuleName		= @MODULE_NAME,
		strTransactionForm = @SCREEN_NAME,
		strTransactionType = A.strTransactionType 
	FROM
		tblARInvoice A
	LEFT JOIN 
		tblARCustomer C
			ON A.intCustomerId = C.intCustomerId
	LEFT JOIN Units U
			ON A.intAccountId = U.intAccountId 			
	INNER JOIN 
		#tmpPostInvoiceData	P
			ON A.intInvoiceId = P.intInvoiceId
			
	--CREDIT MISC
	UNION ALL 
	SELECT	
		strTransactionId = A.strInvoiceNumber, 
		intTransactionId = A.intInvoiceId, 
		intAccountId = B.intAccountId,
		strDescription = A.strComments,
		strReference = C.strCustomerNumber,
		dtmTransactionDate = A.dtmDate,
		dblDebit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE B.dblTotal END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE B.dblTotal END) END, --Invoice Detail
		dblCredit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN B.dblTotal ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN B.dblTotal ELSE 0 END) END, -- Invoice
		dblDebitUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) END,
		dblCreditUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
		dtmDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		ysnIsUnposted = CASE WHEN @post = 1 THEN 0 ELSE 1 END,
		intConcurrencyId = 1,
		dblExchangeRate		= 1,
		intUserId			= @userId,
		intEntityId			= @UserEntityID,
		dtmDateEntered		= GETDATE(),
		strBatchID			= @batchId,
		strCode				= 'AR',
		strModuleName		= @MODULE_NAME,
		strTransactionForm = @SCREEN_NAME,
		strTransactionType = A.strTransactionType
	FROM
		tblARInvoice A 
	LEFT JOIN
		tblARInvoiceDetail B
			ON A.intInvoiceId = B.intInvoiceId
	LEFT JOIN 
		tblARCustomer C
			ON A.intCustomerId = C.intCustomerId
	LEFT JOIN Units U
			ON A.intAccountId = U.intAccountId 			
	INNER JOIN 
		#tmpPostInvoiceData	P
			ON A.intInvoiceId = P.intInvoiceId
	WHERE B.intItemId IS NULL OR B.intItemId = 0

	--CREDIT SALES
	UNION ALL 
	SELECT	
		strTransactionId = A.strInvoiceNumber, 
		intTransactionId = A.intInvoiceId, 
		intAccountId = B.intSalesAccountId,
		strDescription = A.strComments,
		strReference = C.strCustomerNumber,
		dtmTransactionDate = A.dtmDate,
		dblDebit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE B.dblTotal END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE B.dblTotal END) END, --Invoice Detail
		dblCredit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN B.dblTotal ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN B.dblTotal ELSE 0 END) END, -- Invoice
		dblDebitUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) END,
		dblCreditUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
		dtmDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		ysnIsUnposted = CASE WHEN @post = 1 THEN 0 ELSE 1 END,
		intConcurrencyId = 1,
		dblExchangeRate		= 1,
		intUserId			= @userId,
		intEntityId			= @UserEntityID,
		dtmDateEntered		= GETDATE(),
		strBatchID			= @batchId,
		strCode				= 'AR',
		strModuleName		= @MODULE_NAME,
		strTransactionForm = @SCREEN_NAME,
		strTransactionType = A.strTransactionType
	FROM
		tblARInvoice A 
	LEFT JOIN
		tblARInvoiceDetail B
			ON A.intInvoiceId = B.intInvoiceId
	LEFT JOIN 
		tblARCustomer C
			ON A.intCustomerId = C.intCustomerId
	LEFT JOIN Units U
			ON A.intAccountId = U.intAccountId 			
	INNER JOIN 
		#tmpPostInvoiceData	P
			ON A.intInvoiceId = P.intInvoiceId
	WHERE B.intItemId IS NOT NULL AND B.intItemId <> 0

	UNION ALL 
	SELECT	
		strTransactionId = A.strInvoiceNumber, 
		intTransactionId = A.intInvoiceId, 
		intAccountId = L.intFreightIncome,
		strDescription = A.strComments,
		strReference = C.strCustomerNumber,
		dtmTransactionDate = A.dtmDate,
		dblDebit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE A.dblShipping  END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE A.dblShipping  END) END, 
		dblCredit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN A.dblShipping ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN A.dblShipping ELSE 0 END) END, 
		dblDebitUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblShipping, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblShipping, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) END,
		dblCreditUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblShipping, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblShipping, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
		dtmDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		ysnIsUnposted = CASE WHEN @post = 1 THEN 0 ELSE 1 END,
		intConcurrencyId = 1,
		dblExchangeRate		= 1,
		intUserId			= @userId,
		intEntityId			= @UserEntityID,
		dtmDateEntered		= GETDATE(),
		strBatchID			= @batchId,
		strCode				= 'AR',
		strModuleName		= @MODULE_NAME,
		strTransactionForm = @SCREEN_NAME,
		strTransactionType = A.strTransactionType
	FROM
		tblARInvoice A 
	LEFT JOIN 
		tblARCustomer C
			ON A.intCustomerId = C.intCustomerId
	LEFT JOIN Units U
			ON A.intAccountId = U.intAccountId 	
	INNER JOIN
		tblSMCompanyLocation L
			ON A.intCompanyLocationId = L.intCompanyLocationId	
	INNER JOIN 
		#tmpPostInvoiceData	P
			ON A.intInvoiceId = P.intInvoiceId	
	WHERE
		A.dblShipping <> 0.0		
		
UNION ALL 
	
	SELECT	
		strTransactionId = A.strInvoiceNumber, 
		intTransactionId = A.intInvoiceId, 
		intAccountId = L.intSalesAccount,
		strDescription = A.strComments,
		strReference = C.strCustomerNumber,
		dtmTransactionDate = A.dtmDate,
		dblDebit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE A.dblTax  END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE A.dblTax  END) END, 
		dblCredit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN A.dblTax ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN A.dblTax ELSE 0 END) END, 
		dblDebitUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblTax, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblTax, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) END,
		dblCreditUnit			= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblTax, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblTax, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,		
		dtmDate = DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0),
		ysnIsUnposted = CASE WHEN @post = 1 THEN 0 ELSE 1 END,
		intConcurrencyId = 1,
		dblExchangeRate		= 1,
		intUserId			= @userId,
		intEntityId			= @UserEntityID,
		dtmDateEntered		= GETDATE(),
		strBatchID			= @batchId,
		strCode				= 'AR',
		strModuleName		= @MODULE_NAME,
		strTransactionForm = @SCREEN_NAME,
		strTransactionType = A.strTransactionType
	FROM
		tblARInvoice A 
	LEFT JOIN 
		tblARCustomer C
			ON A.intCustomerId = C.intCustomerId
	LEFT JOIN Units U
			ON A.intAccountId = U.intAccountId 	
	INNER JOIN
		tblSMCompanyLocation L
			ON A.intCompanyLocationId = L.intCompanyLocationId	
	INNER JOIN 
		#tmpPostInvoiceData	P
			ON A.intInvoiceId = P.intInvoiceId	
	WHERE
		A.dblTax <> 0.0				


--=====================================================================================================================================
-- 	UPDATE GL SUMMARY RECORDS
---------------------------------------------------------------------------------------------------------------------------------------
IF (@post = 1)
BEGIN

	WITH InvoiceDetail
	AS
	(
		SELECT   dtmDate          = ISNULL(A.dtmDate, GETDATE())
				,intAccountId     = A.intAccountId
				,dblDebit         = CASE  WHEN dblCredit < 0 THEN ABS(dblCredit)
											WHEN dblDebit < 0 THEN 0
											ELSE dblDebit END
				,dblCredit        = CASE  WHEN dblDebit < 0 THEN ABS(dblDebit)
											WHEN dblCredit < 0 THEN 0
											ELSE dblCredit END
				,dblDebitUnit     = ISNULL(dblDebitUnit, 0)
				,dblCreditUnit    = ISNULL(dblCreditUnit, 0)
		FROM #tmpGLDetail A
	)
	
	UPDATE  
		tblGLSummary
	SET
		 dblDebit         = ISNULL(tblGLSummary.dblDebit, 0) + ISNULL(GLDetailGrouped.dblDebit, 0)
		,dblCredit        = ISNULL(tblGLSummary.dblCredit, 0) + ISNULL(GLDetailGrouped.dblCredit, 0)
		,dblDebitUnit     = ISNULL(tblGLSummary.dblDebitUnit, 0) + ISNULL(GLDetailGrouped.dblDebitUnit, 0)
		,dblCreditUnit    = ISNULL(tblGLSummary.dblCreditUnit, 0) + ISNULL(GLDetailGrouped.dblCreditUnit, 0)
		,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	FROM
	(
		SELECT
			 dblDebit         = SUM(ISNULL(B.dblDebit, 0))
			,dblCredit        = SUM(ISNULL(B.dblCredit, 0))
			,dblDebitUnit     = SUM(ISNULL(B.dblDebitUnit, 0))
			,dblCreditUnit    = SUM(ISNULL(B.dblCreditUnit, 0))
			,intAccountId     = A.intAccountId
			,dtmDate          = ISNULL(CONVERT(DATE, A.dtmDate), '')
		FROM
			tblGLSummary A
		INNER JOIN
			InvoiceDetail B
				ON CONVERT(DATE, A.dtmDate) = CONVERT(DATE, B.dtmDate) 
				AND A.intAccountId = B.intAccountId AND A.strCode = 'AR'
		GROUP BY 
			ISNULL(CONVERT(DATE, A.dtmDate), ''), A.intAccountId
	) AS GLDetailGrouped
	WHERE
		tblGLSummary.intAccountId = GLDetailGrouped.intAccountId 
		AND tblGLSummary.strCode = 'AR' 
		AND ISNULL(CONVERT(DATE, tblGLSummary.dtmDate), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.dtmDate), '');
		
	IF @@ERROR <> 0   GOTO Post_Rollback;

	--=====================================================================================================================================
	--  INSERT TO GL SUMMARY RECORDS
	---------------------------------------------------------------------------------------------------------------------------------------
	WITH InvoiceDetail
	AS
	(
		SELECT dtmDate        = ISNULL(A.dtmDate, GETDATE())
			,intAccountId     = A.intAccountId
			,dblDebit         = CASE  WHEN dblCredit < 0 THEN ABS(dblCredit)
										WHEN dblDebit < 0 THEN 0
										ELSE dblDebit END
			,dblCredit        = CASE  WHEN dblDebit < 0 THEN ABS(dblDebit)
										WHEN dblCredit < 0 THEN 0
										ELSE dblCredit END
			,dblDebitUnit     = ISNULL(A.dblDebitUnit, 0)
			,dblCreditUnit    = ISNULL(A.dblCreditUnit, 0)
		FROM #tmpGLDetail A
	)
	INSERT INTO tblGLSummary (
		 intAccountId
		,dtmDate
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,strCode
		,intConcurrencyId
	)
	SELECT
		 intAccountId     = A.intAccountId
		,dtmDate          = ISNULL(CONVERT(DATE, A.dtmDate), '')
		,dblDebit         = SUM(A.dblDebit)
		,dblCredit        = SUM(A.dblCredit)
		,dblDebitUnit     = SUM(A.dblDebitUnit)
		,dblCreditUnit    = SUM(A.dblCreditUnit)
		,strCode = 'AR'
		,intConcurrencyId = 1
	FROM InvoiceDetail A
	WHERE NOT EXISTS
			(
				SELECT TOP 1 1
				FROM 
					tblGLSummary B
				WHERE 
					ISNULL(CONVERT(DATE, A.dtmDate), '') = ISNULL(CONVERT(DATE, B.dtmDate), '') 
					AND A.intAccountId = B.intAccountId 
					AND B.strCode = 'AR'
			)
	GROUP BY ISNULL(CONVERT(DATE, A.dtmDate), ''), A.intAccountId;

END
ELSE
BEGIN

	WITH GLDetail
	AS
	(
		SELECT
			dtmDate      = ISNULL(A.dtmDate, GETDATE())
			,intAccountId = A.intAccountId
			,dblDebit     = CASE  WHEN dblDebit < 0 THEN ABS(dblDebit)
									WHEN dblCredit < 0 THEN 0
									ELSE dblCredit END
			,dblCredit    = CASE  WHEN dblCredit < 0 THEN ABS(dblCredit)
									WHEN dblDebit < 0 THEN 0
									ELSE dblDebit END
			,dblDebitUnit = CASE  WHEN dblDebitUnit < 0 THEN ABS(dblDebitUnit)
									WHEN dblCreditUnit < 0 THEN 0
									ELSE dblCreditUnit END
			,dblCreditUnit= CASE  WHEN dblCreditUnit < 0 THEN ABS(dblCreditUnit)
									WHEN dblDebitUnit < 0 THEN 0
									ELSE dblDebitUnit END
		FROM
			tblGLDetail A 
		WHERE
			A.intTransactionId IN (SELECT intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intInvoiceId FROM #tmpPostInvoiceData))
			AND ysnIsUnposted = 0 AND strCode = 'AR'
	)
	
	UPDATE
		tblGLSummary
	SET
		dblDebit = ISNULL(tblGLSummary.dblDebit, 0) - ISNULL(GLDetailGrouped.dblDebit, 0)
		,dblCredit = ISNULL(tblGLSummary.dblCredit, 0) - ISNULL(GLDetailGrouped.dblCredit, 0)
		,dblDebitUnit = ISNULL(tblGLSummary.dblDebitUnit, 0) - ISNULL(GLDetailGrouped.dblDebitUnit, 0)
		,dblCreditUnit = ISNULL(tblGLSummary.dblCreditUnit, 0) - ISNULL(GLDetailGrouped.dblCreditUnit, 0)
		,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	FROM    (
				SELECT   
					dblDebit         = SUM(ISNULL(B.dblCredit, 0))
					,dblCredit        = SUM(ISNULL(B.dblDebit, 0))
					,dblDebitUnit     = SUM(ISNULL(B.dblCreditUnit, 0))
					,dblCreditUnit    = SUM(ISNULL(B.dblDebitUnit, 0))
					,intAccountId     = A.intAccountId
					,dtmDate          = ISNULL(CONVERT(DATE, A.dtmDate), '')
				FROM
					tblGLSummary A
				INNER JOIN
					GLDetail B
						ON CONVERT(DATE, A.dtmDate) = CONVERT(DATE, B.dtmDate) 
						AND A.intAccountId = B.intAccountId AND A.strCode = 'AR'
				GROUP BY
					ISNULL(CONVERT(DATE, A.dtmDate), ''), A.intAccountId
			) AS GLDetailGrouped
	WHERE
		tblGLSummary.intAccountId = GLDetailGrouped.intAccountId 
		AND tblGLSummary.strCode = 'AR' 
		AND ISNULL(CONVERT(DATE, tblGLSummary.dtmDate), '') = ISNULL(CONVERT(DATE, GLDetailGrouped.dtmDate), '');

END


	IF(ISNULL(@post,0) = 0)
	BEGIN

		--IF(@InvoiceBatchId IS NOT NULL AND @totalRecords > 0)
		--BEGIN
		--	UPDATE tblARInvoiceBatch
		--		SET ysnPosted = 0
		--		FROM tblARInvoiceBatch WHERE intInvoiceBatchId = @InvoiceBatchId
		--END

		UPDATE 
			tblARInvoice
		SET
			ysnPosted = 0
			,ysnPaid = 0
			,dblAmountDue = dblInvoiceTotal 
		FROM
			tblARInvoice 
		WHERE 
			intInvoiceId IN (SELECT intInvoiceId FROM #tmpPostInvoiceData)

		UPDATE
			tblGLDetail
		SET
			ysnIsUnposted = 1
		WHERE
			intTransactionId IN (SELECT intInvoiceId FROM #tmpPostInvoiceData)

		--Insert Successfully unposted transactions.
		INSERT INTO tblARPostResult(
			strMessage
			,strTransactionType
			,strTransactionId
			,strBatchNumber
			,intTransactionId)
		SELECT
			@UnpostSuccessfulMsg
			,A.strTransactionType
			,A.strInvoiceNumber
			,@batchId
			,A.intInvoiceId
		FROM
			tblARInvoice A
		WHERE
			intInvoiceId IN (SELECT intInvoiceId FROM #tmpPostInvoiceData)


	END
	ELSE
	BEGIN

		UPDATE 
			tblARInvoice
		SET
			ysnPosted = 1
			,dblAmountDue = dblInvoiceTotal 
		WHERE
			tblARInvoice.intInvoiceId IN (SELECT intInvoiceId FROM #tmpPostInvoiceData)

		--Insert Successfully posted transactions.
		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			@PostSuccessfulMsg
			,A.strTransactionType
			,A.strInvoiceNumber
			,@batchId
			,A.intInvoiceId
		FROM
			tblARInvoice A
		WHERE
			intInvoiceId IN (SELECT intInvoiceId FROM #tmpPostInvoiceData)

		IF @@ERROR <> 0	GOTO Post_Rollback;
	END
END
ELSE
	BEGIN
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM 
			tblGLDetailRecap
		WHERE 
			intTransactionId IN (SELECT intInvoiceId FROM #tmpPostInvoiceData);

		WITH Units 
		AS 
		(
			SELECT	A.dblLbsPerUnit, B.intAccountId 
			FROM tblGLAccountUnit A INNER JOIN tblGLAccount B ON A.intAccountUnitId = B.intAccountUnitId
		)
		
		INSERT INTO tblGLDetailRecap (
			 strTransactionId
			,intTransactionId
			,intAccountId
			,strDescription
			,strReference	
			,dtmTransactionDate
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,dtmDate
			,ysnIsUnposted
			,intConcurrencyId	
			,dblExchangeRate
			,intUserId
			,intEntityId
			,dtmDateEntered
			,strBatchId
			,strCode
			,strModuleName
			,strTransactionForm
			,strTransactionType
		)
		--DEBIT COGS
		SELECT	
			strTransactionId = A.strInvoiceNumber, 
			intTransactionId = A.intInvoiceId,
			intAccountId = B.intCOGSAccountId,
			strDescription = A.strComments,
			strReference = C.strCustomerNumber,
			dtmTransactionDate = A.dtmDate,
			dblDebit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(IP.dblStandardCost, B.dblTotal) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(IP.dblStandardCost, B.dblTotal) ELSE 0 END) END,
			dblCredit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(IP.dblStandardCost, B.dblTotal) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(IP.dblStandardCost, B.dblTotal) END) END,
			dblDebitUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
			dblCreditUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) END) END,
			dtmDate = A.dtmDate,
			ysnIsUnposted = 0,
			intConcurrencyId = 1,
			dblExchangeRate		= 1,
			intUserID			= @userId,
			intEntityId			= @UserEntityID,
			dtmDateEntered		= GETDATE(),
			strBatchID			= @batchId,
			strCode				= 'AR',
			strModuleName		= @MODULE_NAME,
			strTransactionForm = @SCREEN_NAME,
			strTransactionType = A.strTransactionType 
		FROM
			tblARInvoice A 
		LEFT JOIN
			tblARInvoiceDetail B
				ON A.intInvoiceId = B.intInvoiceId
		LEFT JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId 	
		LEFT JOIN
			tblICItemPricing IP
				ON B.intItemId = IP.intItemId AND B.intCompanyLocationId = IP.intLocationId					
		INNER JOIN 
			#tmpPostInvoiceData	P
				ON A.intInvoiceId = P.intInvoiceId 
		WHERE B.intItemId IS NOT NULL AND B.intItemId <> 0

		--CREDIT INVENTORY
		UNION ALL 
		SELECT	
			strTransactionId = A.strInvoiceNumber, 
			intTransactionId = A.intInvoiceId,
			intAccountId = B.intInventoryAccountId,
			strDescription = A.strComments,
			strReference = C.strCustomerNumber,
			dtmTransactionDate = A.dtmDate,
			dblDebit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(IP.dblStandardCost, B.dblTotal) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(IP.dblStandardCost, B.dblTotal) END) END,
			dblCredit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(IP.dblStandardCost, B.dblTotal) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(IP.dblStandardCost, B.dblTotal) ELSE 0 END) END,
			dblDebitUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) END,
			dblCreditUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
			dtmDate = A.dtmDate,
			ysnIsUnposted = 0,
			intConcurrencyId = 1,
			dblExchangeRate		= 1,
			intUserID			= @userId,
			intEntityId			= @UserEntityID,
			dtmDateEntered		= GETDATE(),
			strBatchID			= @batchId,
			strCode				= 'AR',
			strModuleName		= @MODULE_NAME,
			strTransactionForm = @SCREEN_NAME,
			strTransactionType = A.strTransactionType 
		FROM
			tblARInvoice A 
		LEFT JOIN
			tblARInvoiceDetail B
				ON A.intInvoiceId = B.intInvoiceId
		LEFT JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId 				
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId 	
		LEFT JOIN
			tblICItemPricing IP
				ON B.intItemId = IP.intItemId  AND B.intCompanyLocationId = IP.intLocationId								
		INNER JOIN 
			#tmpPostInvoiceData	P
				ON A.intInvoiceId = P.intInvoiceId 
		WHERE B.intItemId IS NOT NULL OR B.intItemId <> 0
		
		--DEBIT AR
		UNION ALL
		SELECT	
			strTransactionId = A.strInvoiceNumber, 
			intTransactionId = A.intInvoiceId,
			intAccountId = A.intAccountId,
			strDescription = A.strComments,
			strReference = C.strCustomerNumber,
			dtmTransactionDate = A.dtmDate,
			dblDebit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE  WHEN @post = 1 THEN A.dblInvoiceTotal ELSE 0 END) ELSE (CASE  WHEN @post = 0 THEN A.dblInvoiceTotal ELSE 0 END) END,
			dblCredit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE A.dblInvoiceTotal END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE A.dblInvoiceTotal END) END,
			dblDebitUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
			dblCreditUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) END) END,
			dtmDate = A.dtmDate,
			ysnIsUnposted = 0,
			intConcurrencyId = 1,
			dblExchangeRate		= 1,
			intUserID			= @userId,
			intEntityId			= @UserEntityID,
			dtmDateEntered		= GETDATE(),
			strBatchID			= @batchId,
			strCode				= 'AR',
			strModuleName		= @MODULE_NAME,
			strTransactionForm = @SCREEN_NAME,
			strTransactionType = A.strTransactionType 
		FROM
			tblARInvoice A
		LEFT JOIN 
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId 			
		INNER JOIN 
			#tmpPostInvoiceData	P
				ON A.intInvoiceId = P.intInvoiceId 
				
		--CREDIT MISC
		UNION ALL 
		SELECT	
			strTransactionId = A.strInvoiceNumber, 
			intTransactionId = A.intInvoiceId,
			intAccountId = B.intAccountId,
			strDescription = A.strComments,
			strReference = C.strCustomerNumber,
			dtmTransactionDate = A.dtmDate,									
			dblDebit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE B.dblTotal END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE B.dblTotal END) END,
			dblCredit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN B.dblTotal ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN B.dblTotal ELSE 0 END) END,
			dblDebitUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) END,
			dblCreditUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
			dtmDate = A.dtmDate,
			ysnIsUnposted = 0,
			intConcurrencyId = 1,
			dblExchangeRate		= 1,
			intUserID			= @userId,
			intEntityId			= @UserEntityID,
			dtmDateEntered		= GETDATE(),
			strBatchID			= @batchId,
			strCode				= 'AR',
			strModuleName		= @MODULE_NAME,
			strTransactionForm = @SCREEN_NAME,
			strTransactionType = A.strTransactionType 
		FROM
			tblARInvoice A 
		LEFT JOIN
			tblARInvoiceDetail B
				ON A.intInvoiceId = B.intInvoiceId
		LEFT JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId 			
		INNER JOIN 
			#tmpPostInvoiceData	P
				ON A.intInvoiceId = P.intInvoiceId 
		WHERE B.intItemId IS NULL OR B.intItemId = 0

		--CREDIT SALES
		UNION ALL 
		SELECT	
			strTransactionId = A.strInvoiceNumber, 
			intTransactionId = A.intInvoiceId,
			intAccountId = B.intSalesAccountId,
			strDescription = A.strComments,
			strReference = C.strCustomerNumber,
			dtmTransactionDate = A.dtmDate,
			dblDebit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE B.dblTotal END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE B.dblTotal END) END,
			dblCredit = CASE WHEN A.strTransactionType = 'Invoice' THEN  (CASE WHEN @post = 1 THEN B.dblTotal ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN B.dblTotal ELSE 0 END) END,
			dblDebitUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE ISNULL(A.dblInvoiceTotal, 0)  * ISNULL(U.dblLbsPerUnit, 0) END) END,
			dblCreditUnit = CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN ISNULL(A.dblInvoiceTotal, 0) * ISNULL(U.dblLbsPerUnit, 0) ELSE 0 END) END,
			dtmDate = A.dtmDate,
			ysnIsUnposted = 0,
			intConcurrencyId = 1,
			dblExchangeRate		= 1,
			intUserID			= @userId,
			intEntityId			= @UserEntityID,
			dtmDateEntered		= GETDATE(),
			strBatchID			= @batchId,
			strCode				= 'AR',
			strModuleName		= @MODULE_NAME,
			strTransactionForm = @SCREEN_NAME,
			strTransactionType = A.strTransactionType 
		FROM
			tblARInvoice A 
		LEFT JOIN
			tblARInvoiceDetail B
				ON A.intInvoiceId = B.intInvoiceId
		LEFT JOIN
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN 
			Units U
				ON A.intAccountId = U.intAccountId 			
		INNER JOIN 
			#tmpPostInvoiceData	P
				ON A.intInvoiceId = P.intInvoiceId 
		WHERE B.intItemId IS NOT NULL OR B.intItemId <> 0
				
		UNION ALL 
		SELECT	
			strTransactionId = A.strInvoiceNumber, 
			intTransactionId = A.intInvoiceId,
			intAccountId = L.intFreightIncome,
			strDescription = A.strComments,
			strReference = C.strCustomerNumber,
			dtmTransactionDate = A.dtmDate,			
			dblDebit		= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE A.dblShipping END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE A.dblShipping END) END,
			dblCredit		= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN A.dblShipping ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN A.dblShipping ELSE 0 END) END,
			dblDebitUnit	= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE (ISNULL(A.dblShipping, 0)  * ISNULL(U.dblLbsPerUnit, 0)) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE (ISNULL(A.dblShipping, 0)  * ISNULL(U.dblLbsPerUnit, 0)) END) END,
			dblCreditUnit	= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN (ISNULL(A.dblShipping, 0) * ISNULL(U.dblLbsPerUnit, 0)) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN (ISNULL(A.dblShipping, 0) * ISNULL(U.dblLbsPerUnit, 0)) ELSE 0 END) END,
			dtmDate = A.dtmDate,
			ysnIsUnposted = 0,
			intConcurrencyId = 1,
			dblExchangeRate		= 1,
			intUserID			= @userId,
			intEntityId			= @UserEntityID,
			dtmDateEntered		= GETDATE(),
			strBatchID			= @batchId,
			strCode				= 'AR',
			strModuleName		= @MODULE_NAME,
			strTransactionForm = @SCREEN_NAME,
			strTransactionType = A.strTransactionType 
		FROM
			tblARInvoice A 
		LEFT JOIN 
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN Units U
				ON A.intAccountId = U.intAccountId 	
		INNER JOIN
			tblSMCompanyLocation L
				ON A.intCompanyLocationId = L.intCompanyLocationId	
		INNER JOIN 
			#tmpPostInvoiceData	P
				ON A.intInvoiceId = P.intInvoiceId	
		WHERE
			A.dblShipping <> 0.0
				
				
		UNION ALL 
		
		SELECT	
			strTransactionId = A.strInvoiceNumber, 
			intTransactionId = A.intInvoiceId,
			intAccountId = L.intFreightIncome,
			strDescription = A.strComments,
			strReference = C.strCustomerNumber,
			dtmTransactionDate = A.dtmDate,
			dblDebit		= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE A.dblTax END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE A.dblTax END) END,
			dblCredit		= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN A.dblTax ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN A.dblTax ELSE 0 END) END,
			dblDebitUnit	= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN 0 ELSE (ISNULL(A.dblTax, 0)  * ISNULL(U.dblLbsPerUnit, 0)) END) ELSE (CASE WHEN @post = 0 THEN 0 ELSE (ISNULL(A.dblTax, 0)  * ISNULL(U.dblLbsPerUnit, 0)) END) END,
			dblCreditUnit	= CASE WHEN A.strTransactionType = 'Invoice' THEN (CASE WHEN @post = 1 THEN (ISNULL(A.dblTax, 0) * ISNULL(U.dblLbsPerUnit, 0)) ELSE 0 END) ELSE (CASE WHEN @post = 0 THEN (ISNULL(A.dblTax, 0) * ISNULL(U.dblLbsPerUnit, 0)) ELSE 0 END) END,
			dtmDate = A.dtmDate,
			ysnIsUnposted = 0,
			intConcurrencyId = 1,
			dblExchangeRate		= 1,
			intUserID			= @userId,
			intEntityId			= @UserEntityID,
			dtmDateEntered		= GETDATE(),
			strBatchID			= @batchId,
			strCode				= 'AR',
			strModuleName		= @MODULE_NAME,
			strTransactionForm = @SCREEN_NAME,
			strTransactionType = A.strTransactionType 
		FROM
			tblARInvoice A 
		LEFT JOIN 
			tblARCustomer C
				ON A.intCustomerId = C.intCustomerId
		LEFT JOIN Units U
				ON A.intAccountId = U.intAccountId 	
		INNER JOIN
			tblSMCompanyLocation L
				ON A.intCompanyLocationId = L.intCompanyLocationId	
		INNER JOIN 
			#tmpPostInvoiceData	P
				ON A.intInvoiceId = P.intInvoiceId	
		WHERE
			A.dblTax <> 0.0								
				
				

		IF @@ERROR <> 0	GOTO Post_Rollback;

		GOTO Post_Commit;
	END

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID JOURNALS
---------------------------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	SELECT * FROM #tmpPostInvoiceData
	GOTO Post_Cleanup
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Cleanup:
	IF(ISNULL(@recap,0) = 0)
	BEGIN

		IF(@post = 1)
		BEGIN
			--clean gl detail recap after posting
			DELETE FROM tblGLDetailRecap
			FROM tblGLDetailRecap A
			INNER JOIN #tmpPostInvoiceData B ON A.intTransactionId = B.intInvoiceId 
		END

	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPostInvoiceData')) DROP TABLE #tmpPostInvoiceData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvalidInvoiceData')) DROP TABLE #tmpInvalidInvoiceData

GO

