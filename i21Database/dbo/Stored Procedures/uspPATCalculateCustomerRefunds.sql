CREATE PROCEDURE [dbo].[uspPATCalculateCustomerRefunds]
	@intRefundId INT,
	@customerIds PatronIdTable READONLY
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	------------------------------------------------
	----- BEGIN - DECLARE TABLES AND VARIABLES -----
	------------------------------------------------
	DECLARE @intFiscalYearId AS INT;
	DECLARE @dblMinimumRefund AS NUMERIC(18,6);
	DECLARE @dblServiceFee AS NUMERIC(18,6);
	DECLARE @dblCashCutOff AS NUMERIC(18,6);
	DECLARE @strCutOffTo AS NVARCHAR(10);
	DECLARE @strRefund AS NVARCHAR(5);
	DECLARE @customerIdsTransactionTable PatronIdTable;

	DECLARE @stockStatusTable TABLE(
		[strStockStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	);
	
	
	/* REFUND STAGING TABLE */
	CREATE TABLE #RefundStaging(
		[intRowNo] BIGINT,
		[intCustomerId] INT,
		[strStockStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[intRefundRateId] INT,
		[ysnQualified] BIT,
		[dblRefundRate] NUMERIC(18,6),
		[dblCashPayout] NUMERIC(18,6),
		[intPatronageCategoryId] INT,
		[strPurchaseSale] NVARCHAR(50),
		[dblVolume] NUMERIC(18,6)
	);


	/* tblPATRefundCustomer STAGING TABLE*/
	CREATE TABLE #RefundCustomerStaging(
		[intRefundId] INT,
		[intRowNo] INT,
		[intCustomerId] INT,
		[strStockStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[ysnEligibleRefund] BIT,
		[intRefundRateId] INT,
		[dblCashPayout] NUMERIC(18,6),
		[ysnQualified] BIT,
		[dblRefundAmount] NUMERIC(18,6),
		[dblNonRefundAmount] NUMERIC(18,6),
		[dblCashRefund] NUMERIC(18,6),
		[dblEquityRefund] NUMERIC(18,6)
	)

	/* CREATED REFUND CUSTOMER RECORD */
	CREATE TABLE #RefundCustomerRecord(
		[intRefundCustomerId] INT,
		[intRowNo] INT,
		[intCustomerId] INT,
		[intRefundRateId] INT
	)

	/* VARIABLE ASSIGNMENTS */
	SELECT	@intFiscalYearId = Ref.intFiscalYearId,
			@strRefund = Ref.strRefund,
			@dblMinimumRefund = Ref.dblMinimumRefund,
			@dblServiceFee = Ref.dblServiceFee,
			@dblCashCutOff = Ref.dblCashCutoffAmount,
			@strCutOffTo = ComPref.strCutoffTo
	FROM tblPATRefund Ref
	CROSS JOIN tblPATCompanyPreference ComPref
	WHERE intRefundId = @intRefundId

	IF(@strRefund = 'V')
	BEGIN
		INSERT INTO @stockStatusTable
		VALUES('Voting');
	END
	ELSE IF(@strRefund = 'S')
	BEGIN
		INSERT INTO @stockStatusTable
		VALUES('Voting'), ('Non-Voting');
	END
	ELSE
	BEGIN
		INSERT INTO @stockStatusTable
		VALUES('Voting'), ('Non-Voting'), ('Producer'), ('Other');
	END
	------------------------------------------------
	----- END - DECLARE TABLES AND VARIABLES -----
	------------------------------------------------



	--------------------------------------------------------------
	----- BEGIN - COMPUTE RECORDS FOR tblPATRefundCustomer -------
	--------------------------------------------------------------
	IF NOT EXISTS(SELECT * FROM @customerIds)
	BEGIN
		INSERT INTO @customerIdsTransactionTable
		SELECT DISTINCT intCustomerPatronId
		FROM tblPATCustomerVolume
	END
	ELSE
	BEGIN
		INSERT INTO @customerIdsTransactionTable
		SELECT DISTINCT intId
		FROM @customerIds
	END


	INSERT INTO #RefundStaging(
		[intRowNo],
		[intCustomerId],
		[strStockStatus],
		[intRefundRateId],
		[ysnQualified],
		[dblRefundRate],
		[dblCashPayout],
		[intPatronageCategoryId],
		[strPurchaseSale],
		[dblVolume]
	)
	SELECT	intRowNo = DENSE_RANK() OVER(ORDER BY Volume.intCustomerPatronId ASC, RR.intRefundTypeId ASC),
			Volume.intCustomerPatronId,
			Customer.strStockStatus,
			RR.intRefundTypeId,
			RR.ysnQualified,
			RRD.dblRate,
			RR.dblCashPayout,
			Volume.intPatronageCategoryId,
			PatronageCategory.strPurchaseSale,
			dblVolume = SUM(Volume.dblVolume - Volume.dblVolumeProcessed)
	FROM tblPATCustomerVolume Volume
	INNER JOIN (
		tblPATRefundRate RR INNER JOIN tblPATRefundRateDetail RRD
			ON RR.intRefundTypeId = RRD.intRefundTypeId
	) ON RRD.intPatronageCategoryId = Volume.intPatronageCategoryId
	INNER JOIN tblPATPatronageCategory PatronageCategory
		ON PatronageCategory.intPatronageCategoryId = RRD.intPatronageCategoryId
	INNER JOIN tblARCustomer Customer
		ON Customer.intEntityId = Volume.intCustomerPatronId
	WHERE Volume.dblVolume > Volume.dblVolumeProcessed 
	AND ISNULL(Customer.strStockStatus,'') != ''
	AND Volume.intFiscalYear = @intFiscalYearId
	AND Volume.intCustomerPatronId IN (SELECT [intId] FROM @customerIdsTransactionTable)
	GROUP BY Volume.intCustomerVolumeId,
			Volume.intCustomerPatronId,
			Customer.strStockStatus,
			RR.intRefundTypeId,
			RR.ysnQualified,
			RRD.dblRate,
			RR.dblCashPayout,
			PatronageCategory.strPurchaseSale,
			Volume.intPatronageCategoryId

	

	INSERT INTO #RefundCustomerStaging(
		[intRefundId],
		[intRowNo],
		[intCustomerId], 
		[strStockStatus],
		[ysnEligibleRefund], 
		[intRefundRateId],
		[dblCashPayout],
		[ysnQualified], 
		[dblRefundAmount],
		[dblNonRefundAmount],
		[dblCashRefund],
		[dblEquityRefund]
	)
	SELECT	intRefundId = @intRefundId,
			RefundCustomer.intRowNo,
			RefundCustomer.intCustomerId,
			RefundCustomer.strStockStatus,
			ysnEligibleRefund = CASE 
									WHEN RefundCustomer.ysnInStockStatus = 1 AND RefundCustomer.dblRefundAmount >= @dblMinimumRefund THEN 1
									ELSE 0 
								END,
			RefundCustomer.intRefundRateId,
			RefundCustomer.dblCashPayout,
			RefundCustomer.ysnQualified,
			dblRefundAmount =  CASE 
									WHEN RefundCustomer.ysnInStockStatus = 1 AND RefundCustomer.dblRefundAmount >= @dblMinimumRefund THEN RefundCustomer.dblRefundAmount
									ELSE 0 
								END,
			dblNonRefundAmount = CASE 
									WHEN RefundCustomer.ysnInStockStatus = 1 AND RefundCustomer.dblRefundAmount >= @dblMinimumRefund THEN 0
									ELSE RefundCustomer.dblRefundAmount
								END,
			dblCashRefund = CASE 
									WHEN RefundCustomer.ysnInStockStatus = 1 AND RefundCustomer.dblRefundAmount >= @dblMinimumRefund THEN 
										CASE WHEN RefundCustomer.dblCashRefund <= @dblCashCutOff THEN
												CASE WHEN @strCutOffTo = 'Cash' THEN RefundCustomer.dblRefundAmount ELSE 0 END
											 ELSE RefundCustomer.dblCashRefund
										END
									ELSE 0
								END,
			dblEquityRefund = CASE 
									WHEN RefundCustomer.ysnInStockStatus = 1 AND RefundCustomer.dblRefundAmount >= @dblMinimumRefund THEN 
										CASE WHEN RefundCustomer.dblCashRefund <= @dblCashCutOff THEN
												CASE WHEN @strCutOffTo = 'Equity' THEN RefundCustomer.dblRefundAmount ELSE 0 END
											 ELSE RefundCustomer.dblRefundAmount - RefundCustomer.dblCashRefund
										END
									ELSE 0
								END
	FROM (
		SELECT	intRowNo,
				intCustomerId,
				strStockStatus,
				ysnInStockStatus = CASE 
										WHEN strStockStatus IN(SELECT [strStockStatus] FROM @stockStatusTable) THEN 1
										ELSE 0 
									END,
				intRefundRateId,
				dblCashPayout,
				ysnQualified,
				dblRefundAmount = SUM(ROUND(dblRefundRate * dblVolume,2)),
				dblCashRefund = SUM(ROUND((dblRefundRate * dblVolume) * (dbo.fnDivide(dblCashPayout, 100)),2))
		FROM #RefundStaging
		GROUP BY	intRowNo,
					intCustomerId,
					strStockStatus,
					intRefundRateId,
					dblCashPayout,
					ysnQualified
	) RefundCustomer


	DELETE FROM tblPATRefundCustomer
	WHERE intRefundId = @intRefundId;


	/* INSERT RefundCustomerStaging RECORDS TO tblPATRefundCustomer*/
	MERGE 
	INTO [dbo].[tblPATRefundCustomer]
	USING #RefundCustomerStaging AS SourceData
	ON (1 = 0)
	WHEN NOT MATCHED THEN 
	INSERT (
		[intRefundId],
		[intCustomerId], 
		[strStockStatus],
		[ysnEligibleRefund], 
		[intRefundTypeId],
		[dblCashPayout],
		[ysnQualified], 
		[dblRefundAmount],
		[dblNonRefundAmount],
		[dblCashRefund],
		[dblEquityRefund],
		[intConcurrencyId]
	)
	VALUES(
		SourceData.intRefundId,
		SourceData.intCustomerId,
		SourceData.strStockStatus,
		SourceData.ysnEligibleRefund,
		SourceData.intRefundRateId,
		SourceData.dblCashPayout,
		SourceData.ysnQualified,
		SourceData.dblRefundAmount,
		SourceData.dblNonRefundAmount,
		SourceData.dblCashRefund,
		SourceData.dblEquityRefund,
		1
	)
	OUTPUT
		inserted.intRefundCustomerId,
		SourceData.intRowNo,
		SourceData.intCustomerId,
		SourceData.intRefundRateId
	INTO #RefundCustomerRecord
	;
	--------------------------------------------------------------
	----- END - INSERT RECORDS TO tblPATRefundCustomer -----------
	--------------------------------------------------------------


	--------------------------------------------------------------
	----- BEGIN - INSERT RECORDS TO tblPATRefundCategory ---------
	--------------------------------------------------------------

	INSERT INTO tblPATRefundCategory(
		[intRefundCustomerId], 
		[intPatronageCategoryId], 
		[dblRefundRate],
		[dblVolume],
		[dblRefundAmount],
		[intConcurrencyId]
	)
	SELECT	RefTwo.intRefundCustomerId,
			RefOne.intPatronageCategoryId,
			RefOne.dblRefundRate,
			RefOne.dblVolume,
			dblRefundAmount = ROUND(RefOne.dblRefundRate * RefOne.dblVolume, 2),
			1
	FROM #RefundStaging RefOne
	INNER JOIN #RefundCustomerRecord RefTwo
		ON RefOne.intRowNo = RefTwo.intRowNo
		AND RefOne.intCustomerId = RefTwo.intCustomerId
		AND RefOne.intRefundRateId = RefTwo.intRefundRateId
	--------------------------------------------------------------
	----- END - INSERT RECORDS TO tblPATRefundCategory -----------
	--------------------------------------------------------------

END