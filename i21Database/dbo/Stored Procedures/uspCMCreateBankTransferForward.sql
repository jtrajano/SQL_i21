CREATE PROCEDURE uspCMCreateBankTransferForward
(
@BankTransfer CMBankTransferType READONLY,
@Id INT OUT
)
AS
DECLARE @intStartingNumber INT = 12, @BankTransferID NVARCHAR(30), @intBankTransactionTypeId INT = 4, @intBankTransferTypeId  INT = 3
EXEC dbo.uspSMGetStartingNumber @intStartingNumber , @BankTransferID OUTPUT
DECLARE @intDefaultCurrencyId INT 
SELECT @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

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
,dblDifference
,dtmCreated
,strDerivativeId
,intFutOptTransactionId
,intFutOptTransactionHeaderId
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
,dblDifference = dblAmountTo - dblAmountFrom
,dtmCreated
,strDerivativeId
,intFutOptTransactionId
,intFutOptTransactionHeaderId
,intConcurrencyId
FROM CTE BT

SELECT @Id = SCOPE_IDENTITY()


