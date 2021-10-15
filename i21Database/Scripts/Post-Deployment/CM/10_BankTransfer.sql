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

GO
