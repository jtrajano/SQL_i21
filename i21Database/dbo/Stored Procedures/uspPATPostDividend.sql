CREATE PROCEDURE [dbo].[uspPATPostDividend] 
	@intDividendId INT = NULL,
	@ysnPosted BIT = NULL,
	@intUserId INT = NULL,
	@intAPClearingId INT = NULL,
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
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Dividends'
DECLARE @TRAN_TYPE NVARCHAR(25) = 'Dividends'
DECLARE @totalRecords INT
DECLARE @GLEntries AS RecapTableType 
DECLARE @error NVARCHAR(200)
DECLARE @batchId NVARCHAR(40)


---------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
--=====================================================================================================================================
-- 	CREATE GL ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------
IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT


IF ISNULL(@ysnPosted,0) = 1
BEGIN
	INSERT INTO @GLEntries
		SELECT * FROM dbo.fnPATCreateDividendGLEntries(@intDividendId, @batchId, @intUserId, @intAPClearingId)
END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnPATReverseGLDividendEntries(@intDividendId, DEFAULT, @intUserId)
END

BEGIN TRY

EXEC uspGLBookEntries @GLEntries, @ysnPosted
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH

IF ISNULL(@ysnPosted,0) = 0
BEGIN
	
	UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intDividendId 
			AND strCode=N'PAT' 
			AND strTransactionForm=N'Dividend'
END

--=====================================================================================================================================
-- 	UPDATE DIVIDENDS TABLE
---------------------------------------------------------------------------------------------------------------------------------------

	UPDATE tblPATDividends 
	   SET ysnPosted = ISNULL(@ysnPosted,0)
	  FROM tblPATDividends R
	 WHERE R.intDividendId = @intDividendId


IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Cleanup
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Cleanup:
	--DELETE FROM tblGLTest
	--FROM tblGLPostRecap A
	--INNER JOIN #tmpPostBillData B ON A.intTransactionId = B.intBillId 
Post_Exit:

END

GO
