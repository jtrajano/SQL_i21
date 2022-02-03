CREATE PROCEDURE uspCMCreateBankTransferForward
(
@BankTransfer CMBankTransferType READONLY,
@Id INT OUT
)
AS
DECLARE @intStartingNumber INT = 12, @BankTransferID NVARCHAR(30), @intBankTransactionTypeId INT = 4, @intBankTransferTypeId  INT = 3

EXEC dbo.uspSMGetStartingNumber @intStartingNumber , @BankTransferID OUTPUT

;WITH CTE AS (
SELECT 
 intEntityId
,intBankTransactionTypeId = @intBankTransactionTypeId
,intBankTransferTypeId = @intBankTransferTypeId
,strTransactionId = @BankTransferID
,strDescription
,intBankAccountIdFrom
,intBankAccountIdTo
,intGLAccountIdFrom = BAF.intGLAccountId
,intGLAccountIdTo = BAF.intGLAccountId
,intCurrencyIdAmountFrom = BAF.intCurrencyId
,intCurrencyIdAmountTo = BAT.intCurrencyId
,intRateTypeIdAmountFrom = intCurrencyExchangeRateTypeId
,intRateTypeIdAmountTo= intCurrencyExchangeRateTypeId
,intFiscalPeriodId
,dtmAccrual
,dtmDate
,dblRateAmountFrom = BAF.dblRate
,dblRateAmountTo = BAT.dblRate
,dblCrossRate =ROUND(dblAmountForeignTo/dblAmountForeignFrom,6)
,dblReverseRate= Round( 1/dblCrossRate, 6)
,dblAmountForeignFrom
,dblAmountForeignTo
,dblAmountFrom = dblAmountForeignFrom * BAF.dblRate
,dblAmountTo =dblAmountForeignTo * BAT.dblRate
,dtmCreated = GETDATE()
,intConcurrencyId = 1
FROM @bankTransfer BT
OUTER APPLY (
    SELECT TOP 1 intCurrencyId, intGLAccountId, B.dblRate FROM tblCMBankAccount 
    OUTER APPLY dbo.fnSMGetForexRate(intCurrencyId, BT.intCurrencyExchangeRateTypeId, BT.dtmAccrual) B
    WHERE intBankAccountId = BT.intBankAccountIdFrom
) BAF
OUTER APPLY (
    SELECT TOP 1 intCurrencyId, intGLAccountId,B.dblRate FROM tblCMBankAccount 
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
,dblDifference
,dtmCreated
,intConcurrencyId
)
SELECT 
 intEntityId
,intBankTransactionTypeId
,intBankTransferTypeId
,strTransactionId
,strDescription
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
,dblDifference = dblAmountTo - dblAmountFrom
,dtmCreated
,intConcurrencyId
FROM CTE BT

SELECT @Id = SCOPE_IDENTITY()


