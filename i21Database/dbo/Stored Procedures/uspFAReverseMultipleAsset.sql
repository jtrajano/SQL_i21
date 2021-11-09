CREATE PROCEDURE [dbo].[uspFAReverseMultipleAsset]  
  @strBatchId  AS NVARCHAR(100) = ''  
 ,@Id Id READONLY
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
   ,[intCurrencyId]
   ,[intJournalLineNo] 
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
   ,[intAccountId]     
   ,[strDescription]  =  FA.[strAssetDescription]
   ,[strReference]     
   ,[dtmTransactionDate]   
   ,[dblDebit]    = A.[dblCredit]  
   ,[dblCredit]   = A.[dblDebit]   
   ,[dblDebitForeign]  = A.[dblCreditForeign]  
   ,[dblCreditForeign]  = A.[dblDebitForeign]   
   ,[dblDebitUnit]   = A.[dblCreditUnit]  
   ,[dblCreditUnit]  = A.[dblDebitUnit]  
   ,dtmDate = ISNULL(@dtmDateReverse, A.dtmDate) -- If date is provided, use date reverse as the date for unposting the transaction.  
   ,[ysnIsUnposted] = 1   
   ,[intConcurrencyId] = A.[intConcurrencyId]    
   ,[dblExchangeRate]  
   ,[intCurrencyId] = A.[intCurrencyId]
   ,[intJournalLineNo] 
   ,[intCurrencyExchangeRateTypeId] = A.[intCurrencyExchangeRateTypeId]  
   ,[intUserId]   = 0  
   ,[intEntityId]   = @intEntityId  
   ,[dtmDateEntered]  = GETDATE()  
   ,[strBatchId]   = @strBatchId  
   ,[strCode]  
   ,[strTransactionType]  
   ,[strTransactionForm]  
   ,[strModuleName]  
  FROM tblGLDetail A 
  JOIN  @Id B 
    ON B.intId = A.intGLDetailId AND ysnIsUnposted = 0  
  JOIN tblFAFixedAsset FA
    ON FA.intAssetId = A.intTransactionId AND FA.strAssetId = A.strReference
  ORDER BY intGLDetailId  


IF EXISTS(
    SELECT TOP 1 1 FROM  @GLEntries
    WHERE dbo.fnFAIsOpenAccountingDate(dtmDate) = 0
)
BEGIN
  RAISERROR('This reversal can not impact closed periods so General ledger entries will be reflected in the current period', 16,1)
  GOTO Post_Rollback
  RETURN -1
END




IF ISNULL(@ysnRecap, 0) = 0  
BEGIN     
    DECLARE @PostResult INT
    EXEC @PostResult = uspGLBookEntries @GLEntries, 0, 0, 1
    IF @@ERROR <> 0 OR  @PostResult <> 0 RETURN -1
    UPDATE GL set ysnIsUnposted = 1 from tblGLDetail GL  join @Id B on GL.intGLDetailId = B.intId
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
 
  
Post_Exit:
