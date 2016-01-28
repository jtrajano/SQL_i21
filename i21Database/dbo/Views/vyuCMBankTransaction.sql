CREATE VIEW [dbo].[vyuCMBankTransaction]
AS 

SELECT 
*,
ysnPayeeEFTInfoActive = ISNULL((
		SELECT TOP 1 ysnActive FROM tblEntityEFTInformation EFTInfo 
		WHERE intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),0),
ysnPayeeEFTInfoExpired = ISNULL((
		SELECT TOP 1 (CASE WHEN dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END)  FROM tblEntityEFTInformation EFTInfo 
		WHERE intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),0),
strPayeeBankName = ISNULL((
		SELECT TOP 1 strBankName FROM tblEntityEFTInformation EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),''),
strPayeeBankAccountNumber  = ISNULL((
		SELECT TOP 1 strAccountNumber FROM tblEntityEFTInformation EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),''),
strPayeeBankRoutingNumber = ISNULL((
		SELECT TOP 1 strRTN FROM tblEntityEFTInformation EFTInfo 
		INNER JOIN tblCMBank BANK ON EFTInfo.intBankId = BANK.intBankId
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),''),
strEntityNo = ISNULL((
		SELECT strEntityNo FROM tblEntity
		WHERE intEntityId = intPayeeId
),''),
strSocialSecurity = ISNULL((
		SELECT Emp.strSocialSecurity FROM 
		tblPRPaycheck PayCheck  INNER JOIN
		tblPREmployee Emp ON PayCheck.intEntityEmployeeId = Emp.intEntityEmployeeId
		WHERE PayCheck.strPaycheckId = tblCMBankTransaction.strTransactionId 
),'')
FROM tblCMBankTransaction
WHERE dbo.fnIsDepositEntry(strLink) = 0
