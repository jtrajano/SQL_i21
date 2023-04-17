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

IF NOT EXISTS (SELECT 1 FROM tblGLCompanyPreferenceOption WHERE ysnREOverride = 1)
BEGIN
     SET @result = 'Recalc RE is not enabled in System Manager.'  
    GOTO _end   
END

DECLARE    
@ysnREOverrideLocation BIT = 0,    
@ysnREOverrideLOB BIT = 0,    
@ysnREOverrideCompany BIT = 0,
@ysnISOverrideLocation BIT = 0,    
@ysnISOverrideLOB BIT = 0,    
@ysnISOverrideCompany BIT = 0    
    
SELECT TOP 1     
@ysnREOverrideLocation = ISNULL(ysnREOverrideLocation,0),    
@ysnREOverrideLOB = ISNULL(ysnREOverrideLOB,0),    
@ysnREOverrideCompany = ISNULL(ysnREOverrideCompany,0)
-- @ysnISOverrideLocation = ISNULL(ysnISOverrideLocation,0),    
-- @ysnISOverrideLOB = ISNULL(ysnISOverrideLOB,0),    
-- @ysnISOverrideCompany = ISNULL(ysnISOverrideCompany,0)    
FROM tblGLCompanyPreferenceOption  

DECLARE @ysnREOverride BIT --, @ysnISOverride BIT 

SET  @ysnREOverride =  @ysnREOverrideLocation | @ysnREOverrideLOB | @ysnREOverrideCompany 
--SET  @ysnISOverride =  @ysnISOverrideLocation | @ysnISOverrideLOB | @ysnISOverrideCompany 

	
	
IF @ysnREOverride= 0 --OR @ysnISOverride = 0 
BEGIN
	SET @result = 'Please Override Retained Earnings and Income Summary Account to continue.'   
	GOTO _end
END

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

DECLARE @RevalTableTypeRE RevalTableType
WHILE EXISTS (SELECT 1 FROM  @tblPeriod)        
BEGIN        
    SELECT TOP 1 @intGLFiscalYearPeriodId =intGLFiscalYearPeriodId,@strPeriod = strPeriod,        
    @dtmStartDate =  dtmStartDate, @dtmEndDate =dtmEndDate,@strGUID = guidPostId,    
    @intRetainAccount=intRetainAccount,@intIncomeSummaryAccount= intIncomeSummaryAccount    
    FROM @tblPeriod        
        
    DELETE FROM tblGLDetail WHERE strBatchId  = @strGUID    
    
    INSERT INTO @RevalTableTypeRE(          
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

  

DECLARE @OverrideTableType [OverrideTableType]
INSERT INTO @OverrideTableType(intAccountId, intAccountIdOverride)
select intAccountId, intAccountIdOverride from @RevalTableTypeRE
GROUP BY intAccountId,intAccountIdOverride

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
            ,strOverrideAccountError    
            ,strNewAccountIdOverride   
        )
SELECT
            [strTransactionId]          
            ,[intTransactionId]          
            ,[intAccountId] = B.intNewAccountIdOverride         
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
			,B.strOverrideAccountError
            ,B.strNewAccountIdOverride  
FROM 
@RevalTableTypeRE A
OUTER APPLY(
		SELECT 
		fn.intNewAccountIdOverride,
		fn.strOverrideAccountError,
		fn.strNewAccountIdOverride
		from
		fnGLOverrideTableOfAccounts(@OverrideTableType, @ysnREOverrideLocation,@ysnREOverrideLOB,@ysnREOverrideCompany)fn
		where intAccountId =A.intAccountId and A.intAccountIdOverride = intAccountIdOverride
	
)B

--REVERSED BY INCOME SUMMARY ACCOUNT    
DECLARE @RevalTableTypeIS RevalTableType
INSERT INTO @RevalTableTypeIS(          
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
FROM @RevalTableTypeRE 

DELETE FROM @OverrideTableType
INSERT INTO @OverrideTableType(intAccountId, intAccountIdOverride)
select intAccountId, intAccountIdOverride from @RevalTableTypeIS
GROUP BY intAccountId,intAccountIdOverride

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
            ,strOverrideAccountError
            ,strNewAccountIdOverride  
        )
SELECT
            [strTransactionId]          
            ,[intTransactionId]          
            ,[intAccountId]=B.intNewAccountIdOverride         
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
			,B.strOverrideAccountError
            ,B.strNewAccountIdOverride
FROM
@RevalTableTypeIS A 
OUTER APPLY(
		SELECT 
            fn.intNewAccountIdOverride,
            fn.strOverrideAccountError,
            fn.strNewAccountIdOverride
		FROM fnGLOverrideTableOfAccounts(@OverrideTableType, @ysnREOverrideLocation,@ysnREOverrideLOB,@ysnREOverrideCompany)fn
		WHERE intAccountId =A.intAccountId and A.intAccountIdOverride = intAccountIdOverride
)B


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
    ysnIsUnposted,      
    intUserId,      
    intEntityId,      
    strTransactionId,      
    intTransactionId,      
    strTransactionType,      
    strTransactionForm,      
    strModuleName,    
    strOverrideAccountError,
    strNewAccountIdOverride  
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
    0 ysnIsUnposted,      
    intUserId,      
    intEntityId,      
    strTransactionId='RE-'+ REPLACE( CONVERT(date, dtmDate,100),'-', ''),     
    intTransactionId=REPLACE( CONVERT(date, dtmDate,100),'-', ''),      
    strTransactionType='Fiscal Year RE',      
    strTransactionForm ='Fiscal year',      
    strModuleName='General Ledger',     
    strOverrideAccountError,
    strNewAccountIdOverride  
FROM @RevalTableType A         
group by dtmDate,      
    strBatchId,      
    intAccountId,   
    dtmTransactionDate, 
    strCode,    
    dtmDateEntered,      
    strJournalLineDescription,  
    ysnIsUnposted,      
    intUserId,      
    intEntityId,       
    strModuleName,   
    strOverrideAccountError,
    strNewAccountIdOverride  
        
IF EXISTS(SELECT 1 FROM @RevalTableType WHERE ISNULL(strOverrideAccountError,'') <> '' )          
BEGIN
    EXEC uspGLPostRecap @RecapTableType, @intEntityId   
    DECLARE  @MissingAccounts GLMissingAccounts 
    INSERT INTO @MissingAccounts (strAccountId)
    SELECT strNewAccountIdOverride
        FROM   tblGLPostRecap
        WHERE  strOverrideAccountError IS NOT NULL
        GROUP  BY strNewAccountIdOverride     
    EXEC uspGLBuildMissingAccountsRevalueOverride @intEntityId,@MissingAccounts              
    SET @result = 'Error overriding accounts.'  
    GOTO _end      
END        


EXEC uspGLBookEntries @RecapTableType, 1, 1 ,1         
       
SET @result = 'Posted'      
 _end: 