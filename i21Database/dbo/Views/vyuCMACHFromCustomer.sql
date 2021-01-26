﻿CREATE VIEW [dbo].[vyuCMACHFromCustomer]
AS
SELECT DISTINCT       
BT.intBankAccountId, 
Unde.intUndepositedFundId AS intTransactionId,
BT.intTransactionId AS intBDEPTransactionId, 
BT.strTransactionId,
BT.ysnCheckToBePrinted, 
BT.dtmDate, 
Unde.strSourceTransactionId AS strRecordNo, 
Unde.strName, 
Pay.intEntityCustomerId,
BT.intBankTransactionTypeId, 
Unde.dblAmount, 
dbo.fnConvertNumberToWord(Unde.dblAmount) COLLATE Latin1_General_CI_AS AS strAmountInWords,
BT.intCurrencyId, 
BT.dblExchangeRate, 
BT.intEntityId, 
BT.ysnCheckVoid,
Unde.ysnToProcess, 
Unde.ysnCommitted, 
Unde.ysnGenerated, 
Unde.ysnNotified, 
Unde.strNotificationStatus, 
Unde.intBankFileAuditId,
Unde.strReferenceNo, 
Unde.ysnHold,
Unde.strHoldReason,
Unde.intConcurrencyId,
ysnPayeeEFTInfoActive = ISNULL((
		SELECT TOP 1 ysnActive FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),0),
strPayeeEFTInfoEffective = ISNULL((
		SELECT TOP 1 (CASE WHEN dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) THEN 'EFFECTIVE' ELSE 'INEFFECTIVE' END)  FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),'INVALID') COLLATE Latin1_General_CI_AS,
ysnPrenoteSent = ISNULL((
		SELECT TOP 1 ysnPrenoteSent FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),0),
strAccountType = ISNULL((
		SELECT TOP 1 strAccountType FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),''),
strPayeeBankName = ISNULL((
		SELECT TOP 1 strBankName FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),''),
strPayeeBankAccountNumber  = ISNULL((
		SELECT TOP 1 dbo.fnAESDecryptASym(strAccountNumber) FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),'')COLLATE Latin1_General_CI_AS,
strPayeeBankRoutingNumber = ISNULL((
		SELECT TOP 1 dbo.fnAESDecryptASym(strRTN) FROM [tblEMEntityEFTInformation] EFTInfo 
		INNER JOIN tblCMBank BANK ON EFTInfo.intBankId = BANK.intBankId
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),'')COLLATE Latin1_General_CI_AS,
strEntityNo = ISNULL((
		SELECT strEntityNo FROM tblEMEntity
		WHERE intEntityId = Pay.intEntityCustomerId
),'')
FROM            dbo.tblCMBankTransaction AS BT INNER JOIN
                         dbo.tblCMBankTransactionDetail AS BTD ON BT.intTransactionId = BTD.intTransactionId INNER JOIN
                         dbo.tblCMUndepositedFund AS Unde ON BTD.intUndepositedFundId = Unde.intUndepositedFundId INNER JOIN
                         dbo.tblARPayment AS Pay ON Unde.intSourceTransactionId = Pay.intPaymentId
                         
						 
WHERE        (Pay.intPaymentMethodId = 2)
GO