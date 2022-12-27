CREATE PROCEDURE uspGLRecalcRetainedEarnings    
    @intFiscalYearId INT,    
    @intGLFiscalYearPeriodId INT ,
	@ysnAllFiscalYear BIT,
    @intOpen SMALLINT,    
    @intEntityId INT,    
    @result NVARCHAR(100) OUTPUT      
AS      
      
DECLARE @dtmStartDate DATETIME        
DECLARE @dtmEndDate DATETIME        
DECLARE @intRetainAccount INT        
DECLARE @intIncomeSummaryAccount INT        
DECLARE @RevalTableType RevalTableType          
DECLARE @RecapTableType  RecapTableType        
DECLARE @strPeriod NVARCHAR(30)        
DECLARE @dtmNow DATETIME  = GETDATE()        
DECLARE @intDefaultCurrencyId INT
        
DECLARE @tblPeriod TABLE (     
intGLFiscalYearPeriodId INT,      
intRetainAccount INT,     
intIncomeSummaryAccount INT,       
strPeriod NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,      
guidPostId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,     
dtmStartDate DATETIME ,      
dtmEndDate  DATETIME)        
    
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 

DECLARE @strGUID NVARCHAR(40)        

IF @ysnAllFiscalYear = 1
BEGIN	
		INSERT INTO @tblPeriod (intGLFiscalYearPeriodId, guidPostId, intRetainAccount, 
		intIncomeSummaryAccount, strPeriod, dtmStartDate, dtmEndDate)        
		SELECT intGLFiscalYearPeriodId,CAST(guidPostId AS NVARCHAR(40)),B.intRetainAccount, 
		B.intIncomeSummaryAccount, strPeriod, dtmStartDate, dtmEndDate 
		FROM tblGLFiscalYearPeriod A    
		JOIN tblGLFiscalYear B ON A.intFiscalYearId = B.intFiscalYearId    
		WHERE ISNULL(ysnOpen,0) =     
		CASE WHEN @intOpen = 1 THEN 1    
		WHEN @intOpen = 0 THEN 0    
		ELSE ISNULL(ysnOpen,0)    
		END    
END
ELSE
BEGIN
	IF @intFiscalYearId > 0     
	BEGIN	
		INSERT INTO @tblPeriod (intGLFiscalYearPeriodId, guidPostId, intRetainAccount, intIncomeSummaryAccount, strPeriod, dtmStartDate, dtmEndDate)        
		SELECT intGLFiscalYearPeriodId,CAST(guidPostId AS NVARCHAR(40)),B.intRetainAccount, B.intIncomeSummaryAccount, strPeriod, dtmStartDate, dtmEndDate        
		FROM tblGLFiscalYearPeriod A    
		JOIN tblGLFiscalYear B ON A.intFiscalYearId = B.intFiscalYearId    
		WHERE 
		B.intFiscalYearId = @intFiscalYearId AND
		ISNULL(ysnOpen,0) =     
		CASE WHEN @intOpen = 1 THEN 1    
		WHEN @intOpen = 0 THEN 0    
		ELSE ISNULL(ysnOpen,0)    
		END    
	END    
	ELSE
	IF @intGLFiscalYearPeriodId > 0    
	BEGIN    
		INSERT INTO @tblPeriod (intGLFiscalYearPeriodId, guidPostId, intRetainAccount, intIncomeSummaryAccount, strPeriod, dtmStartDate, dtmEndDate)        
		SELECT intGLFiscalYearPeriodId,CAST(A.guidPostId AS NVARCHAR(40)),B.intRetainAccount, B.intIncomeSummaryAccount, strPeriod, dtmStartDate, dtmEndDate        
		FROM tblGLFiscalYearPeriod A JOIN tblGLFiscalYear B ON A.intFiscalYearId = B.intFiscalYearId    
		WHERE intGLFiscalYearPeriodId =@intGLFiscalYearPeriodId    
		    
	END  
END

IF EXISTS(SELECT 1 FROM @tblPeriod where ISNULL(intIncomeSummaryAccount,0) = 0 )
BEGIN
	SET @result = 'Fiscal year has missing Income Summary GL Account'   
	GOTO _end
END
IF EXISTS(SELECT 1 FROM @tblPeriod where ISNULL(intRetainAccount,0) = 0 )
BEGIN
	SET @result = 'Fiscal year has missing Retain Earnings GL Account'   
	GOTO _end
END

--select * from @tblPeriod
    
WHILE EXISTS (SELECT 1 FROM  @tblPeriod)        
BEGIN        
    SELECT TOP 1 @intGLFiscalYearPeriodId =intGLFiscalYearPeriodId,@strPeriod = strPeriod,        
    @dtmStartDate =  dtmStartDate, @dtmEndDate =dtmEndDate,@strGUID = guidPostId,    
    @intRetainAccount=intRetainAccount,@intIncomeSummaryAccount= intIncomeSummaryAccount    
    FROM @tblPeriod        
        
    DELETE FROM tblGLDetail WHERE strBatchId  = @strGUID    
    
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
            ,[dtmTransactionDate]=@dtmEndDate  
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

--select * from @RevalTableType



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
    --intJournalLineNo,      
    ysnIsUnposted,      
    intUserId,      
    intEntityId,      
    strTransactionId,      
    intTransactionId,      
    strTransactionType,      
    strTransactionForm,      
    strModuleName,      
    --intConcurrencyId,      
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
    strDescription = '',        
    dtmTransactionDate,     
    SUM(dblDebit),      
    SUM(dblCredit),     
    strCode = 'GL',     
    intCurrencyId = @intDefaultCurrencyId,      
    dtmDateEntered,      
    strJournalLineDescription,      
    --intJournalLineNo,      
    0 ysnIsUnposted,      
    intUserId,      
    intEntityId,      
    strTransactionId='RE-'+ REPLACE( CONVERT(date, dtmDate,100),'-', ''),     
    intTransactionId=REPLACE( CONVERT(date, dtmDate,100),'-', ''),      
    strTransactionType='Fiscal Year RE',      
    strTransactionForm ='Fiscal year',      
    strModuleName='General Ledger',      
    --intConcurrencyId,      
    intAccountIdOverride,      
    intLocationSegmentOverrideId,      
    intLOBSegmentOverrideId,      
    intCompanySegmentOverrideId,      
    strNewAccountIdOverride,      
    intNewAccountIdOverride,      
    strOverrideAccountError    
FROM fnGLOverridePostAccounts(@RevalTableType,@ysnOverrideLocation,@ysnOverrideLOB,@ysnOverrideCompany) A         
group by dtmDate,      
    strBatchId,      
    intAccountId,     
    --strDescription,        
    dtmTransactionDate,     
    --dblDebit,      
    --dblCredit,     
    strCode,     
    --intCurrencyId,      
    dtmDateEntered,      
    strJournalLineDescription,      
    --intJournalLineNo,      
    ysnIsUnposted,      
    intUserId,      
    intEntityId,      
    --strTransactionId,      
    --intTransactionId,      
    --strTransactionType,      
    --strTransactionForm,      
    strModuleName,      
    --intConcurrencyId,      
    intAccountIdOverride,      
    intLocationSegmentOverrideId,      
    intLOBSegmentOverrideId,      
    intCompanySegmentOverrideId,      
    strNewAccountIdOverride,      
    intNewAccountIdOverride,      
    strOverrideAccountError 
        
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