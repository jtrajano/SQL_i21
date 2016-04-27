﻿CREATE PROCEDURE [dbo].[uspPATPostRefund] 
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

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
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
SELECT	Ref.intRefundId, 
		Ref.intFiscalYearId, 
		Ref.dtmRefundDate, 
		Ref.strRefund,
		Ref.dblMinimumRefund, 
		Ref.dblServiceFee,		   
		Ref.dblCashCutoffAmount, 
		Ref.dblFedWithholdingPercentage, 
		Total.dblPurchaseVolume, 
		Total.dblSaleVolume, 
		dblLessFWT = (Total.dblRate * Total.dblVolume) * (Total.dblCashPayout/100) * (Ref.dblFedWithholdingPercentage/100), 
		dblLessService = (Total.dblRate * Total.dblVolume) * (Total.dblCashPayout/100) * (Ref.dblServiceFee/100),
		dblCheckAmount = (Total.dblRate * Total.dblVolume) * (Total.dblCashPayout/100) - (Total.dblRate * Total.dblVolume) * (Total.dblCashPayout/100) * (Ref.dblFedWithholdingPercentage/100) - (Total.dblRate * Total.dblVolume) * (Total.dblCashPayout/100) * (Ref.dblServiceFee/100),
		dblNoRefund = (CASE WHEN (Total.dblRate * Total.dblVolume) > Ref.dblMinimumRefund THEN 0 ELSE (Total.dblRate * Total.dblVolume) END),
		Ref.ysnPosted,
		RCus.intRefundCustomerId,
		RCus.intCustomerId,
		RCus.strStockStatus,
		RCus.ysnEligibleRefund,
		RCus.intRefundTypeId,
		dblCashPayout = (RCus.dblCashPayout/100),
		RCus.ysnQualified, 
		dblRefundAmount = (CASE WHEN (Total.dblRate * Total.dblVolume) <= Ref.dblMinimumRefund THEN 0 ELSE (Total.dblRate * Total.dblVolume) END),
		dblCashRefund = (Total.dblRate * Total.dblVolume) * (Total.dblCashPayout/100),
		RCus.dblEquityRefund,
		RCat.intRefundCategoryId,
		RCat.dblRefundRate, 
		Total.dblVolume
