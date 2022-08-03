﻿CREATE PROCEDURE uspGLPostRevalue  
 @intConsolidationId   AS INT,  
 @ysnPost     AS BIT,  
 @ysnRecap     AS BIT,  
 @intEntityId    AS INT,
 @strMessage NVARCHAR(MAX) OUT
AS  
DECLARE @RevalTable RevalTableType 
DECLARE @ReversePostGLEntries RevalTableType
DECLARE @RecapTable RecapTableType  
DECLARE @strPostBatchId NVARCHAR(100) = ''  
DECLARE @strReversePostBatchId NVARCHAR(100) = ''  
-- DECLARE @strMessage NVARCHAR(MAX)  
DECLARE @intReverseID INT  
DECLARE @strConsolidationNumber NVARCHAR(30)  
DECLARE @tblPostError TABLE(  
 strPostBatchId NVARCHAR(40),  
 strMessage NVARCHAR(MAX),  
 strTransactionId NVARCHAR(40)  
) 
DECLARE
@ysnOverrideLocation BIT = 0,
@ysnOverrideLOB BIT = 0,
@ysnOverrideCompany BIT = 0 
  
  DECLARE @ysnHasDetails BIT = 0
  SELECT @ysnHasDetails = 1 FROM tblGLRevalueDetails WHERE intConsolidationId = @intConsolidationId

  DECLARE @errorNum INT  
  DECLARE @dateNow DATETIME  
  SELECT @dateNow = GETDATE()  
  DECLARE @errorMsg NVARCHAR(300) = ''  
    
  SELECT @strMessage = dbo.fnGLValidateRevaluePeriod(@intConsolidationId,@ysnPost)   
  IF @strMessage <> ''  
    GOTO _error
  
  IF @ysnRecap = 1  
   SELECT @strPostBatchId =  NEWID()  
  ELSE  
   IF @ysnPost = 1  
   BEGIN  
    IF EXISTS(SELECT TOP 1 1 FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId AND ysnPosted = 1)  
    BEGIN  
     SET @strMessage ='The transaction is already posted.'  
      GOTO _error 
    END  
    EXEC [dbo].uspGLGetNewID 3, @strPostBatchId OUTPUT  
   END  
   ELSE  
   BEGIN  
    SELECT @strPostBatchId =  NEWID()  
   END  
    
  
  -- For Bank Transfer Accounts  
  DECLARE @tblBankTransferAccounts TABLE  
  (  
   strModule NVARCHAR(50),  
   strType NVARCHAR(50),  
   AccountId INT,  
   Offset INT  
  )  
  
  DECLARE   
   @strAccountErrorMessage NVARCHAR(255),  
   @strTransactionType NVARCHAR(255),  
   @intGLFiscalYearPeriodId INT,  
   @strPeriod NVARCHAR(30)  
  
  SELECT   
   @intGLFiscalYearPeriodId = A.intGLFiscalYearPeriodId,  
   @strTransactionType = strTransactionType,  
   @strConsolidationNumber = strConsolidationNumber,  
   @strPeriod = strPeriod  
  FROM tblGLRevalue A JOIN  
  tblGLFiscalYearPeriod P on A.intGLFiscalYearPeriodId = P.intGLFiscalYearPeriodId  
  WHERE intConsolidationId = @intConsolidationId  
  
  -- Validate CM revaluation  
  SELECT @strMessage = dbo.fnCMValidateCMRevaluation(@intGLFiscalYearPeriodId, @strTransactionType, @ysnPost)  
  IF @strMessage IS NOT NULL  
    GOTO _error
  
  IF (@strTransactionType IN ('CM Forwards', 'CM In-Transit', 'CM Swaps'))  
  BEGIN  
   DECLARE @tblTransactions TABLE (  
    strTransactionId NVARCHAR(100)  
   )  
   DECLARE @strCurrentTransaction NVARCHAR(100)  
  
   INSERT INTO @tblTransactions  
   SELECT DISTINCT strTransactionId  
   FROM tblGLRevalueDetails WHERE intConsolidationId = @intConsolidationId  
  
   WHILE EXISTS(SELECT TOP 1 1 FROM @tblTransactions)  
   BEGIN  
    SELECT TOP 1 @strCurrentTransaction = strTransactionId FROM @tblTransactions  
    BEGIN TRY  
     INSERT @tblBankTransferAccounts EXEC dbo.uspCMGetBankTransferGLRevalueAccount @strCurrentTransaction, @strTransactionType  
    END TRY  
    BEGIN CATCH  
     SELECT  @strMessage = ERROR_MESSAGE();   
      GOTO _error 
    END CATCH  
  
    DELETE @tblTransactions WHERE strTransactionId = @strCurrentTransaction  
   END  
  END  
  
 IF @ysnPost =1   
 BEGIN  
  DECLARE @defaultType NVARCHAR(20)   
  SELECT TOP 1 @defaultType = f.strType  from dbo.fnGLGetRevalueAccountTable() f   
  WHERE f.strModule COLLATE Latin1_General_CI_AS = @strTransactionType;  

    IF @ysnHasDetails = 1
    BEGIN
          IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'iRelyPostGLEntries') DROP TABLE iRelyPostGLEntries;
          WITH cte as(  
          SELECT   
            [strTransactionId]  = B.strConsolidationNumber  
          ,[intTransactionId]  = B.intConsolidationId  
          ,[strDescription]  = A.strTransactionId   
          ,[dtmTransactionDate] = B.dtmDate  
          ,[dblDebit]    = ISNULL(CASE WHEN dblUnrealizedGain < 0 THEN ABS(dblUnrealizedGain)  
                  WHEN dblUnrealizedLoss < 0 THEN 0  
                  ELSE dblUnrealizedLoss END,0)  
          ,[dblCredit]   = ISNULL(CASE WHEN dblUnrealizedLoss < 0 THEN ABS(dblUnrealizedLoss)  
                  WHEN dblUnrealizedGain < 0 THEN 0  
                  ELSE dblUnrealizedGain END,0)  
          ,[dtmDate]    = ISNULL(B.[dtmDate], GETDATE())  
          ,[ysnIsUnposted]  = 0   
          ,[intConcurrencyId]  = 1  
          ,[intCurrencyId]  = B.intFunctionalCurrencyId  
          ,[intUserId]   = 0  
          ,[intEntityId]   = @intEntityId    
          ,[dtmDateEntered]  = @dateNow  
          ,[strBatchId]   = @strPostBatchId  
          ,[strCode]    = 'REVAL'  
          ,[intJournalLineNo]  = A.[intConsolidationDetailId]     
          ,[strTransactionType] = 'Revalue Currency'  
          ,[strTransactionForm] = 'Revalue Currency'  
          ,B.dtmReverseDate  
          ,strModule = B.strTransactionType  
          ,A.strType  
          ,Offset = 0  
          ,A.intAccountIdOverride  
          ,A.intLocationSegmentOverrideId  
          ,A.intLOBSegmentOverrideId  
          ,A.intCompanySegmentOverrideId
          FROM [dbo].tblGLRevalueDetails A RIGHT JOIN [dbo].tblGLRevalue B   
          ON A.intConsolidationId = B.intConsolidationId  
          WHERE B.intConsolidationId = @intConsolidationId  
          ),cte1 AS  
          (  
          SELECT   
            [strTransactionId]    
            ,[intTransactionId]    
            ,[strDescription]    
            ,[dtmTransactionDate]   
            ,[dblDebit]   
            ,[dblCredit]  
            ,[dtmDate]      
            ,[ysnIsUnposted]    
            ,[intConcurrencyId]    
            ,[intCurrencyId]    
            ,[intUserId]     
            ,[intEntityId]     
            ,[dtmDateEntered]    
            ,strBatchId  
            ,[strCode]      
            ,[strJournalLineDescription] = 'Revalue '+ @strTransactionType + ' '  + @strPeriod   
            ,[intJournalLineNo]    
            ,[strTransactionType]   
            ,[strTransactionForm]  
            ,strModule   
            ,OffSet = 0  
            ,strType = ISNULL(strType,@defaultType)  
            ,intAccountIdOverride  
            ,intLocationSegmentOverrideId  
            ,intLOBSegmentOverrideId  
            ,intCompanySegmentOverrideId
          FROM  
          cte   
          UNION ALL  
          SELECT   
            [strTransactionId]    
            ,[intTransactionId]    
            ,[strDescription]    
            ,[dtmTransactionDate]   
            ,[dblDebit]    = dblCredit      
            ,[dblCredit]   = dblDebit     
            ,[dtmDate]  
            ,[ysnIsUnposted]    
            ,[intConcurrencyId]    
            ,[intCurrencyId]    
            ,[intUserId]     
            ,[intEntityId]     
            ,[dtmDateEntered]   
            ,strBatchId   
            ,[strCode]      
            ,[strJournalLineDescription] = 'Offset Revalue '+ @strTransactionType + ' '  + @strPeriod   
            ,[intJournalLineNo]    
            ,[strTransactionType]   
            ,[strTransactionForm]   
            ,strModule  
            ,OffSet = 1  
            ,strType = ISNULL(strType,@defaultType)  
            ,intAccountIdOverride  
            ,intLocationSegmentOverrideId  
            ,intLOBSegmentOverrideId  
            ,intCompanySegmentOverrideId
          FROM cte   
          )  
       
          SELECT   
            [strTransactionId]    
          ,[intTransactionId]    
          ,[intAccountId] = CASE WHEN A.strModule IN ('CM Forwards', 'CM In-Transit', 'CM Swaps') THEN BankTransferAccount.AccountId ELSE G.AccountId END  
          ,[strDescription]    
          ,[dtmTransactionDate]   
          ,[dblDebit]      
          ,[dblCredit]     
          ,[dtmDate]      
          ,[ysnIsUnposted]    
          ,[intConcurrencyId]    
          ,[intCurrencyId]    
          ,[intUserId]     
          ,[intEntityId]     
          ,[dtmDateEntered]    
          ,[strBatchId]   
          ,[strCode]      
          ,[strJournalLineDescription]   
          ,[intJournalLineNo]    
          ,[strTransactionType]   
          ,[strTransactionForm]  
          ,strModuleName = 'General Ledger'  
          ,intAccountIdOverride  
          ,intLocationSegmentOverrideId  
          ,intLOBSegmentOverrideId  
          ,intCompanySegmentOverrideId
          ,A.strModule
          INTO #iRelyPostGLEntries
          FROM cte1 A  
          OUTER APPLY (  
          SELECT TOP 1 AccountId from dbo.fnGLGetRevalueAccountTable() f   
          WHERE A.strType COLLATE Latin1_General_CI_AS = f.strType COLLATE Latin1_General_CI_AS   
          AND f.strModule COLLATE Latin1_General_CI_AS = A.strModule COLLATE Latin1_General_CI_AS  
          AND f.OffSet  = A.OffSet  
          )G  
          OUTER APPLY (  
          SELECT TOP 1 AccountId from @tblBankTransferAccounts f   
          WHERE A.strType COLLATE Latin1_General_CI_AS = f.strType COLLATE Latin1_General_CI_AS   
          AND f.strModule COLLATE Latin1_General_CI_AS = A.strModule COLLATE Latin1_General_CI_AS  
          AND f.Offset = A.OffSet  
          ) BankTransferAccount  

