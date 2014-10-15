CREATE VIEW [dbo].[vyuEntityEFTInformation]
AS
SELECT
intEntityEFTInfoId
,intEntityId
,EFT.intBankId
,Bank.strBankName
,strAccountNumber
,strAccountType
,strAccountClassification
,dtmEffectiveDate
,ysnPrintNotifications
,ysnActive
,strPullARBy
,ysnPullTaxSeparately
,ysnRefundBudgetCredits
,ysnPrenoteSent
FROM tblEntityEFTInformation as EFT
INNER JOIN tblCMBank as Bank ON EFT.intBankId = Bank.intBankId