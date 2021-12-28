CREATE FUNCTION [dbo].[fnCMCashFlowTransactions]
(
	@intBankAccountId INT,
    @dtmFrom DATETIME,
    @dtmTo DATETIME
)
RETURNS TABLE
WITH
    SCHEMABINDING
AS
RETURN
    SELECT
        BT.intTransactionId,
        BT.strTransactionId,
        BT.intBankAccountId,
        BT.intCurrencyId,
        BT.dtmDate,
        dblAmount = CASE WHEN (BTT.strDebitCredit = 'D' AND BT.dblAmount > 0) -- If Debit transaction is already negative, do not negate. Negate only Debit that is not negative amount.
                        THEN -(BT.dblAmount)
                        ELSE BT.dblAmount
                        END,
        BA.intGLAccountId,
		BT.intCompanyLocationId,
        BTT.strBankTransactionTypeName strTransactionType
    FROM [dbo].[tblCMBankTransaction] BT
    JOIN [dbo].[tblCMBankAccount] BA ON BA.intBankAccountId = BT.intBankAccountId
    LEFT JOIN [dbo].[tblCMBankTransactionType] BTT ON BTT.intBankTransactionTypeId = BT.intBankTransactionTypeId
    WHERE 
        BT.ysnPosted = 1
        AND BA.intBankAccountId = @intBankAccountId
		AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (BT.dtmDate BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (BT.dtmDate <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1
    UNION ALL -- Bank Transfer With In transit From
    SELECT
        BTR.intTransactionId,
        BTR.strTransactionId,
        BTR.intBankAccountIdFrom,
        BTR.intCurrencyIdAmountFrom,
        BTR.dtmDate,
        BTR.dblAmountForeignFrom * -1,
        BTR.intGLAccountIdFrom,
        NULL,
        'Bank Transfer With In transit (Withdraw)'
    FROM [dbo].[tblCMBankTransfer] BTR
    WHERE 
        BTR.intBankTransferTypeId = 2
        AND BTR.ysnPostedInTransit = 1
        AND BTR.ysnPosted = 0
        AND BTR.intBankAccountIdFrom = @intBankAccountId
        AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (BTR.dtmDate BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (BTR.dtmDate <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1
     UNION ALL -- Bank Transfer With In transit To
    SELECT
        BTR.intTransactionId,
        BTR.strTransactionId,
        BTR.intBankAccountIdTo,
        BTR.intCurrencyIdAmountTo,
        BTR.dtmInTransit,
        BTR.dblAmountForeignTo,
        BTR.intGLAccountIdTo,
        NULL,
        'Bank Transfer With In transit (Deposit)'
    FROM [dbo].[tblCMBankTransfer] BTR
    WHERE 
        BTR.intBankTransferTypeId = 2
        AND BTR.ysnPostedInTransit = 1
        AND BTR.ysnPosted = 0
        AND BTR.intBankAccountIdTo = @intBankAccountId
        AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (BTR.dtmInTransit BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (BTR.dtmInTransit <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1
    UNION ALL -- Bank Forward-- From
    SELECT
        BTR.intTransactionId,
        BTR.strTransactionId,
        BTR.intBankAccountIdFrom,
        BTR.intCurrencyIdAmountFrom,
        BTR.dtmAccrual,
        BTR.dblAmountForeignFrom  * -1,
        BTR.intGLAccountIdFrom,
        NULL,
        'Bank Forward (Withdraw)'
    FROM [dbo].[tblCMBankTransfer] BTR
    WHERE 
        BTR.intBankTransferTypeId = 3
        AND BTR.ysnPostedInTransit = 1
        AND BTR.intBankAccountIdFrom = @intBankAccountId
        AND (CASE 
                WHEN @dtmFrom IS NULL
                    THEN CASE WHEN BTR.dtmAccrual <= @dtmTo AND BTR.ysnPosted = 0 THEN 1 ELSE 0 END
                WHEN BTR.ysnPosted = 0 
                    THEN 1
                ELSE 0 
            END
        ) = 1
        AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (BTR.dtmAccrual BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (BTR.dtmAccrual <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1
     UNION ALL -- Bank Forward To
    SELECT
        BTR.intTransactionId,
        BTR.strTransactionId,
        BTR.intBankAccountIdTo,
        BTR.intCurrencyIdAmountTo,
        BTR.dtmDate,
        BTR.dblAmountForeignTo,
        BTR.intGLAccountIdTo,
        NULL,
        'Bank Forward (Deposit)'
    FROM [dbo].[tblCMBankTransfer] BTR
    WHERE 
        BTR.intBankTransferTypeId = 3
        AND BTR.ysnPostedInTransit = 1
        AND BTR.intBankAccountIdTo = @intBankAccountId
        AND (CASE 
                WHEN @dtmFrom IS NULL
                    THEN CASE WHEN BTR.dtmDate <= @dtmTo AND BTR.ysnPosted = 0 THEN 1 ELSE 0 END
                WHEN BTR.ysnPosted = 0 
                    THEN 1
                ELSE 0 
            END
        ) = 1
        AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (BTR.dtmDate BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (BTR.dtmDate <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1