CREATE PROCEDURE uspGLGetIntraCompanyGLEntries
(
    @GLEntries RecapTableType READONLY,
    @ysnRecap BIT,
    @ysnPost BIT
)
AS
BEGIN

    DECLARE @IntraGLEntries RecapTableType
    
    IF ISNULL(@ysnPost,0) = 0 
          GOTO _Exit

    IF NOT EXISTS( SELECT 1 FROM tblGLCompanyPreferenceOption WHERE ysnAllowIntraCompanyEntries = 1)
        GOTO _Exit

	--CHECK IF COMPANY DOES NOT EXIST
	IF NOT EXISTS(SELECT 1 FROM tblGLAccountStructure A JOIN tblGLSegmentType B ON A.intStructureType = B.intSegmentTypeId WHERE strSegmentType='Company')
		 GOTO _Exit

    DECLARE @intDueToAccountId INT,@intDueFromAccountId INT, @intJournalId INT, @intCompanySegmentId INT,@strJournalId NVARCHAR(30)
    SELECT TOP 1 @intCompanySegmentId=J.intCompanySegmentId,@strJournalId =G.strTransactionId,@intJournalId = J.intJournalId  FROM @GLEntries G
    OUTER APPLY(
        SELECT TOP 1 intCompanySegmentId, intJournalId FROM tblGLJournal WHERE strJournalId = G.strTransactionId
    )J

    IF @intCompanySegmentId IS NULL
        GOTO _Exit

    SELECT TOP 1 @intDueToAccountId=intDueToAccountId, 
	@intDueFromAccountId =intDueFromAccountId  
    FROM tblGLIntraCompanyConfig
    WHERE @intCompanySegmentId = intParentCompanySegmentId

    IF @intDueToAccountId IS NULL OR @intDueFromAccountId IS NULL   
    BEGIN
        RAISERROR( 'Missing Due To/From Accounts setting in Intra Company Config',16,1)
		GOTO _Exit
    END


	--count parent company
	DECLARE @intParentCompanyCount INT,@intNonParentCompanyCount INT
	SELECT @intParentCompanyCount = COUNT(*) FROM @GLEntries A JOIN  vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId 
    WHERE intAccountSegmentId = @intCompanySegmentId
	SELECT @intNonParentCompanyCount = COUNT(*) - @intParentCompanyCount FROM @GLEntries


	IF @intNonParentCompanyCount = 0
	BEGIN
		--PARENT > 0 , --NONPARENT =0
		RAISERROR( 'There should be an entry for a non parent company segment account',16,1)
		GOTO _Exit
	END



	IF @intParentCompanyCount > 0 AND @intNonParentCompanyCount > 0
	BEGIN -- entry here should be balanced between parent and non parent
			DECLARE @dblParentSum DECIMAL(18,6), @dblTotalSum DECIMAL(18,6)

			SELECT @dblTotalSum = SUM(dblDebit-dblCredit)
			from @GLEntries

			SELECT @dblParentSum = SUM(dblDebit-dblCredit)
			from @GLEntries A JOIN vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
			WHERE intAccountSegmentId = @intCompanySegmentId

			IF @dblTotalSum / 2 <> @dblParentSum
			BEGIN
				RAISERROR( 'Parent company amount should be equal to the sum of non-parent company amount.',16,1)
				GOTO _Exit
			END
	END

  
DECLARE @strJournalDescPrefix NVARCHAR(30) = 'Intra Company Entries -'
DECLARE @CreditParent RevalTableType
DECLARE @DebitParent RevalTableType
DECLARE @DebitNonParent RevalTableType
DECLARE @CreditNonParent RevalTableType

IF @intParentCompanyCount > 0
BEGIN
   
    INSERT INTO @CreditParent(
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
            ,strNewAccountIdOverride
    )
    SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueFromOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit] = (dblCredit - dblDebit)
            ,[dblCredit] = 0
            ,dtmDate
            ,[ysnIsUnposted]
            ,1
            ,[intCurrencyId]
            ,intUserId
            ,intEntityId
            ,dtmDateEntered
            ,strBatchId
            ,A.[strCode]
            ,@strJournalDescPrefix + strJournalLineDescription
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,dbo.fnGLGetOverrideAccountBySegment(@intDueFromAccountId, NULL, NULL, @intCompanySegmentId)
    FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    OUTER APPLY
    (
        SELECT TOP 1 intAccountId FROM  tblGLAccount
        WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@intDueFromAccountId, NULL, NULL, @intCompanySegmentId)
    ) DueFromOverrideCompany
    WHERE (dblCredit - dblDebit) > 0
    AND @intCompanySegmentId = B.intAccountSegmentId
    INSERT INTO @DebitParent(
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
            ,strNewAccountIdOverride
    )
    SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueFromOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit] = 0
            ,[dblCredit] = (dblDebit - dblCredit)
            ,dtmDate
            ,[ysnIsUnposted]
            ,1
            ,[intCurrencyId]
            ,intUserId
            ,intEntityId
            ,dtmDateEntered
            ,strBatchId
            ,A.[strCode]
            ,@strJournalDescPrefix + strJournalLineDescription
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,dbo.fnGLGetOverrideAccountBySegment(@intDueToAccountId, NULL, NULL, @intCompanySegmentId)
    FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    OUTER APPLY
    (
        SELECT TOP 1 intAccountId FROM  tblGLAccount
        WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@intDueToAccountId, NULL, NULL, @intCompanySegmentId)
    ) DueFromOverrideCompany
    WHERE (dblDebit - dblCredit) > 0
    AND @intCompanySegmentId = B.intAccountSegmentId
END

