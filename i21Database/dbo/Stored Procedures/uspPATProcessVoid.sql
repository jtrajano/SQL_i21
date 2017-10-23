CREATE PROCEDURE [dbo].[uspPATProcessVoid]
	@stockIds NVARCHAR(MAX) = '',
	@intUserId INT,
	@successfulCount INT = 0 OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION

	DECLARE @tmpTransactions TABLE (
		[intTransactionId] [int] PRIMARY KEY,
		UNIQUE (intTransactionId)
	);
	DECLARE @GLEntries AS RecapTableType;
	DECLARE @totalRecords INT = 0;
	DECLARE @error NVARCHAR(MAX);
	DECLARE @batchId NVARCHAR(40);
	DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Void Retire Stock';
	DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT';

	INSERT INTO @tmpTransactions SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@stockIds)
	
	IF(@batchId IS NULL)
		EXEC uspSMGetStartingNumber 3, @batchId OUT

		INSERT INTO @GLEntries(
				[dtmDate], 
				[strBatchId], 
				[intAccountId],
				[dblDebit],
				[dblCredit],
				[dblDebitUnit],
				[dblCreditUnit],
				[strDescription],
				[strCode],
				[strReference],
				[intCurrencyId],
				[dtmDateEntered],
				[dtmTransactionDate],
				[strJournalLineDescription],
				[intJournalLineNo],
				[ysnIsUnposted],
				[intUserId],
				[intEntityId],
				[strTransactionId],
				[intTransactionId],
				[strTransactionType],
				[strTransactionForm],
				[strModuleName],
				[dblDebitForeign],
				[dblDebitReport],
				[dblCreditForeign],
				[dblCreditReport],
				[dblReportingRate],
				[dblForeignRate],
				[strRateType])
			--VOTING STOCK/NON-VOTING STOCK/OTHER ISSUED
			SELECT	
				[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
				[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
				[intAccountId]					=	CASE WHEN A.strStockStatus = 'Voting' THEN ComPref.intVotingStockId ELSE ComPref.intNonVotingStockId END,
				[dblDebit]						=	0,
				[dblCredit]						=	ROUND(A.dblFaceValue, 2),
				[dblDebitUnit]					=	0,
				[dblCreditUnit]					=	0,
				[strDescription]				=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Void Retire Stock' ELSE 'Posted Non-Voting/Other Void Retire Stock' END,
				[strCode]						=	@MODULE_CODE,
				[strReference]					=	A.strCertificateNo,
				[intCurrencyId]					=	1,
				[dtmDateEntered]				=	GETDATE(),
				[dtmTransactionDate]			=	NULL,
				[strJournalLineDescription]		=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Void Retire Stock' ELSE 'Posted Non-Voting/Other Void Retire Stock' END,
				[intJournalLineNo]				=	1,
				[ysnIsUnposted]					=	0,
				[intUserId]						=	@intUserId,
				[intEntityId]					=	@intUserId,
				[strTransactionId]				=	A.intCustomerStockId, 
				[intTransactionId]				=	A.intCustomerStockId, 
				[strTransactionType]			=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Voting' ELSE 'Non-Voting/Other' END,
				[strTransactionForm]			=	@SCREEN_NAME,
				[strModuleName]					=	@MODULE_NAME,
				[dblDebitForeign]				=	0,      
				[dblDebitReport]				=	0,
				[dblCreditForeign]				=	0,
				[dblCreditReport]				=	0,
				[dblReportingRate]				=	0,
				[dblForeignRate]				=	0,
				[strRateType]					=	NULL
			FROM	[dbo].[tblPATCustomerStock] A
					CROSS JOIN tblPATCompanyPreference ComPref
			WHERE	A.intCustomerStockId IN (SELECT [intTransactionId] FROM @tmpTransactions)
			UNION ALL
			--AP CLEARING
			SELECT	
				[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
				[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
				[intAccountId]					=	ComPref.intAPClearingGLAccount,
				[dblDebit]						=	ROUND(A.dblFaceValue,2),
				[dblCredit]						=	0,
				[dblDebitUnit]					=	0,
				[dblCreditUnit]					=	0,
				[strDescription]				=	'Posted AP Clearing for Void Retire Stock',
				[strCode]						=	@MODULE_CODE,
				[strReference]					=	A.strCertificateNo,
				[intCurrencyId]					=	1,
				[dtmDateEntered]				=	GETDATE(),
				[dtmTransactionDate]			=	NULL,
				[strJournalLineDescription]		=	'Posted AP Clearing for Void Retire Stock',
				[intJournalLineNo]				=	1,
				[ysnIsUnposted]					=	0,
				[intUserId]						=	@intUserId,
				[intEntityId]					=	@intUserId,
				[strTransactionId]				=	A.intCustomerStockId, 
				[intTransactionId]				=	A.intCustomerStockId, 
				[strTransactionType]			=	'Void Retire Stock',
				[strTransactionForm]			=	@SCREEN_NAME,
				[strModuleName]					=	@MODULE_NAME,
				[dblDebitForeign]				=	0,      
				[dblDebitReport]				=	0,
				[dblCreditForeign]				=	0,
				[dblCreditReport]				=	0,
				[dblReportingRate]				=	0,
				[dblForeignRate]				=	0,
				[strRateType]					=	NULL
			FROM	[dbo].[tblPATCustomerStock] A
					CROSS JOIN tblPATCompanyPreference ComPref
			WHERE	A.intCustomerStockId IN (SELECT [intTransactionId] FROM @tmpTransactions)

	BEGIN TRY
		SELECT * FROM @GLEntries
		EXEC uspGLBookEntries @GLEntries, 1
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback
	END CATCH

	UPDATE tblPATCustomerStock
		SET strActivityStatus = 'Open',
			dtmRetireDate = null,
			intBillId = null
		WHERE intCustomerStockId IN (SELECT [intTransactionId] FROM @tmpTransactions);

	SELECT @totalRecords = COUNT([intTransactionId]) FROM @tmpTransactions;

IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit
Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
Post_Exit:
	
END