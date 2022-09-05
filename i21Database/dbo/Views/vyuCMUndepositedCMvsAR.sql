CREATE VIEW vyuCMUndepositedCMvsAR      
AS      
WITH 
ARPosting AS      
(      
    SELECT       
      AR.strRecordNumber,      
      GL.strAccountId,    
      AR.intAccountId,  
      GL.dblAmount,      
      intUndepositedFundId,      
      GL.dtmDate,      
      CMUF.intBankDepositId,      
      ysnPosted = AR.ysnPosted,
      GL.intGLDetailId,
      GL.strCode,
      GL.strTransactionType,
      GL.strTransactionForm,
      GL.strModuleName,
      GL.intTransactionId,
      ysnValidUndepGLAccount = ISNULL(CL.ysnValidUndepGLAccount, 0)
    FROM vyuARPostedTransactionForUndeposited AR      
    LEFT join tblCMUndepositedFund CMUF on CMUF.strSourceTransactionId = AR.strRecordNumber   

    OUTER apply (      
      SELECT TOP 1 dtmDate,intAccountId, intGLDetailId, (dblDebit- dblCredit) dblAmount, strAccountId, strCode,
		  strTransactionType,
		  strTransactionForm,
		  strModuleName,
		  intTransactionId
	  FROM vyuGLDetail where       
      strTransactionId = AR.strRecordNumber AND  ysnIsUnposted = 0      
      AND intAccountId =  AR.intAccountId --  in( SELECT intAccountId FROM vyuGLAccountDetail where strAccountCategory = 'Undeposited Funds')  
    )GL      
    OUTER APPLY (
      SELECT TOP 1 CAST(1 AS BIT) ysnValidUndepGLAccount FROM tblSMCompanyLocation WHERE intUndepositedFundsId = GL.intAccountId  
    ) CL

),      
CMPosting AS(      
    SELECT  
      CM.strTransactionId,      
      GL.strAccountId,   
      GL.intAccountId,  
      CMUF.intUndepositedFundId,      
      (CMD.dblCredit- CMD.dblDebit) * ISNULL(CMD.dblExchangeRate,1)  *  CASE WHEN CM.intBankTransactionTypeId = 2 THEN -1 ELSE 1 END  CMAmount,      
      ysnPosted = CM.ysnPosted,  
      GL.dtmDate,
      GL.intGLDetailId,
      GL.strCode,
      GL.strTransactionType,
      GL.strTransactionForm,
      GL.strModuleName,
      GL.intTransactionId,
      ysnValidUndepGLAccount = ISNULL(CL.ysnValidUndepGLAccount, 0)
    FROM tblCMBankTransactionDetail CMD      
    LEFT join tblCMUndepositedFund CMUF on CMUF.intUndepositedFundId = CMD.intUndepositedFundId 
    LEFT join tblCMBankTransaction CM on CM.intTransactionId = CMD.intTransactionId     
    OUTER APPLY( 
      SELECT 
		  dtmDate,
		  intAccountId, 
		  strAccountId, 
		  intGLDetailId, 
		  strCode, 
		  strTransactionType,
		  strTransactionForm,
		  strModuleName,
		  intTransactionId
	  
	  FROM vyuGLDetail WHERE strTransactionId = CM.strTransactionId   
      AND (dblCredit-dblDebit) = ((CMD.dblCredit-CMD.dblDebit) * ISNULL(CMD.dblExchangeRate,1)) 
      AND ysnIsUnposted = 0      
      AND intAccountId = CMD.intGLAccountId
    ) GL
    OUTER APPLY (SELECT TOP 1 CAST(1 AS BIT) ysnValidUndepGLAccount FROM tblSMCompanyLocation WHERE intUndepositedFundsId = GL.intAccountId  ) CL
) ,  
PartitionCMPosting AS(
    SELECT ROW_NUMBER() OVER(PARTITION BY intUndepositedFundId, strTransactionId  ORDER BY intUndepositedFundId ) rowId, *
    FROM CMPosting 
),
GLQuery AS(
   SELECT       
      ysnARCMEntry = CAST(0 AS BIT),    
      strRecordNumber =  GL.strTransactionId,      
      strARAccountId = '',      
      strCMAccountId = GL.strAccountId,      
      strTransactionId = GL.strTransactionId,      
      dtmARDate = NULL,      
      dtmCMDate = GL.dtmDate,      
      dblARAmount = NULL,      
      dblCMAmount = GL.dblDebit - GL.dblCredit,      
      ysnARPosted = NULL,      
      ysnCMPosted = CAST(1 AS BIT),      
      ysnGLMismatch = NULL, 
      ysnARGLEntryError = NULL,  
      ysnCMGLEntryError = NULL,  
      ysnCMInvalidGLAccount = CAST(0 AS BIT),
      ysnARInvalidGLAccount = CAST(0 AS BIT),
      intBankDepositId = NULL,  
      intUndepositedFundId = NULL,
      GL.intGLDetailId intARGLDetailId,
      GL.intGLDetailId intCMGLDetailId,
      GL.strTransactionType strARTransactionType,
      GL.strTransactionForm strARTransactionForm,
      GL.strModuleName strARModuleName,
      GL.intTransactionId intARTransactionId,
      GL.strCode strARCode,
      GL.strTransactionType strCMTransactionType,
      GL.strTransactionForm strCMTransactionForm,
      GL.strModuleName strCMModuleName,
      GL.intTransactionId intCMTransactionId,
      GL.strCode strCMCode,
      strCode,
      ROW_NUMBER() OVER(PARTITION BY GL.strTransactionId ORDER BY GL.intGLDetailId ) rowId
    FROM vyuGLDetail GL
    JOIN tblSMCompanyLocation CL ON CL.intUndepositedFundsId = GL.intAccountId
    WHERE strModuleName NOT IN('Cash Management', 'Accounts Receivable', 'Receive Payments')
    AND ysnIsUnposted = 0

),
Query AS(  
    SELECT     
      ysnARCMEntry = CAST(1 AS BIT),      
      AR.strRecordNumber,      
      AR.strAccountId strARAccountId,      
      CM.strAccountId strCMAccountId,      
      CM.strTransactionId ,      
      AR.dtmDate dtmARDate,      
      CM.dtmDate dtmCMDate,      
      AR.dblAmount dblARAmount,      
      CM.CMAmount dblCMAmount,      
      ISNULL(AR.ysnPosted,0 ) ysnARPosted,      
      ISNULL(CM.ysnPosted,0 ) ysnCMPosted,      
      ysnGLMismatch = CASE WHEN ISNULL(AR.ysnPosted,0) = 1 AND ISNULL(CM.ysnPosted , 0) = 1 AND AR.intAccountId != CM.intAccountId THEN CAST(1 AS bit) else CAST(0 AS bit) end,  
      ysnARGLEntryError = CASE WHEN AR.ysnPosted = 1 AND AR.dblAmount IS NULL THEN CAST(1 AS bit) else CAST (0 AS bit) end,  
      ysnCMGLEntryError = CASE WHEN CM.ysnPosted = 1 AND CM.CMAmount IS NULL THEN CAST(1 AS bit) else CAST (0 AS bit) end,
      ysnCMInvalidGLAccount = CASE WHEN CM.ysnValidUndepGLAccount = 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
      ysnARInvalidGLAccount = CASE WHEN AR.ysnValidUndepGLAccount = 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
      AR.intBankDepositId,  
      AR.intUndepositedFundId,
	    AR.intGLDetailId intARGLDetailId,
      CM.intGLDetailId intCMGLDetailId,
      AR.strTransactionType strARTransactionType,
      AR.strTransactionForm strARTransactionForm,
      AR.strModuleName strARModuleName,
      AR.intTransactionId intARTransactionId,
      AR.strCode strARCode,
      CM.strTransactionType strCMTransactionType,
      CM.strTransactionForm strCMTransactionForm,
      CM.strModuleName strCMModuleName,
      CM.intTransactionId intCMTransactionId,
      CM.strCode strCMCode,
      ISNULL(AR.strCode, CM.strCode) strCode
    FROM ARPosting AR join      
        PartitionCMPosting CM on CM.intUndepositedFundId = AR.intUndepositedFundId   
    WHERE rowId =1
    UNION ALL
    SELECT       
          ysnARCMEntry,    
      strRecordNumber ,      
      strARAccountId ,      
      strCMAccountId,      
      strTransactionId,      
      dtmARDate,      
      dtmCMDate,      
      dblARAmount,      
      dblCMAmount,      
      ysnARPosted,      
      ysnCMPosted,      
      ysnGLMismatch, 
      ysnARGLEntryError,  
      ysnCMGLEntryError,  
      ysnCMInvalidGLAccount,
      ysnARInvalidGLAccount,
      intBankDepositId,  
      intUndepositedFundId,
      intARGLDetailId,
      intCMGLDetailId,
      strARTransactionType,
      strARTransactionForm,
      strARModuleName,
      intARTransactionId,
      strARCode,
      strCMTransactionType,
      strCMTransactionForm,
      strCMModuleName,
      intCMTransactionId,
      strCMCode,
      strCode
    FROM GLQuery GL WHERE rowId = 1
)
SELECT CAST(ROW_NUMBER() over(order by strRecordNumber) AS int) intRowId,     
strStatus =  CASE 
  WHEN ysnARCMEntry = 0 THEN 'Non-CM/AR GL Entry'    
  WHEN ISNULL(Q.ysnARPosted,0) = 1 AND Q.intUndepositedFundId IS NULL THEN 'Missing in Undeposited'       
  WHEN ISNULL(Q.ysnARPosted,0) = 0 AND ISNULL(Q.ysnCMPosted , 0) = 0 AND Q.intUndepositedFundId IS NOT null THEN 'Unposted AR/CM in Undeposited'   
  WHEN Q.dblARAmount <> Q.dblCMAmount  AND ISNULL(Q.ysnARPosted,0) = 1 AND ISNULL(Q.ysnCMPosted,0) =1 THEN 'Mismatched Amount'  
  WHEN Q.ysnARGLEntryError = 1  THEN 'AR GL Entry Error'  
  WHEN Q.ysnCMGLEntryError =1 THEN 'CM GL Entry Error'  
  WHEN ysnGLMismatch = 1 THEN 'GL Account Matching Error' 
ELSE 
  'Good'
END COLLATE Latin1_General_CI_AS,      
*  FROM  
Query Q  