-- NO PARENT COMPANY ENTRY
IF @intNonParentCompanyCount > 0
BEGIN
-- Credit entry for non parent
    INSERT INTO @DebitNonParent(
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
			,strNewAccountIdOverride
        )
    SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueToOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit] = 0
            ,[dblCredit]  = (dblDebit - dblCredit )
            ,dtmDate
            ,[ysnIsUnposted]
            ,1
            ,[intCurrencyId]
            ,intUserId
            ,intEntityId
            ,dtmDateEntered
            ,strBatchId
            ,A.[strCode]
            ,@strJournalDescPrefix + strJournalLineDescription
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,dbo.fnGLGetOverrideAccountBySegment(@intDueToAccountId, NULL, NULL, B.intAccountSegmentId )
    FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    OUTER APPLY
    (
        SELECT TOP 1 intAccountId FROM  tblGLAccount
        WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@intDueToAccountId, NULL, NULL, B.intAccountSegmentId )
    ) DueToOverrideCompany
    WHERE (dblDebit - dblCredit) > 0
    AND @intCompanySegmentId <> B.intAccountSegmentId
    IF @intParentCompanyCount  = 0
    BEGIN -- insert credit side
        INSERT INTO @DebitNonParent(
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
                ,strNewAccountIdOverride
            )
        SELECT
                [strTransactionId]
                ,[intTransactionId]
                ,DueFromOverrideCompany.intAccountId
                ,A.[strDescription]
                ,[dtmTransactionDate]
                ,[dblCredit]
                ,[dblDebit] 
                ,[dtmDate]
                ,[ysnIsUnposted]
                ,1
                ,[intCurrencyId]
                ,intUserId
                ,intEntityId
                ,dtmDateEntered
                ,strBatchId
                ,[strCode]
                ,strJournalLineDescription
                ,[intJournalLineNo]
                ,[strTransactionType]
                ,[strTransactionForm]
                ,strModuleName
                ,dbo.fnGLGetOverrideAccountBySegment(@intDueFromAccountId, NULL, NULL, @intCompanySegmentId )
        FROM  @DebitNonParent A
        OUTER APPLY
        (
            SELECT TOP 1 intAccountId FROM  tblGLAccount
            WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@intDueFromAccountId, NULL, NULL, @intCompanySegmentId )
        ) DueFromOverrideCompany
    END
    INSERT INTO @CreditNonParent(
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
            ,strNewAccountIdOverride
        )
    SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueFromOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit] =  (dblCredit - dblDebit)
            ,[dblCredit]  = 0
            ,dtmDate
            ,[ysnIsUnposted]
            ,1
            ,[intCurrencyId]
            ,intUserId
            ,intEntityId
            ,dtmDateEntered
            ,strBatchId
            ,A.[strCode]
            ,@strJournalDescPrefix + strJournalLineDescription
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,dbo.fnGLGetOverrideAccountBySegment(@intDueFromAccountId, NULL, NULL, B.intAccountSegmentId )
    FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    OUTER APPLY
    (
        SELECT TOP 1 intAccountId FROM  tblGLAccount
        WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@intDueFromAccountId, NULL, NULL, B.intAccountSegmentId )
    ) DueFromOverrideCompany
    WHERE (dblCredit - dblDebit) > 0
    AND @intCompanySegmentId <> B.intAccountSegmentId

    IF @intParentCompanyCount  = 0
    BEGIN
        INSERT INTO @CreditNonParent(
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
                ,strNewAccountIdOverride
            )
        SELECT
                [strTransactionId]
                ,[intTransactionId]
                ,DueToOverrideCompany.intAccountId
                ,A.[strDescription]
                ,[dtmTransactionDate]
                ,[dblCredit]
                ,[dblDebit] 
                ,[dtmDate]
                ,[ysnIsUnposted]
                ,1
                ,[intCurrencyId]
                ,intUserId
                ,intEntityId
                ,dtmDateEntered
                ,strBatchId
                ,[strCode]
                ,strJournalLineDescription
                ,[intJournalLineNo]
                ,[strTransactionType]
                ,[strTransactionForm]
                ,strModuleName
                ,dbo.fnGLGetOverrideAccountBySegment(@intDueToAccountId, NULL, NULL, @intCompanySegmentId )
        FROM  @CreditNonParent A
        OUTER APPLY
        (
            SELECT TOP 1 intAccountId FROM  tblGLAccount
            WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@intDueToAccountId, NULL, NULL, @intCompanySegmentId )
        ) DueToOverrideCompany
    END
END
	
    INSERT INTO @IntraGLEntries
    (
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
    FROM @CreditParent 
    UNION SELECT
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
    FROM @DebitParent
    UNION SELECT
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
    FROM @DebitNonParent
    UNION SELECT
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
    FROM @CreditNonParent   




UPDATE @IntraGLEntries SET strOverrideAccountError = strNewAccountIdOverride  + ' is not an existing GL Account.'
        WHERE intAccountId IS NULL
        

IF EXISTS (SELECT 1 FROM @IntraGLEntries WHERE strOverrideAccountError IS NOT NULL)
BEGIN
    IF @ysnRecap = 0
    BEGIN
        DECLARE @strNewAccountIdOverride NVARCHAR(30)
        SELECT @strNewAccountIdOverride  = strNewAccountIdOverride FROM @IntraGLEntries WHERE intAccountId IS NULL 
        DECLARE @errorMsg NVARCHAR(100) = @strNewAccountIdOverride + ' is not an existing GL Account'
        RAISERROR(@errorMsg,16,1)
        GOTO _Exit
    END
END

_Exit:

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
    ,strOverrideAccountError
    ,strNewAccountIdOverride
 FROM @IntraGLEntries

 
END

