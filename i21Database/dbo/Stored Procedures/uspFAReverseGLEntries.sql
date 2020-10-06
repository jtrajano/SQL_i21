CREATE PROCEDURE [dbo].[uspFAReverseGLEntries]  
  @strBatchId  AS NVARCHAR(100) = ''  
 ,@strParams NVARCHAR(40) = NULL  
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
  
BEGIN TRANSACTION;  



DECLARE @tmpPostJournals JournalIDTableType  
INSERT INTO @tmpPostJournals EXEC (@strParams)  

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
   ,dtmDate = ISNULL(@dtmDateReverse, A.dtmDate) -- If date is provided, use date reverse as the date for unposting the transaction.  
   ,[ysnIsUnposted] = 1   
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



IF ISNULL(@ysnRecap, 0) = 0  
BEGIN     
    DECLARE @PostResult INT
    EXEC @PostResult = uspGLBookEntries @GLEntries, 0, 0, 1
    IF @@ERROR <> 0 OR  @PostResult <> 0 RETURN -1
    UPDATE GL set ysnIsUnposted = 1 from tblGLDetail GL  join @tmpPostJournals B on GL.intGLDetailId = B.intJournalId
    SET @successfulCount = (SELECT COUNT(*) FROM tblGLDetail WHERE strBatchId = @strBatchId)  
END  
ELSE  
    BEGIN  
    EXEC uspGLPostRecap @GLEntries, @intEntityId  
    SET @successfulCount = (SELECT COUNT(*) FROM tblGLPostRecap WHERE strBatchId = @strBatchId)  
    IF @@ERROR <> 0 RETURN -1
 END  
  
IF @@ERROR <> 0 GOTO Post_Rollback;  
  
--=====================================================================================================================================  
--  RETURN TOTAL NUMBER OF VALID GL ENTRIES  
---------------------------------------------------------------------------------------------------------------------------------------  

  
IF @@ERROR <> 0 GOTO Post_Rollback;  
  
--=====================================================================================================================================  
--  FINALIZING STAGE  
---------------------------------------------------------------------------------------------------------------------------------------  
Post_Commit:  
IF @@TRANCOUNT > 0  
 COMMIT TRANSACTION  
 

 GOTO Post_Exit  
  
Post_Rollback:  
IF @@TRANCOUNT > 0  
 ROLLBACK TRANSACTION                
 GOTO Post_Exit  
  
Post_Exit: