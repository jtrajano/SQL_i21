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
SELECT	R.intRefundId, 
		R.intFiscalYearId, 
		R.dtmRefundDate, 
		R.strRefund,
		R.dblMinimumRefund, 
		R.dblServiceFee,		   
		R.dblCashCutoffAmount, 
		R.dblFedWithholdingPercentage, 
		dblPurchaseVolume = (CASE WHEN RCatPCat.strPurchaseSale = 'Purchase' THEN RCatPCat.dblVolume ELSE 0 END), 
		dblSaleVolume = (CASE WHEN RCatPCat.strPurchaseSale = 'Sale' THEN RCatPCat.dblVolume ELSE 0 END), 
		dblLessFWT = CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 ELSE RCus.dblCashRefund * (R.dblFedWithholdingPercentage/100) END,
		dblLessService = RCus.dblCashRefund * (R.dblServiceFee/100),
		dblCheckAmount = CASE WHEN (RCus.dblCashRefund - (CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 ELSE RCus.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RCus.dblCashRefund * (R.dblServiceFee/100)) < 0) THEN 0 ELSE RCus.dblCashRefund - (CASE WHEN ARC.ysnSubjectToFWT = 0 THEN 0 ELSE RCus.dblCashRefund * (R.dblFedWithholdingPercentage/100) END) - (RCus.dblCashRefund * (R.dblServiceFee/100)) END,
		R.ysnPosted,
		RCus.intRefundCustomerId,
		RCus.intCustomerId,
		RCus.strStockStatus,
		RCus.ysnEligibleRefund,
		RCus.intRefundTypeId,
		RR.dblCashPayout,
		RCus.ysnQualified, 
		RCus.dblRefundAmount,
		RCus.dblCashRefund,
		RCus.dblEquityRefund,
		RCatPCat.intRefundCategoryId,
		RCatPCat.dblRefundRate, 
		RCatPCat.dblVolume
INTO #tmpRefundData
FROM tblPATRefundCustomer RCus
INNER JOIN tblPATRefund R
	ON R.intRefundId = RCus.intRefundId
INNER JOIN tblARCustomer ARC
	ON RCus.intCustomerId = ARC.intEntityCustomerId
INNER JOIN tblPATRefundRate RR
	ON RR.intRefundTypeId = RCus.intRefundTypeId
INNER JOIN
	(
		SELECT	intRefundCustomerId = RCat.intRefundCustomerId,
				intPatronageCategoryId = RCat.intPatronageCategoryId,
				RCat.intRefundCategoryId,
				dblRefundRate = RCat.dblRefundRate,
				strPurchaseSale = PCat.strPurchaseSale,
				dblVolume = RCat.dblVolume
		FROM tblPATRefundCategory RCat
		INNER JOIN tblPATPatronageCategory PCat
			ON RCat.intPatronageCategoryId = PCat.intPatronageCategoryId
	) RCatPCat
		ON RCatPCat.intRefundCustomerId = RCus.intRefundCustomerId
WHERE R.intRefundId = @intRefundId AND RCus.ysnEligibleRefund = 1

SELECT	intRefundId, 
		intFiscalYearId, 
		intRefundTypeId,
		dtmRefundDate, 
		strRefund,
		dblMinimumRefund, 
		dblServiceFee,		   
		dblCashCutoffAmount, 
		dblFedWithholdingPercentage, 
		dblPurchaseVolume = SUM(dblPurchaseVolume), 
		dblSaleVolume = SUM(dblSaleVolume), 
		dblLessFWT = SUM(dblLessFWT), 
		dblLessService = SUM(dblLessService),
		dblCheckAmount = SUM(dblCheckAmount),
		ysnPosted,
		intCustomerId,
		strStockStatus,
		ysnEligibleRefund,
		ysnQualified, 
		dblRefundAmount = SUM(dblRefundAmount),
		dblCashRefund = SUM(dblCashRefund),
		dblEquityRefund = SUM(dblEquityRefund),
		dblRefundRate = SUM(dblRefundRate), 
		dblVolume = SUM(dblVolume)
INTO #tmpRefundDataCombined
FROM #tmpRefundData
GROUP BY	intCustomerId,
			intRefundTypeId,
			intRefundId,
			intFiscalYearId,
			dtmRefundDate,
			strRefund,
			dblMinimumRefund, 
			dblServiceFee,		   
			dblCashCutoffAmount, 
			dblFedWithholdingPercentage,
			ysnPosted,
			strStockStatus,
			ysnEligibleRefund,
			ysnQualified

