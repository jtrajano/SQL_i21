CREATE VIEW [dbo].[vyuEntityEFTInformation]
AS


select 
	intEntityEFTInfoId,
	EFT.intEntityId,
	ENT.strName,
	ENT.strEntityNo,
	EFT.intBankId,
	Bank.strBankName,
	strAccountNumberWithMask = '**********' + RIGHT(dbo.fnAESDecryptASym(strAccountNumber), 4),
	strAccountNumber = dbo.fnAESDecryptASym(strAccountNumber),
	strAccountType,
	strAccountClassification,
	strEFTType = REPLACE(strEFTType, ',', ', '),
	dtmEffectiveDate,
	ysnPrintNotifications,
	ysnActive,
	strPullARBy,
	ysnPullTaxSeparately,
	ysnRefundBudgetCredits,
	ysnPrenoteSent,
	Vendor,
	Customer,
	Employee,
	intCurrencyId,
	strCurrency,
	strIBANWithMask = '**********' + RIGHT(dbo.fnAESDecryptASym(strIBAN), 4),
    strIBAN = dbo.fnAESDecryptASym(strIBAN),
    strSwiftCode,
    strBicCode,
    strBranchCode,
    ysnDefaultAccount,
    strIntermediaryBank,
    strIntermediaryBankAddress,
    strIntermediarySwiftCode,
    strIntermediaryBicCode,
    strNationalBankIdentifier,
    strComment,
    strDetailsOfCharges,
    strFiftySevenFormat,
    strFiftySixFormat,
	strIntermediaryIBANWithMask = '**********' + RIGHT(dbo.fnAESDecryptASym(strIntermediaryIBAN), 4),
    strIntermediaryIBAN = dbo.fnAESDecryptASym(strIntermediaryIBAN),
	intEntityEFTHeaderId


FROM tblEMEntityEFTInformation EFT
	JOIN ( SELECT intEntityId, strEntityNo, strName
	
			FROM tblEMEntity )  ENT

		ON EFT.intEntityId = ENT.intEntityId
	INNER JOIN 
		(SELECT intBankId, strBankName 
			FROM tblCMBank 
		)Bank ON EFT.intBankId = Bank.intBankId
	INNER JOIN (
		SELECT intEntityId, Vendor, Customer, Employee 
		FROM vyuEMEntityType
	) ETYPE 
	ON ETYPE.intEntityId = EFT.intEntityId
