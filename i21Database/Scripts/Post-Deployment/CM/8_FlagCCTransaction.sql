GO
PRINT ('Begin marking credit card transaction in bank transaction')
GO
    UPDATE CM SET ysnCCTransaction = 1 
    FROM tblCCSiteHeader CC 
    JOIN tblCMBankTransaction CM ON CM.intTransactionId = CC.intCMBankTransactionId 
    WHERE ysnCCTransaction IS NULL
GO
PRINT ('Finished marking credit card transaction in bank transaction')
GO