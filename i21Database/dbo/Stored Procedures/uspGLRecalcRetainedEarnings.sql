CREATE PROCEDURE uspGLRecalcRetainedEarnings
    @intFiscalYearId INT = NULL,
    @ysnOpen BIT = NULL,
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
    
DECLARE @tblPeriod TABLE ( 
intGLFiscalYearPeriodId INT,  
intRetainAccount INT, 
intIncomeSummaryAccount INT,   
strPeriod NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,  
guidPostId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
dtmStartDate DATETIME ,  
dtmEndDate  DATETIME)    

DECLARE @strGUID NVARCHAR(40)    
    
DECLARE @tblFiscalYear TABLE (
intFiscalYearId INT,  
guidPostId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
intRetainAccount INT, 
intIncomeSummaryAccount INT)

INSERT INTO @tblFiscalYear (intFiscalYearId, guidPostId,intRetainAccount,intIncomeSummaryAccount)
SELECT    
intFiscalYearId,
CAST(guidPostId AS NVARCHAR(40)),    
intRetainAccount,    
intIncomeSummaryAccount    
FROM tblGLFiscalYear WHERE ISNULL(@intFiscalYearId,intFiscalYearId) = intFiscalYearId

DELETE FROM tblGLDetail WHERE strBatchId IN (SELECT guidPostId FROM @tblFiscalYear)
DELETE FROM tblGLPostRecap WHERE strBatchId IN (SELECT guidPostId FROM @tblFiscalYear)

    
INSERT INTO @tblPeriod (intGLFiscalYearPeriodId, guidPostId, intRetainAccount, intIncomeSummaryAccount, strPeriod, dtmStartDate, dtmEndDate)    
SELECT intGLFiscalYearPeriodId,B.guidPostId,B.intRetainAccount, B.intIncomeSummaryAccount, strPeriod, dtmStartDate, dtmEndDate    
FROM tblGLFiscalYearPeriod A
JOIN @tblFiscalYear B ON A.intFiscalYearId = B.intFiscalYearId
WHERE ISNULL(ysnOpen,0) = 
CASE WHEN @ysnOpen = 1 THEN 1
WHEN @ysnOpen = 0 THEN 0
ELSE ISNULL(ysnOpen,0)
END

  
    
WHILE EXISTS (SELECT 1 FROM  @tblPeriod)    
BEGIN    
    
    SELECT TOP 1 @intGLFiscalYearPeriodId =intGLFiscalYearPeriodId,@strPeriod = strPeriod,    
    @dtmStartDate =  dtmStartDate, @dtmEndDate =dtmEndDate,@strGUID = guidPostId,
    @intRetainAccount=intRetainAccount,@intIncomeSummaryAccount= intIncomeSummaryAccount
    FROM @tblPeriod    
    
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
    
    DELETE FROM @tblPeriod WHERE @intGLFiscalYearPeriodId = intGLFiscalYearPeriodId    
    
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