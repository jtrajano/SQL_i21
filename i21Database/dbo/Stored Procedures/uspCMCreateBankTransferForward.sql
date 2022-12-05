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
,dblCrossRate =ROUND(dblAmountForeignTo/dblAmountForeignFrom,6)
,dblReverseRate= Round(dblAmountForeignFrom/dblAmountForeignTo, 6)
,dblAmountForeignFrom = ROUND(dblAmountForeignFrom, 2)
,dblAmountForeignTo = ROUND(dblAmountForeignTo, 2)
,dblAmountFrom = ROUND(dblAmountForeignFrom * BAF.dblRate, 2)
,dblAmountTo = ROUND(dblAmountForeignTo * BAT.dblRate, 2)
,strDerivativeId
,intFutOptTransactionId
,intFutOptTransactionHeaderId
,dtmCreated = GETDATE()
,DER.intSegmentCodeId intItemLOBSegmentId
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
OUTER APPLY(
    SELECT TOP 1 SM.intSegmentCodeId
    FROM tblRKFutOptTransaction der
    JOIN tblCTContractDetail CD
        ON CD.intContractDetailId = der.intContractDetailId
    JOIN tblCTContractHeader CH
        ON CH.intContractHeaderId = CD.intContractDetailId
    JOIN tblICCommodity C
        ON C.intCommodityId = CH.intCommodityId
    JOIN tblSMLineOfBusiness SM ON SM.intLineOfBusinessId = C.intLineOfBusinessId
    WHERE der.strInternalTradeNo = BT.strDerivativeId

)DER

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
,intItemLOBSegmentId
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
,intItemLOBSegmentId
,intConcurrencyId
FROM CTE BT

SELECT @Id = SCOPE_IDENTITY()


