CREATE PROCEDURE [dbo].[uspCMGenerateAPCashFlow]
(
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
		@intCurrentAccountId INT,
		@intCurrentBankAccountId INT,
		@strCurrentAccountId NVARCHAR(100),
		@dblBucket1 NUMERIC(18, 6) = 0,
		@dblBucket2 DECIMAL(18, 6) = 0,
		@dblBucket3 DECIMAL(18, 6) = 0,
		@dblBucket4 DECIMAL(18, 6) = 0,
		@dblBucket5 DECIMAL(18, 6) = 0,
		@dblBucket6 DECIMAL(18, 6) = 0,
		@dblBucket7 DECIMAL(18, 6) = 0,
		@dblBucket8 DECIMAL(18, 6) = 0,
		@dblBucket9 DECIMAL(18, 6) = 0

	DECLARE @tblRateFilters TABLE (
		[intFilterCurrencyId]	INT,
		[dblRateBucket1]	NUMERIC(18,6),
		[dblRateBucket2]	NUMERIC(18,6),
		[dblRateBucket3]	NUMERIC(18,6),
		[dblRateBucket4]	NUMERIC(18,6),
		[dblRateBucket5]	NUMERIC(18,6),
		[dblRateBucket6]	NUMERIC(18,6),
		[dblRateBucket7]	NUMERIC(18,6),
		[dblRateBucket8]	NUMERIC(18,6),
		[dblRateBucket9]	NUMERIC(18,6)
	)

	DECLARE @tblRateTypeFilters TABLE(
		intFilterCurrencyId INT,
		intRateTypeBucket1 INT,
		intRateTypeBucket2 INT,
		intRateTypeBucket3 INT,
		intRateTypeBucket4 INT,
		intRateTypeBucket5 INT,
		intRateTypeBucket6 INT,
		intRateTypeBucket7 INT,
		intRateTypeBucket8 INT,
		intRateTypeBucket9 INT
	)

	INSERT INTO @tblRateFilters
	SELECT 
		intFilterCurrencyId,
		dblRateBucket1,
		dblRateBucket2,
		dblRateBucket3,
		dblRateBucket4,
		dblRateBucket5,
		dblRateBucket6,
		dblRateBucket7,
		dblRateBucket8,
		dblRateBucket9
	FROM tblCMCashFlowReportRate
	WHERE intCashFlowReportId = @intCashFlowReportId

	INSERT INTO @tblRateTypeFilters
	SELECT
		intFilterCurrencyId,
		intRateTypeBucket1,
		intRateTypeBucket2,
		intRateTypeBucket3,
		intRateTypeBucket4,
		intRateTypeBucket5,
		intRateTypeBucket6,
		intRateTypeBucket7,
		intRateTypeBucket8,
		intRateTypeBucket9
	FROM tblCMCashFlowReportRateType
	WHERE intCashFlowReportId = @intCashFlowReportId

	/*
		TO DO/IN PROGRESS: Filter by Bank Account
		Insert each transactions of each bucket to the drilldown table	
	*/

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
		-1, -- no specific transactions for Current bucket - it can be thousands/millions of records.
		'Current',
		NULL,
		@dtmReportDate,
		ISNULL(SUM(dblAmount), 0) * RateFilter.dblRateBucket1 * -1,
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
		NULL,
		NULL,
		@intCompanyLocationId,
		1
	FROM [dbo].[fnAPCashFlowTransactions](NULL, NULL)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND dtmDate <= @dtmReportDate
	GROUP BY
		RateFilter.dblRateBucket1,
		intCurrencyId,
		RateTypeFilter.intRateTypeBucket1

	-- Bucket 1 - 7
	UNION ALL
	SELECT
		@intCashFlowReportId,
		intTransactionId,
		strTransactionId,
		strTransactionType,
		dtmDate,
		0,
		(dblAmount * RateFilter.dblRateBucket2) * -1,
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
		NULL, --intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnAPCashFlowTransactions](NULL, NULL)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND dtmDate BETWEEN DATEADD(DAY, 1, @dtmReportDate) AND DATEADD(DAY, 7, @dtmReportDate)
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
		(dblAmount * RateFilter.dblRateBucket3) * -1,
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
		NULL, --intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnAPCashFlowTransactions](NULL, NULL)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND dtmDate BETWEEN DATEADD(DAY, 8, @dtmReportDate) AND DATEADD(DAY, 14, @dtmReportDate)
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
		(dblAmount * RateFilter.dblRateBucket4) * -1,
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
		NULL, --intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnAPCashFlowTransactions](NULL, NULL)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND dtmDate BETWEEN DATEADD(DAY, 15, @dtmReportDate) AND DATEADD(DAY, 21, @dtmReportDate)
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
		(dblAmount * RateFilter.dblRateBucket5) * -1,
		0,
		0,
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket5,
		RateFilter.dblRateBucket5,
		intGLAccountId,
		NULL, --intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnAPCashFlowTransactions](NULL, NULL)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND dtmDate BETWEEN DATEADD(DAY, 22, @dtmReportDate) AND DATEADD(DAY, 29, @dtmReportDate)
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
		(dblAmount * RateFilter.dblRateBucket6) * -1,
		0,
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket6,
		RateFilter.dblRateBucket6,
		intGLAccountId,
		NULL, --intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnAPCashFlowTransactions](NULL, NULL)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND dtmDate BETWEEN DATEADD(DAY, 30, @dtmReportDate) AND DATEADD(DAY, 60, @dtmReportDate)
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
		(dblAmount * RateFilter.dblRateBucket7) * -1,
		0,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket7,
		RateFilter.dblRateBucket7,
		intGLAccountId,
		NULL, --intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnAPCashFlowTransactions](NULL, NULL)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND dtmDate BETWEEN DATEADD(DAY, 60, @dtmReportDate) AND DATEADD(DAY, 90, @dtmReportDate)
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
		(dblAmount * RateFilter.dblRateBucket8) * -1,
		0,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket8,
		RateFilter.dblRateBucket8,
		intGLAccountId,
		NULL, --intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnAPCashFlowTransactions](NULL, NULL)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
	AND dtmDate BETWEEN DATEADD(DAY, 90, @dtmReportDate) AND DATEADD(DAY, 120, @dtmReportDate)
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
		(dblAmount * RateFilter.dblRateBucket9) * -1,
		intCurrencyId,
		@intReportingCurrencyId,
		RateTypeFilter.intRateTypeBucket9,
		RateFilter.dblRateBucket9,
		intGLAccountId,
		NULL, --intBankAccountId,
		intCompanyLocationId,
		1
	FROM [dbo].[fnAPCashFlowTransactions](NULL, NULL)
	JOIN @tblRateFilters RateFilter
		ON RateFilter.intFilterCurrencyId = intCurrencyId
	JOIN @tblRateTypeFilters RateTypeFilter
		ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
	WHERE 
		(
			CASE WHEN @intCompanyLocationId IS NULL
				THEN 1
				ELSE CASE WHEN intCompanyLocationId = @intCompanyLocationId THEN 1 ELSE 0 END
				END
		) = 1
		AND dtmDate BETWEEN DATEADD(DAY, 90, @dtmReportDate) AND DATEADD(DAY, 120, @dtmReportDate)

	-- Get sum of each bucket
		SELECT 
			@dblBucket1 = ISNULL(SUM(dblBucket1), 0)
		FROM tblCMCashFlowReportSummaryDetail 
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

		SELECT 
			@dblBucket2 = ISNULL(SUM(dblBucket2), 0)
		FROM tblCMCashFlowReportSummaryDetail 
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

		SELECT 
			@dblBucket3 = ISNULL(SUM(dblBucket3), 0)
		FROM tblCMCashFlowReportSummaryDetail 
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

		SELECT 
			@dblBucket4 = ISNULL(SUM(dblBucket4), 0)
		FROM tblCMCashFlowReportSummaryDetail 
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

		SELECT 
			@dblBucket5 = ISNULL(SUM(dblBucket5), 0)
		FROM tblCMCashFlowReportSummaryDetail 
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

		SELECT 
			@dblBucket6 = ISNULL(SUM(dblBucket6), 0)
		FROM tblCMCashFlowReportSummaryDetail 
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

		SELECT 
			@dblBucket7 = ISNULL(SUM(dblBucket7), 0)
		FROM tblCMCashFlowReportSummaryDetail 
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

		SELECT 
			@dblBucket8 = ISNULL(SUM(dblBucket8), 0)
		FROM tblCMCashFlowReportSummaryDetail 
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

		SELECT 
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
			,NULL--@intCurrentBankAccountId
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
			,5 -- Report Code = 3 for Total AP
			,1
		)
		
		DECLARE @intCashFlowReportSummaryId INT
		SELECT @intCashFlowReportSummaryId = CAST(IDENT_CURRENT('dbo.tblCMCashFlowReportSummary') AS INT)

		-- Update the intCashFlowReportSummaryId of drilldown records
		UPDATE tblCMCashFlowReportSummaryDetail
		SET
			intCashFlowReportSummaryId = @intCashFlowReportSummaryId
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL
END
RETURN 0
