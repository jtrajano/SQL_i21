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
 ysnPosted = AR.ysnPosted  ,
 GL.intGLDetailId
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
GL.strAccountId,   
GL.intAccountId,  
CMUF.intUndepositedFundId,      
(CMD.dblCredit- CMD.dblDebit) CMAmount,      
ysnPosted = CM.ysnPosted,  
GL.dtmDate,
GL.intGLDetailId
from tblCMBankTransactionDetail CMD      
left join tblCMUndepositedFund CMUF on CMUF.intUndepositedFundId = CMD.intUndepositedFundId      
left join tblCMBankTransaction CM on CM.intTransactionId = CMD.intTransactionId      
left join vyuGLDetail GL ON GL.strTransactionId = CM.strTransactionId   
  and (GL.dblCredit-GL.dblDebit) = (CMD.dblCredit-CMD.dblDebit) and ysnIsUnposted = 0      
  and intAccountId = CMD.intGLAccountId --in (select intAccountId from vyuGLAccountDetail where strAccountCategory = 'Undeposited Funds'            
) ,  
PartitionCMPosting as(
select 
 ROW_NUMBER() OVER(PARTITION BY intUndepositedFundId  ORDER BY intUndepositedFundId ) rowId, *
  from CMPosting 
),
query as(  
select       
cast( ROW_NUMBER() over(order by AR.strRecordNumber) as int) intRowId,    
AR.strRecordNumber,      
AR.strAccountId strARAccountId,      
CM.strAccountId strCMAccountId,      
CM.strTransactionId ,      
AR.dtmDate dtmARDate,      
CM.dtmDate dtmCMDate,      
AR.dblAmount dblARAmount,      
CM.CMAmount dblCMAmount,      
isnull(AR.ysnPosted,0) ysnARPosted,      
isnull(CM.ysnPosted, 0) ysnCMPosted,      
ysnGLMismatch = case when isnull(AR.ysnPosted,0) = 1 and ISNULL(CM.ysnPosted , 0) = 1 AND AR.intAccountId != CM.intAccountId then cast(1 as bit) else cast(0 as bit) end,  
ysnARGLEntryError = case when AR.ysnPosted = 1 and AR.dblAmount is null then cast(1 as bit) else cast (0 as bit) end,  
ysnCMGLEntryError = case when CM.ysnPosted = 1 and CM.CMAmount is null then cast(1 as bit) else cast (0 as bit) end,  
AR.intBankDepositId,  
AR.intUndepositedFundId,
AR.intGLDetailId ARGLDetailId,
CM.intGLDetailId CMGLDetailId
from       
ARPosting AR left join      
PartitionCMPosting CM on CM.intUndepositedFundId = AR.intUndepositedFundId      
AND CM.rowId = 1
)  
select   
strStatus = case       
when isnull(Q.ysnARPosted,0) = 1 and Q.intUndepositedFundId is null then 'Missing in Undeposited'       
when isnull(Q.ysnARPosted,0) = 0 and ISNULL(Q.ysnCMPosted , 0) = 0 and Q.intUndepositedFundId is NOT null then 'Unposted AR/CM in Undeposited'   
when Q.dblARAmount <> Q.dblCMAmount  and isnull(Q.ysnARPosted,0) = 1 and isnull(Q.ysnCMPosted,0) =1 then 'Mismatched Amount'       
when Q.ysnARGLEntryError = 1 or Q.ysnCMGLEntryError =1 then 'Posting Error'  
when ysnGLMismatch = 1 then 'GL Account Matching Error'  
--when isnull(Q.ysnARPosted,0) = 0 and ISNULL(Q.ysnCMPosted , 0) = 0 and Q.intUndepositedFundId is null then 'Unposted AR'   
--when isnull(Q.ysnARPosted,0) = 1 and ISNULL(Q.ysnCMPosted , 0) = 0 and Q.intUndepositedFundId is not null then 'Unposted CM'      
--when Q.intBankDepositId is null and isNull(Q.ysnARPosted,0) = 1 and isnull(Q.ysnCMPosted,0) = 0 and Q.intUndepositedFundId is not null then 'Undeposited'        
--when Q.dblARAmount = Q.dblCMAmount  and isnull(Q.ysnARPosted,0) = 1 and isnull(Q.ysnCMPosted,0) =1 then 'Matched Amount'       
else 'Good'end,      
*  from  
query Q  