-- Insert Unreealized Gain/Loss  (Realized for GL using fnGLGetRevalueAccountTable) with offset
          INSERT INTO @RevalTable(  
           [strTransactionId]  
          ,[intTransactionId]  
          ,[intAccountId]  
          ,[strDescription]  
          ,[dtmTransactionDate]  
          ,[dblDebit]  
          ,[dblCredit]  
          ,[dtmDate]  
          ,[ysnIsUnposted]  
          ,[intConcurrencyId]   
          ,[intCurrencyId]  
          ,[intUserId]  
          ,[intEntityId]     
          ,[dtmDateEntered]  
          ,[strBatchId]  
          ,[strCode]     
          ,[strJournalLineDescription]  
          ,[intJournalLineNo]  
          ,[strTransactionType]  
          ,[strTransactionForm]  
          ,strModuleName  
          ,intAccountIdOverride  
          ,intLocationSegmentOverrideId  
          ,intLOBSegmentOverrideId  
          ,intCompanySegmentOverrideId
          ) 
          SELECT
           [strTransactionId]  
          ,[intTransactionId]  
          ,[intAccountId]  
          ,[strDescription]  
          ,[dtmTransactionDate]  
          ,[dblDebit]  
          ,[dblCredit]  
          ,[dtmDate]  
          ,[ysnIsUnposted]  
          ,[intConcurrencyId]   
          ,[intCurrencyId]  
          ,[intUserId]  
          ,[intEntityId]     
          ,[dtmDateEntered]  
          ,[strBatchId]  
          ,[strCode]     
          ,[strJournalLineDescription]  
          ,[intJournalLineNo]  
          ,[strTransactionType]  
          ,[strTransactionForm]  
          ,strModuleName  
          ,intAccountIdOverride  
          ,intLocationSegmentOverrideId  
          ,intLOBSegmentOverrideId  
          ,intCompanySegmentOverrideId
          FROM #iRelyPostGLEntries


