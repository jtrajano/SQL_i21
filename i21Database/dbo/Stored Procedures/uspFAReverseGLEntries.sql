CREATE PROCEDURE [dbo].[uspFAReverseGLEntries]  
  @strBatchId  AS NVARCHAR(100) = ''  
 ,@strParams NVARCHAR(200) = NULL  
 ,@ysnRecap   AS BIT   = 0  
 ,@dtmDateReverse DATETIME  = NULL   
 ,@intEntityId  INT    = NULL   
 ,@successfulCount AS INT   = 0 OUTPUT  
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  

DECLARE @tmpPostJournals JournalIDTableType  
INSERT INTO @tmpPostJournals(intJournalId) EXEC (@strParams)  

IF ISNULL(@ysnRecap, 0) = 0  
BEGIN     
    DECLARE @ReverseEntry INT
    EXEC @ReverseEntry = [uspFAInsertReverseGLEntry] @tmpPostJournals,@intEntityId,@dtmDateReverse, @strBatchId  
    IF @@ERROR <> 0 OR  @ReverseEntry <> 0 RETURN -1
    SET @successfulCount = (SELECT COUNT(*) FROM tblGLDetail WHERE strBatchId = @strBatchId)  
END  
ELSE  
    BEGIN  
    DECLARE @GLEntries RecapTableType  
    
  INSERT INTO @GLEntries (  
    [strTransactionId]  
   ,[intTransactionId]  
   ,[intAccountId]  
   ,[strDescription]  
   ,[strReference]   
   ,[dtmTransactionDate]  
   ,[dblDebit]  
   ,[dblCredit]  
   ,[dblDebitForeign]  
   ,[dblCreditForeign]  
   ,[dblDebitUnit]  
   ,[dblCreditUnit]  
   ,[dtmDate]  
   ,[ysnIsUnposted]  
   ,[intConcurrencyId]   
   ,[dblExchangeRate]  
   ,[intCurrencyExchangeRateTypeId]  
   ,[intUserId]  
   ,[intEntityId]  
   ,[dtmDateEntered]  
   ,[strBatchId]  
   ,[strCode]  
   ,[strTransactionType]  
   ,[strTransactionForm]  
   ,[strModuleName]  
  )  
  SELECT   
    [strTransactionId]  
   ,[intTransactionId]  
   ,A.[intAccountId]     
   ,[strDescription]  =  A.strJournalLineDescription  
   ,A.[strReference]     
   ,[dtmTransactionDate]   
   ,[dblDebit]    = A.[dblCredit]  
   ,[dblCredit]   = A.[dblDebit]   
   ,[dblDebitForeign]  = A.[dblCreditForeign]  
   ,[dblCreditForeign]  = A.[dblDebitForeign]   
   ,[dblDebitUnit]   = A.[dblCreditUnit]  
   ,[dblCreditUnit]  = A.[dblDebitUnit]  
   ,A.[dtmDate]      
   ,[ysnIsUnposted]    
   ,A.[intConcurrencyId]    
   ,[dblExchangeRate]  
   ,[intCurrencyExchangeRateTypeId] = A.[intCurrencyExchangeRateTypeId]  
   ,[intUserId]   = 0  
   ,[intEntityId]   = @intEntityId  
   ,[dtmDateEntered]  = GETDATE()  
   ,[strBatchId]   = @strBatchId  
   ,[strCode]  
   ,[strTransactionType]  
   ,[strTransactionForm]  
   ,[strModuleName]  
  FROM tblGLDetail A JOIN
  @tmpPostJournals B on B.intJournalId = A.intGLDetailId
  AND ysnIsUnposted = 0  
  ORDER BY intGLDetailId  
  
  EXEC uspGLPostRecap @GLEntries, @intEntityId  
  SET @successfulCount = (SELECT COUNT(*) FROM tblGLPostRecap WHERE strBatchId = @strBatchId)  
      
  IF @@ERROR <> 0 RETURN -1
  

 END  
  

  
--=====================================================================================================================================  
--  RETURN TOTAL NUMBER OF VALID GL ENTRIES  
---------------------------------------------------------------------------------------------------------------------------------------  

  
IF @@ERROR <> 0 RETURN -1
  
--=====================================================================================================================================  
--  FINALIZING STAGE  
---------------------------------------------------------------------------------------------------------------------------------------  
RETURN 0