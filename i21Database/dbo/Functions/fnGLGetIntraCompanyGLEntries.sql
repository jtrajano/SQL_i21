CREATE FUNCTION fnGLGetIntraCompanyGLEntries
(
    @GLEntries RecapTableType READONLY,
    @ysnRecap BIT,
    @ysnPost BIT
)

RETURNS  @IntraGLEntries TABLE (
    [dtmDate]                   DATETIME         NULL,
	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NULL,
	[dtmDateEntered]            DATETIME         NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NULL,
	[dblDebitForeign]			NUMERIC (18, 6) NULL,
	[dblDebitReport]			NUMERIC (18, 6) NULL,
	[dblCreditForeign]			NUMERIC (18, 6) NULL,
	[dblCreditReport]			NUMERIC (18, 6) NULL,
	[dblReportingRate]			NUMERIC (18, 6) NULL,
	[dblForeignRate]			NUMERIC (18, 6) NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[strRateType]			    NVARCHAR(50)	COLLATE Latin1_General_CI_AS,
	[strDocument]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strComments]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	-- new columns GL-3550
	[strSourceDocumentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intSourceLocationId]		INT NULL,
	[intSourceUOMId]			INT NULL,
	[dblSourceUnitDebit]		NUMERIC (18, 6)  NULL,
	[dblSourceUnitCredit]		NUMERIC (18, 6)  NULL,
	[intCommodityId]			INT NULL,
	intSourceEntityId INT NULL,
	ysnRebuild BIT NULL,
	-- new columns GL-3550

	--strModuleCode nvarchar(5) Collate Latin1_General_CI_AS,
    intAccountIdOverride INT NULL,
    intLocationSegmentOverrideId INT NULL,
    intLOBSegmentOverrideId INT NULL,
    intCompanySegmentOverrideId INT NULL,
    strNewAccountIdOverride NVARCHAR(40) Collate Latin1_General_CI_AS NULL,
    intNewAccountIdOverride INT NULL,
    strOverrideAccountError NVARCHAR(800) Collate Latin1_General_CI_AS NULL,
    intCompanyLocationId INT NULL,
	[intLedgerId] INT NULL,
	[intSubledgerId] INT NULL

)

AS
BEGIN
    
    IF ISNULL(@ysnPost,0) = 0 
            RETURN

    IF NOT EXISTS( SELECT 1 FROM tblGLCompanyPreferenceOption WHERE ysnAllowIntraCompanyEntries = 1)
        RETURN

	--CHECK IF COMPANY DOES NOT EXIST
	IF NOT EXISTS(SELECT 1 FROM tblGLAccountStructure A JOIN tblGLSegmentType B ON A.intStructureType = B.intSegmentTypeId WHERE strSegmentType='Company')
		 RETURN

    DECLARE @intDueToAccountId INT,@intDueFromAccountId INT, @intJournalId INT, @intCompanySegmentId INT,@strJournalId NVARCHAR(30)
    SELECT TOP 1 @intCompanySegmentId=J.intCompanySegmentId,@strJournalId =G.strTransactionId,@intJournalId = J.intJournalId  FROM @GLEntries G
    OUTER APPLY(
        SELECT TOP 1 intCompanySegmentId, intJournalId FROM tblGLJournal WHERE strJournalId = G.strTransactionId
    )J

    IF @intCompanySegmentId IS NULL
        RETURN

   

	--count parent company
	DECLARE @intParentCompanyCount INT,@intNonParentCompanyCount INT
	SELECT @intParentCompanyCount = COUNT(*) FROM @GLEntries A JOIN  vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId 
    WHERE intAccountSegmentId = @intCompanySegmentId
	SELECT @intNonParentCompanyCount = COUNT(*) - @intParentCompanyCount FROM @GLEntries
    DECLARE @i INT

	IF @intNonParentCompanyCount = 0
	BEGIN
		--PARENT > 0 , --NONPARENT =0
		SET @i = CAST( 'There should be an entry for a non parent company segment account' AS INT)
		
	END

    
    DECLARE @strCodeNoConfig NVARCHAR(10) =''
    SELECT @strCodeNoConfig =  B.strCode  FROM @GLEntries A JOIN vyuGLCompanyAccountId B ON
    A.intAccountId = B.intAccountId
    OUTER APPLY(
        SELECT Count(*) Cnt  FROM tblGLIntraCompanyConfig WHERE intParentCompanySegmentId = @intCompanySegmentId
        AND intTargetCompanySegmentId = B.intAccountSegmentId
    ) Intra
    WHERE Intra.Cnt = 0
    AND B.intAccountSegmentId <>  @intCompanySegmentId
    
    IF ( @strCodeNoConfig <> '' )
        SET @i = CAST( @strCodeNoConfig  + ' is missing in the Intra Company Config' AS INT)





