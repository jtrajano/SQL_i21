CREATE  PROCEDURE  [dbo].[uspFRDGLBulkPostingCompare]              
 @strReport AS NVARCHAR (100),    
 @strStartDate AS NVARCHAR (100),    
 @strEndDate AS NVARCHAR (100),  
 @successfulCount AS INT = 0 OUTPUT          
AS              
BEGIN              
              
SET QUOTED_IDENTIFIER OFF              
SET ANSI_NULLS ON              
SET NOCOUNT ON               
            
 --MAIN DATA SOURCE            
 DELETE tblGLPostedCompare WHERE strReport = @strReport  
 ---------------------------------------------------------------------------------------------------------------------------------------              
INSERT INTO tblGLPostedCompare (intAccountId,dtmDate,dblDebit,dblCredit,dblDebitForeign,dblCreditForeign,dblDebitUnit,dblCreditUnit,strCode,intConcurrencyId,intCurrencyId,intLedgerId,dtmDateEntered,strReport)               
 SELECT  T2.intAccountId,T2.dtmDate,        
  SUM(dblDebit)dblDebit,SUM(dblCredit)dblCredit,                  
  SUM(dblDebitForeign)dblDebitForeign,SUM(dblCreditForeign)dblCreditForeign,                  
  SUM(dblDebitUnit)dblDebitUnit,SUM(dblCreditUnit)dblCreditUnit,                  
  T2.strCode,1,T2.intCurrencyID,T2.intLedgerId,T2.dtmDateEntered,@strReport        
  FROM (        
   SELECT T0.intAccountId,T0.dtmDate,                  
   T0.dblDebit,T0.dblCredit,                  
   T0.dblDebitForeign,T0.dblCreditForeign,                  
   T0.dblDebitUnit,T0.dblCreditUnit,                  
    ISNULL(T0.strCode,'') AS strCode,ISNULL(T0.intCurrencyId,T1.intCurrencyID)intCurrencyID,ISNULL(T0.intLedgerId,0)intLedgerId,T0.dtmDateEntered FROM                    
   tblGLDetail T0          
   LEFT JOIN tblGLAccount T1          
   ON T0.intAccountId = T1.intAccountId          
   WHERE T0.ysnIsUnposted = 0 AND  T0.dtmDateEntered BETWEEN @strStartDate AND @strEndDate    
  )T2        
  GROUP BY T2.intAccountId,T2.dtmDate,T2.strCode,T2.intCurrencyID,T2.intLedgerId,T2.dtmDateEntered                 
            
 SELECT @@ROWCOUNT            
 END  