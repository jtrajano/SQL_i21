CREATE PROCEDURE uspGLRecalcRetainedEarnings  
  
    @intFiscalYearId INT,    
    @intEntityId INT,  
    @result NVARCHAR(30) OUTPUT  
AS  
  
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
    

DECLARE
  @ysnOverrideLocation BIT = 0,
    @ysnOverrideLOB BIT = 0,
    @ysnOverrideCompany BIT = 0 


    Declare  @tbl1 TABLE( intStructureType int );


    with  st as (
        select ROW_NUMBER() over(order by intSort)  rowId, intStructureType from tblGLAccountStructure where strType not in( 'Divider', 'Primary')
    ),
    ov as(

    SELECT G.Item FROM tblGLCompanyPreferenceOption A
    outer apply dbo.fnSplitString( A.strOverrideREArray, ',')G
    )
    insert into @tbl1
    select intStructureType from st A join ov B on A.rowId = B.Item

    SELECT @ysnOverrideLocation = 1 FROM @tbl1 WHERE intStructureType = 3
    SELECT @ysnOverrideLOB = 1 FROM @tbl1 WHERE intStructureType = 5
    SELECT @ysnOverrideCompany = 1 FROM @tbl1 WHERE intStructureType = 6




  
    
  INSERT INTO @PostGLEntries2   SELECT * FROM fnGLOverridePostAccounts(@PostGLEntries,@ysnOverrideLocation,@ysnOverrideLOB,@ysnOverrideCompany) A       
    
  
    
   IF EXISTS(SELECT 1 FROM @PostGLEntries2 WHERE ISNULL(strOverrideAccountError,'') <> '' )      
   BEGIN    
  
  
  DELETE FROM tblGLPostRecap WHERE strBatchId = @strGUID    
  EXEC uspGLPostRecap @PostGLEntries2, @intEntityId      
  EXEC uspGLBuildMissingAccountsRevalueOverride @intEntityId  
  SET @result = 'Error overriding accounts.'  
  GOTO _end  
   END    
    
DELETE FROM tblGLDetail WHERE strBatchId = @strGUID    
    
EXEC uspGLBookEntries @PostGLEntries2, 1, 1 ,1     
  
            
SET @result = 'Posted'  
    
    
 _end:   