﻿CREATE  VIEW [dbo].[vyuCMBankTransaction]
AS 
SELECT 
A.*,
strBankTransactionTypeName = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = A.intBankTransactionTypeId),
ysnPayeeEFTInfoActive = ISNULL((
		SELECT TOP 1 ysnActive FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),0),
dtmEFTEffectiveDate = 
		(SELECT TOP 1 dtmEffectiveDate  FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 
		AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc),
strPayeeEFTInfoEffective = ISNULL((
		SELECT TOP 1 (CASE WHEN dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) THEN 'EFFECTIVE' ELSE 'INEFFECTIVE' END)  FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 
		AND dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) 
		AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),'INVALID') COLLATE Latin1_General_CI_AS,
ysnPrenoteSent = ISNULL((
		SELECT TOP 1 ysnPrenoteSent FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),0),
strAccountType = ISNULL((
		SELECT TOP 1 strAccountType FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),''),
strPayeeBankName = ISNULL((
		SELECT TOP 1 strBankName FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),''),
strPayeeBankAccountNumber  = ISNULL((
		SELECT TOP 1 strAccountNumber FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),''),
strPayeeBankRoutingNumber = ISNULL((
		SELECT TOP 1 strRTN FROM [tblEMEntityEFTInformation] EFTInfo 
		INNER JOIN tblCMBank BANK ON EFTInfo.intBankId = BANK.intBankId
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),''),
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
strAccountClassification = ISNULL((
		SELECT TOP 1 strAccountClassification FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),''),
dblDebit = ISNULL(Detail.dblDebit,0),
dblCredit = ISNULL(Detail.dblCredit,0)
FROM tblCMBankTransaction A
OUTER APPLY (
	SELECT SUM(ISNULL(dblDebit,0)) dblDebit, SUM(ISNULL(dblCredit,0)) dblCredit FROM tblCMBankTransactionDetail WHERE intTransactionId = A.intTransactionId
)Detail
GO