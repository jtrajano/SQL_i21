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

	-- Filter table - table for filter currency and currency exchange rates per bucket
	DECLARE @tblFilter CMCashFlowReportFilterRateType
	INSERT INTO @tblFilter
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
		JOIN @tblFilter F ON F.intFilterCurrencyId = BA.intCurrencyId
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
			SELECT dblRateBucket1 FROM @tblFilter WHERE intFilterCurrencyId = Accounts.intCurrencyId
		) FilterTable
    
		-- Set to true to for process next bank account
		UPDATE A SET A.ysnProcessed = 1
		FROM #tblAccounts A
		WHERE A.intAccountId = @intCurrentAccountId;

		/* Get all posted bank transactions (after report date) on each bank account per bucket*/
		-- 1-7
		SELECT @dblBucket2 = ISNULL(dblAmount, 0) FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(2, @intCurrentAccountId, DATEADD(DAY, 1, @dtmReportDate), DATEADD(DAY, 7, @dtmReportDate), @tblFilter);
		-- 8-14
		SELECT @dblBucket3 = ISNULL(dblAmount, 0) FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(3, @intCurrentAccountId, DATEADD(DAY, 8, @dtmReportDate), DATEADD(DAY, 14, @dtmReportDate), @tblFilter);
		-- 15-21
		SELECT @dblBucket4 = ISNULL(dblAmount, 0) FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(4, @intCurrentAccountId, DATEADD(DAY, 15, @dtmReportDate), DATEADD(DAY, 21, @dtmReportDate), @tblFilter);
		-- 22-29
		SELECT @dblBucket5 = ISNULL(dblAmount, 0) FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(5, @intCurrentAccountId, DATEADD(DAY, 22, @dtmReportDate), DATEADD(DAY, 29, @dtmReportDate), @tblFilter);
		-- 30-60
		SELECT @dblBucket6 = ISNULL(dblAmount, 0) FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(6, @intCurrentAccountId, DATEADD(DAY, 30, @dtmReportDate), DATEADD(DAY, 60, @dtmReportDate), @tblFilter);
		-- 60-90
		SELECT @dblBucket7 = ISNULL(dblAmount, 0) FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(7, @intCurrentAccountId, DATEADD(DAY, 60, @dtmReportDate), DATEADD(DAY, 90, @dtmReportDate), @tblFilter);
		-- 90-120
		SELECT @dblBucket8 = ISNULL(dblAmount, 0) FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(8, @intCurrentAccountId, DATEADD(DAY, 90, @dtmReportDate), DATEADD(DAY, 120, @dtmReportDate), @tblFilter);
		-- 120+ (120 + 10 yrs)
		SELECT @dblBucket9 = ISNULL(dblAmount, 0) FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(9, @intCurrentAccountId, DATEADD(DAY, 120, @dtmReportDate), DATEADD(DAY, 3650, @dtmReportDate), @tblFilter);
	
		-- Insert all buckets to report summary table
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
	END

END
