CREATE PROCEDURE uspCMCreateBankTransferIntransitPostEntries
@strTransactionId NVARCHAR(20),
@strBatchId NVARCHAR(40),
@intDefaultCurrencyId INT = 3,
@ysnPostedInTransit BIT = 0
AS


DECLARE @GL_DETAIL_CODE AS NVARCHAR(10)   = 'BTFR' -- String code used in GL Detail table.     
 ,@MODULE_NAME AS NVARCHAR(100)    = 'Cash Management' -- Module where this posting code belongs.    
 ,@TRANSACTION_FORM AS NVARCHAR(100)   = 'Bank Transfer'    
 ,@intBTInTransitAccountId INT
 ,@dtmDate DATETIME


SELECT TOP 1 @intBTInTransitAccountId = intBTInTransitAccountId FROM tblCMCompanyPreferenceOption  
  IF @intBTInTransitAccountId IS NULL  
BEGIN  
    RAISERROR('Cannot find the in transit GL Account ID Setting in Company Configuration.', 11, 1)    
    RETURN
END 
DECLARE @dblFeesFrom DECIMAL(18,6),@dblFeesForeignFrom DECIMAL(18,6), @intGLAccountIdFrom INT,@intGLAccountIdTo INT
SELECT @dblFeesFrom = dblFeesFrom, @dblFeesForeignFrom =dblFeesForeignFrom,
 @intGLAccountIdFrom=intGLAccountIdFrom,@intGLAccountIdTo = intGLAccountIdTo,
 @dtmDate = CASE WHEN @ysnPostedInTransit = 0 THEN dtmDate ELSE dtmInTransit END
 FROM tblCMBankTransfer WHERE @strTransactionId = strTransactionId


