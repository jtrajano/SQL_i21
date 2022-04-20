CREATE PROCEDURE uspCMCreateBankSwapLong
	@intSwapShortId INT
AS

DECLARE @intBankSwapId INT, @intSwapLongId INT, @strTransactionId NVARCHAR(40)
select @intBankSwapId = intBankSwapId --, @intSwapLongId = intSwapLongId 
from tblCMBankSwap WHERE @intSwapShortId = intSwapShortId

DECLARE @intBTForwardToFXGLAccountId INT,@intBTForwardFromFXGLAccountId INT
SELECT TOP 1 
@intBTForwardToFXGLAccountId = intBTForwardToFXGLAccountId,
@intBTForwardFromFXGLAccountId = intBTForwardFromFXGLAccountId
     
    FROM tblCMCompanyPreferenceOption  

DECLARE @dblCreditForeign DECIMAL(18,6)
DECLARE @defaultCurrencyId INT
SELECT @defaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference


SELECT TOP 1 strTransactionId FROM tblCMBankTransfer where intTransactionId = @intSwapShortId

EXEC uspSMGetStartingNumber 12, @strTransactionId OUT

insert into tblCMBankTransfer (
strTransactionId,
intBankTransferTypeId, 
intBankAccountIdFrom, 
intBankAccountIdTo,
intGLAccountIdFrom, 
intGLAccountIdTo, 
intCurrencyIdAmountFrom,
intCurrencyIdAmountTo,
dblAmountTo,
dblAmountForeignTo,
dblRateAmountTo,
dblAmountForeignFrom,
dblAmountFrom, 
dblRateAmountFrom,
intRateTypeIdAmountFrom,
dtmDate, 
dtmInTransit,
intBankTransactionTypeId, 
dblCrossRate,
dblReverseRate,
dblAmountSettlementFrom,
dblRateAmountSettlementFrom,
intConcurrencyId
)
select 
@strTransactionId, 
5, 
intBankAccountIdTo, 
intBankAccountIdFrom, 
intGLAccountIdTo, 
intGLAccountIdFrom,
intCurrencyIdAmountTo,
intCurrencyIdAmountFrom,
dblAmountTo = dblAmountFrom,
dblAmountForeignTo = dblAmountForeignFrom,
dblRateAmountFrom,
GLDetail.dblCreditForeign,
GLDetail.dblCredit,
GLDetail.dblExchangeRate,
intRateTypeIdAmountFrom = GLDetail.intCurrencyExchangeRateTypeId,
DATEADD(DAY, 1, dtmDate),
DATEADD(DAY, 1, dtmDate), 
4,
ROUND(dblAmountFrom/dblAmountTo,6),
ROUND(dblAmountTo/dblAmountFrom,6),
dblAmountSettlementFrom = CASE WHEN intCurrencyIdAmountTo = @defaultCurrencyId THEN GLDetail.dblCreditForeign ELSE 0 END,
dblRateAmountSettlementFrom = CASE WHEN intCurrencyIdAmountTo = @defaultCurrencyId THEN 1 ELSE 0 END,
1
from tblCMBankTransfer  A
OUTER APPLY(
	SELECT TOP 1 dblCreditForeign, dblExchangeRate, intCurrencyExchangeRateTypeId, dblCredit
    FROM tblGLDetail 
	WHERE intAccountId = @intBTForwardToFXGLAccountId
	AND strTransactionId =A.strTransactionId
	AND ysnIsUnposted = 0
	ORDER by intGLDetailId DESC
)GLDetail
where intTransactionId = @intSwapShortId

SET @intSwapLongId = SCOPE_IDENTITY()
UPDATE tblCMBankSwap set intSwapLongId =@intSwapLongId, ysnLockLong = 0 WHERE intBankSwapId = @intBankSwapId