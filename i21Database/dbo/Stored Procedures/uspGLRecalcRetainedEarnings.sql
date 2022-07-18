CREATE PROCEDURE uspGLRecalcRetainedEarnings  
  
    @intFiscalYearId INT,    
    @intEntityId INT,  
    @result NVARCHAR(30) OUTPUT  
AS  
  
DECLARE @dtmStartDate DATETIME    
DECLARE @dtmEndDate DATETIME    
DECLARE @intRetainAccount INT    
DECLARE @intIncomeSummaryAccount INT    
DECLARE @RevalTableType RevalTableType      
DECLARE @RecapTableType  RecapTableType    
DECLARE @strPeriod NVARCHAR(30)    
DECLARE @intGLFiscalYearPeriodId INT    
DECLARE @dtmNow DATETIME  = GETDATE()    
    
DECLARE @tbl TABLE ( intGLFiscalYearPeriodId INT,     
strPeriod NVARCHAR(30),  dtmStartDate DATETIME ,  dtmEndDate  DATETIME)    
DECLARE @strGUID NVARCHAR(40)    
    
SELECT    
@strGUID =  CAST( guidPostId AS NVARCHAR(40)) ,    
@intRetainAccount= intRetainAccount,    
@intIncomeSummaryAccount = intIncomeSummaryAccount    
FROM tblGLFiscalYear WHERE @intFiscalYearId = intFiscalYearId    

DELETE FROM tblGLDetail WHERE strBatchId = @strGUID
DELETE FROM tblGLPostRecap WHERE strBatchId = @strGUID    
    
INSERT INTO @tbl (intGLFiscalYearPeriodId,strPeriod, dtmStartDate, dtmEndDate)    
SELECT intGLFiscalYearPeriodId, strPeriod, dtmStartDate, dtmEndDate    
FROM tblGLFiscalYearPeriod WHERE intFiscalYearId = @intFiscalYearId     
  
    
WHILE EXISTS (SELECT 1 FROM  @tbl)    
BEGIN    
    
    SELECT TOP 1 @intGLFiscalYearPeriodId =intGLFiscalYearPeriodId,@strPeriod = strPeriod,    
    @dtmStartDate =  dtmStartDate, @dtmEndDate =dtmEndDate    
    FROM @tbl    
    
      INSERT INTO @RevalTableType(      
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
        )    
        SELECT     
            [strTransactionId]      
            ,[intTransactionId]     
            ,@intRetainAccount    
            ,A.[strDescription]      
            ,[dtmTransactionDate]
            ,[dblDebit]      
            ,[dblCredit]      
            ,@dtmEndDate      
            ,[ysnIsUnposted]      
            ,1      
            ,[intCurrencyId]      
            ,@intEntityId     
            ,@intEntityId       
            ,@dtmNow    
            ,@strGUID      
            ,'GL'        
            ,'Retained Earnings Entry for ' + ISNULL(@strPeriod,'')    
            ,[intJournalLineNo]      
            ,[strTransactionType]      
            ,[strTransactionForm]      
            ,'General Ledger'      
            ,A.intAccountId    
         FROM tblGLDetail A     
  JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId    
  WHERE     
        B.strAccountType in ('Expense','Revenue')     
        AND ISNULL(ysnIsUnposted,0) = 0    
        AND dtmDate BETWEEN @dtmStartDate AND @dtmEndDate    
    
    DELETE FROM @tbl WHERE @intGLFiscalYearPeriodId = intGLFiscalYearPeriodId    
    
END    
    
    
--REVERSED BY INCOME SUMMARY ACCOUNT    
INSERT INTO @RevalTableType(      
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
)    
SELECT     
    [strTransactionId]      
    ,[intTransactionId]      
    ,@intIncomeSummaryAccount    
    ,[strDescription]      
    ,[dtmTransactionDate]
    ,[dblCredit]    
    ,[dblDebit]      
    ,[dtmDate]      
    ,[ysnIsUnposted]      
    ,[intConcurrencyId]       
    ,[intCurrencyId]      
    ,[intUserId]      
    ,[intEntityId]         
    ,[dtmDateEntered]      
    ,[strBatchId]      
    ,[strCode]         
    ,REPLACE(strJournalLineDescription, 'Retained Earnings',   'Income Summary' )    
    ,[intJournalLineNo]      
    ,[strTransactionType]      
    ,[strTransactionForm]      
    ,strModuleName      
    ,intAccountIdOverride    
FROM @RevalTableType    
    

DECLARE
@ysnOverrideLocation BIT = 0,
@ysnOverrideLOB BIT = 0,
@ysnOverrideCompany BIT = 0 

SELECT TOP 1 
@ysnOverrideLocation = ISNULL(ysnREOverrideLocation,0),
@ysnOverrideLOB = ISNULL(ysnREOverrideLOB,0),
@ysnOverrideCompany = ISNULL(ysnREOverrideCompany,0)
FROM tblGLCompanyPreferenceOption
 
INSERT INTO @RecapTableType(
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
FROM fnGLOverridePostAccounts(@RevalTableType,@ysnOverrideLocation,@ysnOverrideLOB,@ysnOverrideCompany) A       
    
IF EXISTS(SELECT 1 FROM @RecapTableType WHERE ISNULL(strOverrideAccountError,'') <> '' )      
BEGIN    

EXEC uspGLPostRecap @RecapTableType, @intEntityId      
EXEC uspGLBuildMissingAccountsRevalueOverride @intEntityId  
SET @result = 'Error overriding accounts.'  
GOTO _end  
END    
    
EXEC uspGLBookEntries @RecapTableType, 1, 1 ,1     
  
            
SET @result = 'Posted'  
    
    
 _end:   