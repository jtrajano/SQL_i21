CREATE PROCEDURE uspCMCreateBankTransferSwapShortPostEntries  
@strTransactionId NVARCHAR(20),  
@strBatchId NVARCHAR(40),  
@intDefaultCurrencyId INT,  
@ysnPostedInTransit BIT = 0  
AS  
  
  
DECLARE @GL_DETAIL_CODE AS NVARCHAR(10)   = 'BTFR' -- String code used in GL Detail table.       
 ,@MODULE_NAME AS NVARCHAR(100)    = 'Cash Management' -- Module where this posting code belongs.      
 ,@TRANSACTION_FORM AS NVARCHAR(100)   = 'Bank Transfer'      
 ,@intBTInTransitAccountId INT  
 ,@intRealizedGainOnSwap INT
 ,@dtmDate DATETIME  
  
  
SELECT TOP 1 @intBTInTransitAccountId = intBTInTransitAccountId FROM tblCMCompanyPreferenceOption    
  IF ISNULL(@intBTInTransitAccountId,0) = 0
BEGIN    
    RAISERROR('Cannot find the in transit GL Account ID Setting in Company Configuration.', 11, 1)      
    RETURN  
END   

SELECT TOP 1 @intRealizedGainOnSwap = intGainOnSwapRealizedId FROM tblSMMultiCurrency
  IF ISNULL(@intRealizedGainOnSwap,0) = 0
BEGIN    
    RAISERROR('Cannot find the Realized Gain on Swap GL Account ID Setting in Company Configuration.', 11, 1)      
    RETURN  
END   


DECLARE @intGLAccountIdFrom INT,@intGLAccountIdTo INT  
SELECT   
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
        ,[strJournalLineDescription]  = 'In-Transit Entry'
        ,[ysnIsUnposted]         = 0       
        ,[intConcurrencyId]      = 1      
        ,[intUserId]             = intLastModifiedUserId      
        ,[strTransactionType]    = @TRANSACTION_FORM      
        ,[strTransactionForm]    = @TRANSACTION_FORM      
        ,[strModuleName]         = @MODULE_NAME      
        ,[intEntityId]           = A.intEntityId      
    FROM [dbo].tblCMBankTransfer A 
    CROSS APPLY(SELECT TOP 1 strDescription FROM tblGLAccount
         WHERE intAccountId = @intBTInTransitAccountId) GLAccnt
    WHERE A.strTransactionId = @strTransactionId      
    
  
    -- EXEC uspCMCreateBankTransferDiffEntries @strTransactionId, @dtmDate, @strBatchId, @intDefaultCurrencyId  
    EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdFrom, 'From',   
        @dtmDate, @strBatchId, @intDefaultCurrencyId     
      
END  
ELSE  
BEGIN  
DECLARE @intBTSwapToFXGLAccountId INT  -- payable
, @intBTSwapFromFXGLAccountId INT -- receivable

SELECT TOP 1 @intBTSwapToFXGLAccountId = intBTSwapToFXGLAccountId, @intBTSwapFromFXGLAccountId = intBTSwapFromFXGLAccountId 
FROM tblCMCompanyPreferenceOption    

IF ISNULL(@intBTSwapToFXGLAccountId,0) = 0   
BEGIN    
    RAISERROR('Cannot find the Account Payable Swap GL Account ID Setting in Company Configuration.', 11, 1)      
    RETURN  
END   

IF ISNULL(@intBTSwapFromFXGLAccountId,0) = 0   
BEGIN    
    RAISERROR('Cannot find the Account Receivable Swap GL Account ID Setting in Company Configuration.', 11, 1)      
    RETURN  