INTO #tmpRefundData
FROM tblPATRefund Ref
LEFT JOIN tblPATRefundCustomer RCus
ON Ref.intRefundId = RCus.intRefundId
LEFT JOIN tblPATRefundCategory RCat
ON RCus.intRefundCustomerId = RCat.intRefundCustomerId
INNER JOIN tblPATCustomerVolume CVol
ON CVol.intCustomerPatronId = RCus.intCustomerId
INNER JOIN
(
	select
		Cus.intCustomerId,
		Cus.dblPurchaseVolume,
		Cus.dblSaleVolume,
		Cus.dblRate,
		dblVolume = Cus.dblPurchaseVolume + Cus.dblSaleVolume,
		RCus.dblCashRefund,
		RCus.dblEquityRefund,
		RCus.dblCashPayout,
		RCus.dblRefundAmount,
		Cus.intRefundCategoryId
	from tblPATRefundCustomer RCus
	inner join
	(
		select distinct CVol.intCustomerPatronId AS intCustomerId,
						dblPurchaseVolume = SUM(CASE WHEN PCat.strPurchaseSale = 'Purchase' THEN (CVol.dblVolume * (case when RRD.strPurchaseSale = 'Purchase' then RRD.dblRate else 0.00 end))ELSE 0 END),
						dblSaleVolume = SUM(CASE WHEN PCat.strPurchaseSale = 'Sale' THEN (CVol.dblVolume * (case when RRD.strPurchaseSale = 'Sale' then RRD.dblRate else 0.00 end)) ELSE 0 END),
						dblRate = SUM(RRD.dblRate),
						intRefundCategoryId = (CASE WHEN RCat.intRefundCustomerId = (CASE WHEN RCus.intRefundTypeId = RRD.intRefundTypeId THEN RCus.intRefundCustomerId ELSE null END) THEN RCat.intRefundCategoryId ELSE null END),
						intRefundCustomerId = (CASE WHEN RCus.intRefundTypeId = RRD.intRefundTypeId THEN RCus.intRefundCustomerId ELSE null END)
		from tblPATCustomerVolume CVol
		inner join tblPATPatronageCategory PCat
		on CVol.intPatronageCategoryId = PCat.intPatronageCategoryId
		inner join tblPATRefundRateDetail RRD
		on PCat.intPatronageCategoryId = RRD.intPatronageCategoryId
		inner join tblPATRefundCustomer RCus
		on RCus.intCustomerId = CVol.intCustomerPatronId
		inner join tblPATRefundCategory RCat
		on RCus.intRefundCustomerId = RCat.intRefundCustomerId
		where intRefundCategoryId is not null
		GROUP BY	CVol.intCustomerPatronId, 
					PCat.strPurchaseSale,
					RCat.dblRefundAmount,
					RCus.intRefundCustomerId,RCus.intRefundTypeId,RRD.intRefundTypeId,RCat.intRefundCategoryId,RCat.intRefundCustomerId
	) Cus
	on RCus.intRefundCustomerId = Cus.intRefundCustomerId AND Cus.intRefundCustomerId is not null
) Total
ON CVol.intCustomerPatronId = Total.intCustomerId AND Total.intRefundCategoryId is not null AND RCat.intRefundCategoryId = Total.intRefundCategoryId
GROUP BY
		Ref.intRefundId, 
		Ref.intFiscalYearId, 
		Ref.dtmRefundDate, 
		Ref.strRefund,
		Ref.dblMinimumRefund, 
		Ref.dblServiceFee,		   
		Ref.dblCashCutoffAmount, 
		Ref.dblFedWithholdingPercentage, 
		Total.dblPurchaseVolume, 
		Total.dblSaleVolume, 
		Total.dblRate,
		Ref.dblLessFWT, 
		Ref.dblLessService,
		Ref.dblNoRefund,
		Ref.ysnPosted,
		RCus.intRefundCustomerId,
		RCus.intCustomerId,
		RCus.strStockStatus,
		RCus.ysnEligibleRefund,
		RCus.intRefundTypeId,
		RCus.dblCashPayout,
		RCus.ysnQualified, 
		RCus.dblCashRefund, 
		RCus.dblEquityRefund,
		RCat.intRefundCategoryId,
		RCat.dblRefundRate, 
		Total.dblVolume,
		Total.dblCashPayout,
		Ref.dblCashRefund

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

-- CREATE TEMP GL ENTRIES
SELECT DISTINCT @validRefundIds = COALESCE(@validRefundIds + ',', '') +  CONVERT(VARCHAR(12),intRefundId)
FROM #tmpRefundData
ORDER BY 1

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

