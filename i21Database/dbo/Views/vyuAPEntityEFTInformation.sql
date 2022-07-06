CREATE VIEW [dbo].[vyuAPEntityEFTInformation]
AS
SELECT EFT.intEntityEFTInfoId,
	   EFT.intEntityId,
	   EFT.intBankId,
	   B.strBankName,
	   ISNULL(dbo.fnAESDecryptASym(EFT.strAccountNumber), EFT.strAccountNumber) COLLATE Latin1_General_CI_AS strAccountNumber,
	   EFT.intCurrencyId,
	   C.strCurrency,
	   ISNULL(EFT.ysnDefaultAccount, 0) ysnDefaultAccount
FROM tblEMEntityEFTInformation EFT
LEFT JOIN vyuCMBank B ON B.intBankId = EFT.intBankId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = EFT.intCurrencyId
WHERE EFT.ysnActive = 1