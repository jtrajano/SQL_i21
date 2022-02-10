CREATE VIEW dbo.vyuCMBankTransaction
AS
SELECT   
A.*,  
EFT.intEntityEFTInfoId,  
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
dblCredit = ISNULL(Detail.dblCredit,0)  
FROM tblCMBankTransaction A  
OUTER APPLY (  
 SELECT SUM(ISNULL(dblDebit,0)) dblDebit, SUM(ISNULL(dblCredit,0)) dblCredit FROM tblCMBankTransactionDetail WHERE intTransactionId = A.intTransactionId  
)Detail  
outer apply (  
 SELECT TOP 1 intEntityId, ysnActive, ysnPrenoteSent,strAccountType, BANK.strBankName, strAccountNumber, strRTN, strAccountClassification, intEntityEFTInfoId, dtmEffectiveDate, ysnDefaultAccount 
 FROM [tblEMEntityEFTInformation] E   
 LEFT JOIN vyuCMBank BANK ON E.intBankId = BANK.intBankId  
  WHERE ysnActive = 1    
  AND ysnDefaultAccount = 1  
  and intEntityId = intPayeeId
  ORDER BY dtmEffectiveDate desc  

)EFT