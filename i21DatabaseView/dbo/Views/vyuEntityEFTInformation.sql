CREATE VIEW [dbo].[vyuEntityEFTInformation]
AS


select 
	intEntityEFTInfoId,
	EFT.intEntityId,
	ENT.strName,
	ENT.strEntityNo,
	EFT.intBankId,
	Bank.strBankName,
	strAccountNumber = '**********' + RIGHT(dbo.fnAESDecryptASym(strAccountNumber), 4),
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
	Employee


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
