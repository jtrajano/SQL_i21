CREATE PROCEDURE [dbo].[uspAPPostOriginPayment]
	@batchId			AS NVARCHAR(20)		= NULL,
	@transactionType	AS NVARCHAR(30)		= NULL,
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= NULL,
	@userId				AS INT				= 1,
	@beginDate			AS DATE				= NULL,
	@endDate			AS DATE				= NULL,
	@beginTransaction	AS NVARCHAR(50)		= NULL,
	@endTransaction		AS NVARCHAR(50)		= NULL,
	@successfulCount	AS INT				= 0 OUTPUT,
	@invalidCount		AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@batchIdUsed		AS NVARCHAR(20)		= NULL OUTPUT,
	@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
AS
BEGIN

		DECLARE @successful BIT,
		@successCount INT,
		@invalid INT,
		@usedBatchId NVARCHAR(20),
		@idRecap NVARCHAR(250);

		CREATE TABLE #tmpPayments(intPaymentId INT)

		INSERT INTO #tmpPayments
		EXEC uspAPPostPayment @post=@post,
			@recap=@recap,
			@param=@param,
			@transactionType=@transactionType,
			@beginDate=@beginDate,
			@endDate=@endDate,
			@beginTransaction=@beginTransaction,
			@endTransaction=@endTransaction,
			@userId=@userId,
			@batchId=@batchId,
			@success=@successful OUTPUT,
			@successfulCount=@successCount OUTPUT,
			@invalidCount=@invalid OUTPUT,
			@batchIdUsed=@usedBatchId OUTPUT,
			@recapId=@idRecap OUTPUT
	
	--IF @post = 0 AND @recap = 0
	--BEGIN

	--	--Removed payment that is not from origin
	--	DELETE FROM #tmpPayments
	--	FROM #tmpPayments A
	--		INNER JOIN tblAPPayment B
	--			ON A.intPaymentId = B.intPaymentId

	--	IF EXISTS(SELECT 1 FROM #tmpPayments)
	--	BEGIN

	--		--Create reversal for journal of origin payment
	--		SELECT A.*, B.intPaymentId INTO #tmpJournalPayments
	--		FROM tblGLJournalDetail A
	--			INNER JOIN tblAPPayment B
	--			ON A.strDocument = B.strPaymentInfo
	--			AND (A.strSourcePgm = 'apqckn ' OR A.strSourcePgm = 'apselu  ')
	--			AND B.intPaymentId IN (SELECT intPaymentId FROM #tmpPayments)

	--		INSERT INTO tblGLDetail (
	--			[strTransactionId], 
	--			[intAccountId],
	--			[strDescription],
	--			[strReference],
	--			[dtmTransactionDate],
	--			[dblDebit],
	--			[dblCredit],
	--			[dblDebitUnit],
	--			[dblCreditUnit],
	--			[dtmDate],
	--			[ysnIsUnposted],
	--			[intConcurrencyId],
	--			[dblExchangeRate],
	--			[intUserId],
	--			[dtmDateEntered],
	--			[strBatchId],
	--			[strCode],
	--			[strModuleName],
	--			[strTransactionForm]
	--		)
	--		SELECT
	--			[strTransactionId]		=	B.strJournalId, 
	--			[intAccountId]			=	A.intAccountId,
	--			[strDescription]		=	A.strDescription,
	--			[strReference]			=	'Reversal entry from voiding ' + C.strPaymentRecordNum,
	--			[dtmTransactionDate]	=	A.dtmDate,
	--			[dblDebit]				=	A.dblCredit,
	--			[dblCredit]				=	A.dblDebit,
	--			[dblDebitUnit]			=	A.dblCreditUnit,
	--			[dblCreditUnit]			=	A.dblDebitUnit,
	--			[dtmDate]				=	GETDATE(),
	--			[ysnIsUnposted]			=	0,
	--			[intConcurrencyId]		=	1,
	--			[dblExchangeRate]		=	1,
	--			[intUserId]				=	@userId,
	--			[dtmDateEntered]		=	GETDATE(),
	--			[strBatchId]			=	@batchId,
	--			[strCode]				=	'GJ',
	--			[strModuleName]			=	'General Ledger',
	--			[strTransactionForm]	=	'General Journal'
	--		FROM #tmpJournalPayments A
	--			INNER JOIN tblGLJournal B
	--			ON A.intJournalId = B.intJournalId
	--			INNER JOIN tblAPPayment C
	--			ON A.intPaymentId = B.intPaymentId AND C.ysnOrigin = 1
	--	END

	--END

		SET @successfulCount = @successCount;
		SET @invalidCount = @invalid;
		SET @batchIdUsed = @usedBatchId;
		SET @recapId = @idRecap;
		SET @success = @successful;

END

