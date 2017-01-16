CREATE PROCEDURE [dbo].[uspPATPostEquityPayments]
	@intEquityPayId AS INT = NULL,
	@ysnPosted AS BIT = NULL,
	@intUserId AS INT = NULL,
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
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Equity Payments'
DECLARE @totalRecords INT
DECLARE @GLEntries AS RecapTableType 
DECLARE @error NVARCHAR(200)
DECLARE @dateToday AS DATETIME = GETDATE();
DECLARE @batchId NVARCHAR(40);


IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT
	
SET @batchIdUsed = @batchId;

	SELECT	EP.intEquityPayId,
			EP.strPaymentNumber,
			EP.dblPayoutPercent,
			EPS.intCustomerPatronId,
			EPD.intCustomerEquityId,
			EPD.intFiscalYearId,
			EPD.intRefundTypeId,
			EPD.strEquityType,
			EPD.dblEquityPay
	INTO #tempEquityPayment
	FROM tblPATEquityPay EP
	INNER JOIN tblPATEquityPaySummary EPS
		ON EPS.intEquityPayId = EP.intEquityPayId
	INNER JOIN tblPATEquityPayDetail EPD
		ON EPD.intEquityPaySummaryId = EPS.intEquityPaySummaryId
	WHERE EP.intEquityPayId = @intEquityPayId


	BEGIN TRANSACTION
	---------------- BEGIN - GET GL ENTRIES ----------------
	IF(@ysnPosted = 1)
	BEGIN
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATCreateEquityPayoutGLEntries](@intEquityPayId, @batchIdUsed, @intUserId)
	END
	ELSE
	BEGIN
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATReverseEquityPayoutGLEntries](@intEquityPayId, @dateToday, @batchId, @intUserId)

		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intEquityPayId 
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
	UPDATE tblPATEquityPay
	SET ysnPosted = @ysnPosted WHERE intEquityPayId = @intEquityPayId

	UPDATE CE
	SET	CE.dblEquityPaid = CASE WHEN @ysnPosted = 1 THEN CE.dblEquityPaid + tEP.dblEquityPay ELSE CE.dblEquityPaid - tEP.dblEquityPay END
	FROM tblPATCustomerEquity CE
	INNER JOIN #tempEquityPayment tEP
		ON tEP.intCustomerEquityId = CE.intCustomerEquityId

	---------------- END - UPDATE TABLES ------------------
---------------------------------------------------------------------------------------------------------------------------------------
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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempEquityPayment')) DROP TABLE #tempEquityPayment
END