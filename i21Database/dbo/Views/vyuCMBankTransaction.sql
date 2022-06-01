﻿CREATE VIEW dbo.vyuCMBankTransaction
AS
SELECT   
A.*,  
intEntityEFTInfoId = ISNULL(A.intEFTInfoId, EFT.intEntityEFTInfoId),  
EFT.ysnDefaultAccount,  
strBankTransactionTypeName = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = A.intBankTransactionTypeId),  
ysnPayeeEFTInfoActive =ISNULL(EFT.ysnActive,0),  
dtmEFTEffectiveDate = EFT.dtmEffectiveDate,  
ysnPrenoteSent = ISNULL(EFT.ysnPrenoteSent,0),  
strAccountType = ISNULL(EFT.strAccountType,''),   
strPayeeBankName = ISNULL(EFT.strBankName, ''),  
strPayeeBankAccountNumber  = ISNULL(EFT.strAccountNumber,''),  
strPayeeBankRoutingNumber = ISNULL(EFT.strRTN,''),  
strEntityNo = ISNULL((  
  SELECT strEntityNo FROM tblEMEntity  
  WHERE intEntityId = intPayeeId  
),''),  
strSocialSecurity = ISNULL((  
  SELECT Emp.strSocialSecurity FROM   
  tblPRPaycheck PayCheck  INNER JOIN  
  tblPREmployee Emp ON PayCheck.intEntityEmployeeId = Emp.[intEntityId]  
  WHERE PayCheck.strPaycheckId = A.strTransactionId   
),''),  
strAccountClassification = ISNULL(EFT.strAccountClassification,''),  
dblDebit = ISNULL(Detail.dblDebit,0),  
dblCredit = ISNULL(Detail.dblCredit,0),
strBankName = B.strBankName,
strBankAccountType = BAT.strBankAccountType,
strBrokerageAccount = BRA.strAccountNumber
FROM tblCMBankTransaction A  
LEFT JOIN tblCMBankAccount BA 
	ON BA.intBankAccountId = A.intBankAccountId
LEFT JOIN tblCMBank B
	ON B.intBankId = BA.intBankId
LEFT JOIN tblCMBankAccountType BAT
	ON BAT.intBankAccountTypeId = BA.intBankAccountTypeId
LEFT JOIN tblRKBrokerageAccount BRA
	ON BRA.intBrokerageAccountId = BA.intBrokerageAccountId
OUTER APPLY (  
 SELECT SUM(ISNULL(dblDebit,0)) dblDebit, SUM(ISNULL(dblCredit,0)) dblCredit FROM tblCMBankTransactionDetail WHERE intTransactionId = A.intTransactionId  
)Detail  
OUTER APPLY (  
 SELECT TOP 1 intEntityId, ysnActive, ysnPrenoteSent,strAccountType, BANK.strBankName, strAccountNumber, 
 strRTN, strAccountClassification, intEntityEFTInfoId, dtmEffectiveDate, ysnDefaultAccount 
 FROM [tblEMEntityEFTInformation] E   
 LEFT JOIN vyuCMBank BANK ON E.intBankId = BANK.intBankId  
  WHERE ysnActive = 1    
  AND intEntityId = intPayeeId
  ORDER BY dtmEffectiveDate desc  
  

)EFT

