CREATE PROCEDURE [dbo].[uspPATPostRefund] 
	@intRefundId INT = NULL,
	@ysnPosted BIT = NULL,
	@intUserId INT = NULL,
	@intAPClearingId INT = NULL,
	@intFiscalYearId INT = NULL,
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

--DECLARE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.';
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.';
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Refund';
DECLARE @TRAN_TYPE NVARCHAR(25) = 'Refund';
DECLARE @totalRecords INT;
DECLARE @GLEntries AS RecapTableType;
DECLARE @error NVARCHAR(200);
DECLARE @batchId NVARCHAR(40);

--=====================================================================================================================================
--  VALIDATE REFUND DETAILS
---------------------------------------------------------------------------------------------------------------------------------------
IF(@ysnPosted = 1)
BEGIN
	DECLARE  @validateRefundCustomer TABLE(
		[intRefundCustomerId] INT,
		[intCustomerVolumeId] INT
	)

	INSERT INTO @validateRefundCustomer
	SELECT	RC.intRefundCustomerId,
			CV.intCustomerVolumeId
	FROM tblPATRefundCustomer RC
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RC.intRefundId
	INNER JOIN tblPATCustomerVolume CV
		ON CV.intRefundCustomerId = RC.intRefundCustomerId
	WHERE R.intRefundId = @intRefundId

	IF EXISTS(SELECT 1 FROM @validateRefundCustomer)
	BEGIN
		SET @error = 'There are volumes that were already processed which made the record obsolete. Please delete this refund record.';
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback
	END
END

--=====================================================================================================================================
--  GET REFUND DETAILS
---------------------------------------------------------------------------------------------------------------------------------------
SELECT R.intRefundId, 
		R.intFiscalYearId, 
		R.dtmRefundDate, 
		R.strRefund,
		R.dblMinimumRefund, 
		R.dblServiceFee,		   
		R.dblCashCutoffAmount, 
		R.dblFedWithholdingPercentage,
		RC.intRefundCustomerId,
		RC.intCustomerId,
		RC.strStockStatus,
		RC.ysnEligibleRefund,
		RC.intRefundTypeId,
		RC.ysnQualified, 
		RC.dblRefundAmount,
		RC.dblCashRefund,
		RC.dblEquityRefund
	INTO #tmpRefundData 
	FROM tblPATRefundCustomer RC 
	INNER JOIN tblPATRefund R 
		ON R.intRefundId = RC.intRefundId 
	WHERE R.intRefundId = @intRefundId

SELECT @totalRecords = COUNT(*) FROM #tmpRefundData	where ysnEligibleRefund = 1

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

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

DECLARE @validRefundIds NVARCHAR(MAX)

-- CREATE TEMP GL ENTRIES
SELECT DISTINCT @validRefundIds = COALESCE(@validRefundIds + ',', '') +  CONVERT(VARCHAR(12),intRefundId)
FROM #tmpRefundData

DECLARE @dblDiff NUMERIC(18,6)
DECLARE @intAdjustmentId INT

IF ISNULL(@ysnPosted,0) = 1
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnPATCreateRefundGLEntries(@validRefundIds, @intUserId, @intAPClearingId, @batchId)

----------------------------------------------------------------------------------

END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnPATReverseGLRefundEntries(@validRefundIds, DEFAULT, @intUserId)

----------------------------------------------------------------------------------

END

BEGIN TRY
	SELECT * FROM @GLEntries
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
		WHERE intTransactionId = @intRefundId 
			AND strModuleName = @MODULE_NAME 
			AND strTransactionForm = @TRAN_TYPE
END


--=====================================================================================================================================
-- 	UPDATE CUSTOMER EQUITY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRY
	MERGE tblPATCustomerEquity AS EQ
	USING (SELECT * FROM #tmpRefundData WHERE ysnEligibleRefund = 1) AS B
		ON (EQ.intCustomerId = B.intCustomerId AND EQ.intFiscalYearId = B.intFiscalYearId AND EQ.intRefundTypeId = B.intRefundTypeId)
		WHEN MATCHED
			THEN UPDATE SET EQ.dblEquity = CASE WHEN @ysnPosted = 1 THEN EQ.dblEquity + B.dblEquityRefund ELSE EQ.dblEquity - B.dblEquityRefund END
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, intConcurrencyId)
				VALUES (B.intCustomerId, B.intFiscalYearId , 'Undistributed', B.intRefundTypeId, B.dblEquityRefund, 1);
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH
---------------------------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================================
-- 	UPDATE CUSTOMER VOLUME TABLE
---------------------------------------------------------------------------------------------------------------------------------------
	IF(@ysnPosted = 1)
	BEGIN
		UPDATE CV
		SET CV.intRefundCustomerId = tRD.intRefundCustomerId
		FROM tblPATCustomerVolume CV
		INNER JOIN #tmpRefundData tRD
			ON CV.intCustomerPatronId = tRD.intCustomerId AND CV.intFiscalYear = tRD.intFiscalYearId 
		WHERE CV.ysnRefundProcessed = 0 AND CV.intRefundCustomerId IS NULL
	END
	ELSE
	BEGIN
		UPDATE CV
		SET CV.intRefundCustomerId = null
		FROM tblPATCustomerVolume CV
		INNER JOIN #tmpRefundData tRD
			ON CV.intRefundCustomerId = tRD.intRefundCustomerId
	END

	UPDATE tblPATCustomerVolume
	SET ysnRefundProcessed = @ysnPosted
	WHERE intFiscalYear = @intFiscalYearId AND intCustomerPatronId IN (SELECT DISTINCT intCustomerId FROM #tmpRefundData)
	

---------------------------------------------------------------------------------------------------------------------------------------


--=====================================================================================================================================
-- 	UPDATE REFUND TABLE
---------------------------------------------------------------------------------------------------------------------------------------

	UPDATE tblPATRefund 
	SET ysnPosted = @ysnPosted
	WHERE intRefundId = @intRefundId
	
---------------------------------------------------------------------------------------------------------------------------------------

IF @@ERROR <> 0	GOTO Post_Rollback;

GOTO Post_Commit;

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRefundData')) DROP TABLE #tmpRefundData
END
---------------------------------------------------------------------------------------------------------------------------------------
GO