GO
PRINT ('Update Bank Deposit Foreign Debit and Credit')
GO
    DECLARE @intDefaultCurrencyId INT = NULL;
    SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

    IF (@intDefaultCurrencyId IS NOT NULL)
    BEGIN
        UPDATE B
            SET B.dblCreditForeign = CASE WHEN ISNULL(B.dblCreditForeign, 0) = 0 THEN ISNULL(B.dblCredit, 0) ELSE  B.dblCreditForeign END,
                B.dblDebitForeign = CASE WHEN ISNULL(B.dblDebitForeign, 0) = 0 THEN ISNULL(B.dblDebit, 0) ELSE  B.dblDebitForeign END
        FROM tblCMBankTransaction A
        JOIN tblCMBankTransactionDetail B ON B.intTransactionId = A.intTransactionId
        WHERE A.intBankTransactionTypeId = 1 AND A.intCurrencyId = @intDefaultCurrencyId
    END
GO
PRINT ('Finished updating Bank Deposit Foreign Debit and Credit')
GO