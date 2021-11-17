﻿CREATE FUNCTION [dbo].[fnCMGetPostedBankTransactionFromDate]
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
        BT.dblAmount,
        BA.intGLAccountId,
		BT.intCompanyLocationId
    FROM [dbo].[tblCMBankTransaction] BT
    JOIN [dbo].[tblCMBankAccount] BA ON BA.intBankAccountId = BT.intBankAccountId
    WHERE 
        BT.ysnPosted = 1
        AND BA.intBankAccountId = @intBankAccountId
		AND 
        (CASE WHEN @dtmFrom IS NOT NULL
            THEN CASE WHEN (BT.dtmDate BETWEEN @dtmFrom AND @dtmTo) THEN 1 ELSE 0 END
            ELSE CASE WHEN (BT.dtmDate <= @dtmTo) THEN 1 ELSE 0 END
            END
        ) = 1