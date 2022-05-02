CREATE PROCEDURE uspGLRecalcRetainedEarnings  
    @intFiscalYearId INT,-- =8,  
    @intEntityId INT =1
as  
DECLARE @dtmStartDate DATETIME  
DECLARE @dtmEndDate DATETIME  
DECLARE @intRetainAccount INT  
DECLARE @intIncomeSummaryAccount INT  
DECLARE @PostGLEntries RecapTableType    
DECLARE @PostGLEntries2  RecapTableType  
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
  
INSERT INTO @tbl (intGLFiscalYearPeriodId,strPeriod, dtmStartDate, dtmEndDate)  
SELECT intGLFiscalYearPeriodId, strPeriod, dtmStartDate, dtmEndDate  
FROM tblGLFiscalYearPeriod WHERE intFiscalYearId = @intFiscalYearId   

  
WHILE EXISTS (SELECT 1 FROM  @tbl)  
BEGIN  
  
    SELECT TOP 1 @intGLFiscalYearPeriodId =intGLFiscalYearPeriodId,@strPeriod = strPeriod,  
    @dtmStartDate =  dtmStartDate, @dtmEndDate =dtmEndDate  
    FROM @tbl  
  
      INSERT INTO @PostGLEntries(    
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
            ,A.strDescription   
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
INSERT INTO @PostGLEntries(    
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
FROM @PostGLEntries  
  
  
  
  
  INSERT INTO @PostGLEntries2   SELECT * FROM fnGLOverridePostAccounts(@PostGLEntries) A     
  
   
  
   IF EXISTS(SELECT 1 FROM @PostGLEntries2 WHERE ISNULL(strOverrideAccountError,'') <> '' )    
   BEGIN  
       
     DELETE FROM tblGLPostRecap WHERE strBatchId = @strGUID  
     EXEC uspGLPostRecap @PostGLEntries2, @intEntityId    
	  EXEC uspGLBuildMissingAccountsRevalueOverride @intEntityId
     GOTO _raiseOverrideError    
   END  
  
DELETE FROM tblGLDetail WHERE strBatchId = @strGUID  
  
EXEC uspGLBookEntries @PostGLEntries2, 1, 1 ,1   
          
  
  
GOTO _end    
  
_raiseOverrideError:  
  RAISERROR( 'Error overriding accounts.',11,1)    
  GOTO _end    
  
 --END    
  
 _end: 