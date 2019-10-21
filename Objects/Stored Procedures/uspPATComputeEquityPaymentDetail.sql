CREATE PROCEDURE [dbo].[uspPATComputeEquityPaymentDetail]
	@intEquityPayId AS INT,
	@customerIds PatronIdTable READONLY,
	@distributionMethod AS INT = NULL, 
	/*
		Types: 
		1 = Equally up to a Year
		2 = By Year
		3 = To Oldest Year Onwards
	*/
	@equityPayout AS NUMERIC(18,6) = NULL,
	@payoutType AS VARCHAR(1) = '%',
	@fiscalYear AS INT = NULL,
	@intCompanyLocationId AS INT
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
	DECLARE @equityPayoutPercent AS NUMERIC(18,6) = dbo.fnDivide(@equityPayout,100);
	DECLARE @customerIdsTransactionTable AS PatronIdTable;
	DECLARE @withholdingPecentage AS NUMERIC(18,6);

	CREATE TABLE #tempCustomerEquity(
		[intCustomerEquityId]		INT NOT NULL,
		[intCustomerPatronId]		INT NOT NULL,
		[intFiscalYearId]			INT NOT NULL,
		[dtmDateFrom]				DATETIME NOT NULL,
		[strEquityType]				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		[intRefundTypeId]			INT NOT NULL,
		[ysnQualified]				BIT NOT NULL,
		[ysnWithholding]			BIT NOT NULL,
		[dblEquityAvailable]		NUMERIC(18,6) NOT NULL DEFAULT(0)
	);

	CREATE TABLE #tempEquityPaySummary (
		[intEquityPaySummaryId]		INT NOT NULL,
		[intCustomerPatronId]		INT NOT NULL,
		[ysnQualified]				BIT NOT NULL,
		[dblEquityAvailable]		NUMERIC(18,6) NOT NULL DEFAULT(0),
		[dblEquityPaid]				NUMERIC(18,6) NOT NULL DEFAULT(0),
		[dblFWT]					NUMERIC(18,6) NOT NULL DEFAULT(0),
		[dblCheckAmount]			NUMERIC(18,6) NOT NULL DEFAULT(0)
	);

	CREATE TABLE #tempEquityDetailGrouped(
		[intCustomerEquityId]		INT NOT NULL,
		[intEquityPaySummaryId]		INT NOT NULL,
		[intRowNo]					INT NOT NULL,
		[intCustomerId]				INT NOT NULL,
		[intFiscalYearId]			INT NOT NULL,
		[strEquityType]				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		[intRefundTypeId]			INT NOT NULL,
		[ysnQualified]				BIT NOT NULL,
		[dblEquityAvailable]		NUMERIC(18,6) DEFAULT 0,
		[dblEquityToPay]			NUMERIC(18,6) DEFAULT 0,
	);
	----------------------------------------------
	----- END - DECLARE TABLES AND VARIABLES -----
	----------------------------------------------


	--------------------------------------------------------------
	----- BEGIN - COMPUTE RECORDS FOR tblPATEquityPaySummary -----
	--------------------------------------------------------------
	/* BEGIN - Get Customers to process from equity table */
	IF NOT EXISTS(SELECT * FROM @customerIds)
	BEGIN
		INSERT INTO @customerIdsTransactionTable
		SELECT DISTINCT intCustomerId
		FROM tblPATCustomerEquity
	END
	ELSE
	BEGIN
		INSERT INTO @customerIdsTransactionTable
		SELECT DISTINCT intId
		FROM @customerIds
	END
	/* END - Get Customers to process from equity table */

	DELETE FROM tblPATEquityPaySummary
	WHERE intEquityPayId = @intEquityPayId;


	-- Get Withholding Percentage
	SELECT @withholdingPecentage = (dblWithholdPercent/100)
	FROM tblSMCompanyLocation 
	WHERE intCompanyLocationId = @intCompanyLocationId;

	/* BEGIN - Fill #tempCutomerEquity and get the customer equities to process*/
	INSERT INTO #tempCustomerEquity(
		[intCustomerEquityId],
		[intCustomerPatronId],
		[intFiscalYearId],
		[dtmDateFrom],
		[strEquityType],
		[intRefundTypeId],
		[ysnQualified],
		[ysnWithholding],
		[dblEquityAvailable]
	)
	SELECT	CustomerEquity.intCustomerEquityId,
			CustomerEquity.intCustomerId,
			CustomerEquity.intFiscalYearId,
			FiscalYear.dtmDateFrom,
			CustomerEquity.strEquityType,
			CustomerEquity.intRefundTypeId,
			RefundRate.ysnQualified,
			Vendor.ysnWithholding,
			dblEquityAvailable = CustomerEquity.dblEquity - CustomerEquity.dblEquityPaid
	FROM tblPATCustomerEquity CustomerEquity
	INNER JOIN tblAPVendor Vendor
		ON Vendor.intEntityId = CustomerEquity.intCustomerId
	INNER JOIN tblPATRefundRate RefundRate
		ON RefundRate.intRefundTypeId = CustomerEquity.intRefundTypeId
	INNER JOIN (
		SELECT	intFiscalYearId, dtmDateFrom
		FROM tblGLFiscalYear
		WHERE (1 = @distributionMethod AND dtmDateFrom <= (SELECT dtmDateFrom FROM tblGLFiscalYear WHERE intFiscalYearId = @fiscalYear))
			OR (2 = @distributionMethod AND intFiscalYearId = @fiscalYear)
			OR (3 = @distributionMethod)
	) FiscalYear
		ON FiscalYear.intFiscalYearId = CustomerEquity.intFiscalYearId
	WHERE CustomerEquity.intCustomerId IN (SELECT intId FROM @customerIdsTransactionTable)
		AND (CustomerEquity.dblEquity - CustomerEquity.dblEquityPaid) > 0;
	/* END - Fill #tempCutomerEquity and get the customer equities to process*/

	/* BEGIN - Insert Equity Payments to tblPATEquityPaySummary */
	INSERT INTO tblPATEquityPaySummary(
		intEquityPayId,
		intCustomerPatronId,
		ysnQualified,
		dblEquityAvailable,
		dblEquityPaid,
		dblFWT,
		dblCheckAmount
	)
	SELECT	@intEquityPayId,
			ComputedEquity.intCustomerPatronId,
			ComputedEquity.ysnQualified,
			ComputedEquity.dblEquityAvailable,
			dblEquityPaid	= CASE 
								WHEN @payoutType = '%' THEN  dbo.fnMultiply(ComputedEquity.dblEquityAvailable, @equityPayoutPercent)
								ELSE @equityPayout
							END,
			dblFWT			= CASE 
								WHEN @payoutType = '%' THEN dbo.fnMultiply(
																dbo.fnMultiply(ComputedEquity.dblEquityAvailable, @equityPayoutPercent)
																,ComputedEquity.dblWithholdPercent
															)
								ELSE dbo.fnMultiply(@equityPayout, ComputedEquity.dblWithholdPercent)
							END,
			dblCheckAmount	= CASE 
								WHEN @payoutType = '%' THEN dbo.fnMultiply(ComputedEquity.dblEquityAvailable, @equityPayoutPercent)
															- dbo.fnMultiply(
																dbo.fnMultiply(ComputedEquity.dblEquityAvailable, @equityPayoutPercent)
																,ComputedEquity.dblWithholdPercent
															)
								ELSE @equityPayout - dbo.fnMultiply(@equityPayout, ComputedEquity.dblWithholdPercent)
							END
	FROM (
		SELECT	intCustomerPatronId,
				ysnQualified,
				dblEquityAvailable = SUM(ISNULL(dblEquityAvailable,0)),
				dblWithholdPercent = CASE WHEN ISNULL(ysnWithholding, 0) = 1 THEN @withholdingPecentage ELSE 0 END
		FROM #tempCustomerEquity 
		GROUP BY intCustomerPatronId, ysnQualified, ysnWithholding
	) ComputedEquity
	ORDER BY intCustomerPatronId, ysnQualified
	/* END - Insert Equity Payments to tblPATEquityPaySummary */

	--------------------------------------------------------------
	----- END - COMPUTE RECORDS FOR tblPATEquityPaySummary -------
	--------------------------------------------------------------

	
	--------------------------------------------------------------
	----- BEGIN - COMPUTE RECORDS FRO tblPATEquityPayDetail ------
	--------------------------------------------------------------
	INSERT INTO #tempEquityPaySummary(
		[intEquityPaySummaryId],
		[intCustomerPatronId],
		[ysnQualified],
		[dblEquityAvailable],
		[dblEquityPaid],
		[dblFWT],
		[dblCheckAmount]
	)
	SELECT	intEquityPaySummaryId,
			intCustomerPatronId,
			ysnQualified,
			dblEquityAvailable,
			dblEquityPaid,
			dblFWT,
			dblCheckAmount
	FROM tblPATEquityPaySummary
	WHERE intEquityPayId = @intEquityPayId

	
	IF(@distributionMethod = 1 -- Distribution Method = Equally to Each Year
		OR @distributionMethod = 2) -- Distribution Method = By Year
	BEGIN

		INSERT INTO tblPATEquityPayDetail(
			intEquityPaySummaryId,
			intCustomerEquityId,
			intFiscalYearId,
			strEquityType,
			intRefundTypeId,
			ysnQualified,
			dblEquityAvailable,
			dblEquityPay
		)
		SELECT	EPS.intEquityPaySummaryId,
				tempCE.intCustomerEquityId,
				tempCE.intFiscalYearId,
				tempCE.strEquityType,
				tempCE.intRefundTypeId,
				tempCE.ysnQualified,
				tempCE.dblEquityAvailable,
				tempCustomerEquityPay = CASE 
										WHEN @payoutType = '%' THEN  dbo.fnMultiply(tempCE.dblEquityAvailable, @equityPayoutPercent)
										ELSE dbo.fnDivide(@equityPayout, customerGrouped.CustomerCount)
									END
		FROM #tempCustomerEquity tempCE
		LEFT JOIN #tempEquityPaySummary EPS 
			ON EPS.intCustomerPatronId = tempCE.intCustomerPatronId AND EPS.ysnQualified = tempCE.ysnQualified
		LEFT JOIN (SELECT intCustomerPatronId, ysnQualified, COUNT(intCustomerPatronId) as CustomerCount
					FROM #tempCustomerEquity
					GROUP BY intCustomerPatronId, ysnQualified
		) customerGrouped
			ON EPS.intCustomerPatronId = customerGrouped.intCustomerPatronId AND EPS.ysnQualified = customerGrouped.ysnQualified
		ORDER BY tempCE.intCustomerPatronId, tempCE.ysnQualified, tempCE.dtmDateFrom ASC, tempCE.strEquityType DESC
	END
	ELSE IF(@distributionMethod = 3) -- Distribution Method = To Oldest Year Onwards
	BEGIN

		INSERT INTO #tempEquityDetailGrouped(
			[intCustomerEquityId],
			[intEquityPaySummaryId],
			[intRowNo],
			[intCustomerId],
			[intFiscalYearId],
			[strEquityType],
			[intRefundTypeId],
			[ysnQualified],
			[dblEquityAvailable],
			[dblEquityToPay]
		)
		SELECT	tempCE.intCustomerEquityId,
				EPS.intEquityPaySummaryId,
				ROW_NUMBER() OVER (PARTITION BY tempCE.intCustomerPatronId, tempCE.ysnQualified ORDER BY tempCE.dtmDateFrom) AS [intRowNo],
				tempCE.intCustomerPatronId,
				tempCE.intFiscalYearId,
				tempCE.strEquityType,
				tempCE.intRefundTypeId, 
				tempCE.ysnQualified,
				tempCE.dblEquityAvailable,
				EPS.dblEquityPaid
		FROM #tempCustomerEquity tempCE
		LEFT JOIN #tempEquityPaySummary EPS 
			ON EPS.intCustomerPatronId = tempCE.intCustomerPatronId AND EPS.ysnQualified = tempCE.ysnQualified
		ORDER BY tempCE.intCustomerPatronId , tempCE.ysnQualified, tempCE.dtmDateFrom ASC, tempCE.strEquityType DESC;

		-- Recursion to obtain the remaining equity payment to deduct for the next equity
		WITH SourceEquityPay AS (
			SELECT *
			FROM #tempEquityDetailGrouped
		),
		EquityPayDetail AS (
			SELECT	*, 
					[Remaining] = CAST(dblEquityAvailable - dblEquityToPay AS NUMERIC(18,6))
			FROM SourceEquityPay
			WHERE intRowNo = 1
			UNION ALL
			SELECT	SEP.*,
					[Remaining] = CAST(EPD.Remaining + SEP.dblEquityAvailable AS NUMERIC(18,6))
			FROM EquityPayDetail EPD
			INNER JOIN SourceEquityPay SEP
				ON EPD.intCustomerId = SEP.intCustomerId
					AND EPD.ysnQualified = SEP.ysnQualified 
					AND EPD.intRefundTypeId = EPD.intRefundTypeId
					AND EPD.intRowNo + 1 = SEP.intRowNo

		)

		INSERT INTO tblPATEquityPayDetail(
			intEquityPaySummaryId,
			intCustomerEquityId,
			intFiscalYearId,
			strEquityType,
			intRefundTypeId,
			ysnQualified,
			dblEquityAvailable,
			dblEquityPay
		)
		SELECT	intEquityPaySummaryId,
				intCustomerEquityId,
				intFiscalYearId,
				strEquityType,
				intRefundTypeId,
				ysnQualified,
				dblEquityAvailable,
				dblEquityPay = CASE	
								WHEN Remaining < 0 OR Remaining = 0 THEN dblEquityAvailable
								WHEN Remaining < dblEquityAvailable THEN dblEquityAvailable - Remaining
								ELSE 0
							END
		FROM EquityPayDetail
		ORDER BY intEquityPaySummaryId, intRowNo
	END

	------------------------------------------------------------
	----- END - COMPUTE RECORDS FRO tblPATEquityPayDetail ------
	------------------------------------------------------------

END