--Insert Reverse Entries ( Except GL )
          INSERT INTO @RevalTable (  
            [strTransactionId]  
          ,[intTransactionId]  
          ,[intAccountId]  
          ,[strDescription]  
          ,[dtmTransactionDate]  
          ,[dblDebit]  
          ,[dblCredit]  
          ,[dtmDate]  
          ,[ysnIsUnposted]  
          ,[intConcurrencyId]   
          ,[intCurrencyId]  
          ,[intUserId]  
          ,[intEntityId]     
          ,[dtmDateEntered]  
          ,[strBatchId]  
          ,[strCode]     
          ,[strJournalLineDescription]  
          ,[intJournalLineNo]  
          ,[strTransactionType]  
          ,[strTransactionForm]  
          ,strModuleName  
          ,intAccountIdOverride  
          ,intLocationSegmentOverrideId  
          ,intLOBSegmentOverrideId  
          ,intCompanySegmentOverrideId  
          )  
          SELECT   
            [strTransactionId]  
          ,[intTransactionId]  
          ,[intAccountId]  
          ,[strDescription]  
          ,[dtmTransactionDate]  
          ,[dblCredit]  
          ,[dblDebit]  
          ,[dtmDate] = U.dtmReverseDate  
          ,[ysnIsUnposted]  
          ,[intConcurrencyId]   
          ,[intCurrencyId]  
          ,[intUserId]  
          ,[intEntityId]     
          ,[dtmDateEntered]  
          ,[strBatchId]  
          ,[strCode]     
          ,[strJournalLineDescription] = 'Reverse Revalue '+ @strTransactionType + ' '  + @strPeriod   
          ,[intJournalLineNo]  
          ,[strTransactionType]  
          ,[strTransactionForm]  
          ,strModuleName  
          ,intAccountIdOverride  
          ,intLocationSegmentOverrideId  
          ,intLOBSegmentOverrideId  
          ,intCompanySegmentOverrideId  
          FROM #iRelyPostGLEntries
          OUTER APPLY(  
          SELECT dtmReverseDate FROM tblGLRevalue  WHERE intConsolidationId = @intConsolidationId  
          )U  
		      WHERE strModule NOT IN ('GL', 'CM')  
    
          DECLARE @dtmReverseDate DATETIME  
          SELECT TOP 1 @dtmReverseDate = dtmReverseDate , @strMessage = 'Forex Gain/Loss account setting is required in Company Configuration screen for ' +  strTransactionType + ' transaction type.' FROM tblGLRevalue WHERE intConsolidationId = @intConsolidationId
          IF EXISTS(Select TOP 1 1 FROM @RevalTable WHERE intAccountId IS NULL)  
          BEGIN  
            GOTO _error
          END  

    END --IF @ysnHasDetails = 1
  
 END  
 ELSE  
 BEGIN  
  INSERT INTO @RevalTable(  
   [strTransactionId]  
   ,[intTransactionId]  
   ,[intAccountId]
   ,[strDescription]  
   ,[dtmTransactionDate]  
   ,[dblDebit]  
   ,[dblCredit]  
   ,[dtmDate]  
   ,[ysnIsUnposted]  
   ,[intConcurrencyId]   
   ,[intCurrencyId]  
   ,[intUserId]  
   ,[intEntityId]     
   ,[dtmDateEntered]  
   ,[strBatchId]  
   ,[strCode]     
   ,[strJournalLineDescription]  
   ,[intJournalLineNo]  
   ,[strTransactionType]  
   ,[strTransactionForm]  
   ,strModuleName  
   )     
  SELECT   
   [strTransactionId]    
   ,[intTransactionId]    
   ,[intAccountId]
   ,[strDescription]  
   ,[dtmTransactionDate]  
   ,[dblCredit]   
   ,[dblDebit]      
   ,[dtmDate]      
   ,[ysnIsUnposted] = 1  
   ,[intConcurrencyId]    
   ,[intCurrencyId]    
   ,[intUserId]     
   ,[intEntityId]     
   ,[dtmDateEntered]    
   ,[strBatchId] = @strPostBatchId  
   ,[strCode]      
   ,[strJournalLineDescription]   
   ,[intJournalLineNo]    
   ,[strTransactionType]   
   ,[strTransactionForm]  
   ,strModuleName  
  FROM tblGLDetail A   
  WHERE strTransactionId = @strConsolidationNumber  
  AND ysnIsUnposted = 0  
  
 END  
  IF @ysnRecap = 0   
  BEGIN  
  
   INSERT INTO @RecapTable  (
    dtmDate,  
    strBatchId,  
    intAccountId,
    strDescription, 
    dtmTransactionDate,   
    dblDebit,  
    dblCredit, 
    strCode, 
    intCurrencyId,  
    dtmDateEntered,  
    strJournalLineDescription,  
    intJournalLineNo,  
    ysnIsUnposted,  
    intUserId,  
    intEntityId,  
    strTransactionId,  
    intTransactionId,  
    strTransactionType,  
    strTransactionForm,  
    strModuleName,  
    intConcurrencyId,  
    intAccountIdOverride,  
    intLocationSegmentOverrideId,  
    intLOBSegmentOverrideId,  
    intCompanySegmentOverrideId,  
    strNewAccountIdOverride,  
    intNewAccountIdOverride,  
    strOverrideAccountError 
   )
   SELECT 
    dtmDate,  
    strBatchId,  
    intAccountId,  
    strDescription, 
    dtmTransactionDate,
    dblDebit,  
    dblCredit, 
    strCode, 
    intCurrencyId,  
    dtmDateEntered,  
    strJournalLineDescription,  
    intJournalLineNo,  
    ysnIsUnposted,  
    intUserId,  
    intEntityId,  
    strTransactionId,  
    intTransactionId,  
    strTransactionType,  
    strTransactionForm,  
    strModuleName,  
    intConcurrencyId,  
    intAccountIdOverride,  
    intLocationSegmentOverrideId,  
    intLOBSegmentOverrideId,  
    intCompanySegmentOverrideId,  
    strNewAccountIdOverride,  
    intNewAccountIdOverride,  
    strOverrideAccountError 
    from fnGLOverridePostAccounts(@RevalTable,@ysnOverrideLocation,@ysnOverrideLOB,@ysnOverrideCompany) A   
     
      
    IF EXISTS(SELECT 1 FROM @RecapTable WHERE ISNULL(strOverrideAccountError,'') <> '' ) 
    BEGIN 

      EXEC uspGLPostRecap @RecapTable, @intEntityId  
      GOTO _overrideError
    END
  
   IF EXISTS ( SELECT 1 FROM @RecapTable )
      EXEC uspGLBookEntries @RecapTable, @ysnPost, 1 ,1  
  
   IF @@ERROR <> 0 RETURN  
  
   IF @ysnPost = 0  
    UPDATE GL SET ysnIsUnposted = 1  
    FROM tblGLDetail GL  
    WHERE strTransactionId = @strConsolidationNumber  
    AND ysnIsUnposted = 0  
  END  
  ELSE  
  BEGIN  
   INSERT INTO @RecapTable  (
    dtmDate,  
    strBatchId,  
    intAccountId, 
    strDescription, 
    dtmTransactionDate,   
    dblDebit,  
    dblCredit, 
    strCode, 
    intCurrencyId,  
    dtmDateEntered,  
    strJournalLineDescription,  
    intJournalLineNo,  
    ysnIsUnposted,  
    intUserId,  
    intEntityId,  
    strTransactionId,  
    intTransactionId,  
    strTransactionType,  
    strTransactionForm,  
    strModuleName,  
    intConcurrencyId,  
    intAccountIdOverride,  
    intLocationSegmentOverrideId,  
    intLOBSegmentOverrideId,  
    intCompanySegmentOverrideId,  
    strNewAccountIdOverride,  
    intNewAccountIdOverride,  
    strOverrideAccountError 
   
   )
   SELECT 
    dtmDate,  
    strBatchId,  
    intAccountId,  
    strDescription, 
    dtmTransactionDate,  
    dblDebit,  
    dblCredit, 
    strCode, 
    intCurrencyId,  
    dtmDateEntered,  
    strJournalLineDescription,  
    intJournalLineNo,  
    ysnIsUnposted,  
    intUserId,  
    intEntityId,  
    strTransactionId,  
    intTransactionId,  
    strTransactionType,  
    strTransactionForm,  
    strModuleName,  
    intConcurrencyId,  
    intAccountIdOverride,  
    intLocationSegmentOverrideId,  
    intLOBSegmentOverrideId,  
    intCompanySegmentOverrideId,  
    strNewAccountIdOverride,  
    intNewAccountIdOverride,  
    strOverrideAccountError 
   from fnGLOverridePostAccounts(@RevalTable,@ysnOverrideLocation,@ysnOverrideLOB,@ysnOverrideCompany) A  
  
   EXEC uspGLPostRecap @RecapTable, @intEntityId  
  
   IF EXISTS(SELECT 1 FROM @RecapTable WHERE ISNULL(strOverrideAccountError,'') <> '' )  
      GOTO _overrideError
   
  END  
  
  
  
  if @ysnRecap = 0  
  BEGIN  
   UPDATE tblGLRevalue SET ysnPosted = @ysnPost WHERE intConsolidationId in ( @intConsolidationId, @intReverseID)  
     
     
   IF @strTransactionType = 'GL'   
    UPDATE tblGLFiscalYearPeriod SET ysnRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
   IF @strTransactionType = 'AR'   
    UPDATE tblGLFiscalYearPeriod SET ysnARRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
   IF @strTransactionType = 'AP'   
    UPDATE tblGLFiscalYearPeriod SET ysnAPRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
   IF @strTransactionType = 'INV'   
    UPDATE tblGLFiscalYearPeriod SET ysnINVRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
   IF @strTransactionType = 'CT'   
    UPDATE tblGLFiscalYearPeriod SET ysnCTRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
   IF @strTransactionType = 'CM'   
    UPDATE tblGLFiscalYearPeriod SET ysnCMRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
   IF @strTransactionType = 'FA'   
    UPDATE tblGLFiscalYearPeriod SET ysnFARevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
   IF @strTransactionType = 'CM Forwards'  
    UPDATE tblGLFiscalYearPeriod SET ysnCMForwardsRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
   IF @strTransactionType = 'CM In-Transit'  
    UPDATE tblGLFiscalYearPeriod SET ysnCMInTransitRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
   IF @strTransactionType = 'CM Swaps'  
    UPDATE tblGLFiscalYearPeriod SET ysnCMSwapsRevalued = @ysnPost WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
  
   IF @strTransactionType = 'All'   
    UPDATE tblGLFiscalYearPeriod SET   
     ysnRevalued  = @ysnPost,  
     ysnARRevalued =  @ysnPost,  
     ysnAPRevalued =  @ysnPost,  
     ysnINVRevalued = @ysnPost,  
     ysnCTRevalued =  @ysnPost,  
     ysnCMRevalued =  @ysnPost,  
     ysnFARevalued =     @ysnPost,  
     ysnCMForwardsRevalued =  @ysnPost,  
     ysnCMInTransitRevalued = @ysnPost,  
     ysnCMSwapsRevalued =  @ysnPost  
    WHERE intGLFiscalYearPeriodId = @intGLFiscalYearPeriodId  
  
     
  END  
   
  
 SET @strMessage = @strPostBatchId

 RETURN  

 _error:
  SET @strMessage = 'Error Posting Revalue:'  + @strMessage

  RETURN

 _overrideError:
  SET @strMessage = 'Error Overriding Accounts'  
  EXEC uspGLBuildMissingAccountsRevalueOverride @intEntityId