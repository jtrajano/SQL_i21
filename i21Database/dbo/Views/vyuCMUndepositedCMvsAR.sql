CREATE VIEW vyuCMUndepositedCMvsAR      
AS      
WITH 
ARPosting AS      
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
(CMD.dblCredit- CMD.dblDebit) * ISNULL(CMD.dblExchangeRate,1) CMAmount,      
ysnPosted = CM.ysnPosted,  
GL.dtmDate,
GL.intGLDetailId
from tblCMBankTransactionDetail CMD      
left join tblCMUndepositedFund CMUF on CMUF.intUndepositedFundId = CMD.intUndepositedFundId 
left join tblCMBankTransaction CM on CM.intTransactionId = CMD.intTransactionId      
left join vyuGLDetail GL ON GL.strTransactionId = CM.strTransactionId   
  and (GL.dblCredit-GL.dblDebit) = ((CMD.dblCredit-CMD.dblDebit) * ISNULL(CMD.dblExchangeRate,1)) 
  and ysnIsUnposted = 0      
  and GL.intAccountId = CMD.intGLAccountId --in (select intAccountId from vyuGLAccountDetail where strAccountCategory = 'Undeposited Funds'            
) ,  
PartitionCMPosting as(
select 
 ROW_NUMBER() OVER(PARTITION BY intUndepositedFundId  ORDER BY intUndepositedFundId ) rowId, *
  from CMPosting 
),
query as(  
select     
ysnARCMEntry = CAST(1 AS BIT),      
AR.strRecordNumber,      
AR.strAccountId strARAccountId,      
CM.strAccountId strCMAccountId,      
CM.strTransactionId ,      
AR.dtmDate dtmARDate,      
CM.dtmDate dtmCMDate,      
AR.dblAmount dblARAmount,      
CM.CMAmount dblCMAmount,      
isnull(AR.ysnPosted,0 ) ysnARPosted,      
isnull(CM.ysnPosted,0 ) ysnCMPosted,      
ysnGLMismatch = case when isnull(AR.ysnPosted,0) = 1 and ISNULL(CM.ysnPosted , 0) = 1 AND AR.intAccountId != CM.intAccountId then cast(1 as bit) else cast(0 as bit) end,  
ysnARGLEntryError = case when AR.ysnPosted = 1 and AR.dblAmount is null then cast(1 as bit) else cast (0 as bit) end,  
ysnCMGLEntryError = case when CM.ysnPosted = 1 and CM.CMAmount is null then cast(1 as bit) else cast (0 as bit) end,
AR.intBankDepositId,  
AR.intUndepositedFundId,
AR.intGLDetailId ARGLDetailId,
CM.intGLDetailId CMGLDetailId
from       
ARPosting AR join      
PartitionCMPosting CM on CM.intUndepositedFundId = AR.intUndepositedFundId   
AND CM.rowId = 1
UNION ALL
select       
ysnARCMEntry = CAST(0 AS BIT),    
strRecordNumber =  GL.strTransactionId,      
strARAccountId =  GL.strAccountId,      
strCMAccountId = '',      
strTransactionId = '',      
dtmARDate = GL.dtmDate,      
dtmCMDate = NULL,      
dblARAmount = GL.dblDebit - GL.dblCredit,      
dblCMAmount = 0,      
ysnARPosted = CAST(1 AS BIT),      
ysnCMPosted = NULL,      
ysnGLMismatch = NULL, 
ysnARGLEntryError = NULL,  
ysnCMGLEntryError = NULL,  
intBankDepositId = NULL,  
intUndepositedFundId = NULL,
ARGLDetailId = GL.intGLDetailId,
CMGLDetailId = NULL
FROM
vyuGLDetail GL
WHERE strModuleName NOT IN('Cash Management', 'Accounts Receivable', 'Receive Payments')
AND ysnIsUnposted = 0

)  
SELECT  
cast(ROW_NUMBER() over(order by strRecordNumber) as int) intRowId,     
strStatus = case   
WHEN ysnARCMEntry = 0 THEN 'Non-CM/AR GL Entry'    
WHEN isnull(Q.ysnARPosted,0) = 1 and Q.intUndepositedFundId is null then 'Missing in Undeposited'       
WHEN isnull(Q.ysnARPosted,0) = 0 and ISNULL(Q.ysnCMPosted , 0) = 0 and Q.intUndepositedFundId is NOT null then 'Unposted AR/CM in Undeposited'   
WHEN Q.dblARAmount <> Q.dblCMAmount  and isnull(Q.ysnARPosted,0) = 1 and isnull(Q.ysnCMPosted,0) =1 then 'Mismatched Amount'  
WHEN Q.ysnARGLEntryError = 1  then 'AR GL Entry Error'  
WHEN Q.ysnCMGLEntryError =1 then 'CM GL Entry Error'  
WHEN ysnGLMismatch = 1 then 'GL Account Matching Error' 
ELSE 'Good'END,      
*  FROM  
query Q  