IF @ysnPostedInTransit = 0
BEGIN
    INSERT INTO #tmpGLDetail (    
        [strTransactionId]    
        ,[intTransactionId]    
        ,[dtmDate]    
        ,[strBatchId]    
        ,[intAccountId]    
        ,[dblDebit]    
        ,[dblCredit]    
        ,[dblDebitForeign]     
        ,[dblCreditForeign]    
        ,[dblDebitUnit]    
        ,[dblCreditUnit]    
        ,[strDescription]    
        ,[strCode]    
        ,[strReference]    
        ,[intCurrencyId]    
        ,[intCurrencyExchangeRateTypeId]    
        ,[dblExchangeRate]    
        ,[dtmDateEntered]    
        ,[dtmTransactionDate]    
        ,[strJournalLineDescription]    
        ,[ysnIsUnposted]    
        ,[intConcurrencyId]    
        ,[intUserId]    
        ,[strTransactionType]    
        ,[strTransactionForm]    
        ,[strModuleName]    
        ,[intEntityId]    
    )    
    SELECT [strTransactionId]  = strTransactionId    
        ,[intTransactionId]      = intTransactionId    
        ,[dtmDate]               = @dtmDate    
        ,[strBatchId]            = @strBatchId    
        ,[intAccountId]          = GLAccnt.intAccountId    
        ,[dblDebit]              = 0    
        ,[dblCredit]             = dblAmountFrom
        ,[dblDebitForeign]       = 0    
        ,[dblCreditForeign]      = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom   
                                    THEN dblAmountFrom ELSE  dblAmountForeignFrom END  
        ,[dblDebitUnit]          = 0    
        ,[dblCreditUnit]         = 0    
        ,[strDescription]        = A.strDescription    
        ,[strCode]               = @GL_DETAIL_CODE    
        ,[strReference]          = A.strReferenceFrom    
        ,[intCurrencyId]         = intCurrencyIdAmountFrom    
        ,[intCurrencyExchangeRateTypeId] =  CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN NULL ELSE  intRateTypeIdAmountFrom  END  
        ,[dblExchangeRate]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN 1 ELSE dblRateAmountFrom  END  
        ,[dtmDateEntered]        = GETDATE()    
        ,[dtmTransactionDate]    = A.dtmDate    
        ,[strJournalLineDescription]  = GLAccnt.strDescription    
        ,[ysnIsUnposted]         = 0     
        ,[intConcurrencyId]      = 1    
        ,[intUserId]             = intLastModifiedUserId    
        ,[strTransactionType]    = @TRANSACTION_FORM    
        ,[strTransactionForm]    = @TRANSACTION_FORM    
        ,[strModuleName]         = @MODULE_NAME    
        ,[intEntityId]           = A.intEntityId    
    FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt    
    ON A.intGLAccountIdFrom = GLAccnt.intAccountId    
    WHERE A.strTransactionId = @strTransactionId    
    -- 2. DEBIT SIdE (TARGET OF THE FUND)    
    UNION ALL     
   SELECT [strTransactionId]  = strTransactionId    
        ,[intTransactionId]      = intTransactionId    
        ,[dtmDate]               = @dtmDate    
        ,[strBatchId]            = @strBatchId    
        ,[intAccountId]          = @intBTInTransitAccountId
        ,[dblDebit]              = dblAmountFrom    
        ,[dblCredit]             = 0
        ,[dblDebitForeign]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom   
                                    THEN dblAmountFrom ELSE  dblAmountForeignFrom END      
        ,[dblCreditForeign]      = 0
        ,[dblDebitUnit]          = 0    
        ,[dblCreditUnit]         = 0    
        ,[strDescription]        = A.strDescription    
        ,[strCode]               = @GL_DETAIL_CODE    
        ,[strReference]          = A.strReferenceFrom    
        ,[intCurrencyId]         = intCurrencyIdAmountFrom    
        ,[intCurrencyExchangeRateTypeId] =  CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN NULL ELSE  intRateTypeIdAmountFrom  END  
        ,[dblExchangeRate]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN 1 ELSE dblRateAmountFrom  END  
        ,[dtmDateEntered]        = GETDATE()    
        ,[dtmTransactionDate]    = A.dtmDate    
        ,[strJournalLineDescription]  = GLAccnt.strDescription    
        ,[ysnIsUnposted]         = 0     
        ,[intConcurrencyId]      = 1    
        ,[intUserId]             = intLastModifiedUserId    
        ,[strTransactionType]    = @TRANSACTION_FORM    
        ,[strTransactionForm]    = @TRANSACTION_FORM    
        ,[strModuleName]         = @MODULE_NAME    
        ,[intEntityId]           = A.intEntityId    
    FROM [dbo].tblCMBankTransfer A 
    OUTER APPLY(
        SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = @intBTInTransitAccountId
    )GLAccnt
    WHERE A.strTransactionId = @strTransactionId   


    EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdFrom, 'From', 
        @dtmDate, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom,  @intDefaultCurrencyId   
    
