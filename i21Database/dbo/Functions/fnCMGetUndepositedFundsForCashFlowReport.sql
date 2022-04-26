CREATE FUNCTION [dbo].[fnCMGetUndepositedFundsForCashFlowReport]
(
	@intBankAccountId INT,
    @dtmFrom DATETIME,
    @dtmTo DATETIME
)
RETURNS TABLE
AS
RETURN SELECT 
        intTransactionId = UF.intSourceTransactionId,
        strTransactionId = UF.strSourceTransactionId,
        intBankAccountId = UF.intBankAccountId,
        intCurrencyId = UF.intCurrencyId,
        dtmDate = UF.dtmDate,
        dblAmount = ISNULL(UF.dblAmount, 0),
        intGLAccountId = BA.intGLAccountId,
		intCompanyLocationId = UF.intLocationId,
        strTransactionType = UF.strPaymentMethod
    FROM [dbo].[tblCMUndepositedFund] UF
    JOIN [dbo].[tblCMBankAccount] BA
        ON BA.intBankAccountId = UF.intBankAccountId
    WHERE 
        UF.intBankAccountId = @intBankAccountId
        AND intBankDepositId IS NULL
        AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (UF.dtmDate BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (UF.dtmDate <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1