IF @intParentCompanyCount > 0 AND @intNonParentCompanyCount > 0
BEGIN -- entry here should be balanced between parent and non parent
        DECLARE @dblParentSum DECIMAL(18,6), @dblNonParentSum DECIMAL(18,6)

        
        SELECT @dblNonParentSum = SUM(dblDebit-dblCredit)
        from @GLEntries A JOIN vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
        WHERE intAccountSegmentId <> @intCompanySegmentId

        SELECT @dblParentSum = SUM(dblCredit- dblDebit)
        from @GLEntries A JOIN vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
        WHERE intAccountSegmentId = @intCompanySegmentId

        IF @dblNonParentSum <> @dblParentSum
        BEGIN
            SET @i = CAST( 'Parent company amount should be equal to the sum of non-parent company amount.' AS INT)
            
        END
END

  
DECLARE @strJournalDescPrefix NVARCHAR(30) = 'Intra Company Entries -'

DECLARE @TargetSegmentId INT




IF @intParentCompanyCount  = 0 -- CASE 1
BEGIN

    SELECT TOP 1 @TargetSegmentId = B.intAccountSegmentId FROM @GLEntries A 
    JOIN vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    WHERE intAccountSegmentId <> @intCompanySegmentId
    BEGIN -- CREDIT SIDE DUE ACCOUNT TO
        INSERT INTO @IntraGLEntries(
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
            ,intAccountIdOverride
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
            ,@strJournalDescPrefix + ' Due To Account'
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,OverrideString.Value
            ,intAccountIdOverride =Intra.intDueToAccountId
        FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
        OUTER APPLY(
            SELECT TOP 1  
            intDueToAccountId 
            FROM tblGLIntraCompanyConfig
            WHERE @intCompanySegmentId = intParentCompanySegmentId
            AND B.intAccountSegmentId = intTargetCompanySegmentId
        )Intra
        OUTER APPLY ( SELECT dbo.fnGLGetOverrideAccountBySegment(Intra.intDueToAccountId, NULL, NULL, @intCompanySegmentId ) Value ) OverrideString
        OUTER APPLY(
            SELECT TOP 1 intAccountId FROM  tblGLAccount
            WHERE strAccountId = OverrideString.Value 
        )DueToOverrideCompany
        WHERE (dblDebit - dblCredit) > 0
        UNION
        SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueToOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit]=0
            ,[dblCredit] =dblDebit - dblCredit
            ,[dtmDate]
            ,[ysnIsUnposted]
            ,1
            ,[intCurrencyId]
            ,intUserId
            ,intEntityId
            ,dtmDateEntered
            ,strBatchId
            ,A.strCode
            ,@strJournalDescPrefix + ' Due To Account'
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,strModuleName
            ,OverrideString.Value
            ,intAccountIdOverride=Intra.intDueToAccountId
        FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
        OUTER APPLY(
            SELECT TOP 1  
            intDueToAccountId 
            FROM tblGLIntraCompanyConfig
            WHERE @intCompanySegmentId = intParentCompanySegmentId
            AND B.intAccountSegmentId = intTargetCompanySegmentId
        )Intra
        OUTER APPLY ( SELECT dbo.fnGLGetOverrideAccountBySegment(Intra.intDueToAccountId, NULL, NULL, B.intAccountSegmentId ) Value ) OverrideString
        OUTER APPLY(
            SELECT TOP 1 intAccountId FROM  tblGLAccount
            WHERE strAccountId = OverrideString.Value 
        )DueToOverrideCompany
        WHERE (dblDebit - dblCredit) > 0
    END
    
    BEGIN --DEBIT SIDE DUE ACCOUNT FROM
        -- insert credit side
        INSERT INTO @IntraGLEntries(
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
                ,intAccountIdOverride
            )
        SELECT
                [strTransactionId]
                ,[intTransactionId]
                ,DueFromOverrideCompany.intAccountId
                ,A.[strDescription]
                ,[dtmTransactionDate]
                ,[dblDebit]=dblCredit - dblDebit
                ,[dblCredit] =0
                ,[dtmDate]
                ,[ysnIsUnposted]
                ,1
                ,[intCurrencyId]
                ,intUserId
                ,intEntityId
                ,dtmDateEntered
                ,strBatchId
                ,A.strCode
                ,@strJournalDescPrefix + ' Due From Account'
                ,[intJournalLineNo]
                ,[strTransactionType]
                ,[strTransactionForm]
                ,strModuleName
                ,OverrideString.Value
                ,intAccountIdOverride=Intra.intDueFromAccountId
        FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
        OUTER APPLY(
            SELECT TOP 1  
            intDueFromAccountId 
            FROM tblGLIntraCompanyConfig
            WHERE @intCompanySegmentId = intParentCompanySegmentId
            AND B.intAccountSegmentId = intTargetCompanySegmentId
        )Intra
        OUTER APPLY ( SELECT dbo.fnGLGetOverrideAccountBySegment(Intra.intDueFromAccountId, NULL, NULL, @intCompanySegmentId ) Value ) OverrideString
        OUTER APPLY(
            SELECT TOP 1 intAccountId FROM  tblGLAccount
            WHERE strAccountId = OverrideString.Value 
        )DueFromOverrideCompany
        WHERE (dblCredit - dblDebit) > 0
        UNION
        SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueFromOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit] = dblCredit - dblDebit
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
            ,@strJournalDescPrefix + ' Due From Account'
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,OverrideString.Value
            ,intAccountIdOverride =Intra.intDueFromAccountId
        FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
        OUTER APPLY(
            SELECT TOP 1  
            intDueFromAccountId 
            FROM tblGLIntraCompanyConfig
            WHERE @intCompanySegmentId = intParentCompanySegmentId
            AND B.intAccountSegmentId = intTargetCompanySegmentId
        )Intra
        OUTER APPLY ( SELECT dbo.fnGLGetOverrideAccountBySegment(Intra.intDueFromAccountId, NULL, NULL, B.intAccountSegmentId ) Value ) OverrideString
        OUTER APPLY(
            SELECT TOP 1 intAccountId FROM  tblGLAccount
            WHERE strAccountId = OverrideString.Value 
        )DueFromOverrideCompany
        WHERE (dblCredit - dblDebit) > 0
    
    END