SELECT @totalRecords = COUNT(*) FROM #tmpRefundDataCombined	

COMMIT TRANSACTION --COMMIT inserted invalid transaction


IF(@totalRecords = 0)  
BEGIN
	SET @success = 0
	GOTO Post_Exit
END


IF (@ysnPosted = 1)
BEGIN
	--=====================================================================================================================================
	-- 	UPDATE CUSTOMER VOLUME TABLE
	---------------------------------------------------------------------------------------------------------------------------------------
	SELECT DISTINCT intCustomerId FROM #tmpRefundDataCombined
	UPDATE CVol
	SET CVol.dtmLastActivityDate = GETDATE(), CVol.ysnRefundProcessed = ISNULL(@ysnPosted,1)
	FROM tblPATCustomerVolume CVol
	WHERE CVol.intFiscalYear = @intFiscalYearId AND CVol.intCustomerPatronId IN (SELECT DISTINCT intCustomerId FROM #tmpRefundDataCombined)
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
	   SET ysnPosted = ISNULL(@ysnPosted,1)
	  FROM tblPATRefund R
	 WHERE R.intRefundId = @intRefundId


DECLARE @validRefundIds NVARCHAR(MAX)

-- CREATE TEMP GL ENTRIES
SELECT DISTINCT @validRefundIds = COALESCE(@validRefundIds + ',', '') +  CONVERT(VARCHAR(12),intRefundId)
FROM #tmpRefundData
ORDER BY 1

DECLARE @dblDiff NUMERIC(18,6)
DECLARE @intAdjustmentId INT

IF ISNULL(@ysnPosted,0) = 1
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnPATCreateRefundGLEntries(@validRefundIds, @intUserId, @intAPClearingId)

---------------------FORCE BALANCING------------------------------------------------
--check out of balance 
--offset discrepancy
SELECT @dblDiff = SUM(dblDebit) - SUM(dblCredit) FROM @GLEntries
-- long term, there has to be a setup for adjustment
-- for now, we adjust by force :)
IF @dblDiff <> 0
BEGIN
	IF @dblDiff <0 -- credit is higher than debit
		BEGIN
			WITH UpdateListView AS (
				SELECT TOP 1 *
				FROM @GLEntries 
				WHERE strTransactionType = 'General Reserve' 
				AND dblDebit >0
			)
			UPDATE UpdateListView
			SET dblDebit = dblDebit + ABS(@dblDiff)
				
		END
	ELSE -- debit is higher than credit
		BEGIN
			WITH UpdateListView AS (
				SELECT TOP 1 *
				FROM @GLEntries 
				WHERE strTransactionType = 'Undistributed Equity' 
				AND dblCredit > 0
			)
			UPDATE UpdateListView
			SET dblCredit = dblCredit + ABS(@dblDiff)
				
		END

END
----------------------------------------------------------------------------------

END
ELSE
BEGIN
	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnPATReverseGLRefundEntries(@validRefundIds, DEFAULT, @intUserId)

---------------------FORCE BALANCING REVERSE--------------------------------------
--check out of balance 
--offset discrepancy
SELECT @dblDiff = SUM(dblCredit) - SUM(dblDebit) FROM @GLEntries
-- long term, there has to be a setup for adjustment
-- for now, we adjust by force :)
IF @dblDiff <> 0
BEGIN
	IF @dblDiff <0 -- debit is higher than debit
		BEGIN
			WITH UpdateListView AS (
				SELECT TOP 1 *
				FROM @GLEntries 
				WHERE strTransactionType = 'General Reserve' 
				AND dblCredit > 0
			)
			UPDATE UpdateListView
			SET dblCredit = dblCredit + ABS(@dblDiff)
				
		END
	ELSE -- credit is higher than credit
		BEGIN
			WITH UpdateListView AS (
				SELECT TOP 1 *
				FROM @GLEntries 
				WHERE strTransactionType = 'Undistributed Equity' 
				AND dblDebit >0
			)
			UPDATE UpdateListView
			SET dblDebit = dblDebit + ABS(@dblDiff)
				
		END

END
----------------------------------------------------------------------------------

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

