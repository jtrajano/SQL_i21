CREATE PROCEDURE uspGLInsertIntraCompanyEntries
AS

BEGIN

	
    DECLARE @ysnAllowIntraCompanyEntries BIT,@rowCount INT
    SELECT @ysnAllowIntraCompanyEntries = ysnAllowIntraCompanyEntries FROM tblGLCompanyPreferenceOption
    IF ISNULL(@ysnAllowIntraCompanyEntries, 0) = 0 RETURN

    DECLARE @cntSegment INT, @msg NVARCHAR(50), @errorMsg NVARCHAR(500),@ysnHasError BIT = 0
    SELECT 1  FROM #tmpGLDetail A JOIN tblGLAccount B ON
        A.intAccountId = B.intAccountId
        GROUP BY intCompanySegmentId

	SET @rowCount = @@ROWCOUNT

    IF @rowCount > 2
    BEGIN
        SET @msg = ' only have '
        SET @ysnHasError = 1
    END

    IF @rowCount < 2
    BEGIN
        SET @msg = ' have '
        SET @ysnHasError = 1
    END

    IF @ysnHasError = 1
    BEGIN
        SET @errorMsg = 'GL Entries should' + @msg + '2 (two) distinct Company Segment Entries '
        RAISERROR(@errorMsg, 11, 1 )   
        RETURN
    END


    -- DUE TO - CREDIT
    -- DUE FROM - DEBIT

    DECLARE @intDueTo INT , @intDueFrom INT
    SELECT @intDueTo = intDueToAccountId, @intDueFrom=intDueFromAccountId FROM tblGLCompanyPreferenceOption 

    IF ISNULL(@intDueTo,0) = 0
    BEGIN
        SET @ysnHasError = 1
        SET @msg = 'Due To'
    END

    IF ISNULL(@intDueFrom,0) = 0
    BEGIN
        SET @ysnHasError = 1
        SET @msg = 'Due From'
    END
    IF @ysnHasError = 1
    BEGIN
        SET @errorMsg = @msg + ' is missing in General Ledger Company Configuration'
            RAISERROR(@msg, 11, 1 )
        RETURN
    END

    DECLARE @tbl TABLE (
        intCompanySegmentId INT,
        dblDebit DECIMAL(18,2),
        dblCredit DECIMAL(18,2),
        intAccountId INT NULL,
        strAccountId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    )

    INSERT INTO @tbl(intCompanySegmentId, dblCredit, dblDebit)
    SELECT intCompanySegmentId, 
    CASE WHEN SUM(dblDebit - dblCredit) > 0 THEN SUM(dblDebit - dblCredit) ELSE 0 END,
    CASE WHEN SUM(dblCredit - dblDebit ) > 0 THEN SUM( dblCredit - dblDebit) ELSE 0 END
    FROM #tmpGLDetail A JOIN tblGLAccount B ON
        A.intAccountId = B.intAccountId
        GROUP BY intCompanySegmentId

    UPDATE A  SET strAccountId = dbo.fnGLGetOverrideAccountBySegment(@intDueTo,NULL, NULL, A.intCompanySegmentId) FROM @tbl A 
    WHERE dblDebit > 0

    UPDATE A  SET strAccountId = dbo.fnGLGetOverrideAccountBySegment(@intDueFrom,NULL, NULL, A.intCompanySegmentId) FROM @tbl A 
    WHERE dblCredit > 0

    
    UPDATE A SET intAccountId = GL.intAccountId
    FROM @tbl A 
    OUTER APPLY(
        SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = A.strAccountId
    )GL

    DECLARE @missingAccountId NVARCHAR(50)= ''

    SELECT TOP 1 @missingAccountId= strAccountId FROM @tbl WHERE intAccountId IS NULL


    IF @missingAccountId <> ''
    BEGIN
        SET @errorMsg = @missingAccountId + ' is not an existing account Id.'
        RAISERROR(@errorMsg, 11,1)
        RETURN
    END



    INSERT INTO #tmpGLDetail
    (
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
        ,[intCurrencyId]    
        ,[intCurrencyExchangeRateTypeId]    
        ,[dblExchangeRate]    
        ,[intUserId]    
        ,[intEntityId]       
        ,[dtmDateEntered]    
        ,[strBatchId]    
        ,[strCode]       
        ,[strJournalLineDescription]    
        ,[intJournalLineNo]    
        ,[strTransactionType]    
        ,[strTransactionForm]    
        ,[strModuleName]     
    )
   SELECT
    GL.[strTransactionId]    
   ,GL.[intTransactionId]    
   ,[intAccountId]    
   ,''    
   ,''     
   ,GL.[dtmTransactionDate]    
   ,[dblDebit]    
   ,[dblCredit]    
   ,[dblDebit]    
   ,[dblCredit]    
   ,0   
   ,0   
   ,GL.[dtmDate]    
   ,0
   ,1   
   ,SM.[intDefaultCurrencyId]    
   ,NULL  
   ,1   
   ,GL.[intUserId]    
   ,GL.[intEntityId]       
   ,GL.[dtmDateEntered]    
   ,GL.[strBatchId]    
   ,GL.[strCode]       
   ,'Intra Company Entries'
   ,NULL    
   ,GL.[strTransactionType]    
   ,GL.[strTransactionForm]    
   ,GL.[strModuleName]     

   FROM 
   @tbl 
    OUTER APPLY(
        SELECT TOP 1 dtmDate,intUserId,intEntityId,dtmDateEntered,strBatchId,strCode,strTransactionType, strTransactionForm,strModuleName,dtmTransactionDate
        ,intTransactionId,strTransactionId
        FROM #tmpGLDetail
    )GL
    OUTER APPLY(
        SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference
    )SM




END