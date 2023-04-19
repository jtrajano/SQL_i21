CREATE PROCEDURE uspCMCreateBankTransferForward
(
    @BankTransfer CMBankTransferType READONLY,
    @Id INT OUT
)
AS
DECLARE @intStartingNumber INT = 12, 
    @BankTransferID NVARCHAR(30), 
    @intBankTransactionTypeId INT = 4, 
    @intBankTransferTypeId  INT = 3,
    @intBTBankFeesAccountId INT,
    @intDefaultCurrencyId INT 

EXEC dbo.uspSMGetStartingNumber @intStartingNumber , @BankTransferID OUTPUT

SELECT @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

SELECT TOP 1 @intBTBankFeesAccountId=intBTBankFeesAccountId FROM tblCMCompanyPreferenceOption

;WITH CTE AS (
    SELECT 
    intEntityId
    ,intBankTransactionTypeId = @intBankTransactionTypeId
    ,intBankTransferTypeId = @intBankTransferTypeId
    ,strTransactionId = @BankTransferID
    ,strDescription
    ,strReferenceFrom
    ,strReferenceTo
    ,intBankAccountIdFrom
    ,intBankAccountIdTo
    ,intGLAccountIdFrom = BAF.intGLAccountId
    ,intGLAccountIdTo = BAT.intGLAccountId
    ,intCurrencyIdAmountFrom = BAF.intCurrencyId
    ,intCurrencyIdAmountTo = BAT.intCurrencyId
    ,intRateTypeIdAmountFrom = intCurrencyExchangeRateTypeId
    ,intRateTypeIdAmountTo= intCurrencyExchangeRateTypeId
    ,intFiscalPeriodId
    ,dtmAccrual
    ,dtmDate
    ,dblRateAmountFrom = BAF.dblRate
    ,dblRateAmountTo = BAT.dblRate
    ,dblCrossRate =dblAmountForeignTo/dblAmountForeignFrom
    ,dblReverseRate= dblAmountForeignFrom/dblAmountForeignTo
    ,dblAmountForeignFrom = ROUND(dblAmountForeignFrom, 2)
    ,dblAmountForeignTo = ROUND(dblAmountForeignTo, 2)
    ,dblAmountFrom = ROUND(dblAmountForeignFrom * BAF.dblRate, 2)
    ,dblAmountTo = ROUND(dblAmountForeignTo * BAT.dblRate, 2)
    ,dblRateFeesFrom= BAF.dblRate
    ,dblRateFeesTo=BAT.dblRate
    ,dblRateAmountSettlementFrom=CASE WHEN BAF.intCurrencyId = @intDefaultCurrencyId THEN 1 ELSE 0 END
    ,dblRateAmountSettlementTo=CASE WHEN BAT.intCurrencyId = @intDefaultCurrencyId THEN 1 ELSE 0 END
    ,strDerivativeId
    ,intFutOptTransactionId
    ,intFutOptTransactionHeaderId
    ,dtmCreated = GETDATE()
    ,intConcurrencyId = 1
    FROM @BankTransfer BT
    OUTER APPLY (
        SELECT TOP 1 intCurrencyId, intGLAccountId,CASE WHEN intCurrencyId = @intDefaultCurrencyId THEN 1 ELSE B.dblRate END dblRate FROM tblCMBankAccount 
        OUTER APPLY dbo.fnSMGetForexRate(intCurrencyId, BT.intCurrencyExchangeRateTypeId, BT.dtmAccrual) B
        WHERE intBankAccountId = BT.intBankAccountIdFrom
    ) BAF
    OUTER APPLY (
        SELECT TOP 1 intCurrencyId, intGLAccountId,CASE WHEN intCurrencyId = @intDefaultCurrencyId THEN 1 ELSE B.dblRate END dblRate FROM tblCMBankAccount 
        OUTER APPLY dbo.fnSMGetForexRate(intCurrencyId, BT.intCurrencyExchangeRateTypeId, BT.dtmAccrual) B
        WHERE intBankAccountId = BT.intBankAccountIdTo
    ) BAT
)
    INSERT INTO tblCMBankTransfer(
    intEntityId
    ,intBankTransactionTypeId
    ,intBankTransferTypeId
    ,strTransactionId
    ,strDescription
    ,strReferenceFrom
    ,strReferenceTo
    ,intBankAccountIdFrom
    ,intBankAccountIdTo
    ,intGLAccountIdFrom
    ,intGLAccountIdTo
    ,intCurrencyIdAmountFrom
    ,intCurrencyIdAmountTo
    ,intRateTypeIdAmountFrom
    ,intRateTypeIdAmountTo
    ,intFiscalPeriodId
    ,dtmAccrual
    ,dtmDate
    ,dblRateAmountFrom
    ,dblRateAmountTo
    ,dblCrossRate
    ,dblReverseRate
    ,dblAmountForeignFrom
    ,dblAmountForeignTo
    ,dblAmountFrom
    ,dblAmountTo
    ,dblRateFeesFrom
    ,dblRateFeesTo
    ,dblRateAmountSettlementFrom
    ,dblRateAmountSettlementTo
    ,dblDifference
    ,dtmCreated
    ,strDerivativeId
    ,intFutOptTransactionId
    ,intFutOptTransactionHeaderId
    ,intGLAccountIdFeesFrom
    ,intGLAccountIdFeesTo
    ,intConcurrencyId
    )
    SELECT 
    intEntityId
    ,intBankTransactionTypeId
    ,intBankTransferTypeId
    ,strTransactionId
    ,strDescription
    ,strReferenceFrom
    ,strReferenceTo
    ,intBankAccountIdFrom
    ,intBankAccountIdTo
    ,intGLAccountIdFrom
    ,intGLAccountIdTo
    ,intCurrencyIdAmountFrom
    ,intCurrencyIdAmountTo
    ,intRateTypeIdAmountFrom
    ,intRateTypeIdAmountTo
    ,intFiscalPeriodId
    ,dtmAccrual
    ,dtmDate
    ,dblRateAmountFrom
    ,dblRateAmountTo
    ,dblCrossRate
    ,dblReverseRate
    ,dblAmountForeignFrom
    ,dblAmountForeignTo
    ,dblAmountFrom 
    ,dblAmountTo
    ,dblRateFeesFrom
    ,dblRateFeesTo
    ,dblRateAmountSettlementFrom
    ,dblRateAmountSettlementTo
    ,dblDifference = dblAmountTo - dblAmountFrom
    ,dtmCreated
    ,strDerivativeId
    ,intFutOptTransactionId
    ,intFutOptTransactionHeaderId
    ,@intBTBankFeesAccountId
    ,@intBTBankFeesAccountId
    ,intConcurrencyId
    FROM CTE BT

    SELECT @Id = SCOPE_IDENTITY()


