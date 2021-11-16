CREATE PROCEDURE uspCMCreateBankSwapLong
	@intSwapShortId INT
AS

DECLARE @intBankSwapId INT, @intSwapLongId INT, @strTransactionId NVARCHAR(40)
select @intBankSwapId = intBankSwapId --, @intSwapLongId = intSwapLongId 
from tblCMBankSwap WHERE @intSwapShortId = intSwapShortId


EXEC uspSMGetStartingNumber 12, @strTransactionId OUT

insert into tblCMBankTransfer (strTransactionId,intBankTransferTypeId,  intBankAccountIdFrom, intBankAccountIdTo,intGLAccountIdFrom, 
intGLAccountIdTo, 
intCurrencyIdAmountTo,
intCurrencyIdAmountFrom,

dblAmount, dblAmountFrom, dblAmountForeignFrom,
dblRateAmountFrom,dtmAccrual, dtmDate, intBankTransactionTypeId, intConcurrencyId
)
select @strTransactionId, 5, intBankAccountIdFrom, intBankAccountIdTo, intGLAccountIdFrom, intGLAccountIdTo,
intCurrencyIdAmountTo,
intCurrencyIdAmountFrom,
dblAmount,dblAmountFrom,
dblAmountForeignFrom,
 dblRateAmountFrom,
DATEADD(DAY, 1, dtmDate),DATEADD(DAY, 2, dtmDate), 4,1

 from tblCMBankTransfer where intTransactionId = @intSwapShortId

SET @intSwapLongId = SCOPE_IDENTITY()
UPDATE tblCMBankSwap set intSwapLongId =@intSwapLongId, ysnLockShort = 1, ysnLockLong = 0 WHERE intBankSwapId = @intBankSwapId

