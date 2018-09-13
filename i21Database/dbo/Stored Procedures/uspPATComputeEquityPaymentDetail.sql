CREATE PROCEDURE [dbo].[uspPATComputeEquityPaymentDetail]
	@intEquityPayId AS INT,
	@customerIds PatronIdTable READONLY,
	@distributionMethod AS INT = NULL, -- 1 = Equally to Each Year, 2 = To Oldest Year Onwards
	@equityPayout AS NUMERIC(18,6) = NULL,
	@payoutType AS VARCHAR(1) = '%',
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
	DECLARE @customerIdsTransactionTable PatronIdTable;


	CREATE TABLE #tempEquityPaySummary (
		[intEquityPaySummaryId]		INT NOT NULL,
		[intCustomerPatronId]		INT NOT NULL,
		[ysnQualified]				BIT NOT NULL,
		[dblEquityAvailable]		NUMERIC(18,6) NOT NULL DEFAULT(0),
		[dblEquityPaid]				NUMERIC(18,6) NOT NULL DEFAULT(0),
		[dblFWT]					NUMERIC(18,6) NOT NULL DEFAULT(0),
		[dblCheckAmount]			NUMERIC(18,6) NOT NULL DEFAULT(0)
	)

	CREATE TABLE #tempEquityDetailGrouped(
		[intCustomerEquityId]		INT NOT NULL,
		[intEquityPaySummaryId]		INT NOT NULL,
		[intRowNo]					INT NOT NULL,
		[intCustomerId]				INT NOT NULL,
		[intFiscalYearId]			INT NOT NULL,
		[strFiscalYear]				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		[strEquityType]				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		[intRefundTypeId]			INT NOT NULL,
		[ysnQualified]				BIT NOT NULL,
		[dblEquityAvailable]		NUMERIC(18,6) DEFAULT 0,
		[dblEquityToPay]			NUMERIC(18,6) DEFAULT 0,
	)
	----------------------------------------------
	----- END - DECLARE TABLES AND VARIABLES -----
	----------------------------------------------


	--------------------------------------------------------------
	----- BEGIN - COMPUTE RECORDS FOR tblPATEquityPaySummary -----
	--------------------------------------------------------------

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

	DELETE FROM tblPATEquityPaySummary
	WHERE intEquityPayId = @intEquityPayId;

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
	FROM (SELECT	intCustomerPatronId,
					ysnQualified,
					dblEquityAvailable	= SUM(ISNULL(dblEquityAvailable,0)),
					dblWithholdPercent	
			FROM vyuPATComputeEquityPayment
			WHERE intCustomerPatronId IN (SELECT intId FROM @customerIdsTransactionTable)
				AND intCompanyLocationId = @intCompanyLocationId 
			GROUP BY intCustomerPatronId, ysnQualified, dblWithholdPercent
	) ComputedEquity
	ORDER BY intCustomerPatronId, ysnQualified
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

	
	IF(@distributionMethod = 1) -- Distribution Method = Equally to Each Year
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
		FROM (SELECT	intCustomerEquityId, 
						intCustomerId,
						FY.intFiscalYearId, 
						FY.dtmDateFrom,
						strEquityType, 
						RR.intRefundTypeId, 
						RR.ysnQualified,
						dblEquityAvailable = dblEquity - dblEquityPaid
				FROM tblPATCustomerEquity CE
				INNER JOIN tblGLFiscalYear FY
					ON FY.intFiscalYearId = CE.intFiscalYearId
				INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = CE.intRefundTypeId
				WHERE (dblEquity - dblEquityPaid) > 0 AND CE.intCustomerId IN (SELECT intId FROM @customerIdsTransactionTable)
		) tempCE
		LEFT JOIN #tempEquityPaySummary EPS 
			ON EPS.intCustomerPatronId = tempCE.intCustomerId AND EPS.ysnQualified = tempCE.ysnQualified
		LEFT JOIN (SELECT CE.intCustomerId, RR.ysnQualified, COUNT(intCustomerId) as CustomerCount
					FROM tblPATCustomerEquity CE
					INNER JOIN tblPATRefundRate RR ON CE.intRefundTypeId = RR.intRefundTypeId
					WHERE CE.intCustomerId IN (SELECT intId FROM @customerIdsTransactionTable)
					GROUP BY CE.intCustomerId, RR.ysnQualified
		) customerGrouped
			ON EPS.intCustomerPatronId = customerGrouped.intCustomerId AND EPS.ysnQualified = customerGrouped.ysnQualified
		ORDER BY tempCE.intCustomerId, tempCE.ysnQualified, tempCE.dtmDateFrom ASC, tempCE.strEquityType DESC
	END
	ELSE IF(@distributionMethod = 2) -- Distribution Method = To Oldest Year Onwards
	BEGIN

		INSERT INTO #tempEquityDetailGrouped(
			[intCustomerEquityId],
			[intEquityPaySummaryId],
			[intRowNo],
			[intCustomerId],
			[intFiscalYearId],
			[strFiscalYear],
			[strEquityType],
			[intRefundTypeId],
			[ysnQualified],
			[dblEquityAvailable],
			[dblEquityToPay]
		)
		SELECT	tempCE.intCustomerEquityId,
				EPS.intEquityPaySummaryId,
				ROW_NUMBER() OVER (PARTITION BY tempCE.intCustomerId, tempCE.ysnQualified ORDER BY tempCE.dtmDateFrom) AS [intRowNo],
				tempCE.intCustomerId,
				tempCE.intFiscalYearId,
				tempCE.strFiscalYear,
				tempCE.strEquityType,
				tempCE.intRefundTypeId, 
				tempCE.ysnQualified,
				tempCE.dblEquityAvailable,
				EPS.dblEquityPaid
		FROM (SELECT	intCustomerEquityId, 
						intCustomerId,
						FY.intFiscalYearId, 
						FY.strFiscalYear,
						FY.dtmDateFrom,
						strEquityType, 
						RR.intRefundTypeId, 
						RR.ysnQualified,
						dblEquityAvailable = dblEquity - dblEquityPaid
				FROM tblPATCustomerEquity CE
				INNER JOIN tblGLFiscalYear FY
					ON FY.intFiscalYearId = CE.intFiscalYearId
				INNER JOIN tblPATRefundRate RR
					ON RR.intRefundTypeId = CE.intRefundTypeId
				WHERE (CE.dblEquity - CE.dblEquityPaid) > 0 AND CE.intCustomerId IN (SELECT intId FROM @customerIdsTransactionTable)
		) tempCE
		LEFT JOIN #tempEquityPaySummary EPS 
			ON EPS.intCustomerPatronId = tempCE.intCustomerId AND EPS.ysnQualified = tempCE.ysnQualified
		ORDER BY tempCE.intCustomerId, tempCE.ysnQualified, tempCE.dtmDateFrom ASC, tempCE.strEquityType DESC;


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