--=====================================================================================================================================
-- 	UPDATE CUSTOMER EQUITY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRY
	MERGE tblPATCustomerEquity AS EQ
	USING (SELECT * FROM #tmpRefundDataCombined WHERE intRefundId = @intRefundId) AS B
		ON (EQ.intCustomerId = B.intCustomerId AND EQ.intFiscalYearId = B.intFiscalYearId AND EQ.intRefundTypeId = B.intRefundTypeId)
		--WHEN MATCHED AND B.ysnPosted = 0 AND EQ.dblEquity = B.dblVolume -- is this correct? dblVolume
		--	THEN DELETE
		WHEN MATCHED
			THEN UPDATE SET EQ.dblEquity = CASE WHEN @ysnPosted = 1 THEN EQ.dblEquity + B.dblEquityRefund ELSE EQ.dblEquity - B.dblEquityRefund END,
			EQ.dtmLastActivityDate = GETDATE()
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity, dtmLastActivityDate, intConcurrencyId)
				VALUES (B.intCustomerId, B.intFiscalYearId , 'Undistributed', B.intRefundTypeId, B.dblEquityRefund, GETDATE(), 1);

	IF (@ysnPosted = 0)
	BEGIN
		----------------------------------REVERSE VOLUME---------------------------------------------------------------------

		UPDATE CVol
		SET CVol.dtmLastActivityDate = GETDATE(), CVol.ysnRefundProcessed = ISNULL(@ysnPosted, 0)
		FROM tblPATCustomerVolume CVol
		WHERE CVol.intFiscalYear = @intFiscalYearId AND CVol.intCustomerPatronId IN (SELECT DISTINCT intCustomerId FROM #tmpRefundData)
		--SELECT	RCus.intCustomerId,
		--RCat.intPatronageCategoryId,
		--Ref.intFiscalYearId, 
		--RCat.dblVolume
		--INTO #tmpCustomerVolume
		--FROM tblPATRefund Ref
		--INNER JOIN tblPATRefundCustomer RCus
		--ON Ref.intRefundId = RCus.intRefundId
		--INNER JOIN tblPATRefundCategory RCat
		--ON RCus.intRefundCustomerId	 = RCat.intRefundCustomerId
		--INNER JOIN tblPATPatronageCategory PCat
		--ON RCat.intPatronageCategoryId = PCat.intPatronageCategoryId
		--INNER JOIN tblARCustomer ARC
		--ON RCus.intCustomerId = ARC.intEntityCustomerId
		--WHERE Ref.intRefundId = @intRefundId

		--IF NOT EXISTS(SELECT * FROM #tmpCustomerVolume)
		--BEGIN
		--	DROP TABLE #tmpCustomerVolume
		--END
		--ELSE
		--BEGIN
		--	MERGE tblPATCustomerVolume AS PAT
		--	USING #tmpCustomerVolume AS B
		--	   ON (PAT.intCustomerPatronId = B.intCustomerId AND PAT.intPatronageCategoryId = B.intPatronageCategoryId AND PAT.intFiscalYear = B.intFiscalYearId)
		--	 WHEN MATCHED
		--		  THEN UPDATE SET PAT.dblVolume = PAT.dblVolume + B.dblVolume, PAT.dtmLastActivityDate = GETDATE()
		--	 WHEN NOT MATCHED BY TARGET
		--		  THEN INSERT (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dtmLastActivityDate, dblVolume, intConcurrencyId)
		--			   VALUES (B.intCustomerId, B.intPatronageCategoryId, B.intFiscalYearId, GETDATE(),  B.dblVolume, 1);

		--	DROP TABLE #tmpCustomerVolume
		--END

		----------------------------------------------------------------------------------------------------------------------------

		--DELETE RCat
		--FROM tblPATRefund Ref
		--INNER JOIN tblPATRefundCustomer RCus
		--ON Ref.intRefundId = RCus.intRefundId
		--INNER JOIN tblPATRefundCategory RCat
		--ON RCus.intRefundCustomerId	 = RCat.intRefundCustomerId
		--INNER JOIN tblPATPatronageCategory PCat
		--ON RCat.intPatronageCategoryId = PCat.intPatronageCategoryId
		--WHERE Ref.intRefundId = @intRefundId

		--DELETE RCus
		--FROM tblPATRefund Ref
		--INNER JOIN tblPATRefundCustomer RCus
		--ON Ref.intRefundId = RCus.intRefundId
		--WHERE Ref.intRefundId = @intRefundId

		--DELETE Ref
		--FROM tblPATRefund Ref
		--WHERE Ref.intRefundId = @intRefundId
	END

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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRefundDataCombined')) DROP TABLE #tmpRefundDataCombined
	--IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCurrentData')) DROP TABLE #tmpCurrentData
END
---------------------------------------------------------------------------------------------------------------------------------------
GO