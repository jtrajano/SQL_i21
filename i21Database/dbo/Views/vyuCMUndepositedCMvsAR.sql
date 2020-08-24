CREATE VIEW vyuCMUndepositedCMvsAR    
AS    
WITH ARPosting AS    
(    
 select     
 AR.strRecordNumber,    
 GL.strAccountId,     
 AR.intAccountId,    
 GL.dblAmount,    
 intUndepositedFundId,    
 GL.dtmDate,    
 CMUF.intBankDepositId,    
 ysnPosted = case when GL.intGLDetailId is null then  cast(0 as bit) else  cast(1 as bit) end    
 from vyuARPostedTransactionForUndeposited AR    
 left join tblCMUndepositedFund CMUF on CMUF.strSourceTransactionId = AR.strRecordNumber    
 outer apply (    
  select TOP 1 dtmDate, intGLDetailId, (dblDebit- dblCredit) dblAmount, strAccountId from vyuGLDetail where     
  strTransactionId = AR.strRecordNumber and  ysnIsUnposted = 0    
  and intAccountId =  AR.intAccountId --  in( select intAccountId from vyuGLAccountDetail where strAccountCategory = 'Undeposited Funds')
 )GL    

),    
CMPosting AS(    
select     
CM.strTransactionId,    
GL.intAccountId,    
CMUF.intUndepositedFundId,    
(CMD.dblCredit- CMD.dblDebit) CMAmount,    
GL.dblAmount GLAmount,    
ysnPosted = case when GL.intGLDetailId is null then  cast(0 as bit) else  cast(1 as bit) end,    
GL.strAccountId,    
GL.dtmDate    
from tblCMBankTransactionDetail CMD    
left join tblCMUndepositedFund CMUF on CMUF.intUndepositedFundId = CMD.intUndepositedFundId    
left join tblCMBankTransaction CM on CM.intTransactionId = CMD.intTransactionId    
outer apply (    
  select TOP 1 intGLDetailId,intAccountId, dtmDate, strAccountId,  (dblCredit-dblDebit)dblAmount  from 
  vyuGLDetail where strTransactionId = CM.strTransactionId 
  and (dblCredit-dblDebit) = (CMD.dblCredit-CMD.dblDebit) and ysnIsUnposted = 0    
  and intAccountId = CMD.intGLAccountId --in (select intAccountId from vyuGLAccountDetail where strAccountCategory = 'Undeposited Funds'    
   --union all  select intARAccountId from tblARCompanyPreference    
      
)GL    
    
)    
select     
cast( ROW_NUMBER() over(order by AR.strRecordNumber) as int) intRowId,  
AR.strRecordNumber,    
AR.strAccountId strARAccountId,    
CM.strAccountId strCMAccountId,    
CM.strTransactionId ,    
AR.dtmDate dtmARDate,    
CM.dtmDate dtmCMDate,    
AR.dblAmount dblARAmount,    
CM.GLAmount dblCMAmount,    
isnull(AR.ysnPosted,0) ysnARPosted,    
isnull(CM.ysnPosted, 0) ysnCMPosted,    
strStatus = case     
when isnull(AR.ysnPosted,0) = 1 and ISNULL(CM.ysnPosted , 0) = 0 and AR.intUndepositedFundId is null then 'Missing in Undeposited'     
when isnull(AR.ysnPosted,0) = 0 and ISNULL(CM.ysnPosted , 0) = 0 and AR.intUndepositedFundId is null then 'Unposted AR' 
when isnull(AR.ysnPosted,0) = 0 and ISNULL(CM.ysnPosted , 0) = 0 and AR.intUndepositedFundId is NOT null then 'Unposted AR/CM with ' 
when isnull(AR.ysnPosted,0) = 1 and ISNULL(CM.ysnPosted , 0) = 0 and AR.intUndepositedFundId is not null then 'Unposted CM'    
when AR.intBankDepositId is null and isNull(AR.ysnPosted,0) = 1 and isnull(CM.ysnPosted,0) = 0 and AR.intUndepositedFundId is not null then 'Undeposited'      
when AR.dblAmount = CM.GLAmount  and isnull(AR.ysnPosted,0) = 1 and isnull(CM.ysnPosted,0) =1 then 'Matched Amount'     
when AR.dblAmount <> CM.GLAmount  and isnull(AR.ysnPosted,0) = 1 and isnull(CM.ysnPosted,0) =1 then 'Mismatched Amount'     
else 'Error'end,    
strAccountMatch = case when isnull(AR.ysnPosted,0) = 1 and ISNULL(CM.ysnPosted , 0) = 1 AND AR.intAccountId != CM.intAccountId then 'Account Mismatch' else '' end
from     
ARPosting AR left join    
CMPosting CM on CM.intUndepositedFundId = AR.intUndepositedFundId    
    