END
ELSE
BEGIN
    INSERT INTO #tmpGLDetail (    
        [strTransactionId]    
        ,[intTransactionId]    
        ,[dtmDate]    
        ,[strBatchId]    
        ,[intAccountId]    
        ,[dblDebit]    
        ,[dblCredit]    
        ,[dblDebitForeign]     
        ,[dblCreditForeign]    
        ,[dblDebitUnit]    
        ,[dblCreditUnit]    
        ,[strDescription]    
        ,[strCode]    
        ,[strReference]    
        ,[intCurrencyId]    
        ,[intCurrencyExchangeRateTypeId]    
        ,[dblExchangeRate]    
        ,[dtmDateEntered]    
        ,[dtmTransactionDate]    
        ,[strJournalLineDescription]    
        ,[ysnIsUnposted]    
        ,[intConcurrencyId]    
        ,[intUserId]    
        ,[strTransactionType]    
        ,[strTransactionForm]    
        ,[strModuleName]    
        ,[intEntityId]    
    )    
    SELECT   
        [strTransactionId]      = @strTransactionId    
        ,[intTransactionId]     = intTransactionId    
        ,[dtmDate]              = @dtmDate    
        ,[strBatchId]           = @strBatchId    
        ,[intAccountId]         = GLAccnt.intAccountId    
        ,[dblDebit]             = dblAmountTo
        ,[dblCredit]            = 0     
        ,[dblDebitForeign]      = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo   
                                    THEN dblAmountTo ELSE  dblAmountForeignTo END  
        ,[dblCreditForeign]     = 0    
        ,[dblDebitUnit]         = 0    
        ,[dblCreditUnit]        = 0    
        ,[strDescription]       = A.strDescription    
        ,[strCode]              = @GL_DETAIL_CODE    
        ,[strReference]         = strReferenceTo    
        ,[intCurrencyId]        = intCurrencyIdAmountTo    
        ,[intCurrencyExchangeRateTypeId] = CASE WHEN @intDefaultCurrencyId =  intCurrencyIdAmountTo THEN NULL ELSE intRateTypeIdAmountTo END  
        ,[dblExchangeRate]      = CASE WHEN @intDefaultCurrencyId =  intCurrencyIdAmountTo THEN 1  
                                        --WHEN @ysnForeignToForeign = 1 THEN dblAmountSettlementTo/dblAmountForeignFrom  
                                        ELSE dblRateAmountTo END  
        ,[dtmDateEntered]       = GETDATE()    
        ,[dtmTransactionDate]   = A.dtmDate    
        ,[strJournalLineDescription]  = GLAccnt.strDescription    
        ,[ysnIsUnposted]        = 0     
        ,[intConcurrencyId]     = 1    
        ,[intUserId]            = A.intLastModifiedUserId    
        ,[strTransactionType]   = @TRANSACTION_FORM    
        ,[strTransactionForm]   = @TRANSACTION_FORM    
        ,[strModuleName]        = @MODULE_NAME    
        ,[intEntityId]          = A.intEntityId    
    FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt    
    ON A.intGLAccountIdTo = GLAccnt.intAccountId      
    WHERE A.strTransactionId = @strTransactionId   
    UNION ALL
    SELECT [strTransactionId]  = strTransactionId    
        ,[intTransactionId]      = intTransactionId    
        ,[dtmDate]               = @dtmDate    
        ,[strBatchId]            = @strBatchId    
        ,[intAccountId]          = @intBTInTransitAccountId
        ,[dblDebit]              = 0
        ,[dblCredit]             = dblAmountFrom    
        ,[dblDebitForeign]       = 0
        ,[dblCreditForeign]      = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom   
                                    THEN dblAmountFrom ELSE  dblAmountForeignFrom END      
        ,[dblDebitUnit]          = 0    
        ,[dblCreditUnit]         = 0    
        ,[strDescription]        = A.strDescription    
        ,[strCode]               = @GL_DETAIL_CODE    
        ,[strReference]          = A.strReferenceFrom    
        ,[intCurrencyId]         = intCurrencyIdAmountFrom    
        ,[intCurrencyExchangeRateTypeId] =  CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN NULL ELSE  intRateTypeIdAmountFrom  END  
        ,[dblExchangeRate]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN 1 ELSE dblRateAmountFrom  END  
        ,[dtmDateEntered]        = GETDATE()    
        ,[dtmTransactionDate]    = A.dtmDate    
        ,[strJournalLineDescription]  = GLAccnt.strDescription    
        ,[ysnIsUnposted]         = 0     
        ,[intConcurrencyId]      = 1    
        ,[intUserId]             = intLastModifiedUserId    
        ,[strTransactionType]    = @TRANSACTION_FORM    
        ,[strTransactionForm]    = @TRANSACTION_FORM    
        ,[strModuleName]         = @MODULE_NAME    
        ,[intEntityId]           = A.intEntityId    
    FROM [dbo].tblCMBankTransfer A 
    OUTER APPLY(
        SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = @intBTInTransitAccountId
    )GLAccnt
    WHERE A.strTransactionId = @strTransactionId    

    EXEC uspCMCreateBankTransferDiffEntries @strTransactionId, @dtmDate, @strBatchId, @intDefaultCurrencyId

    EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdTo, 'To'  
    , @dtmDate, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom, @intDefaultCurrencyId  


END