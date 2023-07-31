PRINT N'EM tblEMEntityEFTInformationtblCMBankTransaction Data fix for CM with non existent EFT Info - START'

UPDATE	tblCMBankTransaction
SET		intEFTInfoId = NULL
WHERE   intEFTInfoId NOT IN (SELECT intEntityEFTInfoId FROM tblEMEntityEFTInformation)

PRINT N'EM tblEMEntityEFTInformationtblCMBankTransaction Data fix for CM with non existent EFT Info - END'


