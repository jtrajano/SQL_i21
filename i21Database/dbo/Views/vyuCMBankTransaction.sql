CREATE VIEW [dbo].[vyuCMBankTransaction]
AS 

SELECT 
*,
strPayeeBankName = (
		SELECT TOP 1 strBankName FROM tblEntityEFTInformation EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),
strPayeeBankAccountNumber  = (
		SELECT TOP 1 strAccountNumber FROM tblEntityEFTInformation EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
),
strPayeeBankRoutingNumber = (
		SELECT TOP 1 strRTN FROM tblEntityEFTInformation EFTInfo 
		INNER JOIN tblCMBank BANK ON EFTInfo.intBankId = BANK.intBankId
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
)
FROM tblCMBankTransaction
WHERE dbo.fnIsDepositEntry(strLink) = 0
