CREATE PROCEDURE [dbo].[uspPATPostCancelEquity]
	@intCancelEquityId INT = NULL,
	@ysnPosted BIT = NULL,
	@intUserId INT = NULL,
	@batchIdUsed NVARCHAR(40) = NULL OUTPUT,
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


--DECLARE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.';
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.';
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Cancel Equity';
DECLARE @totalRecords INT;
DECLARE @GLEntries AS RecapTableType;
DECLARE @error NVARCHAR(200);
DECLARE @dateToday AS DATETIME = GETDATE();
DECLARE @batchId NVARCHAR(40);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

	SELECT	CE.intCancelEquityId,
			CE.dtmCancelDate,
			CE.strCancelNo,
			CE.strDescription,
			CE.strCancelBy,
			CE.dblCancelByValue,
			CE.ysnPosted,
			CED.intCancelEquityDetailId,
			CED.intFiscalYearId,
			CED.intCustomerId,
			CED.strEquityType,
			CED.intRefundTypeId,
			CED.dblQuantityAvailable,
			CED.dblQuantityCancelled
	INTO #tempCancelEquity
	FROM tblPATCancelEquity CE
	INNER JOIN tblPATCancelEquityDetail CED
		ON CED.intCancelEquityId = CE.intCancelEquityId
	WHERE CE.intCancelEquityId = @intCancelEquityId

	SELECT @totalRecords = COUNT(*) FROM #tempCancelEquity

	BEGIN TRANSACTION
	---------------- BEGIN - GET GL ENTRIES ----------------
	IF(@ysnPosted = 1)
	BEGIN
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATCreateCancelEquityGLEntries](@intCancelEquityId, @batchId, @intUserId)
	END
	ELSE
	BEGIN
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATReverseCancelEquityGLEntries](@intCancelEquityId, @dateToday, @batchId, @intUserId)

		
		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intCancelEquityId 
		AND strModuleName = @MODULE_NAME AND strTransactionForm = @SCREEN_NAME
	END
	---------------- END - GET GL ENTRIES ----------------

	---------------- BEGIN - BOOK GL ----------------
	BEGIN TRY
		SELECT * FROM @GLEntries
		EXEC uspGLBookEntries @GLEntries, @ysnPosted
	END TRY
	BEGIN CATCH
		SET @error = ERROR_MESSAGE()
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback
	END CATCH
	---------------- END - BOOK GL ----------------

	---------------- BEGIN - UPDATE TABLES ----------------
	UPDATE tblPATCancelEquity SET ysnPosted = @ysnPosted
		WHERE intCancelEquityId = @intCancelEquityId

	UPDATE CE
	SET CE.dblEquity = CASE WHEN @ysnPosted = 1 THEN CE.dblEquity - tempCE.dblQuantityCancelled ELSE CE.dblEquity + tempCE.dblQuantityCancelled END
	FROM tblPATCustomerEquity AS CE
	INNER JOIN #tempCancelEquity AS tempCE
		ON CE.intCustomerId = tempCE.intCustomerId AND CE.intFiscalYearId = tempCE.intFiscalYearId AND CE.intRefundTypeId = tempCE.intRefundTypeId 
			AND CE.strEquityType = tempCE.strEquityType

	---------------- END - UPDATE TABLES ----------------


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
	GOTO Post_Exit

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempCancelEquity')) DROP TABLE #tempCancelEquity
END