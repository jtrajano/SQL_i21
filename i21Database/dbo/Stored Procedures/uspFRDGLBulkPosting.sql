CREATE  PROCEDURE  [dbo].[uspFRDGLBulkPosting]          
           
AS          
BEGIN          
          
SET QUOTED_IDENTIFIER OFF          
SET ANSI_NULLS ON          
SET NOCOUNT ON           
        
 --MAIN DATA SOURCE        
 TRUNCATE TABLE tblGLPosted    
 ---------------------------------------------------------------------------------------------------------------------------------------          
INSERT INTO tblGLPosted (intAccountId,dtmDate,dblDebit,dblCredit,dblDebitForeign,dblCreditForeign,dblDebitUnit,dblCreditUnit,strCode,intConcurrencyId,intCurrencyId,intLedgerId,intSubledgerId)           
 SELECT  T2.intAccountId,T2.dtmDate,    
  SUM(dblDebit)dblDebit,SUM(dblCredit)dblCredit,              
  SUM(dblDebitForeign)dblDebitForeign,SUM(dblCreditForeign)dblCreditForeign,              
  SUM(dblDebitUnit)dblDebitUnit,SUM(dblCreditUnit)dblCreditUnit,              
  T2.strCode,1,T2.intCurrencyID,T2.intLedgerId,T2.intSubledgerId            
  FROM (    
   SELECT T0.intAccountId,T0.dtmDate,              
   SUM(dblDebit)dblDebit,SUM(dblCredit)dblCredit,              
   SUM(dblDebitForeign)dblDebitForeign,SUM(dblCreditForeign)dblCreditForeign,              
   SUM(dblDebitUnit)dblDebitUnit,SUM(dblCreditUnit)dblCreditUnit,              
    ISNULL(T0.strCode,'') AS strCode ,ISNULL(T0.intCurrencyId,T1.intCurrencyID)intCurrencyID,ISNULL(T0.intLedgerId,0)intLedgerId,ISNULL(T0.intSubledgerId,0)intSubledgerId FROM                
   tblGLDetail T0      
   LEFT JOIN tblGLAccount T1      
   ON T0.intAccountId = T1.intAccountId      
   WHERE T0.ysnIsUnposted = 0  
   GROUP BY T0.intAccountId,T0.dtmDate,T0.strCode,T0.intCurrencyId,T1.intCurrencyID,T0.intLedgerId,T0.intSubledgerId                  
  )T2    
  GROUP BY T2.intAccountId,T2.dtmDate,T2.strCode,T2.intCurrencyID,T2.intLedgerId,T2.intSubledgerId                              
        
 SELECT @@ROWCOUNT        
 END      