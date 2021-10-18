GO
UPDATE BT SET 
intCurrencyIdAmountFrom =  _From.intCurrencyId,
intCurrencyIdAmountTo =  _To.intCurrencyId 
FROM tblCMBankTransfer BT 
OUTER APPLY(
    SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = BT.intBankAccountIdFrom

)_From
OUTER APPLY(
    SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = BT.intBankAccountIdTo

)_To
WHERE intBankTransferTypeId  IS NULL

UPDATE tblCMBankTransfer SET intBankTransferTypeId = 1 WHERE intBankTransferTypeId  IS NULL

-- Transfer values to new table schema


DECLARE @intDefaultCurrencyId INT
SELECT @intDefaultCurrencyId=intDefaultCurrencyId FROM tblSMCompanyPreference

--UPDATE dblAmountForeignFrom WHERE bank currency FROM is foreign
UPDATE A SET dblAmountForeignFrom = dblAmount 
FROM tblCMBankTransfer A WHERE
intCurrencyIdAmountFrom <> @intDefaultCurrencyId -- default currency
AND ISNULL(A.dblAmountForeignFrom,0) = 0

--UPDATE dblRateAmountFrom = historic rate WHERE FROM currency is foreign
UPDATE A SET dblRateAmountFrom = dbo.fnCMGetBankAccountHistoricRate(A.intBankAccountIdFrom, dtmDate) 
FROM tblCMBankTransfer A
WHERE A.intCurrencyIdAmountFrom <> @intDefaultCurrencyId -- default currency
AND ISNULL(A.dblRateAmountFrom,0) =0

--UPDATE dblAmountFrom WHERE bank currency FROM is foreign
UPDATE A SET 
dblAmountFrom =ROUND(dblAmount * dblRateAmountFrom,2) 
FROM tblCMBankTransfer A WHERE
intCurrencyIdAmountFrom <> @intDefaultCurrencyId -- default currency
AND ISNULL(A.dblAmountFrom,0) = 0


-- Local to local FROM currency

UPDATE A 
SET dblAmountFrom = A.dblAmount , dblAmountTo = A.dblAmount
,dblRateAmountFrom = 1 , dblRateAmountTo =1
 FROM
tblCMBankTransfer A 
WHERE A.intCurrencyIdAmountFrom = A.intCurrencyIdAmountFrom
AND A.intCurrencyIdAmountFrom = @intDefaultCurrencyId
AND (ISNULL(A.dblAmount,0) = 0 OR ISNULL(A.dblAmountFrom,0) = 0 OR
ISNULL(A.dblRateAmountFrom,0) = 0 OR ISNULL(A.dblRateAmountTo,0) = 0
)
--Local to Foreign

 UPDATE A SET 
 dblRateAmountFrom = dblRateAmountTo,
 dblAmountForeignFrom =ROUND( dblAmount/dblRateAmountTo,2),
 dblAmountForeignTo =ROUND( dblAmount/dblRateAmountTo,2)
 FROM tblCMBankTransfer A
 WHERE intCurrencyIdAmountFrom = @intDefaultCurrencyId AND intCurrencyIdAmountTo <> @intDefaultCurrencyId
 AND (ISNULL(dblRateAmountFrom,0) = 0 OR ISNULL(dblAmountForeignFrom,0) = 0 OR ISNULL(dblAmountForeignTo,0) = 0)

  -- Foreign to Local
 UPDATE A SET
 dblAmountForeignTo = A.dblAmount,
 dblAmountTo = ROUND(A.dblAmountForeignFrom * A.dblRateAmountTo,2)
 FROM tblCMBankTransfer A 
 WHERE A.intCurrencyIdAmountFrom <> @intDefaultCurrencyId AND A.intCurrencyIdAmountTo = @intDefaultCurrencyId
 AND( ISNULL(A.dblAmountForeignFrom ,0) = 0  OR ISNULL(A.dblAmountForeignTo,0) = 0 OR ISNULL(A.dblAmountTo,0) = 0)
  

GO
