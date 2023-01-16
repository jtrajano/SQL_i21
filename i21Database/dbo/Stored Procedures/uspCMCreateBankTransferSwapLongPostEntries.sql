CREATE PROCEDURE uspCMCreateBankTransferSwapLongPostEntries  
    @strTransactionId NVARCHAR(20),  
    @strBatchId NVARCHAR(40),  
    @intDefaultCurrencyId INT,  
    @ysnPostedInTransit BIT
AS  

DECLARE @GL_DETAIL_CODE AS NVARCHAR(10)   = 'BTFR' -- String code used in GL Detail table.       
 ,@MODULE_NAME AS NVARCHAR(100)    = 'Cash Management' -- Module where this posting code belongs.      
 ,@TRANSACTION_FORM AS NVARCHAR(100)   = 'Bank Transfer'      
 ,@intBTInTransitAccountId INT  
 ,@intBTForexDiffAccountId INT
 ,@dtmDate DATETIME  
  
  
SELECT TOP 1 @intBTInTransitAccountId = intBTInTransitAccountId FROM tblCMCompanyPreferenceOption    
  IF ISNULL(@intBTInTransitAccountId,0) = 0
BEGIN    
    RAISERROR('Cannot find the in transit GL Account ID Setting in Company Configuration.', 11, 1)      
    RETURN  
END   

SELECT TOP 1 @intBTForexDiffAccountId = intBTForexDiffAccountId FROM tblCMCompanyPreferenceOption    
  IF ISNULL(@intBTForexDiffAccountId,0) = 0   
BEGIN    
    RAISERROR('Cannot find the Forex Difference GL Account ID Setting in Company Configuration.', 11, 1)      
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
        ,[dblCredit]             = dblAmountSettlementFrom
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
        ,[dblExchangeRate]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN 1 ELSE dblRateAmountSettlementFrom  END    
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
        ,[dblDebit]              = dblAmountSettlementFrom 
        ,[dblCredit]             = 0
        ,[dblDebitForeign]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom
                                   THEN dblAmountFrom ELSE  dblAmountForeignFrom END   
        ,[dblCreditForeign]      = 0
        ,[dblDebitUnit]          = 0      
        ,[dblCreditUnit]         = 0      
        ,[strDescription]        = A.strDescription      
        ,[strCode]               = @GL_DETAIL_CODE      
        ,[strReference]          = A.strReferenceTo
        ,[intCurrencyId]         = intCurrencyIdAmountFrom
        ,[intCurrencyExchangeRateTypeId] =  CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN NULL ELSE  intRateTypeIdAmountFrom  END    
        ,[dblExchangeRate]       = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountFrom THEN 1 ELSE dblRateAmountSettlementFrom END    
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

SELECT TOP 1 @intBTSwapToFXGLAccountId = intBTSwapToFXGLAccountId,@intBTSwapFromFXGLAccountId = intBTSwapFromFXGLAccountId 
FROM tblCMCompanyPreferenceOption    

IF @intBTSwapToFXGLAccountId IS NULL    
BEGIN    
    RAISERROR('Cannot find the Accrued Payable Forward GL Account ID Setting in Company Configuration.', 11, 1)      
    RETURN  
END   