END   


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
        ,[dblExchangeRate]      = CASE WHEN @intDefaultCurrencyId =  intCurrencyIdAmountTo THEN 1 ELSE dblRateAmountTo END    
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
        ,[strReference]          = A.strReferenceTo  
        ,[intCurrencyId]         = intCurrencyIdAmountFrom
        ,[intCurrencyExchangeRateTypeId] =  CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN NULL ELSE  intRateTypeIdAmountFrom  END    
        ,[dblExchangeRate]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN 1 ELSE dblRateAmountFrom  END    
        ,[dtmDateEntered]        = GETDATE()      
        ,[dtmTransactionDate]    = A.dtmDate      
        ,[strJournalLineDescription]  = 'In-Transit Entry'
        ,[ysnIsUnposted]         = 0       
        ,[intConcurrencyId]      = 1      
        ,[intUserId]             = intLastModifiedUserId      
        ,[strTransactionType]    = @TRANSACTION_FORM      
        ,[strTransactionForm]    = @TRANSACTION_FORM      
        ,[strModuleName]         = @MODULE_NAME      
        ,[intEntityId]           = A.intEntityId      
    FROM [dbo].tblCMBankTransfer A   
    WHERE A.strTransactionId = @strTransactionId   
    UNION ALL
    SELECT [strTransactionId]  = strTransactionId      
        ,[intTransactionId]      = intTransactionId      
        ,[dtmDate]               = @dtmDate
        ,[strBatchId]            = @strBatchId      
        ,[intAccountId]          = @intRealizedGainOnSwap  
        ,[dblDebit]              = 0  
        ,[dblCredit]             = dblDifference  
        ,[dblDebitForeign]       = 0  
        ,[dblCreditForeign]      = dblDifference
        ,[dblDebitUnit]          = 0      
        ,[dblCreditUnit]         = 0      
        ,[strDescription]        = A.strDescription      
        ,[strCode]               = @GL_DETAIL_CODE      
        ,[strReference]          = A.strReferenceTo  
        ,[intCurrencyId]         = @intDefaultCurrencyId
        ,[intCurrencyExchangeRateTypeId] =  NULL
        ,[dblExchangeRate]       = 1
        ,[dtmDateEntered]        = GETDATE()      
        ,[dtmTransactionDate]    = A.dtmDate      
        ,[strJournalLineDescription]  = 'Forex Difference'
        ,[ysnIsUnposted]         = 0       
        ,[intConcurrencyId]      = 1      
        ,[intUserId]             = intLastModifiedUserId      
        ,[strTransactionType]    = @TRANSACTION_FORM      
        ,[strTransactionForm]    = @TRANSACTION_FORM      
        ,[strModuleName]         = @MODULE_NAME      
        ,[intEntityId]           = A.intEntityId      
    FROM [dbo].tblCMBankTransfer A   
    WHERE A.strTransactionId = @strTransactionId     
    UNION ALL -- currency payable 
     SELECT [strTransactionId]  = strTransactionId      
        ,[intTransactionId]      = intTransactionId      
        ,[dtmDate]               = @dtmDate
        ,[strBatchId]            = @strBatchId      
        ,[intAccountId]          = @intBTSwapToFXGLAccountId
        ,[dblDebit]              = 0
        ,[dblCredit]             = dblPayableFn -- dblAmountFrom
        ,[dblDebitForeign]       = 0
        ,[dblCreditForeign]      = dblPayableFx -- dblAmountFrom/dblRateAmountTo  
        ,[dblDebitUnit]          = 0      
        ,[dblCreditUnit]         = 0      
        ,[strDescription]        = A.strDescription      
        ,[strCode]               = @GL_DETAIL_CODE      
        ,[strReference]          = A.strReferenceTo  
        ,[intCurrencyId]         = intCurrencyIdAmountTo
        ,[intCurrencyExchangeRateTypeId] =  intRateTypeIdAmountTo
        ,[dblExchangeRate]       = dblPayableFn/dblPayableFx
        ,[dtmDateEntered]        = GETDATE()      
        ,[dtmTransactionDate]    = A.dtmDate      
        ,[strJournalLineDescription]  = 'Currency Payable'
        ,[ysnIsUnposted]         = 0       
        ,[intConcurrencyId]      = 1      
        ,[intUserId]             = intLastModifiedUserId      
        ,[strTransactionType]    = @TRANSACTION_FORM      
        ,[strTransactionForm]    = @TRANSACTION_FORM      
        ,[strModuleName]         = @MODULE_NAME      
        ,[intEntityId]           = A.intEntityId      
    FROM [dbo].tblCMBankTransfer A   
    WHERE A.strTransactionId = @strTransactionId      
    UNION ALL -- currency receivable 
     SELECT [strTransactionId]  = strTransactionId      
        ,[intTransactionId]      = intTransactionId      
        ,[dtmDate]               = @dtmDate
        ,[strBatchId]            = @strBatchId      
        ,[intAccountId]          = @intBTSwapFromFXGLAccountId
        ,[dblDebit]              = dblReceivableFn-- dblAmountFrom
        ,[dblCredit]             = 0
        ,[dblDebitForeign]       = dblReceivableFx-- dblAmountForeignFrom
        ,[dblCreditForeign]      = 0
        ,[dblDebitUnit]          = 0      
        ,[dblCreditUnit]         = 0      
        ,[strDescription]        = A.strDescription      
        ,[strCode]               = @GL_DETAIL_CODE      
        ,[strReference]          = A.strReferenceTo  
        ,[intCurrencyId]         = intCurrencyIdAmountFrom
        ,[intCurrencyExchangeRateTypeId] =  intRateTypeIdAmountFrom
        ,[dblExchangeRate]       = dblReceivableFn/dblReceivableFx
        ,[dtmDateEntered]        = GETDATE()      
        ,[dtmTransactionDate]    = A.dtmDate      
        ,[strJournalLineDescription]  = 'Currency Receivable'
        ,[ysnIsUnposted]         = 0       
        ,[intConcurrencyId]      = 1      
        ,[intUserId]             = intLastModifiedUserId      
        ,[strTransactionType]    = @TRANSACTION_FORM      
        ,[strTransactionForm]    = @TRANSACTION_FORM      
        ,[strModuleName]         = @MODULE_NAME      
        ,[intEntityId]           = A.intEntityId      
    FROM [dbo].tblCMBankTransfer A   
    WHERE A.strTransactionId = @strTransactionId      


    EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdTo, 'To' , @dtmDate, @strBatchId, @intDefaultCurrencyId    
  
  
END