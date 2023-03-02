﻿CREATE PROCEDURE [dbo].[uspCMGenerateLGCashFlow]
(
	@tblRateTypeFilters CMCashFlowReportFilterRateTypeTable READONLY,
	@tblRateFilters CMCashFlowReportFilterRateTable READONLY,
	@intCashFlowReportId INT,
	@dtmReportDate DATETIME,
	@intReportingCurrencyId INT,
	@intBankId INT = NULL,
	@intBankAccountId INT = NULL,
	@intCompanyLocationId INT = NULL
)
AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	DECLARE
		@dblBucket1 NUMERIC(18, 6) = 0,
		@dblBucket2 DECIMAL(18, 6) = 0,
		@dblBucket3 DECIMAL(18, 6) = 0,
		@dblBucket4 DECIMAL(18, 6) = 0,
		@dblBucket5 DECIMAL(18, 6) = 0,
		@dblBucket6 DECIMAL(18, 6) = 0,
		@dblBucket7 DECIMAL(18, 6) = 0,
		@dblBucket8 DECIMAL(18, 6) = 0,
		@dblBucket9 DECIMAL(18, 6) = 0,
		@strTransactionType NVARCHAR(20)

	SET @strTransactionType = 'Outbound Shipment'

	START_PROCESS:

	IF @strTransactionType IS NULL
		GOTO END_PROCESS

	INSERT INTO tblCMCashFlowReportSummaryDetail (
		[intCashFlowReportId]
		,[intTransactionId]
		,[strTransactionId]
		,[strTransactionType]
		,[dtmTransactionDate]
		,[dblBucket1]
		,[dblBucket2]
		,[dblBucket3]
		,[dblBucket4]
		,[dblBucket5]
		,[dblBucket6]
		,[dblBucket7]
		,[dblBucket8]
		,[dblBucket9]
		,[intCurrencyId]
		,[intReportingCurrencyId]
		,[intCurrencyExchangeRateTypeId]
		,[dblRate]
		,[intAccountId]
		,[intBankAccountId]
		,[intCompanyLocationId]
		,[intConcurrencyId]
	)
	-- Bucket Current
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		dblAmount * RateFilter.dblRateBucket1,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket1,
		RateFilter.dblRateBucket1,
		intGLAccountId,
		intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnLGCashFlowTransactions](NULL, @dtmReportDate)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intBankAccountId IS NULL
				THEN 1
				ELSE CASE WHEN intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
				END
		) = 1
		AND
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND ysnPosted = 1
		AND strTransactionType = @strTransactionType

	-- Bucket 1 - 7
	UNION ALL
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		0,
		(dblAmount * RateFilter.dblRateBucket2),
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket2,
		RateFilter.dblRateBucket2,
		intGLAccountId,
		intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnLGCashFlowTransactions](DATEADD(DAY, 1, @dtmReportDate), DATEADD(DAY, 7, @dtmReportDate))
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intBankAccountId IS NULL
				THEN 1
				ELSE CASE WHEN intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
				END
		) = 1
		AND
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND ysnPosted = 1
		AND strTransactionType = @strTransactionType

	-- Bucket 8 - 14
	UNION ALL
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		0,
		0,
		(dblAmount * RateFilter.dblRateBucket3),
		0,
		0,
		0,
		0,
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket3,
		RateFilter.dblRateBucket3,
		intGLAccountId,
		intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnLGCashFlowTransactions](DATEADD(DAY, 8, @dtmReportDate), DATEADD(DAY, 14, @dtmReportDate))
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intBankAccountId IS NULL
				THEN 1
				ELSE CASE WHEN intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
				END
		) = 1
		AND
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND ysnPosted = 1
		AND strTransactionType = @strTransactionType

	-- Bucket 15 - 21
	UNION ALL
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		0,
		0,
		0,
		(dblAmount * RateFilter.dblRateBucket4),
		0,
		0,
		0,
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket4,
		RateFilter.dblRateBucket4,
		intGLAccountId,
		intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnLGCashFlowTransactions](DATEADD(DAY, 15, @dtmReportDate), DATEADD(DAY, 21, @dtmReportDate))
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intBankAccountId IS NULL
				THEN 1
				ELSE CASE WHEN intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
				END
		) = 1
		AND
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND ysnPosted = 1
		AND strTransactionType = @strTransactionType

	-- Bucket 22 - 29
	UNION ALL
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		0,
		0,
		0,
		0,
		(dblAmount * RateFilter.dblRateBucket5),
		0,
		0,
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket5,
		RateFilter.dblRateBucket5,
		intGLAccountId,
		intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnLGCashFlowTransactions](DATEADD(DAY, 22, @dtmReportDate), DATEADD(DAY, 29, @dtmReportDate))
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intBankAccountId IS NULL
				THEN 1
				ELSE CASE WHEN intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
				END
		) = 1
		AND
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND ysnPosted = 1
		AND strTransactionType = @strTransactionType

	-- Bucket 30 - 60
	UNION ALL
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		0,
		0,
		0,
		0,
		0,
		(dblAmount * RateFilter.dblRateBucket6),
		0,
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket6,
		RateFilter.dblRateBucket6,
		intGLAccountId,
		intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnLGCashFlowTransactions](DATEADD(DAY, 30, @dtmReportDate), DATEADD(DAY, 60, @dtmReportDate))
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intBankAccountId IS NULL
				THEN 1
				ELSE CASE WHEN intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
				END
		) = 1
		AND
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND ysnPosted = 1
		AND strTransactionType = @strTransactionType
	
	-- Bucket 60 - 90
	UNION ALL
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		0,
		0,
		0,
		0,
		0,
		0,
		(dblAmount * RateFilter.dblRateBucket7),
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket7,
		RateFilter.dblRateBucket7,
		intGLAccountId,
		intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnLGCashFlowTransactions](DATEADD(DAY, 61, @dtmReportDate), DATEADD(DAY, 90, @dtmReportDate))
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intBankAccountId IS NULL
				THEN 1
				ELSE CASE WHEN intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
				END
		) = 1
		AND
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND ysnPosted = 1
		AND strTransactionType = @strTransactionType

	-- Bucket 90 - 120
	UNION ALL
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		(dblAmount * RateFilter.dblRateBucket8),
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket8,
		RateFilter.dblRateBucket8,
		intGLAccountId,
		intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnLGCashFlowTransactions](DATEADD(DAY, 91, @dtmReportDate), DATEADD(DAY, 120, @dtmReportDate))
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intBankAccountId IS NULL
				THEN 1
				ELSE CASE WHEN intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
				END
		) = 1
		AND
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND ysnPosted = 1
		AND strTransactionType = @strTransactionType

	-- Bucket 120+
	UNION ALL
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		(dblAmount * RateFilter.dblRateBucket9),
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket9,
		RateFilter.dblRateBucket9,
		intGLAccountId,
		intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnLGCashFlowTransactions](DATEADD(DAY, 121, @dtmReportDate), DATEADD(DAY, 3650, @dtmReportDate))
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intBankAccountId IS NULL
				THEN 1
				ELSE CASE WHEN intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
				END
		) = 1
		AND
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND ysnPosted = 1
		AND strTransactionType = @strTransactionType

	-- Get sum of each bucket
	SELECT 
		@dblBucket1 = ISNULL(SUM(dblBucket1), 0),
		@dblBucket2 = ISNULL(SUM(dblBucket2), 0), 
		@dblBucket3 = ISNULL(SUM(dblBucket3), 0),
		@dblBucket4 = ISNULL(SUM(dblBucket4), 0),
		@dblBucket5 = ISNULL(SUM(dblBucket5), 0),
		@dblBucket6 = ISNULL(SUM(dblBucket6), 0),
		@dblBucket7 = ISNULL(SUM(dblBucket7), 0),
		@dblBucket8 = ISNULL(SUM(dblBucket8), 0),
		@dblBucket9 = ISNULL(SUM(dblBucket9), 0)
	FROM tblCMCashFlowReportSummaryDetail 
	WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

	-- Insert sum of buckets to report summary table
	INSERT INTO tblCMCashFlowReportSummary
	(
		dtmReportDate,
		intReportingCurrencyId,
		intBankAccountId,
		intCompanyLocationId,
		dblTotal,
		dblBucket1,
		dblBucket2,
		dblBucket3,
		dblBucket4,
		dblBucket5,
		dblBucket6,
		dblBucket7,
		dblBucket8,
		dblBucket9,
		intCashFlowReportId,
		intCashFlowReportSummaryCodeId,
		intConcurrencyId
	)
	VALUES (
			@dtmReportDate
		,@intReportingCurrencyId
		,@intBankAccountId
		,@intCompanyLocationId
		,@dblBucket1 + @dblBucket2 + @dblBucket3 + @dblBucket4 + @dblBucket5 + @dblBucket6 + @dblBucket7 + @dblBucket8 + @dblBucket9
		,@dblBucket1
		,@dblBucket2
		,@dblBucket3
		,@dblBucket4
		,@dblBucket5
		,@dblBucket6
		,@dblBucket7
		,@dblBucket8
		,@dblBucket9
		,@intCashFlowReportId
		,CASE WHEN @strTransactionType = 'Outbound Shipment' THEN 4 ELSE 5 END -- Report Code = 4 Total Sales Logistics Shipments; 5 = Total Purchase Logistics Shipments
		,1
	)
		
	DECLARE @intCashFlowReportSummaryId INT
	SELECT @intCashFlowReportSummaryId = CAST(IDENT_CURRENT('dbo.tblCMCashFlowReportSummary') AS INT)

	-- Update the intCashFlowReportSummaryId of drilldown records
	UPDATE tblCMCashFlowReportSummaryDetail
	SET
		intCashFlowReportSummaryId = @intCashFlowReportSummaryId
	WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

	SET @dblBucket1 = 0
	SET @dblBucket2 = 0
	SET @dblBucket3 = 0
	SET	@dblBucket4 = 0
	SET @dblBucket5 = 0
	SET @dblBucket6 = 0
	SET @dblBucket7 = 0
	SET @dblBucket8 = 0
	SET @dblBucket9 = 0

	IF @strTransactionType = 'Outbound Shipment'
		SET @strTransactionType = 'Inbound Shipments'
	ELSE 
		SET @strTransactionType = NULL -- this will end the loop

	GOTO START_PROCESS

END_PROCESS:

END
RETURN 0