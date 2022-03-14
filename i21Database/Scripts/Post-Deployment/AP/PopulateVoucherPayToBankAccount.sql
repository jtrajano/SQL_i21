GO

PRINT N'START: POPULATING VOUCHER PAY TO BANK ACCOUNT'
--POPULATE EMPTY VOUCHER PAY TO ACCOUNT TO VENDOR'S DEFAULT
UPDATE B
SET B.intPayToBankAccountId = EFT.intEntityEFTInfoId
FROM tblAPBill B
INNER JOIN tblEMEntityEFTInformation EFT ON EFT.intEntityId = B.intEntityVendorId AND EFT.intCurrencyId = B.intCurrencyId AND EFT.ysnDefaultAccount = 1
WHERE B.intPayToBankAccountId IS NULL

PRINT N'SUCCESS: POPULATING VOUCHER PAY TO BANK ACCOUNT'

GO
PRINT N'START: POPULATING BANK TRANSACTION EFT ACCOUNT'

IF NOT EXISTS (SELECT 1 FROM tblCMDataFixLog WHERE strDescription = 'Update NULL tblCMBankTransaction.intEFTInfo')
BEGIN
    UPDATE C SET intEFTInfoId = B.intPayToBankAccountId 
    FROM tblCMBankTransaction C 
    CROSS APPLY(
        SELECT TOP 1 intPayToBankAccountId FROM
        tblAPPayment P JOIN tblAPBill B ON B.intPaymentId = P.intPaymentId
        WHERE P.strPaymentRecordNum = C.strTransactionId 
        AND B.intPayToBankAccountId IS NOT NULL 
        AND C.intEFTInfoId IS NULL
    )BP
    INSERT INTO tblCMDataFixLog(dtmDate,strDescription,intRowsAffected) SELECT GETDATE(), 'Update NULL tblCMBankTransaction.intEFTInfo', @@ROWCOUNT
END

PRINT N'SUCCESS: POPULATING BANK TRANSACTION EFT ACCOUNT'
GO