CREATE VIEW [dbo].[vyuCMACHFromCustomer]
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
EFT.intEntityEFTInfoId,
ysnPayeeEFTInfoActive = ISNULL((
		SELECT TOP 1 ysnActive FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),0),
dtmEFTEffectiveDate = 
		(SELECT TOP 1 dtmEffectiveDate  FROM [tblEMEntityEFTInformation] EFTInfo 
			WHERE EFTInfo.ysnActive = 1 
			AND intEntityId =  Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc),
ysnPrenoteSent = ISNULL((
		SELECT TOP 1 ysnPrenoteSent FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),0),
strAccountType = ISNULL((
		SELECT TOP 1 strAccountType FROM [tblEMEntityEFTInformation] EFTInfo 
		WHERE EFTInfo.ysnActive = 1 AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc
),''),
strPayeeBankName = ISNULL(EFT.strBankName,''),
strPayeeBankAccountNumber  = ISNULL(EFT.strAccountNumber,'')COLLATE Latin1_General_CI_AS,
strPayeeBankRoutingNumber = ISNULL(EFT.strRTN,'')COLLATE Latin1_General_CI_AS,
strEntityNo = ISNULL((
		SELECT strEntityNo FROM tblEMEntity
		WHERE intEntityId = Pay.intEntityCustomerId
),'')
FROM            dbo.tblCMBankTransaction AS BT INNER JOIN
                         dbo.tblCMBankTransactionDetail AS BTD ON BT.intTransactionId = BTD.intTransactionId INNER JOIN
                         dbo.tblCMUndepositedFund AS Unde ON BTD.intUndepositedFundId = Unde.intUndepositedFundId INNER JOIN
                         dbo.tblARPayment AS Pay ON Unde.intSourceTransactionId = Pay.intPaymentId
OUTER APPLY(
		SELECT TOP 1 intEntityEFTInfoId, strRTN,
		strAccountNumber , EFTInfo.strBankName FROM [tblEMEntityEFTInformation] EFTInfo 
		JOIN vyuCMBank B ON B.intBankId = EFTInfo.intBankId
		WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = Pay.intEntityCustomerId ORDER BY dtmEffectiveDate desc

)EFT

						 
WHERE        (Pay.intPaymentMethodId = 2)
GO