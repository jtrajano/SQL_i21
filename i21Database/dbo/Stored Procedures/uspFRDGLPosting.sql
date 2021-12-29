CREATE  PROCEDURE  [dbo].[uspFRDGLPosting]        
@GLEntries RecapTableType READONLY    
         
AS        
BEGIN        
        
SET QUOTED_IDENTIFIER OFF        
SET ANSI_NULLS ON        
SET NOCOUNT ON        
      
 DECLARE @intAccountId AS INT      
 DECLARE @dtmDate AS DATETIME      
 DECLARE @intCurrencyId AS INT        
 DECLARE @strCode AS NVARCHAR(80)  
 DECLARE @intPostedCount AS INT        
 DECLARE @Rowcount AS INT  = 0      
      
 DECLARE @dblDebit AS NUMERIC      
 DECLARE @dblCredit AS NUMERIC      
 DECLARE @dblDebitForeign AS NUMERIC      
 DECLARE @dblCreditForeign AS NUMERIC      
 DECLARE @dblDebitUnit AS NUMERIC      
 DECLARE @dblCreditUnit AS NUMERIC      
      
 --MAIN DATA SOURCE      
 SELECT intAccountId,dtmDate,          
    SUM(dblDebit)dblDebit,SUM(dblCredit)dblCredit,          
    SUM(dblDebitForeign)dblDebitForeign,SUM(dblCreditForeign)dblCreditForeign,          
    SUM(dblDebitUnit)dblDebitUnit,SUM(dblCreditUnit)dblCreditUnit,          
    strCode,intCurrencyId INTO #TMPPOSTED FROM            
    @GLEntries     
    GROUP BY intAccountId,dtmDate,strCode,intCurrencyId           
      
 BEGIN        
  WHILE EXISTS(SELECT 1 FROM #TMPPOSTED)           
   BEGIN        
    --Priamary Key    
    Select Top 1 @intAccountId = intAccountId From #TMPPOSTED       
    Select Top 1 @dtmDate = dtmDate From #TMPPOSTED       
    Select Top 1 @intCurrencyId = intCurrencyId From #TMPPOSTED       
 Select Top 1 @strCode = strCode From #TMPPOSTED       
   --Amounts    
    Select Top 1 @dblDebit = dblDebit From #TMPPOSTED       
    Select Top 1 @dblCredit = dblCredit From #TMPPOSTED       
    Select Top 1 @dblDebitForeign = dblDebitForeign From #TMPPOSTED       
    Select Top 1 @dblCreditForeign = dblCreditForeign From #TMPPOSTED       
    Select Top 1 @dblDebitUnit = dblDebitUnit From #TMPPOSTED       
    Select Top 1 @dblCreditUnit = dblCreditUnit From #TMPPOSTED       
      
  SET @intPostedCount = (SELECT COUNT(0) FROM tblGLPosted WHERE intAccountId = @intAccountId AND dtmDate = @dtmDate AND intCurrencyId = @intCurrencyId AND strCode = @strCode)      
      
  IF @intPostedCount  = 0      
   BEGIN       
     INSERT INTO tblGLPosted (intAccountId,dtmDate,dblDebit,dblCredit,dblDebitForeign,dblCreditForeign,dblDebitUnit,dblCreditUnit,strCode,intCurrencyId)       
     SELECT * FROM #TMPPOSTED WHERE intAccountId = @intAccountId AND dtmDate = @dtmDate AND intCurrencyId = @intCurrencyId      
     set @Rowcount = @Rowcount + (Select @@ROWCOUNT)      
   END      
  ELSE      
   BEGIN       
     UPDATE tblGLPosted      
     SET      
      dblDebit = dblDebit + @dblDebit,      
      dblCredit = dblCredit + @dblCredit ,      
      dblDebitForeign = dblDebitForeign + @dblDebitForeign ,      
      dblCreditForeign = dblCreditForeign + @dblCreditForeign,      
      dblDebitUnit = dblDebitUnit + @dblDebitUnit,      
      dblCreditUnit = dblCreditUnit + @dblCreditUnit      
     WHERE intAccountId = @intAccountId AND dtmDate = @dtmDate AND intCurrencyId = @intCurrencyId      
    
     set @Rowcount = @Rowcount + (Select @@ROWCOUNT)      
   END      
       
  DELETE #TMPPOSTED WHERE intAccountId = @intAccountId AND dtmDate = @dtmDate AND intCurrencyId = @intCurrencyId  AND strCode = @strCode  
 END             
  END    
      
  DROP TABLE #TMPPOSTED      
      
 SELECT @Rowcount      
 END    
        
        
--=====================================================================================================================================        
--  SCRIPT EXECUTION         
---------------------------------------------------------------------------------------------------------------------------------------        
        
--EXEC [dbo].[uspFRDGLPosting]        
            
      
