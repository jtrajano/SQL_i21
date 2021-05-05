CREATE VIEW [dbo].[vyuCMUndepositedPayment]
AS 
SELECT 
Undep.intUndepositedFundId
,Undep.intBankAccountId
,Undep.strSourceTransactionId
,Undep.intSourceTransactionId
,Undep.intLocationId
,ISNULL(Loc.strLocationName,'') strLocationName
,Undep.dtmDate
,Undep.strName
,Undep.dblAmount
,Undep.strSourceSystem
,Undep.strPaymentMethod
,Undep.intBankDepositId
,Undep.intCreatedUserId
,ISNULL(EM.strName,'') strUserName
,Undep.dtmCreated
,Undep.intCurrencyId
,RCV.strBatchId
,Pay.strCardType
,Undep.strPaymentSource
,Undep.strEODNumber
,Undep.strEODDrawer 
,Undep.ysnEODComplete 
FROM tblCMUndepositedFund Undep
LEFT JOIN tblEMEntity EM ON Undep.intCreatedUserId = EM.intEntityId
LEFT JOIN tblSMCompanyLocation Loc ON Undep.intLocationId = Loc.intCompanyLocationId
LEFT JOIN tblSMPayment Pay ON Undep.strSourceTransactionId =  Pay.strTransactionNo
LEFT JOIN tblARPayment RCV ON RCV.strRecordNumber = Undep.strSourceTransactionId
WHERE
Undep.intUndepositedFundId NOT IN( 
	SELECT intUndepositedFundId 
	FROM tblCMBankTransactionDetail BTDtl
	INNER JOIN tblCMBankTransaction BT ON BTDtl.intTransactionId = BT.intTransactionId 
	WHERE BTDtl.intUndepositedFundId IS NOT NULL 
)
AND
Undep.dblAmount <> 0

GO


