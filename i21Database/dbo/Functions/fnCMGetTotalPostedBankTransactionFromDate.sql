CREATE FUNCTION [dbo].[fnCMGetTotalPostedBankTransactionFromDate]
(
	@intBucket INT = 1,
	@intGLAccountId INT,
    @dtmFrom DATETIME,
    @dtmTo DATETIME,
	@tblFilterCurrency AS [dbo].[CMCashFlowReportFilterRateType] READONLY
)
RETURNS TABLE
WITH
    SCHEMABINDING
AS
RETURN
SELECT 
    tblBankTransactions.intGLAccountId, 
    dblAmount = SUM(tblBankTransactions.dblCredit - tblBankTransactions.dblDebit)
FROM 
(
    SELECT DISTINCT
        BT.intTransactionId,
        BA.intGLAccountId,
        BT.dtmDate,
        dblDebit = (BTD.dblDebit * (
			CASE 
				WHEN @intBucket = 2
					THEN ISNULL(FilterCurrency.dblRateBucket2, 1)
				WHEN @intBucket = 3
					THEN ISNULL(FilterCurrency.dblRateBucket3, 1)
				WHEN @intBucket = 4
					THEN ISNULL(FilterCurrency.dblRateBucket4, 1)
				WHEN @intBucket = 5
					THEN ISNULL(FilterCurrency.dblRateBucket5, 1)
				WHEN @intBucket = 6
					THEN ISNULL(FilterCurrency.dblRateBucket6, 1)
				WHEN @intBucket = 7
					THEN ISNULL(FilterCurrency.dblRateBucket7, 1)
				WHEN @intBucket = 8
					THEN ISNULL(FilterCurrency.dblRateBucket8, 1)
				WHEN @intBucket = 9
					THEN ISNULL(FilterCurrency.dblRateBucket9, 1)
				ELSE 
					ISNULL(FilterCurrency.dblRateBucket1, 1)
			END
		)),
        dblCredit = (BTD.dblCredit* (
			CASE 
				WHEN @intBucket = 2
					THEN ISNULL(FilterCurrency.dblRateBucket2, 1)
				WHEN @intBucket = 3
					THEN ISNULL(FilterCurrency.dblRateBucket3, 1)
				WHEN @intBucket = 4
					THEN ISNULL(FilterCurrency.dblRateBucket4, 1)
				WHEN @intBucket = 5
					THEN ISNULL(FilterCurrency.dblRateBucket5, 1)
				WHEN @intBucket = 6
					THEN ISNULL(FilterCurrency.dblRateBucket6, 1)
				WHEN @intBucket = 7
					THEN ISNULL(FilterCurrency.dblRateBucket7, 1)
				WHEN @intBucket = 8
					THEN ISNULL(FilterCurrency.dblRateBucket8, 1)
				WHEN @intBucket = 9
					THEN ISNULL(FilterCurrency.dblRateBucket9, 1)
				ELSE 
					ISNULL(FilterCurrency.dblRateBucket1, 1)
			END
		))
    FROM [dbo].[tblCMBankTransaction] BT
    JOIN [dbo].[tblCMBankTransactionDetail] BTD ON BTD.intTransactionId = BT.intTransactionId
    JOIN [dbo].[tblCMBankAccount] BA ON BA.intBankAccountId = BT.intBankAccountId
	OUTER APPLY (
		SELECT DISTINCT
			intFilterCurrencyId,
			ISNULL(dblRateBucket1, 1) dblRateBucket1,
			ISNULL(dblRateBucket2, 1) dblRateBucket2,
			ISNULL(dblRateBucket3, 1) dblRateBucket3,
			ISNULL(dblRateBucket4, 1) dblRateBucket4,
			ISNULL(dblRateBucket5, 1) dblRateBucket5,
			ISNULL(dblRateBucket6, 1) dblRateBucket6,
			ISNULL(dblRateBucket7, 1) dblRateBucket7,
			ISNULL(dblRateBucket8, 1) dblRateBucket8,
			ISNULL(dblRateBucket9, 1) dblRateBucket9
		FROM @tblFilterCurrency 
		WHERE intFilterCurrencyId = BT.intCurrencyId OR intFilterCurrencyId = BA.intCurrencyId
	) FilterCurrency
    WHERE 
        BTD.intGLAccountId IS NOT NULL AND 
        BT.ysnPosted = 1 AND 
        BA.intGLAccountId = @intGLAccountId AND 
		BT.dtmDate BETWEEN @dtmFrom AND @dtmTo AND
		FilterCurrency.intFilterCurrencyId IS NOT NULL
) AS tblBankTransactions 
GROUP BY tblBankTransactions.intGLAccountId;