--=====================================================================================================================================
-- 	UPDATE CUSTOMER EQUITY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRY

	DECLARE @strCutoffTo NVARCHAR(50) = (SELECT TOP 1 strCutoffTo from tblPATCompanyPreference)

	MERGE tblPATCustomerEquity AS EQ
	USING (SELECT * FROM #tmpRefundData WHERE intRefundId = (SELECT MAX(intRefundId) FROM #tmpRefundData)) AS B
		ON (EQ.intCustomerId = B.intCustomerId AND EQ.intFiscalYearId = B.intFiscalYearId AND EQ.intRefundTypeId = B.intRefundTypeId)
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


--=====================================================================================================================================
-- 	UPDATE REFUND TABLE
---------------------------------------------------------------------------------------------------------------------------------------
	SELECT	TRD.intRefundId as intRefundId, 
			TRD.intFiscalYearId as intFiscalYearId, 
			dblPurchaseVolume = SUM(TRD.dblPurchaseVolume), 
			dblSaleVolume = SUM(TRD.dblSaleVolume), 
			dblEquityRefund = SUM(TRD.dblEquityRefund), 
			dblCashRefund = SUM(TRD.dblCashRefund),
			dblLessFWT = SUM(TRD.dblLessFWT),
			dblLessService = SUM(TRD.dblLessService),
			dblCheckAmount = SUM(TRD.dblCheckAmount),
			dblNoRefund = SUM(TRD.dblNoRefund)
	INTO #tmpCurrentData
	FROM #tmpRefundData TRD
	WHERE intRefundId = (SELECT MAX(intRefundId) FROM #tmpRefundData)
	GROUP BY TRD.intRefundId, TRD.intFiscalYearId;

	UPDATE Ref
	SET Ref.dblPurchaseVolume = CDat.dblPurchaseVolume, 
	Ref.dblSaleVolume = CDat.dblSaleVolume,
	Ref.dblEquityRefund = CDat.dblEquityRefund,
	Ref.dblCashRefund = CDat.dblCashRefund,
	Ref.dblLessFWT = CDat.dblLessFWT,
	Ref.dblLessService = CDat.dblLessService,
	Ref.dblCheckAmount = CDat.dblCheckAmount,
	Ref.dblNoRefund = CDat.dblNoRefund
	FROM tblPATRefund Ref
	INNER JOIN #tmpCurrentData CDat
	ON Ref.intRefundId = CDat.intRefundId

--=====================================================================================================================================
-- 	UPDATE REFUND CATEGORY TABLE
---------------------------------------------------------------------------------------------------------------------------------------

UPDATE RCat
SET RCat.intPatronageCategoryId = CVol.intPatronageCategoryId,
RCat.dblVolume = CVol.dblVolume,
RCat.dblRefundRate = CVol.dblRate
FROM tblPATRefundCategory RCat
INNER JOIN 
(
	select
		Cus.intCustomerId,
		dblVolume = Cus.dblPurchaseVolume + Cus.dblSaleVolume,
		Cus.dblRate,
		Cus.intPatronageCategoryId,
		Cus.intRefundCategoryId,
		Cus.intRefundCustomerId
	from tblPATRefundCustomer RCus
	inner join
	(
		select distinct CVol.intCustomerPatronId AS intCustomerId,
						intRefundCategoryId = (CASE WHEN RCat.intRefundCustomerId = (CASE WHEN RCus.intRefundTypeId = RRD.intRefundTypeId THEN RCus.intRefundCustomerId ELSE null END) THEN RCat.intRefundCategoryId ELSE null END),
						intRefundCustomerId = (CASE WHEN RCus.intRefundTypeId = RRD.intRefundTypeId THEN RCus.intRefundCustomerId ELSE null END),
						PCat.intPatronageCategoryId,
						dblRate = SUM(RRD.dblRate),
						dblPurchaseVolume = (CASE WHEN PCat.strPurchaseSale = 'Purchase' THEN CVol.dblVolume ELSE 0 END),
						dblSaleVolume = (CASE WHEN PCat.strPurchaseSale = 'Sale' THEN CVol.dblVolume ELSE 0 END)
		from tblPATCustomerVolume CVol
		inner join tblPATPatronageCategory PCat
		on CVol.intPatronageCategoryId = PCat.intPatronageCategoryId
		inner join tblPATRefundRateDetail RRD
		on PCat.intPatronageCategoryId = RRD.intPatronageCategoryId
		inner join tblPATRefundCustomer RCus
		on RCus.intCustomerId = CVol.intCustomerPatronId
		inner join tblPATRefundCategory RCat
		on RCus.intRefundCustomerId = RCat.intRefundCustomerId
		where intRefundCategoryId is not null
		GROUP BY	CVol.intCustomerPatronId, 
					PCat.strPurchaseSale,
					RCat.dblRefundAmount,
					CVol.dblVolume,
					RCus.intRefundCustomerId,RCus.intRefundTypeId,RRD.intRefundTypeId,RCat.intRefundCategoryId,RCat.intRefundCustomerId,PCat.intPatronageCategoryId
	) Cus
	on RCus.intRefundCustomerId = Cus.intRefundCustomerId AND Cus.intRefundCustomerId is not null
) CVol
ON RCat.intRefundCategoryId = CVol.intRefundCategoryId
WHERE CVol.dblVolume <> 0.00

--=====================================================================================================================================
-- 	UPDATE CUSTOMER VOLUME TABLE
---------------------------------------------------------------------------------------------------------------------------------------

	UPDATE CVol
	SET CVol.dblVolume = 0.00
	FROM tblPATCustomerVolume CVol
	INNER JOIN #tmpCurrentData
	ON CVol.intFiscalYear = #tmpCurrentData.intFiscalYearId
	WHERE CVol.dblVolume <> 0.00

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
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCurrentData')) DROP TABLE #tmpCurrentData
END
---------------------------------------------------------------------------------------------------------------------------------------
GO