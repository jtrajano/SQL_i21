CREATE VIEW [dbo].vyuCMUndepositedFund
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
,SUBSTRING(Pay.strPaymentInfo,1,PATINDEX('% ending%',Pay.strPaymentInfo)) as strCardType
,GL.strCode strCompanySegment
,GL.strAccountId
FROM tblCMUndepositedFund Undep
LEFT JOIN tblEMEntity EM ON Undep.intCreatedUserId = EM.intEntityId
LEFT JOIN tblSMCompanyLocation Loc ON Undep.intLocationId = Loc.intCompanyLocationId
LEFT JOIN tblSMPayment Pay ON Undep.intSourceTransactionId =  Pay.intTransactionId
OUTER APPLY(
    SELECT strAccountId, strCode FROM tblGLAccount A JOIN tblGLAccountSegment B ON A.intCompanySegmentId = B.intAccountSegmentId WHERE intAccountId = Undep.intAccountId
)GL