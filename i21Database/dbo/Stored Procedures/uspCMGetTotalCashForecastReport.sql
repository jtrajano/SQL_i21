CREATE PROCEDURE [dbo].[uspCMGetTotalCashForecastReport]
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
		@intDefaultCurrencyId INT,
		@strCurrentAccountId NVARCHAR(100),
		@dblBeginBalance NUMERIC(18, 6) = 0,
		@dblBucket2 DECIMAL(18, 6) = 0,
		@dblBucket3 DECIMAL(18, 6) = 0,
		@dblBucket4 DECIMAL(18, 6) = 0,
		@dblBucket5 DECIMAL(18, 6) = 0,
		@dblBucket6 DECIMAL(18, 6) = 0,
		@dblBucket7 DECIMAL(18, 6) = 0,
		@dblBucket8 DECIMAL(18, 6) = 0,
		@dblBucket9 DECIMAL(18, 6) = 0

	SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

	-- Rate Filter table - table for filter currency and currency exchange rates per bucket
	DECLARE @tblRateFilters CMCashFlowReportFilterRateType
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

	-- Table for GL Accounts to be processed
	CREATE TABLE 
		#tblAccounts 
	(
		intAccountId int,
		strAccountId nvarchar(100),
		intBankAccountId int,
		intCurrencyId int,
		dblBeginBalance numeric(18, 6),
		ysnMultiCurrency bit DEFAULT (0),
		ysnProcessed bit DEFAULT(0) -- For looping
	);

	-- Get all Bank Accounts that has the same currency with currency/currencies on the Filter table
	-- Filter by intCompanyLocation and intBankAccountId if supplied
	INSERT INTO #tblAccounts
	SELECT 
		BA.intGLAccountId, 
		A.strAccountId, 
		BA.intBankAccountId, 
		BA.intCurrencyId, 
		0,
		CAST ((CASE WHEN @intDefaultCurrencyId = BA.intCurrencyId THEN 0 ELSE 1 END) AS BIT),
		CAST (0 AS BIT)
		FROM tblCMBankAccount BA
		JOIN tblGLAccount A ON A.intAccountId = BA.intGLAccountId
		JOIN @tblRateFilters F ON F.intFilterCurrencyId = BA.intCurrencyId
		OUTER APPLY (
			SELECT S.intAccountSegmentId FROM tblGLAccountSegment S
			JOIN tblGLAccountSegmentMapping ASM ON ASM.intAccountSegmentId = S.intAccountSegmentId
			JOIN tblSMCompanyLocation CL ON CL.intProfitCenter = S.intAccountSegmentId
			WHERE ASM.intAccountId = A.intAccountId AND CL.intCompanyLocationId = @intCompanyLocationId
		) Segment
		WHERE 
			(
				CASE WHEN @intCompanyLocationId IS NULL
					THEN 1
					ELSE CASE WHEN Segment.intAccountSegmentId IS NOT NULL THEN 1 ELSE 0 END
					END
			) = 1
			AND
			(
				CASE WHEN @intBankAccountId IS NULL
					THEN 1
					ELSE CASE WHEN BA.intBankAccountId = @intBankAccountId THEN 1 ELSE 0 END
					END
			) = 1
			AND
			(
				CASE WHEN @intBankId IS NULL
					THEN 1
					ELSE CASE WHEN BA.intBankId = @intBankId THEN 1 ELSE 0 END
					END
			) = 1
		ORDER BY A.intAccountId

	-- Loop thru each Bank Account
	WHILE EXISTS (SELECT TOP 1 1 FROM #tblAccounts WHERE ysnProcessed = 0 ORDER BY intAccountId)
	BEGIN
		-- Set current bank account 
		SELECT TOP (1) 
			@intCurrentAccountId = 
				intAccountId, 
			@strCurrentAccountId = 
				strAccountId,
			@intCurrentBankAccountId =
				intBankAccountId
		FROM #tblAccounts 
		WHERE ysnProcessed = 0 
		ORDER BY intAccountId;
    
		-- Get Beginning Balance of each account then convert to the rate specified in the bucket 1
		SELECT 
			@dblBeginBalance = 
				ISNULL((CASE WHEN Accounts.ysnMultiCurrency = 0 THEN beginBalance ELSE beginBalanceForeign END), 0) * (ISNULL(FilterTable.dblRateBucket1, 1))
		FROM dbo.fnGLGetBeginningBalanceAndUnit(@strCurrentAccountId, DATEADD(DAY, 1, @dtmReportDate))
		OUTER APPLY (
			SELECT intCurrencyId, ysnMultiCurrency FROM #tblAccounts WHERE strAccountId = @strCurrentAccountId AND intAccountId = @intCurrentAccountId
		) Accounts
		OUTER APPLY (
			SELECT dblRateBucket1 FROM @tblRateFilters WHERE intFilterCurrencyId = Accounts.intCurrencyId
		) FilterTable

		--- Insert each transactions of each bucket to the drilldown table		
		INSERT INTO tblCMCashFlowReportSummaryDetail (
			[intCashFlowReportId]
			,[intTransactionId]
			,[strTransactionId]
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
		SELECT 
			@intCashFlowReportId,
			1, -- no specific transactions for Current bucket - it can be thousands/millions of records.
			'Current',
			@dtmReportDate,
			@dblBeginBalance,
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
			@intCurrentAccountId,
			intBankAccountId,
			@intCompanyLocationId,
			1
		FROM #tblAccounts
		JOIN @tblRateFilters RateFilter
			ON RateFilter.intFilterCurrencyId = intCurrencyId
		JOIN @tblRateTypeFilters RateTypeFilter
			ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
		WHERE intAccountId = @intCurrentAccountId
		-- 1-7
		UNION ALL
		SELECT 
			@intCashFlowReportId,
			intTransactionId,
			strTransactionId,
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
		FROM [dbo].[fnCMGetPostedBankTransactionFromDate](@intCurrentBankAccountId, DATEADD(DAY, 1, @dtmReportDate), DATEADD(DAY, 7, @dtmReportDate))
		JOIN @tblRateFilters RateFilter
			ON RateFilter.intFilterCurrencyId = intCurrencyId
		JOIN @tblRateTypeFilters RateTypeFilter
			ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
		-- 8-14
		UNION ALL
		SELECT 
			@intCashFlowReportId,
			intTransactionId,
			strTransactionId,
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
		FROM [dbo].[fnCMGetPostedBankTransactionFromDate](@intCurrentBankAccountId, DATEADD(DAY, 8, @dtmReportDate), DATEADD(DAY, 14, @dtmReportDate))
		JOIN @tblRateFilters RateFilter
			ON RateFilter.intFilterCurrencyId = intCurrencyId
		JOIN @tblRateTypeFilters RateTypeFilter
			ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
		-- 15 - 21
		UNION ALL
		SELECT 
			@intCashFlowReportId,
			intTransactionId,
			strTransactionId,
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
		FROM [dbo].[fnCMGetPostedBankTransactionFromDate](@intCurrentBankAccountId, DATEADD(DAY, 15, @dtmReportDate), DATEADD(DAY, 21, @dtmReportDate))
		JOIN @tblRateFilters RateFilter
			ON RateFilter.intFilterCurrencyId = intCurrencyId
		JOIN @tblRateTypeFilters RateTypeFilter
			ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
		-- 22 - 29
		UNION ALL
		SELECT 
			@intCashFlowReportId,
			intTransactionId,
			strTransactionId,
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
		FROM [dbo].[fnCMGetPostedBankTransactionFromDate](@intCurrentBankAccountId, DATEADD(DAY, 22, @dtmReportDate), DATEADD(DAY, 29, @dtmReportDate))
		JOIN @tblRateFilters RateFilter
			ON RateFilter.intFilterCurrencyId = intCurrencyId
		JOIN @tblRateTypeFilters RateTypeFilter
			ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
		-- 30 - 60
		UNION ALL
		SELECT 
			@intCashFlowReportId,
			intTransactionId,
			strTransactionId,
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
		FROM [dbo].[fnCMGetPostedBankTransactionFromDate](@intCurrentBankAccountId, DATEADD(DAY, 30, @dtmReportDate), DATEADD(DAY, 60, @dtmReportDate))
		JOIN @tblRateFilters RateFilter
			ON RateFilter.intFilterCurrencyId = intCurrencyId
		JOIN @tblRateTypeFilters RateTypeFilter
			ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
		-- 60 - 90
		UNION ALL
		SELECT 
			@intCashFlowReportId,
			intTransactionId,
			strTransactionId,
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
		FROM [dbo].[fnCMGetPostedBankTransactionFromDate](@intCurrentBankAccountId, DATEADD(DAY, 60, @dtmReportDate), DATEADD(DAY, 90, @dtmReportDate))
		JOIN @tblRateFilters RateFilter
			ON RateFilter.intFilterCurrencyId = intCurrencyId
		JOIN @tblRateTypeFilters RateTypeFilter
			ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
		-- 90 - 120
		UNION ALL
		SELECT 
			@intCashFlowReportId,
			intTransactionId,
			strTransactionId,
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
		FROM [dbo].[fnCMGetPostedBankTransactionFromDate](@intCurrentBankAccountId, DATEADD(DAY, 90, @dtmReportDate), DATEADD(DAY, 120, @dtmReportDate))
		JOIN @tblRateFilters RateFilter
			ON RateFilter.intFilterCurrencyId = intCurrencyId
		JOIN @tblRateTypeFilters RateTypeFilter
			ON RateTypeFilter.intFilterCurrencyId = intCurrencyId
		-- 120+
		UNION ALL
		SELECT 
			@intCashFlowReportId,
			intTransactionId,
			strTransactionId,
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
		FROM [dbo].[fnCMGetPostedBankTransactionFromDate](@intCurrentBankAccountId, DATEADD(DAY, 120, @dtmReportDate), DATEADD(DAY, 3650, @dtmReportDate))
		JOIN @tblRateFilters RateFilter
			ON RateFilter.intFilterCurrencyId = intCurrencyId
		JOIN @tblRateTypeFilters RateTypeFilter
			ON RateTypeFilter.intFilterCurrencyId = intCurrencyId

		-- Get sum of each bucket
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
			,@intCurrentBankAccountId
			,@intCompanyLocationId
			,@dblBeginBalance + @dblBucket2 + @dblBucket3 + @dblBucket4 + @dblBucket5 + @dblBucket6 + @dblBucket7 + @dblBucket8 + @dblBucket9
			,@dblBeginBalance
			,@dblBucket2
			,@dblBucket3
			,@dblBucket4
			,@dblBucket5
			,@dblBucket6
			,@dblBucket7
			,@dblBucket8
			,@dblBucket9
			,@intCashFlowReportId
			,1 -- Report Code = 1 for Total Cash
			,1
		)
		
		DECLARE @intCashFlowReportSummaryId INT
		SELECT @intCashFlowReportSummaryId = CAST(IDENT_CURRENT('dbo.tblCMCashFlowReportSummary') AS INT)

		-- Update the intCashFlowReportSummaryId of drilldown records
		UPDATE tblCMCashFlowReportSummaryDetail
		SET
			intCashFlowReportSummaryId = @intCashFlowReportSummaryId
		WHERE intCashFlowReportId = @intCashFlowReportId AND intCashFlowReportSummaryId IS NULL

		-- Reset values
		SET @dblBeginBalance = 0
		SET @dblBucket2 = 0
		SET @dblBucket3 = 0
		SET @dblBucket4 = 0
		SET @dblBucket5 = 0
		SET @dblBucket6 = 0
		SET @dblBucket7 = 0
		SET @dblBucket8 = 0
		SET @dblBucket9 = 0

		-- Set to true to process next bank account
		UPDATE A SET A.ysnProcessed = 1
		FROM #tblAccounts A
		WHERE A.intAccountId = @intCurrentAccountId;

	END

END
