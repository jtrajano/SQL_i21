CREATE PROCEDURE uspCMCreateBankTransferForwardPostEntries
@strTransactionId NVARCHAR(20),
@strBatchId NVARCHAR(40),
@intDefaultCurrencyId INT = 3,
@ysnPostedInTransit BIT = 0
AS

DECLARE @GL_DETAIL_CODE AS NVARCHAR(10)   = 'BTFR' -- String code used in GL Detail table.     
 ,@MODULE_NAME AS NVARCHAR(100)    = 'Cash Management' -- Module where this posting code belongs.    
 ,@TRANSACTION_FORM AS NVARCHAR(100)   = 'Bank Transfer',
 @dblFeesFrom DECIMAL(18,6),@dblFeesForeignFrom DECIMAL(18,6), @intGLAccountIdFrom INT,@intGLAccountIdTo INT,
 @intBTForwardToFXGLAccountId INT, @intBTForwardFromFXGLAccountId INT,
 @dtmDate DATETIME


 SELECT TOP 1 @intBTForwardToFXGLAccountId = intBTForwardToFXGLAccountId,   
    @intBTForwardFromFXGLAccountId = intBTForwardFromFXGLAccountId  
    FROM tblCMCompanyPreferenceOption  
  
    IF ISNULL(@intBTForwardToFXGLAccountId ,0) = 0  
    BEGIN  
        RAISERROR('Accrued Receivable Forward GL Account is not assigned.', 11, 1)    
        RETURN
    END  
  
    IF ISNULL(@intBTForwardFromFXGLAccountId,0) = 0  
    BEGIN  
        RAISERROR('Accrued Payable Forward GL Account is not assigned.', 11, 1)    
        RETURN
    END  

SELECT @dblFeesFrom = dblFeesFrom, @dblFeesForeignFrom =dblFeesForeignFrom, 
@intGLAccountIdFrom=intGLAccountIdFrom,@intGLAccountIdTo = intGLAccountIdTo
,@dtmDate = CASE WHEN @ysnPostedInTransit = 0 THEN dtmAccrual ELSE dtmDate END

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
        ,[intAccountId]          = @intBTForwardFromFXGLAccountId
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
        SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId =@intBTForwardFromFXGLAccountId
    ) GLAccnt
    WHERE A.strTransactionId = @strTransactionId    
    -- 2. DEBIT SIdE (TARGET OF THE FUND)    
    UNION ALL     
    SELECT   
        [strTransactionId]      = @strTransactionId    
        ,[intTransactionId]     = intTransactionId    
        ,[dtmDate]              = @dtmDate
        ,[strBatchId]           = @strBatchId    
        ,[intAccountId]         = @intBTForwardToFXGLAccountId
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
    FROM [dbo].tblCMBankTransfer A 
    OUTER APPLY(
        SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId =@intBTForwardToFXGLAccountId
    ) GLAccnt
    WHERE A.strTransactionId = @strTransactionId   
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
    SELECT [strTransactionId]  = strTransactionId    
        ,[intTransactionId]      = intTransactionId    
        ,[dtmDate]               = @dtmDate    
        ,[strBatchId]            = @strBatchId    
        ,[intAccountId]          = @intBTForwardFromFXGLAccountId
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
        SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId =@intBTForwardFromFXGLAccountId
    ) GLAccnt
    WHERE A.strTransactionId = @strTransactionId    
    -- 2. DEBIT SIdE (TARGET OF THE FUND)    
    UNION ALL     
    SELECT   
        [strTransactionId]      = @strTransactionId    
        ,[intTransactionId]     = intTransactionId    
        ,[dtmDate]              = @dtmDate    
        ,[strBatchId]           = @strBatchId    
        ,[intAccountId]         = @intBTForwardToFXGLAccountId
        ,[dblDebit]             = 0
        ,[dblCredit]            = dblAmountTo     
        ,[dblDebitForeign]      = 0
        ,[dblCreditForeign]     = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo   
                                    THEN dblAmountTo ELSE  dblAmountForeignTo END      
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
    FROM [dbo].tblCMBankTransfer A 
    OUTER APPLY(
        SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId =@intBTForwardToFXGLAccountId
    ) GLAccnt
    WHERE A.strTransactionId = @strTransactionId   



END


EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdFrom, 'From', @dtmDate, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom,  @intDefaultCurrencyId
EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdTo, 'To'  , @dtmDate, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom, @intDefaultCurrencyId



RETURN 1