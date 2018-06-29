CREATE PROCEDURE [dbo].[uspPATComputeEquityPaymentDetail]
	@customerId AS INT = NULL,
	@qualified AS BIT = 0,
	@distributionMethod AS INT = NULL, -- 1 = Equally to Each Year, 2 = To Oldest Year Onwards
	@equityPayout AS NUMERIC(18,6) = NULL,
	@payoutType AS NVARCHAR(10) = '%'
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @tempEquityDetail TABLE (
		[intId] INT PRIMARY KEY IDENTITY,
		[intCustomerEquityId] INT,
		[intFiscalYearId] INT,
		[strEquityType] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		[intRefundTypeId] INT,
		[dblEquityAvailable] NUMERIC(18,6)
	);

	DECLARE @equityPaymentDetail TABLE(
		[intCustomerEquityId] INT,
		[intFiscalYearId] INT,
		[strFiscalYear] NVARCHAR(5) COLLATE Latin1_General_CI_AS,
		[strEquityType] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		[intRefundTypeId] INT,
		[strRefundType] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		[ysnQualified] BIT,
		[dblEquityAvailable] NUMERIC(18,6) DEFAULT 0,
		[dblEquityPay] NUMERIC(18,6) DEFAULT 0
	);
	
	INSERT INTO @tempEquityDetail
	SELECT	CE.intCustomerEquityId,
			CE.intFiscalYearId,
			CE.strEquityType,
			CE.intRefundTypeId,
			CE.dblEquityAvailable
	FROM (SELECT intCustomerEquityId, 
				intCustomerId,
				intFiscalYearId, 
				strEquityType, 
				intRefundTypeId, 
				dblEquityAvailable = dblEquity - dblEquityPaid
			FROM tblPATCustomerEquity) CE
	INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CE.intFiscalYearId
	INNER JOIN tblPATRefundRate RR
		ON RR.intRefundTypeId = CE.intRefundTypeId
	WHERE CE.intCustomerId = @customerId AND RR.ysnQualified = @qualified AND CE.dblEquityAvailable > 0
	ORDER BY dtmDateFrom ASC;
	

	IF(@distributionMethod = 1)
	BEGIN
		DECLARE @equityPaymentDetailCount INT;
		SELECT @equityPaymentDetailCount = COUNT(*) FROM @tempEquityDetail;
		
		INSERT INTO @equityPaymentDetail 
		SELECT	tempEP.intCustomerEquityId,
				tempEP.intFiscalYearId,
				FY.strFiscalYear,
				tempEP.strEquityType,
				tempEP.intRefundTypeId,
				RR.strRefundType,
				RR.ysnQualified,
				tempEP.dblEquityAvailable,
				dblEquityPay = ROUND(CASE 
										WHEN @payoutType = '%' THEN tempEP.dblEquityAvailable * (@equityPayout/100)
										ELSE @equityPayout / @equityPaymentDetailCount
									END, 2)
		FROM @tempEquityDetail tempEP
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

		IF(@payoutType = '%')
			SELECT @customerEquityPay = ROUND(SUM(dblEquityAvailable) * (@equityPayout/100),2) FROM @tempEquityDetail;
		ELSE
			SET @customerEquityPay = @equityPayout;

		WHILE EXISTS(SELECT 1 FROM @tempEquityDetail)
		BEGIN
			SELECT TOP 1 @selected = tED.intCustomerEquityId FROM @tempEquityDetail tED INNER JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = FY.intFiscalYearId;

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
											CASE WHEN  tempEP.dblEquityAvailable < (@customerEquityPay - @totalPayout) THEN tempEP.dblEquityAvailable ELSE @customerEquityPay - @totalPayout END
									ELSE 0 END,2)
			FROM @tempEquityDetail tempEP
			INNER JOIN tblGLFiscalYear FY
				ON FY.intFiscalYearId = tempEP.intFiscalYearId
			INNER JOIN tblPATRefundRate RR
				ON RR.intRefundTypeId = tempEP.intRefundTypeId
			WHERE tempEP.intCustomerEquityId = @selected

			SELECT @totalPayout = (@totalPayout + tEP.dblEquityAvailable) FROM @tempEquityDetail tEP WHERE tEP.intCustomerEquityId = @selected;

			DELETE FROM @tempEquityDetail WHERE intCustomerEquityId = @selected;
			SET @selected = 0;

		END
	END

	SELECT * FROM @equityPaymentDetail
END