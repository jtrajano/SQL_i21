CREATE PROCEDURE uspCMCreateBankTransferPostEntries
@strTransactionId NVARCHAR(20),
@intBankTransferTypeId INT,
@dtmDate DATETIME,
@strBatchId NVARCHAR(40),
@intDefaultCurrencyId INT = 3,
@ysnPostedInTransit BIT = 0
AS

declare @GL_DETAIL_CODE AS NVARCHAR(10)   = 'BTFR' -- String code used in GL Detail table.     
 ,@MODULE_NAME AS NVARCHAR(100)    = 'Cash Management' -- Module where this posting code belongs.    
 ,@TRANSACTION_FORM AS NVARCHAR(100)   = 'Bank Transfer'    

IF @ysnPostedInTransit = 0 OR @intBankTransferTypeId = 1
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
        ,[intAccountId]          = GLAccnt.intAccountId    
        ,[dblDebit]              = 0    
        ,[dblCredit]             = dblAmountFrom --   CASE WHEN @ysnForeignToForeign =1 THEN ROUND(A.dblAmount * ISNULL(@dblRate,1),2)  WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountFunctional.Val ELSE A.dblAmount END    
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
    SELECT   
        [strTransactionId]      = @strTransactionId    
        ,[intTransactionId]     = intTransactionId    
        ,[dtmDate]              = @dtmDate    
        ,[strBatchId]           = @strBatchId    
        ,[intAccountId]         = GLAccnt.intAccountId    
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
    FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt    
    ON A.intGLAccountIdTo = GLAccnt.intAccountId      
    WHERE A.strTransactionId = @strTransactionId   

END