IF @intBTSwapFromFXGLAccountId IS NULL    
BEGIN    
    RAISERROR('Cannot find the Accrued Receivable Forward GL Account ID Setting in Company Configuration.', 11, 1)      
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
        ,[intAccountId]         = @intBTInTransitAccountId --GLAccnt.intAccountId   
        ,[dblDebit]             = 0       
        ,[dblCredit]            = dblAmountSettlementFrom
        ,[dblDebitForeign]      = 0
        ,[dblCreditForeign]     = dblAmountForeignFrom      
        ,[dblDebitUnit]         = 0      
        ,[dblCreditUnit]        = 0      
        ,[strDescription]       = A.strDescription      
        ,[strCode]              = @GL_DETAIL_CODE      
        ,[strReference]         = strReferenceFrom      
        ,[intCurrencyId]        = intCurrencyIdAmountFrom      
        ,[intCurrencyExchangeRateTypeId] = NULL
        ,[dblExchangeRate]      = dblRateAmountSettlementFrom
        ,[dtmDateEntered]       = GETDATE()      
        ,[dtmTransactionDate]   = A.dtmDate      
        ,[strJournalLineDescription]  = 'In-Transit Entry'      
        ,[ysnIsUnposted]        = 0       
        ,[intConcurrencyId]     = 1      
        ,[intUserId]            = A.intLastModifiedUserId      
        ,[strTransactionType]   = @TRANSACTION_FORM      
        ,[strTransactionForm]   = @TRANSACTION_FORM      
        ,[strModuleName]        = @MODULE_NAME      
        ,[intEntityId]          = A.intEntityId      
    FROM [dbo].tblCMBankTransfer A-- INNER JOIN [dbo].tblGLAccount GLAccnt      
    --ON A.intGLAccountIdFrom = GLAccnt.intAccountId    
	CROSS APPLY(SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountId = @intBTInTransitAccountId) GLAccnt
    WHERE A.strTransactionId = @strTransactionId 
    UNION ALL -- bank to 
    SELECT     
        [strTransactionId]      = @strTransactionId      
        ,[intTransactionId]     = intTransactionId      
        ,[dtmDate]              = @dtmDate      
        ,[strBatchId]           = @strBatchId      
        ,[intAccountId]         = GLAccnt.intAccountId      
        ,[dblDebit]             = dblAmountSettlementTo
        ,[dblCredit]            = 0 
        ,[dblDebitForeign]      = dblAmountForeignTo 
        ,[dblCreditForeign]     = 0
        ,[dblDebitUnit]         = 0      
        ,[dblCreditUnit]        = 0      
        ,[strDescription]       = A.strDescription      
        ,[strCode]              = @GL_DETAIL_CODE      
        ,[strReference]         = strReferenceTo
        ,[intCurrencyId]        = intCurrencyIdAmountTo
        ,[intCurrencyExchangeRateTypeId] = NULL
        ,[dblExchangeRate]      = dblRateAmountSettlementTo
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
    UNION ALL -- -- currency payable 
    SELECT [strTransactionId]  = strTransactionId      
        ,[intTransactionId]      = intTransactionId      
        ,[dtmDate]               = @dtmDate
        ,[strBatchId]            = @strBatchId      
        ,[intAccountId]          = @intBTSwapToFXGLAccountId
        ,[dblDebit]              = dblReceivableFn
        ,[dblCredit]             = 0
        ,[dblDebitForeign]       = dblReceivableFx
        ,[dblCreditForeign]      = 0
        ,[dblDebitUnit]          = 0      
        ,[dblCreditUnit]         = 0      
        ,[strDescription]        = A.strDescription      
        ,[strCode]               = @GL_DETAIL_CODE      
        ,[strReference]          = A.strReferenceTo
        ,[intCurrencyId]         = intCurrencyIdAmountFrom
        ,[intCurrencyExchangeRateTypeId] = NULL
        ,[dblExchangeRate]       = ROUND(dblReceivableFn/dblReceivableFx,6)
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
        ,[dblDebit]				 = 0
        ,[dblCredit]             = dblPayableFn
        ,[dblDebitForeign]       = 0
        ,[dblCreditForeign]      = dblPayableFx
        ,[dblDebitUnit]          = 0      
        ,[dblCreditUnit]         = 0      
        ,[strDescription]        = A.strDescription      
        ,[strCode]               = @GL_DETAIL_CODE      
        ,[strReference]          = A.strReferenceTo
        ,[intCurrencyId]         = intCurrencyIdAmountTo
        ,[intCurrencyExchangeRateTypeId] =  NULL
        ,[dblExchangeRate]       = ROUND(dblPayableFn/dblPayableFx, 6)
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

    EXEC uspCMCreateBankTransferDiffEntries @strTransactionId, @dtmDate, @strBatchId, @intDefaultCurrencyId  
    EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdFrom, 'To' , @dtmDate, @strBatchId, @intDefaultCurrencyId    
  
END