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
--dblAmount, 
--dblAmountFrom, 
dblAmountForeignFrom,
--dblRateAmountFrom,
--intRateTypeIdAmountFrom,
dtmDate, 
dtmInTransit,
intBankTransactionTypeId, 
-- dblAmountForeignTo,
-- dblAmountTo,
-- dblRateAmountTo,
-- intRateTypeIdAmountTo,
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
--dblAmount = GLDetail.dblCredit,
--dblAmountFrom = GLDetail.dblCredit,
dblAmountForeignFrom = GLDetail.dblCreditForeign,
--dblRateAmountFrom =GLDetail.dblExchangeRate,
--intRateTypeIdAmountFrom = GLDetail.intCurrencyExchangeRateTypeId,
DATEADD(DAY, 1, dtmDate),
DATEADD(DAY, 1, dtmDate), 
4,
-- dblAmountForeignTo = GLDetail1.dblDebitForeign,
-- dblAmountTo = GLDetail1.dblDebit,
-- dblRateAmountTo=GLDetail1.dblExchangeRate,
-- intRateTypeIdAmountTo = GLDetail1.intCurrencyExchangeRateTypeId,
1
from tblCMBankTransfer  A
OUTER APPLY(
	SELECT dblCreditForeign, dblExchangeRate, intCurrencyExchangeRateTypeId, dblCredit
    FROM tblGLDetail 
	WHERE intAccountId = @intBTForwardToFXGLAccountId
	AND strTransactionId =A.strTransactionId
	AND ysnIsUnposted = 0
)GLDetail

where intTransactionId = @intSwapShortId

SET @intSwapLongId = SCOPE_IDENTITY()
UPDATE tblCMBankSwap set intSwapLongId =@intSwapLongId, ysnLockLong = 0 WHERE intBankSwapId = @intBankSwapId

