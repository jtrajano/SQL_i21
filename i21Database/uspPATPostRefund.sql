CREATE PROCEDURE [dbo].[uspPATPostRefund] 
	@intRefundId INT = NULL,
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

BEGIN TRANSACTION -- START TRANSACTION

----=====================================================================================================================================
---- 	DECLARE TEMPORARY TABLES
-----------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpRefundPostData (
	[intRefundId] [int] PRIMARY KEY,
	UNIQUE (intRefundId)
);


--DECLARE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Refund'
DECLARE @TRAN_TYPE NVARCHAR(25) = 'Refund'
DECLARE @totalRecords INT
DECLARE @GLEntries AS RecapTableType 
DECLARE @error NVARCHAR(200)


--=====================================================================================================================================
--  GET REFUND DETAILS
---------------------------------------------------------------------------------------------------------------------------------------
	SELECT PR.intRefundId, PR.intFiscalYearId, PR.dtmRefundDate, PR.strRefund, PR.dblMinimumRefund, PR.dblServiceFee,
		   PR.dblCashCutoffAmount, PR.dblFedWithholdingPercentage, PR.dblPurchaseVolume, PR.dblSaleVolume,
		   PR.dblLessFWT, PR.dblLessService, PR.dblCheckAmount, PR.dblNoRefund, PR.ysnPosted, PRC.intRefundCustomerId,
		   PRC.intCustomerId, PRC.intPatronageCategoryId, PRC.strStockStatus, PRC.ysnEligibleRefund, PRC.intRefundTypeId, PRC.dblCashPayout,
		   PRC.ysnQualified, PRC.dblRefundAmount, PRC.dblCashRefund, PRC.dblEquityRefund, PRCA.intRefundCategoryId,
		   PRCA.dblRefundRate, PRCA.dblVolume
	  INTO #tmpRefundData
	  FROM tblPATRefund PR
INNER JOIN tblPATRefundCustomer PRC
		ON PRC.intRefundId = PR.intRefundId
INNER JOIN tblPATRefundCategory PRCA
		ON PRCA.intRefundCustomerId = PRC.intRefundCustomerId

SELECT @totalRecords = COUNT(*) FROM #tmpRefundData	

COMMIT TRANSACTION --COMMIT inserted invalid transaction


IF(@totalRecords = 0)  
BEGIN
	SET @success = 0
	GOTO Post_Exit
END

---------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
--=====================================================================================================================================
-- 	CREATE GL ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================================
-- 	UPDATE REFUND TABLE
---------------------------------------------------------------------------------------------------------------------------------------

	UPDATE tblPATRefund 
	   SET ysnPosted = ISNULL(@ysnPosted,0)
	  FROM tblPATRefund R
	 WHERE R.intRefundId = @intRefundId


DECLARE @validRefundIds NVARCHAR(MAX)

--CREATE TEMP GL ENTRIES
SELECT @validRefundIds = COALESCE(@validRefundIds + ',', '') +  CONVERT(VARCHAR(12),intRefundId)
FROM #tmpRefundData
ORDER BY intRefundId

IF ISNULL(@ysnPosted,0) = 1
BEGIN
	INSERT INTO @GLEntries
		SELECT * FROM dbo.fnPATCreateRefundGLEntries(@validRefundIds, @intUserId, @intAPClearingId)
END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnPATReverseGLRefundEntries(@validRefundIds, DEFAULT, @intUserId)
END

BEGIN TRY
EXEC uspGLBookEntries @GLEntries, @ysnPosted
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH
	
---------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION

--=====================================================================================================================================
-- 	UPDATE CUSTOMER EQUITY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRY

DECLARE @strCutoffTo NVARCHAR(50) = (SELECT TOP 1 strCutoffTo from tblPATCompanyPreference)

MERGE tblPATCustomerEquity AS EQ
USING #tmpRefundData AS B
	ON (EQ.intCustomerId = B.intCustomerId AND EQ.intFiscalYearId = B.intFiscalYearId)
	WHEN MATCHED AND B.ysnPosted = 0 AND EQ.dblEquity = B.dblVolume -- is this correct? dblVolume
		THEN DELETE
	WHEN MATCHED
		THEN UPDATE SET EQ.dblEquity = CASE WHEN B.ysnPosted = 1 THEN 
												(EQ.dblEquity + (CASE WHEN B.dblRefundAmount < B.dblCashCutoffAmount THEN 
																	(CASE WHEN @strCutoffTo = 'Cash' THEN 0 ELSE B.dblRefundAmount END) ELSE 
																B.dblRefundAmount - (B.dblRefundAmount * .25) END)) 
									   ELSE (EQ.dblEquity - (CASE WHEN B.dblRefundAmount < B.dblCashCutoffAmount THEN 
																	(CASE WHEN @strCutoffTo = 'Cash' THEN 0 ELSE B.dblRefundAmount END) ELSE 
																B.dblRefundAmount - (B.dblRefundAmount * .25) END)) END
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, dtmLastActivityDate, intConcurrencyId)
			VALUES (B.intCustomerId, B.intFiscalYearId , 'Undistributed', B.intRefundTypeId, CASE WHEN B.dblRefundAmount < B.dblCashCutoffAmount THEN 
																	(CASE WHEN @strCutoffTo = 'Cash' THEN 0 ELSE B.dblRefundAmount END) ELSE 
																B.dblRefundAmount - (B.dblRefundAmount * .25) END, GETDATE(), 1);

END TRY
BEGIN CATCH
SET @error = ERROR_MESSAGE()
RAISERROR(@error, 16, 1);
GOTO Post_Rollback
END CATCH

---------------------------------------------------------------------------------------------------------------------------------------

IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;


---------------------------------------------------------------------------------------------------------------------------------------

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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRefundData')) DROP TABLE #tmpRefundData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRefundPostData')) DROP TABLE #tmpRefundPostData
END

---------------------------------------------------------------------------------------------------------------------------------------
GO