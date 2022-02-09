CREATE VIEW [dbo].[vyuAPEntityEFTInformation]
AS
SELECT EFT.intEntityEFTInfoId,
	   EFT.intEntityId,
	   EFT.intBankId,
	   EFT.strBankName COLLATE Latin1_General_CI_AS strBankName,
	   ISNULL(dbo.fnAESDecryptASym(EFT.strAccountNumber), EFT.strAccountNumber) COLLATE Latin1_General_CI_AS strAccountNumber,
	   EFT.intCurrencyId,
	   C.strCurrency COLLATE Latin1_General_CI_AS strCurrency,
	   ISNULL(EFT.ysnDefaultAccount, 0) ysnDefaultAccount
FROM tblEMEntityEFTInformation EFT
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = EFT.intCurrencyId
WHERE EFT.ysnActive = 1