END
ELSE
BEGIN
    SELECT TOP 1 @TargetSegmentId = B.intAccountSegmentId FROM @GLEntries A 
    JOIN vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    WHERE intAccountSegmentId <> @intCompanySegmentId

   
    SELECT TOP 1  
    @intDueToAccountId = intDueToAccountId, 
	@intDueFromAccountId =intDueFromAccountId    
    FROM tblGLIntraCompanyConfig
    WHERE @intCompanySegmentId = intParentCompanySegmentId
    AND @TargetSegmentId = intTargetCompanySegmentId

    --PARENT COMPANY SEGMENT
    INSERT INTO @IntraGLEntries(
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
            ,intAccountIdOverride
    )
   
    SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueToOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit] = 0
            ,[dblCredit] =dblDebit - dblCredit
            ,dtmDate
            ,[ysnIsUnposted]
            ,1
            ,[intCurrencyId]
            ,intUserId
            ,intEntityId
            ,dtmDateEntered
            ,strBatchId
            ,A.[strCode]
            ,@strJournalDescPrefix + ' Due To Account'
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,OverrideString.Value
            ,intAccountIdOverride=Intra.intDueToAccountId
    FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    OUTER APPLY(
        SELECT TOP 1  
        intDueToAccountId 
        FROM tblGLIntraCompanyConfig
        WHERE @intCompanySegmentId = intParentCompanySegmentId
        AND B.intAccountSegmentId = intTargetCompanySegmentId
    )Intra
    OUTER APPLY ( SELECT dbo.fnGLGetOverrideAccountBySegment(Intra.intDueToAccountId, NULL, NULL, B.intAccountSegmentId ) Value ) OverrideString
    OUTER APPLY
    (
        SELECT TOP 1 intAccountId FROM  tblGLAccount
        WHERE strAccountId = OverrideString.Value
    ) DueToOverrideCompany
    WHERE (dblDebit - dblCredit) > 0
    AND B.intAccountSegmentId <> @intCompanySegmentId
    UNION ALL
    SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueFromOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit] = dblCredit - dblDebit
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
            ,@strJournalDescPrefix + ' Due From Account'
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,OverrideString.Value
            ,intAccountIdOverride=Intra.intDueFromAccountId
    FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    OUTER APPLY(
        SELECT TOP 1  
        intDueFromAccountId 
        FROM tblGLIntraCompanyConfig
        WHERE @intCompanySegmentId = intParentCompanySegmentId
        AND B.intAccountSegmentId = intTargetCompanySegmentId
    )Intra
    OUTER APPLY ( SELECT dbo.fnGLGetOverrideAccountBySegment(Intra.intDueFromAccountId, NULL, NULL, B.intAccountSegmentId ) Value ) OverrideString
    OUTER APPLY
    (
        SELECT TOP 1 intAccountId FROM  tblGLAccount
        WHERE strAccountId = OverrideString.Value
    ) DueFromOverrideCompany
    WHERE (dblCredit - dblDebit) > 0
    AND B.intAccountSegmentId <> @intCompanySegmentId 


    INSERT INTO @IntraGLEntries(
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
            ,intAccountIdOverride
        )  SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueFromOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit] = (dblDebit -  dblCredit)
            ,[dblCredit] =0
            ,dtmDate
            ,[ysnIsUnposted]
            ,1
            ,[intCurrencyId]
            ,intUserId
            ,intEntityId
            ,dtmDateEntered
            ,strBatchId
            ,A.[strCode]
            ,@strJournalDescPrefix + ' Due From Account'
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,OverrideString.Value
            ,intAccountIdOverride= Intra.intDueFromAccountId
    FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    OUTER APPLY(

        SELECT TOP 1 intDueFromAccountId  FROM tblGLIntraCompanyConfig WHERE intParentCompanySegmentId = @intCompanySegmentId 
        AND intTargetCompanySegmentId = B.intAccountSegmentId
    )Intra

    OUTER APPLY ( SELECT dbo.fnGLGetOverrideAccountBySegment(Intra.intDueFromAccountId, NULL, NULL, @intCompanySegmentId ) Value ) OverrideString
    OUTER APPLY
    (
        SELECT TOP 1 intAccountId FROM  tblGLAccount
        WHERE strAccountId = OverrideString.Value
    ) DueFromOverrideCompany
    WHERE (dblDebit -  dblCredit) > 0
    AND B.intAccountSegmentId <> @intCompanySegmentId 
    UNION ALL
    SELECT
            [strTransactionId]
            ,[intTransactionId]
            ,DueToOverrideCompany.intAccountId
            ,A.[strDescription]
            ,[dtmTransactionDate]
            ,[dblDebit] = 0
            ,[dblCredit] =dblCredit -  dblDebit
            ,dtmDate
            ,[ysnIsUnposted]
            ,1
            ,[intCurrencyId]
            ,intUserId
            ,intEntityId
            ,dtmDateEntered
            ,strBatchId
            ,A.[strCode]
            ,@strJournalDescPrefix + ' Due To Account'
            ,[intJournalLineNo]
            ,[strTransactionType]
            ,[strTransactionForm]
            ,'General Ledger'
            ,OverrideString.Value
            ,intAccountIdOverride= Intra.intDueToAccountId
    FROM @GLEntries A join vyuGLCompanyAccountId B ON A.intAccountId = B.intAccountId
    OUTER APPLY(

        SELECT TOP 1 intDueToAccountId  FROM tblGLIntraCompanyConfig WHERE intParentCompanySegmentId = @intCompanySegmentId 
        AND intTargetCompanySegmentId = B.intAccountSegmentId
    )Intra

    OUTER APPLY ( SELECT dbo.fnGLGetOverrideAccountBySegment(Intra.intDueToAccountId, NULL, NULL, @intCompanySegmentId ) Value ) OverrideString
    OUTER APPLY
    (
        SELECT TOP 1 intAccountId FROM  tblGLAccount
        WHERE strAccountId = OverrideString.Value
    ) DueToOverrideCompany
    WHERE (dblCredit -  dblDebit) > 0
    AND B.intAccountSegmentId <> @intCompanySegmentId 
  



END

UPDATE @IntraGLEntries SET strOverrideAccountError = strNewAccountIdOverride  + ' is not an existing GL Account.'
        WHERE intAccountId IS NULL


RETURN
 
END

