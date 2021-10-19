CREATE PROCEDURE [dbo].[uspCMGetTotalCashForecastReport]
(
	@intCashFlowReportId INT,
	@dtmReportDate DATETIME,
	@intReportingCurrencyId INT,
	@intBankAccountId INT = NULL,
	@intCompanyLocationId INT = NULL
)
AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	DECLARE
		@intCurrentAccountId INT,
		@strCurrentAccountId NVARCHAR(100),
		@dblBeginBalance NUMERIC(18, 6),
		@dblBeginBalanceUnit NUMERIC(18, 6),
		@dblTotalBeginBalance NUMERIC(18, 6) = 0,
		@dblTotalBeginBalanceUnit NUMERIC(18, 6) = 0,
		@dblBucket1 DECIMAL(18, 6) = 0, -- Current
		@dblBucket2 DECIMAL(18, 6) = 0, -- 1-7
		@dblBucket3 DECIMAL(18, 6) = 0, -- 8-14
		@dblBucket4 DECIMAL(18, 6) = 0, -- 15-21
		@dblBucket5 DECIMAL(18, 6) = 0, -- 22-29
		@dblBucket6 DECIMAL(18, 6) = 0, -- 30-60
		@dblBucket7 DECIMAL(18, 6) = 0, -- 60-90
		@dblBucket8 DECIMAL(18, 6) = 0, -- 90-120
		@dblBucket9 DECIMAL(18, 6) = 0  -- 120+

	-- Table for GL Accounts to be processed
	CREATE TABLE 
		#tblAccounts 
	(
		intAccountId int,
		strAccountId nvarchar(100),
		dblBeginBalance numeric(18, 6),
		dblBeginBalanceUnit numeric(18, 6),
		ysnProcessed bit DEFAULT(0) -- For looping
	);

	-- Fill Cash Account Types table; Filter by intCompanyLocation and intBankAccountId if supplied
	INSERT INTO #tblAccounts
	SELECT A.intAccountId, A.strAccountId, 0, 0, 0
	FROM vyuGLAccountDetail A
	OUTER APPLY (
		SELECT S.intAccountSegmentId FROM tblGLAccountSegment S
		JOIN tblGLAccountSegmentMapping ASM ON ASM.intAccountSegmentId = S.intAccountSegmentId
		JOIN tblSMCompanyLocation CL ON CL.intProfitCenter = S.intAccountSegmentId
		WHERE ASM.intAccountId = A.intAccountId AND CL.intCompanyLocationId = @intCompanyLocationId
	) Segment
	OUTER APPLY (
		SELECT intGLAccountId FROM tblCMBankAccount
		WHERE intBankAccountId = @intBankAccountId
	) BankAccount
	WHERE 
		A.strAccountCategory = 'Cash Account' AND
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
				ELSE CASE WHEN BankAccount.intGLAccountId = A.intAccountId THEN 1 ELSE 0 END
				END
		) = 1
	ORDER BY A.intAccountId

	-- Table for currency exchange rates per bucket
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

	-- Loop thru each cash account type
	WHILE EXISTS (SELECT TOP 1 1 FROM #tblAccounts WHERE ysnProcessed = 0 ORDER BY intAccountId)
	BEGIN
		SELECT TOP (1) 
			@intCurrentAccountId = 
				intAccountId, 
			@strCurrentAccountId = 
				strAccountId 
		FROM #tblAccounts 
		WHERE ysnProcessed = 0 
		ORDER BY intAccountId;
    
		-- Get BeginBalance of each account
		SELECT
			@dblBeginBalance = 
				beginBalance, 
			@dblBeginBalanceUnit = 
				beginBalanceUnit 
		FROM dbo.fnGLGetBeginningBalanceAndUnit(@strCurrentAccountId, @dtmReportDate);
    
		UPDATE 
			#tblAccounts
		SET
			dblBeginBalance = 
				@dblBeginBalance,
			dblBeginBalanceUnit = 
				@dblBeginBalanceUnit,
			ysnProcessed = 
				1
		WHERE intAccountId = @intCurrentAccountId;

		/* Get all posted bank transactions per bucket of each account */
		-- 1-7
		SELECT @dblBucket2 = ISNULL(@dblBucket2, 0) + ISNULL(dblAmount, 0) 
		FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(2, @intCurrentAccountId, DATEADD(DAY, 1, @dtmReportDate), DATEADD(DAY, 7, @dtmReportDate), @tblFilter);
		
		-- 8-14
		SELECT @dblBucket3 = ISNULL(@dblBucket3, 0) + ISNULL(dblAmount, 0) 
		FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(3, @intCurrentAccountId, DATEADD(DAY, 8, @dtmReportDate), DATEADD(DAY, 14, @dtmReportDate), @tblFilter);

		-- 15-21
		SELECT @dblBucket4 = ISNULL(@dblBucket4, 0) + ISNULL(dblAmount, 0) 
		FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(4, @intCurrentAccountId, DATEADD(DAY, 15, @dtmReportDate), DATEADD(DAY, 21, @dtmReportDate), @tblFilter);

		-- 22-29
		SELECT @dblBucket5 = ISNULL(@dblBucket5, 0) + ISNULL(dblAmount, 0) 
		FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(5, @intCurrentAccountId, DATEADD(DAY, 22, @dtmReportDate), DATEADD(DAY, 29, @dtmReportDate), @tblFilter);

		-- 30-60
		SELECT @dblBucket6 = ISNULL(@dblBucket6, 0) + ISNULL(dblAmount, 0) 
		FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(6, @intCurrentAccountId, DATEADD(DAY, 30, @dtmReportDate), DATEADD(DAY, 60, @dtmReportDate), @tblFilter);

		-- 60-90
		SELECT @dblBucket7 = ISNULL(@dblBucket7, 0) + ISNULL(dblAmount, 0) 
		FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(7, @intCurrentAccountId, DATEADD(DAY, 60, @dtmReportDate), DATEADD(DAY, 90, @dtmReportDate), @tblFilter);

		-- 90-120
		SELECT @dblBucket8 = ISNULL(@dblBucket8, 0) + ISNULL(dblAmount, 0) 
		FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(8, @intCurrentAccountId, DATEADD(DAY, 90, @dtmReportDate), DATEADD(DAY, 120, @dtmReportDate), @tblFilter);

		-- 120+ (120 + 10 yrs)
		SELECT @dblBucket9 = ISNULL(@dblBucket9, 0) + ISNULL(dblAmount, 0) 
		FROM dbo.fnCMGetTotalPostedBankTransactionFromDate(9, @intCurrentAccountId, DATEADD(DAY, 120, @dtmReportDate), DATEADD(DAY, 3650, @dtmReportDate), @tblFilter);

	END;

	-- Get Begin Balance total
	SELECT @dblTotalBeginBalance = SUM(dblBeginBalance), @dblTotalBeginBalanceUnit =  SUM(dblBeginBalanceUnit) FROM #tblAccounts

	-- Bucket Current's value is the Total of BeginBalance of each GL accounts
	SET @dblBucket1 = @dblTotalBeginBalance

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
		,1 -- Report Code = 1 for Total Cash
		,1
	)
END