CREATE PROCEDURE [dbo].[uspPATComputeEquityPaymentDetail]
	@equityIds AS NVARCHAR(MAX) = NULL,
	@customerId AS INT = NULL,
	@distributionMethod AS INT = NULL, -- 1 = Equally to Each Year, 2 = To Oldest Year Onwards
	@equityPayout AS NUMERIC(18,6) = NULL
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @customerIdsTable TABLE (
		[intTransactionId] INT PRIMARY KEY,
		UNIQUE([intTransactionId])
	);

	DECLARE @equityPaymentDetail TABLE(
		[intCustomerEquityId] INT,
		[intFiscalYearId] INT,
		[strFiscalYear] NVARCHAR(5),
		[strEquityType] NVARCHAR(50),
		[intRefundTypeId] INT,
		[strRefundType] NVARCHAR(50),
		[ysnQualified] BIT,
		[dblEquityAvailable] NUMERIC(18,6) DEFAULT 0,
		[dblEquityPay] NUMERIC(18,6) DEFAULT 0
	);

	INSERT INTO @customerIdsTable SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@equityIds);

	SELECT	CE.intCustomerEquityId,
			CE.intFiscalYearId,
			CE.strEquityType,
			CE.intRefundTypeId,
			dblEquityAvailable = CE.dblEquity - CE.dblEquityPaid
	INTO #tempEquityDetails
	FROM tblPATCustomerEquity CE
	WHERE CE.intCustomerEquityId IN (SELECT intTransactionId FROM @customerIdsTable) AND CE.intCustomerId = @customerId

	

	IF(@distributionMethod = 1)
	BEGIN
		INSERT INTO @equityPaymentDetail 
		SELECT	tempEP.intCustomerEquityId,
				tempEP.intFiscalYearId,
				FY.strFiscalYear,
				tempEP.strEquityType,
				tempEP.intRefundTypeId,
				RR.strRefundType,
				RR.ysnQualified,
				tempEP.dblEquityAvailable,
				dblEquityPay = ROUND(tempEP.dblEquityAvailable * (@equityPayout/100),2)
		FROM #tempEquityDetails tempEP
		INNER JOIN tblGLFiscalYear FY
			ON FY.intFiscalYearId = tempEP.intFiscalYearId
		INNER JOIN tblPATRefundRate RR
			ON RR.intRefundTypeId = tempEP.intRefundTypeId
	END
	ELSE
	BEGIN
		DECLARE @totalPayout NUMERIC(18,6) = 0;
		DECLARE @customerEquityPay NUMERIC (18,6) = 0;
		DECLARE @selected INT;

		SELECT @customerEquityPay = (SUM(dblEquityAvailable) * (@equityPayout/100)) FROM #tempEquityDetails;

		WHILE EXISTS(SELECT 1 FROM #tempEquityDetails)
		BEGIN
			SELECT TOP 1 @selected = tED.intCustomerEquityId FROM #tempEquityDetails tED INNER JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = FY.intFiscalYearId ORDER BY FY.dtmDateFrom ASC;

			INSERT INTO @equityPaymentDetail 
			SELECT	tempEP.intCustomerEquityId,
					tempEP.intFiscalYearId,
					FY.strFiscalYear,
					tempEP.strEquityType,
					tempEP.intRefundTypeId,
					RR.strRefundType,
					RR.ysnQualified,
					tempEP.dblEquityAvailable,
					dblEquityPay =	ROUND(CASE WHEN @totalPayout < @customerEquityPay THEN 
											CASE WHEN  tempEP.dblEquityAvailable < @customerEquityPay THEN tempEP.dblEquityAvailable ELSE @customerEquityPay - @totalPayout END
									ELSE 0 END,2)
			FROM #tempEquityDetails tempEP
			INNER JOIN tblGLFiscalYear FY
				ON FY.intFiscalYearId = tempEP.intFiscalYearId
			INNER JOIN tblPATRefundRate RR
				ON RR.intRefundTypeId = tempEP.intRefundTypeId
			WHERE tempEP.intCustomerEquityId = @selected

			SELECT @totalPayout = (@totalPayout + tEP.dblEquityAvailable) FROM #tempEquityDetails tEP WHERE tEP.intCustomerEquityId = @selected;

			DELETE FROM #tempEquityDetails WHERE intCustomerEquityId = @selected;
			SET @selected = 0;

		END
	END

	DROP TABLE #tempEquityDetails
	
	SELECT * FROM @equityPaymentDetail
END