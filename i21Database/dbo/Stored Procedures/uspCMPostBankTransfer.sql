﻿CREATE PROCEDURE [dbo].[uspCMPostBankTransfer]    
 @ysnPost      BIT  = 0    
 ,@ysnRecap      BIT  = 0    
 ,@strTransactionId  NVARCHAR(40) = NULL     
 ,@strBatchId     NVARCHAR(40) = NULL     
 ,@intUserId      INT  = NULL     
 ,@intEntityId    INT  = NULL    
 ,@isSuccessful    BIT  = 0 OUTPUT     
 ,@message_id     INT  = 0 OUTPUT     
 ,@outBatchId     NVARCHAR(40) = NULL OUTPUT    
 ,@ysnBatch      BIT  = 0    
AS    
    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS ON    
SET NOCOUNT ON    
SET XACT_ABORT ON    
SET ANSI_WARNINGS OFF    
    
--=====================================================================================================================================    
--  DECLARATION     
---------------------------------------------------------------------------------------------------------------------------------------    
    
-- Start the transaction     
BEGIN TRANSACTION    
    
-- CREATE THE TEMPORARY TABLE     
CREATE TABLE #tmpGLDetail (    
 [dtmDate] [datetime] NOT NULL    
 ,[strBatchId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL    
 ,[intAccountId] [int] NULL    
 ,[dblDebit] [numeric](18, 6) NULL    
 ,[dblCredit] [numeric](18, 6) NULL    
 ,[dblDebitForeign] [numeric](18, 6) NULL    
 ,[dblCreditForeign] [numeric](18, 6) NULL    
 ,[dblDebitUnit] [numeric](18, 6) NULL    
 ,[dblCreditUnit] [numeric](18, 6) NULL    
 ,[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL    
 ,[strCode] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL    
 ,[strTransactionId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL    
 ,[intTransactionId] [int] NULL    
 ,[strReference] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL    
 ,[intCurrencyId] [int] NULL    
 ,[intCurrencyExchangeRateTypeId] [int] NULL    
 ,[dblExchangeRate] [numeric](38, 20) NOT NULL    
 ,[dtmDateEntered] [datetime] NOT NULL    
 ,[dtmTransactionDate] [datetime] NULL    
 ,[strJournalLineDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL    
 ,[intJournalLineNo] [int]    
 ,[ysnIsUnposted] [bit] NOT NULL    
 ,[intUserId] [int] NULL    
 ,[intEntityId] [int] NULL    
 ,[strTransactionType] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL    
 ,[strTransactionForm] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL    
 ,[strModuleName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL      
 ,[intConcurrencyId] [int] NULL    
)    
--CREATE FEES TABLE  
--SELECT * INTO #tmpGLDetailFees FROM #tmpGLDetail  
  
-- Declare the variables     
DECLARE     
 -- Constant Variables.     
 @BANK_TRANSACTION_TYPE_Id AS INT   = 4 -- Bank Transfer Type Id is 4 (See tblCMBankTransactionType).     
 ,@STARTING_NUM_TRANSACTION_TYPE_Id AS INT = 3 -- Starting number for GL Detail table. Ex: 'BATCH-1234',    
 ,@GL_DETAIL_CODE AS NVARCHAR(10)   = 'BTFR' -- String code used in GL Detail table.     
 ,@MODULE_NAME AS NVARCHAR(100)    = 'Cash Management' -- Module where this posting code belongs.    
 ,@TRANSACTION_FORM AS NVARCHAR(100)   = 'Bank Transfer'    
 ,@BANK_TRANSFER_WD AS INT     = 9 -- Transaction code for Bank Transfer Withdrawal. It also refers to as Bank Transfer FROM.    
 ,@BANK_TRANSFER_DEP AS INT     = 10 -- Transaction code for Bank Transfer Deposit. It also refers to as Bank Transfer TO.     
 ,@BANK_TRANSFER_WD_PREFIX AS NVARCHAR(3) = '-WD'    
 ,@BANK_TRANSFER_DEP_PREFIX AS NVARCHAR(4) = '-DEP'    
  
 -- Local Variables    
 ,@intTransactionId AS INT    
 ,@dtmDate AS DATETIME    
 ,@dtmInTransit AS DATETIME    
 ,@dblAmountFrom AS NUMERIC(18,6)    
 ,@dblAmountTo AS NUMERIC(18,6)    
 ,@dblAmountForeignFrom AS NUMERIC(18,6)    
 ,@dblAmountForeignTo AS NUMERIC(18,6)    
 ,@dblRateAmountTo AS NUMERIC(18,6)    
 ,@ysnTransactionPostedFlag AS BIT    
 ,@ysnTransactionClearedFlag AS BIT    
 ,@intBankAccountIdFrom AS INT    
 ,@intBankAccountIdTo AS INT    
 ,@ysnBankAccountActive AS BIT    
 ,@intCreatedEntityId AS INT    
 ,@ysnAllowUserSelfPost AS BIT = 0
 ,@dblHistoricRate DECIMAL (18,6)    
 ,@intCurrencyIdFrom INT    
 ,@intCurrencyIdTo INT    
 ,@intGLAccountIdFrom INT    
 ,@intGLAccountIdTo INT    
 ,@intDefaultCurrencyId INT  
 ,@dblDifference DECIMAL(18,6)  
 ,@intBTInTransitAccountId INT  
 ,@intBTForwardFromFXGLAccountId INT  
 ,@intBTForwardToFXGLAccountId INT  
 ,@ysnInTransit BIT  
 ,@ysnPosted BIT  
 ,@ysnPostedInTransit BIT  
 ,@intBankTransferTypeId INT  
 ,@dtmAccrual DATETIME  
 ,@intRealizedOrDiffAccountId INT    
 -- Table Variables    
 ,@RecapTable AS RecapTableType     
 ,@GLEntries AS RecapTableType   
 ,@dblFeesFrom DECIMAL(18,6)  
 ,@dblFeesTo DECIMAL(18,6)  
 ,@dblFeesForeignFrom DECIMAL(18,6)  
 ,@dblFeesForeignTo DECIMAL(18,6)  
 ,@strReferenceFrom NVARCHAR(150)
 ,@strReferenceTo NVARCHAR(150)
 ,@dblAmountSettlementTo DECIMAL(18,6)
 ,@dblRateAmountSettlementTo DECIMAL(18,6)
 
 -- Note: Table variables are unaffected by COMMIT or ROLLBACK TRANSACTION.     
     
IF @@ERROR <> 0 GOTO Post_Rollback      
    
--=====================================================================================================================================    
--  INITIALIZATION     
---------------------------------------------------------------------------------------------------------------------------------------    
  
  
-- Read bank transfer table     
SELECT TOP 1     
  @intTransactionId = A.intTransactionId    
  ,@dtmDate = A.dtmDate    
  ,@dtmInTransit = A.dtmInTransit  
  ,@dtmAccrual = A.dtmAccrual  
  ,@dblAmountFrom = A.dblAmountFrom
  ,@dblAmountTo =   A.dblAmountTo 
  ,@dblAmountSettlementTo = A.dblAmountSettlementTo
  ,@dblRateAmountSettlementTo= A.dblRateAmountSettlementTo
  ,@dblAmountForeignFrom = A.dblAmountForeignFrom
  ,@dblAmountForeignTo = A.dblAmountForeignTo
  ,@dblFeesForeignFrom = ISNULL(A.dblFeesForeignFrom,0)   
  ,@dblFeesForeignTo = ISNULL(A.dblFeesForeignTo,0)   
  ,@dblRateAmountTo = CASE WHEN A.ysnPostedInTransit = 1 THEN A.dblRateAmountSettlementTo ELSE  A.dblRateAmountTo END
  ,@ysnTransactionPostedFlag = A.ysnPosted    
  ,@intBankAccountIdFrom = A.intBankAccountIdFrom    
  ,@intBankAccountIdTo = A.intBankAccountIdTo    
  ,@intCreatedEntityId = A.intEntityId    
  ,@intCurrencyIdFrom = B.intCurrencyId    
  ,@intCurrencyIdTo = C.intCurrencyId    
  ,@dblDifference = A.dblDifference  
  ,@intBankTransferTypeId = ISNULL(A.intBankTransferTypeId,1)  
  ,@ysnPosted = ISNULL(A.ysnPosted,0)  
  ,@ysnPostedInTransit = CASE WHEN A.intBankTransferTypeId = 1 THEN 1 ELSE ISNULL(A.ysnPostedInTransit,0)  END 
  ,@dblFeesFrom = ISNULL(A.dblFeesFrom,0)   
  ,@dblFeesTo = ISNULL(A.dblFeesTo,0)   
  ,@dblAmountSettlementTo = ISNULL(A.dblAmountSettlementTo,0)
  ,@intGLAccountIdFrom = intGLAccountIdFrom  
  ,@intGLAccountIdTo = intGLAccountIdTo  
  ,@strReferenceFrom = strReferenceFrom
  ,@strReferenceTo =  strReferenceTo

FROM [dbo].tblCMBankTransfer A JOIN    
[dbo].tblCMBankAccount B ON B.intBankAccountId = A.intBankAccountIdFrom JOIN    
[dbo].tblCMBankAccount C ON C.intBankAccountId = A.intBankAccountIdTo    
WHERE strTransactionId = @strTransactionId     
  
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference      
  
IF ((@intCurrencyIdFrom != @intDefaultCurrencyId) OR (@intCurrencyIdTo != @intDefaultCurrencyId ) )AND @ysnPost = 1
BEGIN  
    IF @intBankTransferTypeId = 1 OR @ysnPostedInTransit = 0 -- FOR BANK TRANSFER TYPE THERE IS NO GAIN/LOSS- ONLY DIFFERENCE
    BEGIN
          SELECT TOP 1 @intRealizedOrDiffAccountId= intBTForexDiffAccountId   
          FROM tblCMCompanyPreferenceOption  
          IF @intRealizedOrDiffAccountId is NULL  
          BEGIN  
            RAISERROR ('Foreign Difference Account was not set in Company Configuration screen.',11,1)  
            GOTO Post_Rollback    
          END  
    END
    ELSE
--    IF @ysnPostedInTransit =1 -- GAIN / LOSS WILL BE POSTED IN THE LAST  POSTING
    BEGIN
        IF @intBankTransferTypeId = 2  
        BEGIN  
          SELECT TOP 1 @intRealizedOrDiffAccountId= intCashManagementRealizedId   
          FROM tblSMMultiCurrency  
          IF @intRealizedOrDiffAccountId is NULL  
          BEGIN  
            RAISERROR ('Cash Management Realized Gain/Loss account was not set in Company Configuration screen.',11,1)  
            GOTO Post_Rollback    
          END  
        END  
        IF @intBankTransferTypeId = 3  
        BEGIN  
          SELECT TOP 1 @intRealizedOrDiffAccountId= intGainOnForwardRealizedId   
          FROM tblSMMultiCurrency  
          IF @intRealizedOrDiffAccountId is NULL  
          BEGIN  
            RAISERROR ('Forward Realized Gain/Loss account was not set in Company Configuration screen.',11,1)  
            GOTO Post_Rollback    
          END  
        END  
        IF @intBankTransferTypeId = 5
        BEGIN  
          SELECT TOP 1 @intRealizedOrDiffAccountId= intGainOnSwapRealizedId   
          FROM tblSMMultiCurrency  
          IF @intRealizedOrDiffAccountId is NULL  
          BEGIN  
            RAISERROR ('Swap Realized Gain/Loss account was not set in Company Configuration screen.',11,1)  
            GOTO Post_Rollback    
          END  
        END  
    END
END  

DECLARE @intSwapShortId INT,@intSwapLongId INT, @intBankSwapId INT, @ysnLockShort BIT
IF @intBankTransferTypeId = 5
BEGIN
  SET @intSwapLongId = @intTransactionId
  SELECT @intSwapShortId= intSwapShortId, @intBankSwapId = intBankSwapId, @ysnLockShort = ysnLockShort 
  FROM tblCMBankSwap A WHERE intSwapLongId= @intTransactionId
END

IF @intBankTransferTypeId = 4
BEGIN
  SET @intSwapShortId = @intTransactionId
  SELECT @intSwapLongId= intSwapLongId, @intBankSwapId = intBankSwapId, @ysnLockShort = ysnLockShort 
  FROM tblCMBankSwap A WHERE intSwapShortId= @intTransactionId
END

IF @ysnLockShort = 1 AND @intBankTransferTypeId = 4
BEGIN
    RAISERROR ('Swap short is locked for posting/unposting.',11,1)  
    GOTO Post_Rollback    
END
      
-- todo: pre validation area   
IF ((@intBankTransferTypeId = 2 OR @intBankTransferTypeId = 4) AND @ysnPost = 1 ) OR  @intBankTransferTypeId = 5 
BEGIN  
  SELECT TOP 1 @intBTInTransitAccountId = intBTInTransitAccountId FROM tblCMCompanyPreferenceOption  
  IF @intBTInTransitAccountId IS NULL  
  BEGIN  
    RAISERROR('Cannot find the in transit GL Account ID Setting in Company Configuration.', 11, 1)    
    GOTO Post_Rollback    
  END 
  
  IF @intBankTransferTypeId = 5
  BEGIN
    IF @intSwapShortId IS NULL
    BEGIN
      RAISERROR('Cannot find the bank swap short transaction.', 11, 1)    
      GOTO Post_Rollback    
    END

    IF NOT EXISTS(SELECT TOP 1 1 FROM tblCMBankTransfer WHERE intTransactionId = @intSwapShortId AND ysnPosted = 1)
    BEGIN
      RAISERROR('Please post the bank swap short transaction.', 11, 1)    
      GOTO Post_Rollback    
    END
  END
END  
  
IF @intBankTransferTypeId = 3  OR ((@intBankTransferTypeId = 5 OR @intBankTransferTypeId =4) AND @ysnPostedInTransit = 1)
BEGIN  
    SELECT TOP 1 @intBTForwardToFXGLAccountId = intBTForwardToFXGLAccountId,   
    @intBTForwardFromFXGLAccountId = intBTForwardFromFXGLAccountId  
    FROM tblCMCompanyPreferenceOption  
  
    IF ISNULL(@intBTForwardToFXGLAccountId ,0) = 0  
    BEGIN  
        RAISERROR('Accrued Receivable Forward GL Account is not assigned.', 11, 1)    
        GOTO Post_Rollback  
    END  
  
    IF ISNULL(@intBTForwardFromFXGLAccountId,0) = 0  
    BEGIN  
        RAISERROR('Accrued Payable Forward GL Account is not assigned.', 11, 1)    
        GOTO Post_Rollback  
    END  
END  
  
-- Read the user preference    
SELECT @ysnAllowUserSelfPost = 1    
FROM dbo.tblSMUserPreference     
WHERE ysnAllowUserSelfPost = 1     
  AND [intEntityUserSecurityId] = @intUserId    
IF @@ERROR <> 0 GOTO Post_Rollback       
      
  
-- initialize variable  
  
  
IF @@ERROR <> 0 GOTO Post_Rollback     
  
--=====================================================================================================================================    
--  VALIDATION     
---------------------------------------------------------------------------------------------------------------------------------------    
BEGIN -- VALIDATION  
-- Validate if the bank transfer id exists.     
  IF @intTransactionId IS NULL    
  BEGIN     
  -- Cannot find the transaction.    
  RAISERROR('Cannot find the transaction.', 11, 1)    
  GOTO Post_Rollback    
  END     
      
  -- Check if the transaction is already posted    
  IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1    
  BEGIN     
  -- The transaction is already posted.    
  RAISERROR('The transaction is already posted.', 11, 1)    
  GOTO Post_Rollback    
  END     
      
  -- Check if the transaction is already posted    
  IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0    
  BEGIN     
  -- The transaction is already unposted.    
  IF @intBankTransferTypeId = 1  
  BEGIN  
      RAISERROR('The transaction is already unposted.', 11, 1)    
      GOTO Post_Rollback    
  END  
  ELSE IF @intBankTransferTypeId = 2  
  BEGIN  
    IF @ysnPostedInTransit = 0  
    BEGIN  
      RAISERROR('The transaction is already unposted.', 11, 1)    
    END  
  END  
  
  
  END     
      
  IF  @ysnRecap = 0    
  BEGIN    
  -- Validate the date against the FY Periods    
  IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDate(@dtmDate) = 0) AND @ysnRecap = 0    
  BEGIN     
    -- Unable to find an open fiscal year period to match the transaction date.    
    RAISERROR('Unable to find an open fiscal year period to match the transaction date.', 11, 1)    
    GOTO Post_Rollback    
  END    
      
  -- Validate the date against the FY Periods per module    
  IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDateByModule(@dtmDate,@MODULE_NAME) = 0) AND @ysnRecap = 0    
  BEGIN     
    -- Unable to find an open fiscal year period to match the transaction date and the given module.    
    IF @ysnPost = 1    
    BEGIN    
    --You cannot %s transaction under a closed module.    
    RAISERROR('You cannot %s transaction under a closed module.', 11, 1, 'Post')    
    GOTO Post_Rollback    
    END    
    ELSE    
    BEGIN    
    --You cannot %s transaction under a closed module.    
    RAISERROR('You cannot %s transaction under a closed module.', 11, 1, 'Unpost')    
    GOTO Post_Rollback    
    END    
  END    
  -- Check if the transaction is already cleared or reconciled    
  IF @ysnPost = 0 AND @ysnRecap = 0    
  BEGIN    
    DECLARE @intBankTransactionTypeId AS INT    
    DECLARE @clearedTransactionCount AS INT    
      
    SELECT TOP 1 @ysnTransactionClearedFlag = 1, @intBankTransactionTypeId = intBankTransactionTypeId    
    FROM tblCMBankTransaction     
    WHERE strLink = @strTransactionId    
      AND ysnClr = 1    
      AND intBankTransactionTypeId IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)    
      
    SELECT  @clearedTransactionCount = COUNT(intTransactionId)    
    FROM tblCMBankTransaction     
    WHERE strLink = @strTransactionId    
      AND ysnClr = 1    
      AND intBankTransactionTypeId IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)    
        
    IF @ysnTransactionClearedFlag = 1    
    BEGIN    
    -- 'The transaction is already cleared.'    
    IF @clearedTransactionCount = 2    
    BEGIN    
      RAISERROR('The transaction is already cleared.', 11, 1)    
      GOTO Post_Rollback    
    END    
      
    IF @intBankTransactionTypeId = @BANK_TRANSFER_WD    
    BEGIN    
      RAISERROR('Transfer %s transaction is already cleared.', 11, 1, 'From')    
      GOTO Post_Rollback    
    END    
    ELSE    
      RAISERROR('Transfer %s transaction is already cleared.', 11, 1, 'To')    
      GOTO Post_Rollback    
        
    END    
  END    
      
  -- Check if the bank account is inactive    
  IF @ysnRecap = 0     
  BEGIN    
    SELECT TOP 1 @ysnBankAccountActive = ISNULL(A.ysnActive,0) & ISNULL(B.ysnActive,0)    
    FROM tblCMBankAccount A JOIN vyuGLAccountDetail B    
    ON A.intGLAccountId = B.intAccountId    
    WHERE intBankAccountId IN (@intBankAccountIdFrom, @intBankAccountIdTo)     
      
      
    IF @ysnBankAccountActive = 0    
    BEGIN    
    -- 'The bank account is inactive.'    
    RAISERROR('The bank account or its associated GL account is inactive.', 11, 1)    
    GOTO Post_Rollback    
    END    
  END     
      
  -- Check Company preference: Allow User Self Post    
  IF @ysnAllowUserSelfPost = 1 AND @intEntityId <> @intCreatedEntityId AND @ysnRecap = 0     
  BEGIN     
    -- 'You cannot %s transactions you did not create. Please contact your local administrator.'    
    IF @ysnPost = 1     
    BEGIN     
    RAISERROR('You cannot %s transactions you did not create. Please contact your local administrator.', 11, 1, 'Post')    
    GOTO Post_Rollback    
    END     
    IF @ysnPost = 0    
    BEGIN    
    RAISERROR('You cannot %s transactions you did not create. Please contact your local administrator.', 11, 1, 'Unpost')    
    GOTO Post_Rollback      
    END    
  END     
      
  -- Check if amount is zero.     
  IF @dblAmountFrom = 0 AND @ysnPost = 1 AND @ysnRecap = 0    
  BEGIN     
    -- Cannot post a zero-value transaction.    
    RAISERROR('Cannot post a zero-value transaction.', 11, 1)    
    GOTO Post_Rollback    
  END     
  END    
  
END -- VALIDATION  
    
    
--=====================================================================================================================================    
--  PROCESSING OF THE G/L ENTRIES.     
---------------------------------------------------------------------------------------------------------------------------------------    
    
-- Get the batch post id.     
IF (@strBatchId IS NULL)    
BEGIN    
 IF (@ysnRecap = 0)    
  EXEC dbo.uspSMGetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_Id, @strBatchId OUTPUT     
 ELSE    
  SELECT @strBatchId = NEWID()    
    
 SELECT @outBatchId = @strBatchId    
 IF @@ERROR <> 0 GOTO Post_Rollback    
END    
  
IF @ysnPost = 1    
BEGIN    
 -- Create the G/L Entries for Bank Transfer.     
 -- 1. CREDIT SIdE (SOURCE FUND)    
  EXEC uspCMCreateBankTransferPostEntries 
    @strTransactionId,
    @intBankTransferTypeId,
    @dtmDate,
    @strBatchId,
    @intDefaultCurrencyId,
    @ysnPostedInTransit
-- BANK TRANSFER POSTING 
  IF @intBankTransferTypeId = 1  
  BEGIN  
    SET @ysnPostedInTransit = 1  
      EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdFrom, 'From', @dtmDate, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom,  @intDefaultCurrencyId
      EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdTo, 'To'  , @dtmDate, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom, @intDefaultCurrencyId

  END  

-- BANK TRANSFER WITH IN-TRANSIT POSTING
  IF @intBankTransferTypeId  =2 
  BEGIN  
    IF @ysnPostedInTransit = 0  
    BEGIN  
      --DELETE FROM #tmpGLDetail WHERE intAccountId = @intGLAccountIdTo  
      UPDATE A SET intAccountId = @intBTInTransitAccountId ,
      dblDebit = @dblAmountTo , dblDebitForeign = @dblAmountForeignTo,
      dblExchangeRate = @dblRateAmountTo,
      strJournalLineDescription = 'In-Transit Entry',  
      intCurrencyExchangeRateTypeId = F.intCurrencyExchangeRateTypeId
      from #tmpGLDetail A
      OUTER APPLY(
        SELECT intCurrencyExchangeRateTypeId FROM #tmpGLDetail WHERE  intAccountId = @intGLAccountIdFrom
      )F
      WHERE intAccountId = @intGLAccountIdTo 
      
      EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdFrom, 'From', 
        @dtmDate, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom,  @intDefaultCurrencyId  
  
            
    END  
    ELSE  
    BEGIN  
         UPDATE A SET dtmDate= @dtmInTransit FROM #tmpGLDetail A  
         UPDATE  A    
          SET   
          dtmTransactionDate = @dtmInTransit,  
          strJournalLineDescription = 'In-Transit Entry',  
          intAccountId =GLAccnt.intAccountId
          FROM #tmpGLDetail A   
          CROSS APPLY (  
            SELECT TOP 1 intAccountId, strDescription FROM tblGLAccount WHERE intAccountId = @intBTInTransitAccountId  
          )GLAccnt  
          WHERE A.intAccountId = @intGLAccountIdTo

          UPDATE  A    
          SET   
          dtmTransactionDate = @dtmInTransit,  
          intCurrencyId = BT.intCurrencyIdAmountTo,
          dblDebit = @dblAmountSettlementTo,
          dblCredit = 0,
          dblDebitForeign = @dblAmountForeignTo,
          dblCreditForeign = 0,
          dblExchangerate = @dblRateAmountTo,
          intAccountId =GLAccnt.intAccountId
          FROM #tmpGLDetail A   
          CROSS APPLY(
            SELECT intCurrencyIdAmountTo, dblAmountTo, dblAmountForeignTo FROM tblCMBankTransfer WHERE strTransactionId = @strTransactionId
          )BT
          CROSS APPLY (  
            SELECT TOP 1 intAccountId, strDescription FROM tblGLAccount WHERE intAccountId = @intGLAccountIdTo  
          )GLAccnt  
          WHERE A.intAccountId = @intGLAccountIdFrom

        EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdTo, 'To'  
          , @dtmInTransit, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom, @intDefaultCurrencyId  
      
    END  
  END  
  
-- BANK TRANSFER FORWARD POSTING
  IF @intBankTransferTypeId = 3
  BEGIN  
    IF @ysnPostedInTransit = 0  
    BEGIN  
        UPDATE A   
        SET intAccountId = @intBTForwardToFXGLAccountId   
        ,strJournalLineDescription = 'Accrued Receivable',  
        dtmDate = @dtmAccrual,   
        dtmTransactionDate= @dtmAccrual  
        FROM #tmpGLDetail A  
        OUTER APPLY(  
          SELECT strDescription FROM tblGLAccount WHERE intAccountId = @intBTForwardToFXGLAccountId   
        )GLAccnt  
        WHERE A.intAccountId = @intGLAccountIdTo
  
        UPDATE A SET   
        intAccountId = @intBTForwardFromFXGLAccountId ,
        strJournalLineDescription ='Accrued Payable',
        dtmDate = @dtmAccrual,
        dtmTransactionDate= @dtmAccrual  
        from #tmpGLDetail A   
        OUTER APPLY (  
          select dblAmountFrom, strReferenceTo,dblAmountSettlementTo,dblAmountForeignTo,  (dblAmountForeignTo * dblReverseRate) dblAmountForeignFrom,   
          dblExchangeRate= dblReverseRate  
          FROM tblCMBankTransfer WHERE strTransactionId = @strTransactionId  
        )BT  
        OUTER APPLY(  
          SELECT strDescription FROM tblGLAccount WHERE intAccountId = @intBTForwardToFXGLAccountId   
        )GLAccnt  
        WHERE A.intAccountId = @intGLAccountIdFrom 

        


    END  
    ELSE  
    BEGIN  
      -- from 
      print('123')
      -- stopped here
      
      -- INSERT INTO #tmpGLDetail (    
      -- [strTransactionId]    
      -- ,[intTransactionId]    
      -- ,[dtmDate]    
      -- ,[strBatchId]    
      -- ,[intAccountId]    
      -- ,[dblDebit]    
      -- ,[dblCredit]    
      -- ,[dblDebitForeign]     
      -- ,[dblCreditForeign]    
      -- ,[dblDebitUnit]    
      -- ,[dblCreditUnit]    
      -- ,[strDescription]    
      -- ,[strCode]    
      -- ,[strReference]    
      -- ,[intCurrencyId]    
      -- ,[intCurrencyExchangeRateTypeId]    
      -- ,[dblExchangeRate]    
      -- ,[dtmDateEntered]    
      -- ,[dtmTransactionDate]    
      -- ,[strJournalLineDescription]    
      -- ,[ysnIsUnposted]    
      -- ,[intConcurrencyId]    
      -- ,[intUserId]    
      -- ,[strTransactionType]    
      -- ,[strTransactionForm]    
      -- ,[strModuleName]    
      -- ,[intEntityId])    
      -- SELECT [strTransactionId]  = strTransactionId  
      -- ,[intTransactionId]    = intTransactionId  
      -- ,[dtmDate]           = dtmDate  
      -- ,[strBatchId]        = strBatchId    
      -- ,[intAccountId]       = GLAccnt.intAccountId    
      -- ,[dblDebit]          = dblCredit
      -- ,[dblCredit]          = 0 --   CASE WHEN @ysnForeignToForeign =1 THEN ROUND(A.dblAmount * ISNULL(@dblRate,1),2)  WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountFunctional.Val ELSE A.dblAmount END    
      -- ,[dblDebitForeign]    = dblCreditForeign  
      -- ,[dblCreditForeign]      = 0  
      -- ,[dblDebitUnit]       = 0    
      -- ,[dblCreditUnit]      = 0    
      -- ,[strDescription]       = A.strDescription    
      -- ,[strCode]           = strCode  
      -- ,[strReference]       = strReference  
      -- ,[intCurrencyId]      = intCurrencyId    
      -- ,[intCurrencyExchangeRateTypeId] =  intCurrencyExchangeRateTypeId  
      -- ,[dblExchangeRate]      = dblExchangeRate  
      -- ,[dtmDateEntered]      = dtmDateEntered    
      -- ,[dtmTransactionDate]    = dtmTransactionDate    
      -- ,[strJournalLineDescription]  = 'Accrued Payable'  
      -- ,[ysnIsUnposted]      = 0     
      -- ,[intConcurrencyId]     = 1    
      -- ,[intUserId]        = intUserId    
      -- ,[strTransactionType]    = strTransactionType    
      -- ,[strTransactionForm]    = strTransactionForm    
      -- ,[strModuleName]      = strModuleName    
      -- ,[intEntityId]       = intEntityId    
      -- FROM #tmpGLDetail A  
      -- CROSS APPLY(  
      --   SELECT TOP 1 intAccountId,strDescription FROM tblGLAccount where intAccountId =@intBTForwardToFXGLAccountId  -- todo for clarification  
      -- )GLAccnt  
      -- WHERE A.intAccountId = @intGLAccountIdFrom
      --  UNION ALL  
      -- SELECT [strTransactionId]   = strTransactionId  
      -- ,[intTransactionId]      = intTransactionId  
      -- ,[dtmDate]           = dtmDate  
      -- ,[strBatchId]        = strBatchId    
      -- ,[intAccountId]       = GLAccnt.intAccountId    
      -- ,[dblDebit]          = 0    
      -- ,[dblCredit]          = dblCredit
      -- ,[dblDebitForeign]     = 0  
      -- ,[dblCreditForeign]     = dblCreditForeign
      -- ,[dblDebitUnit]       = 0    
      -- ,[dblCreditUnit]      = 0    
      -- ,[strDescription]       = A.strDescription    
      -- ,[strCode]           = strCode  
      -- ,[strReference]       = strReference  
      -- ,[intCurrencyId]      = intCurrencyId    
      -- ,[intCurrencyExchangeRateTypeId] = NULL-- intCurrencyExchangeRateTypeId  
      -- ,[dblExchangeRate]     = T.dblAmountFrom/ T.dblAmountForeignTo -- T.dblReverseRate  
      -- ,[dtmDateEntered]      = dtmDateEntered    
      -- ,[dtmTransactionDate]    = dtmTransactionDate    
      -- ,[strJournalLineDescription]  = 'Accrued Receivable'  
      -- ,[ysnIsUnposted]      = 0     
      -- ,[intConcurrencyId]     = 1    
      -- ,[intUserId]          = intUserId    
      -- ,[strTransactionType]   = strTransactionType    
      -- ,[strTransactionForm]   = strTransactionForm    
      -- ,[strModuleName]      = strModuleName    
      -- ,[intEntityId]         = intEntityId    
      -- FROM #tmpGLDetail A 
      -- CROSS APPLY(  
      --   SELECT TOP 1 intAccountId,strDescription FROM tblGLAccount where intAccountId =@intBTForwardFromFXGLAccountId  
      -- )GLAccnt  
      -- CROSS APPLY(  
      --   SELECT dblAmountFrom,dblReverseRate, dblAmountForeignTo  FROM tblCMBankTransfer A WHERE strTransactionId = @strTransactionId  
      -- )T  
      -- WHERE A.intAccountId = @intGLAccountIdTo
      --EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdFrom, 'From', @dtmDate, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom,  @intDefaultCurrencyId
      --EXEC uspCMCreateBankTransferFeesEntries @strTransactionId, @intGLAccountIdTo, 'To'  , @dtmDate, @strBatchId,@dblFeesFrom,@dblFeesForeignFrom, @intDefaultCurrencyId
      
    END  
  END
  IF @intBankTransferTypeId = 4
  BEGIN
    IF @ysnPostedInTransit = 0
    BEGIN  
      DELETE FROM #tmpGLDetail WHERE intAccountId = @intGLAccountIdTo  
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
      SELECT [strTransactionId]  =  strTransactionId    
      ,[intTransactionId]      = intTransactionId    
      ,[dtmDate]           = dtmDate    
      ,[strBatchId]        = strBatchId    
      ,[intAccountId]       = GLAccnt.intAccountId    
      ,[dblDebit]          = dblCredit
      ,[dblCredit]          = 0  
      ,[dblDebitForeign]     = dblCreditForeign
      ,[dblCreditForeign]      = 0  
      ,[dblDebitUnit]       = 0    
      ,[dblCreditUnit]      = 0    
      ,[strDescription]       = A.strDescription    
      ,[strCode]           = strCode   
      ,[strReference]       = strReference  
      ,[intCurrencyId]      = intCurrencyId  
      ,[intCurrencyExchangeRateTypeId] = intCurrencyExchangeRateTypeId  
      ,[dblExchangeRate]     = @dblRateAmountTo
      ,[dtmDateEntered]      = dtmDateEntered  
      ,[dtmTransactionDate]    = dtmTransactionDate  
      ,[strJournalLineDescription]  = 'In-Transit Entry'  
      ,[ysnIsUnposted]      = 0     
      ,[intConcurrencyId]     = 1    
      ,[intUserId]          = intUserId    
      ,[strTransactionType]   = strTransactionType  
      ,[strTransactionForm]   = strTransactionForm    
      ,[strModuleName]      = strModuleName  
      ,[intEntityId]         = intEntityId    
      FROM #tmpGLDetail  A  
      OUTER APPLY(  
        SELECT TOP 1 intAccountId, strDescription FROM tblGLAccount WHERE intAccountId = @intBTInTransitAccountId  
      )GLAccnt  

        


  
      --http://jira.irelyserver.com/browse/GL-8511
      --http://inet.irelyserver.com/display/GL/Test+Cases+Swap
    



      -- VERIFY FEES FOR SWAP SHORT HERE
      
  

    END
    ELSE -- ysnPostedInTransit =1
    BEGIN-- ysnPostedInTransit =1
         UPDATE A SET dtmDate= @dtmInTransit FROM #tmpGLDetail A  
         UPDATE  A    
          SET   
          dtmTransactionDate = @dtmInTransit,  
          strJournalLineDescription = 'In-Transit Entry',  
          intAccountId =GLAccnt.intAccountId
          FROM #tmpGLDetail A   
          CROSS APPLY (  
            SELECT TOP 1 intAccountId, strDescription FROM tblGLAccount WHERE intAccountId = @intBTInTransitAccountId  
          )GLAccnt  
          WHERE A.intAccountId = @intGLAccountIdFrom  



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
        SELECT [strTransactionId]
          ,[intTransactionId]  
          ,[dtmDate]            
          ,[strBatchId]        = @strBatchId    
          ,[intAccountId]       = @intBTForwardToFXGLAccountId
          ,[dblDebit]          = 0    
          ,[dblCredit]          = dblAmountFrom --   CASE WHEN @ysnForeignToForeign =1 THEN ROUND(A.dblAmount * ISNULL(@dblRate,1),2)  WHEN @intCurrencyIdFrom <> @intDefaultCurrencyId THEN  AmountFunctional.Val ELSE A.dblAmount END    
          ,[dblDebitForeign]     = 0    
          ,[dblCreditForeign]      = dblAmountFrom/@dblRateAmountTo
          ,[dblDebitUnit]       = 0    
          ,[dblCreditUnit]      = 0    
          ,[strDescription]       = A.strDescription    
          ,[strCode]           = @GL_DETAIL_CODE    
          ,[strReference]       = A.strReferenceTo    
          ,[intCurrencyId]      = intCurrencyIdAmountTo    
          ,[intCurrencyExchangeRateTypeId] =  CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo THEN NULL ELSE  intRateTypeIdAmountTo  END  
          ,[dblExchangeRate]      = CASE WHEN @intDefaultCurrencyId = intCurrencyIdAmountTo THEN 1 ELSE @dblRateAmountTo  END  
          ,[dtmDateEntered]      = GETDATE()    
          ,[dtmTransactionDate]    = A.dtmDate    
          ,[strJournalLineDescription]  = 'Accrued Receivable'
          ,[ysnIsUnposted]      = 0     
          ,[intConcurrencyId]     = 1    
          ,[intUserId]        = intLastModifiedUserId    
          ,[strTransactionType]    = @TRANSACTION_FORM    
          ,[strTransactionForm]    = @TRANSACTION_FORM    
          ,[strModuleName]      = @MODULE_NAME    
          ,[intEntityId]       = A.intEntityId    
        FROM [dbo].tblCMBankTransfer A 
        WHERE A.strTransactionId = @strTransactionId    
        -- 2. DEBIT SIdE (TARGET OF THE FUND)    
        UNION ALL     
        SELECT   
          [strTransactionId]  = @strTransactionId    
          ,[intTransactionId]     = @intTransactionId    
          ,[dtmDate]           = @dtmDate    
          ,[strBatchId]        = @strBatchId    
          ,[intAccountId]       = @intBTForwardFromFXGLAccountId
          ,[dblDebit]         = dblAmountFrom  
          ,[dblCredit]        = 0     
          ,[dblDebitForeign]     =  dblAmountForeignFrom
          ,[dblCreditForeign]    = 0    
          ,[dblDebitUnit]       = 0    
          ,[dblCreditUnit]      = 0    
          ,[strDescription]     = A.strDescription    
          ,[strCode]           = @GL_DETAIL_CODE    
          ,[strReference]       = strReferenceFrom
          ,[intCurrencyId]      = intCurrencyIdAmountFrom   
          ,[intCurrencyExchangeRateTypeId] = CASE WHEN @intDefaultCurrencyId =  intCurrencyIdAmountFrom THEN NULL ELSE intRateTypeIdAmountFrom END  
          ,[dblExchangeRate]      = CASE WHEN @intDefaultCurrencyId =  intCurrencyIdAmountFrom THEN 1  
                                            --WHEN @ysnForeignToForeign = 1 THEN dblAmountSettlementTo/dblAmountForeignFrom  
                                            ELSE dblRateAmountFrom END  
          ,[dtmDateEntered]      = GETDATE()    
          ,[dtmTransactionDate]    = A.dtmDate    
          ,[strJournalLineDescription]  = 'Accrued Payable'
          ,[ysnIsUnposted]      = 0     
          ,[intConcurrencyId]     = 1    
          ,[intUserId]        = A.intLastModifiedUserId    
          ,[strTransactionType]    = @TRANSACTION_FORM    
          ,[strTransactionForm]    = @TRANSACTION_FORM    
          ,[strModuleName]      = @MODULE_NAME    
          ,[intEntityId]       = A.intEntityId    
        FROM [dbo].tblCMBankTransfer A 
        WHERE A.strTransactionId = @strTransactionId    
        



    END-- ysnPostedInTransit =1
  END
  
  IF @intBankTransferTypeId = 5
  BEGIN
    IF @ysnPostedInTransit = 0
    BEGIN
      DELETE FROM #tmpGLDetail WHERE intAccountId = @intGLAccountIdFrom
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
      SELECT [strTransactionId]  =  strTransactionId    
      ,[intTransactionId]      = intTransactionId    
      ,[dtmDate]           = dtmDate    
      ,[strBatchId]        = strBatchId    
      ,[intAccountId]       = GLAccnt.intAccountId    
      ,[dblDebit]          = 0
      ,[dblCredit]          = dblDebit
      ,[dblDebitForeign]     = 0
      ,[dblCreditForeign]      = dblDebitForeign
      ,[dblDebitUnit]       = 0    
      ,[dblCreditUnit]      = 0    
      ,[strDescription]       = A.strDescription    
      ,[strCode]           = strCode   
      ,[strReference]       = strReference  
      ,[intCurrencyId]      = intCurrencyId  
      ,[intCurrencyExchangeRateTypeId] = intCurrencyExchangeRateTypeId  
      ,[dblExchangeRate]     
      ,[dtmDateEntered]      = dtmDateEntered  
      ,[dtmTransactionDate]    = dtmTransactionDate  
      ,[strJournalLineDescription]  = 'In-Transit Entry'  
      ,[ysnIsUnposted]      = 0     
      ,[intConcurrencyId]     = 1    
      ,[intUserId]          = intUserId    
      ,[strTransactionType]   = strTransactionType  
      ,[strTransactionForm]   = strTransactionForm    
      ,[strModuleName]      = strModuleName  
      ,[intEntityId]         = intEntityId    
      FROM #tmpGLDetail  A  
      OUTER APPLY(  
        SELECT TOP 1 intAccountId, strDescription FROM tblGLAccount WHERE intAccountId = @intBTInTransitAccountId  
      )GLAccnt  

    END

    ELSE
    BEGIN
      --DELETE FROM #tmpGLDetail WHERE intAccountId = @intGLAccountIdTo 
      UPDATE #tmpGLDetail SET dtmDate = @dtmInTransit, dtmTransactionDate = @dtmInTransit

      UPDATE  A    
          SET   
          dtmTransactionDate = @dtmInTransit,  
          strJournalLineDescription = 'In-Transit Entry',  
          intAccountId =GLAccnt.intAccountId
          FROM #tmpGLDetail A   
          CROSS APPLY (  
            SELECT TOP 1 intAccountId, strDescription FROM tblGLAccount WHERE intAccountId = @intBTInTransitAccountId  
          )GLAccnt  
          WHERE A.intAccountId = @intGLAccountIdTo  

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
      SELECT [strTransactionId]  =  strTransactionId    
      ,[intTransactionId]      = intTransactionId    
      ,[dtmDate]           = @dtmInTransit    
      ,[strBatchId]        = strBatchId    
      ,[intAccountId]       = GLAccnt.intAccountId    
      ,[dblDebit]          = dblDebit
      ,[dblCredit]          = 0
      ,[dblDebitForeign]     = BT.dblAmountForeignFrom
      ,[dblCreditForeign]      = 0
      ,[dblDebitUnit]       = 0    
      ,[dblCreditUnit]      = 0    
      ,[strDescription]       = A.strDescription    
      ,[strCode]           = strCode   
      ,[strReference]       = strReference  
      ,[intCurrencyId]      = BT.intCurrencyIdAmountFrom 
      ,[intCurrencyExchangeRateTypeId] = null  
      ,[dblExchangeRate]     = BT.dblCrossRate
      ,[dtmDateEntered]      = dtmDateEntered  
      ,[dtmTransactionDate]    = @dtmInTransit  
      ,[strJournalLineDescription]  = 'Accrued Payable'  
      ,[ysnIsUnposted]      = 0     
      ,[intConcurrencyId]     = 1    
      ,[intUserId]          = intUserId    
      ,[strTransactionType]   = strTransactionType  
      ,[strTransactionForm]   = strTransactionForm    
      ,[strModuleName]      = strModuleName  
      ,[intEntityId]         = intEntityId    
      FROM #tmpGLDetail  A  
      OUTER APPLY(  
        SELECT TOP 1 intAccountId, strDescription FROM tblGLAccount WHERE intAccountId = @intBTForwardToFXGLAccountId  
      )GLAccnt  
      OUTER APPLY(
        SELECT intCurrencyIdAmountFrom, dblAmountForeignFrom, dblCrossRate FROM tblCMBankTransfer WHERE  @strTransactionId = strTransactionId
      )BT
      WHERE A.intAccountId = @intBTInTransitAccountId  


      UNION ALL
            SELECT [strTransactionId]  =  strTransactionId    
      ,[intTransactionId]      = intTransactionId    
      ,[dtmDate]           = @dtmInTransit    
      ,[strBatchId]        = strBatchId    
      ,[intAccountId]       = GLAccnt.intAccountId    
      ,[dblDebit]          = 0
      ,[dblCredit]          = dblDebit
      ,[dblDebitForeign]     = 0
      ,[dblCreditForeign]      = dblDebitForeign
      ,[dblDebitUnit]       = 0    
      ,[dblCreditUnit]      = 0    
      ,[strDescription]       = A.strDescription    
      ,[strCode]           = strCode   
      ,[strReference]       = strReference  
      ,[intCurrencyId]      
      ,[intCurrencyExchangeRateTypeId] = null  
      ,[dblExchangeRate]     = 1
      ,[dtmDateEntered]      = dtmDateEntered  
      ,[dtmTransactionDate]    = @dtmInTransit  
      ,[strJournalLineDescription]  = 'Accrued Receivable'  
      ,[ysnIsUnposted]      = 0     
      ,[intConcurrencyId]     = 1    
      ,[intUserId]          = intUserId    
      ,[strTransactionType]   = strTransactionType  
      ,[strTransactionForm]   = strTransactionForm    
      ,[strModuleName]      = strModuleName  
      ,[intEntityId]         = intEntityId    
      FROM #tmpGLDetail  A  
      OUTER APPLY(  
        SELECT TOP 1 intAccountId, strDescription FROM tblGLAccount WHERE intAccountId = @intBTForwardFromFXGLAccountId  
      )GLAccnt  
      WHERE A.intAccountId = @intBTInTransitAccountId  



    END

  END
    
  
  IF @@ERROR <> 0 GOTO Post_Rollback    


  --EXEC dbo.uspCMProcessBankTransferFees @strTransactionId, @strBatchId, @intDefaultCurrencyId  
  
  --IF @intBankTransferTypeId = 1 OR @ysnPostedInTransit = 1 
  --BEGIN  
    --IF @dblDifference <> 0  
  
      IF @ysnPost =1
      BEGIN
        DECLARE @strGainDesc NVARCHAR(50)
        SELECT @strGainDesc = CASE WHEN @ysnPostedInTransit = 0 THEN 'Forex Difference' ELSE 'Gain / Loss from Bank Transfer' END
        EXEC [uspCMInsertGainLossBankTransfer] @intDefaultCurrencyId, 
        @strGainDesc,
        @intRealizedOrDiffAccountId  
      END
  --END  
  
    
END  
ELSE IF @ysnPost = 0    
BEGIN    
 -- Reverse the G/L entries    
 EXEC dbo.uspCMReverseGLEntries @strTransactionId, @GL_DETAIL_CODE, NULL, @intUserId, @strBatchId  
 IF @@ERROR <> 0 GOTO Post_Rollback    
END    
    
--=====================================================================================================================================    
--  Book the G/L ENTRIES to tblGLDetail (The General Ledger Detail table)    
---------------------------------------------------------------------------------------------------------------------------------------    
--EXEC dbo.uspCMBookGLEntries @ysnPost, @ysnRecap, @isSuccessful OUTPUT, @message_id OUTPUT    
--IF @isSuccessful = 0 GOTO Post_Rollback    
IF @ysnRecap = 0    
BEGIN    
 INSERT INTO @GLEntries(    
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
    FROM #tmpGLDetail    
        
    DECLARE @PostResult INT    
    EXEC @PostResult = uspGLBookEntries @GLEntries = @GLEntries, @ysnPost = @ysnPost, @SkipICValidation = 1    
          
    IF @@ERROR <> 0 OR @PostResult <> 0 GOTO Post_Rollback    



  
    
 -- Update the posted flag in the transaction table    
   
    IF @intBankTransferTypeId = 2 OR @intBankTransferTypeId = 3  OR @intBankTransferTypeId = 4 OR @intBankTransferTypeId = 5
    BEGIN  
          IF  @ysnPostedInTransit = 0  --AND @ysnPosted = 0 
          BEGIN    
                UPDATE tblCMBankTransfer    
                SET  ysnPostedInTransit = @ysnPost  
                ,intConcurrencyId += 1     
                WHERE strTransactionId = @strTransactionId    

                IF @intBankTransferTypeId = 5 AND @ysnPost = 1
                BEGIN
                  UPDATE tblCMBankSwap SET ysnLockShort = 1 WHERE intBankSwapId = @intBankSwapId
                END

                -- lock the swap short when swap long is posted
          END  
          ELSE
          BEGIN  
            IF @ysnPosted = 0  
            BEGIN  
              IF @ysnPost = 1  
                UPDATE tblCMBankTransfer    
                SET  ysnPosted = @ysnPost  
                ,intConcurrencyId += 1     
                WHERE strTransactionId = @strTransactionId   
                

              ELSE  
              BEGIN
                UPDATE tblCMBankTransfer    
                SET  ysnPostedInTransit = @ysnPost  
                ,intConcurrencyId += 1     
                WHERE strTransactionId = @strTransactionId    

                IF @intBankTransferTypeId = 5
                BEGIN
                  UPDATE tblCMBankSwap SET ysnLockShort = 0 WHERE intBankSwapId = @intBankSwapId
                END

               
              END
            END  
            ELSE  
            BEGIN  
              IF @ysnPost = 0  
              BEGIN

                UPDATE tblCMBankTransfer    
                SET  ysnPosted = @ysnPost  
                ,intConcurrencyId += 1     
                WHERE strTransactionId = @strTransactionId    


                IF(@intBankTransferTypeId = 4 ) -- posted= 0 && postedintransit =1 && unpost
                BEGIN
                  UPDATE tblCMBankSwap SET intSwapLongId = NULL, ysnLockShort = 0 WHERE @intBankSwapId = intBankSwapId
                  DELETE FROM tblCMBankTransfer WHERE intTransactionId = @intSwapLongId AND ysnPosted = 0 AND ysnPostedInTransit = 0

                END
              END
            END  
          END  
      END  
      
    ELSE  
    BEGIN  
        UPDATE tblCMBankTransfer  
        SET  ysnPosted = @ysnPost  
        ,intConcurrencyId += 1     
        WHERE strTransactionId = @strTransactionId    
    END  
      
    IF @@ERROR <> 0 GOTO Post_Rollback    
    
    IF @ysnPost = 1   
    BEGIN    
      IF  @ysnPostedInTransit = 1
      --@intBankTransferTypeId =1 OR ((@intBankTransferTypeId = 2 OR @intBankTransferTypeId = 3 OR @intBankTransferTypeId = 4  OR @intBankTransferTypeId = 5) AND
      BEGIN  
            INSERT INTO tblCMBankTransaction (    
            strTransactionId    
            ,intBankTransactionTypeId    
            ,intBankAccountId    
            ,intCurrencyId    
            ,intCurrencyExchangeRateTypeId    
            ,dblExchangeRate    
            ,dtmDate    
            ,strPayee    
            ,intPayeeId    
            ,strAddress    
            ,strZipCode    
            ,strCity    
            ,strState    
            ,strCountry    
            ,dblAmount    
            ,strAmountInWords    
            ,strMemo    
            ,strReferenceNo    
            ,dtmCheckPrinted    
            ,ysnCheckToBePrinted    
            ,ysnCheckVoid    
            ,ysnPosted    
            ,strLink    
            ,intFiscalPeriodId    
            ,ysnClr    
            ,intEntityId    
            ,dtmDateReconciled    
            ,intCreatedUserId    
            ,dtmCreated    
            ,intLastModifiedUserId    
            ,dtmLastModified    
            ,intConcurrencyId     
            )    
            -- Bank Transaction Credit    
            SELECT strTransactionId     = A.strTransactionId + @BANK_TRANSFER_WD_PREFIX    
              ,intBankTransactionTypeId   = @BANK_TRANSFER_WD    
              ,intBankAccountId      = A.intBankAccountIdFrom    
              ,intCurrencyId        = @intCurrencyIdFrom    
              ,intCurrencyExchangeRateTypeId  = intRateTypeIdAmountFrom    
              ,dblExchangeRate      = dblRateAmountFrom    
              ,dtmDate            = A.dtmDate    
              ,strPayee          = ''    
              ,intPayeeId         = NULL    
              ,strAddress         = ''    
              ,strZipCode         = ''    
              ,strCity            = ''    
              ,strState          = ''    
              ,strCountry         = ''    
              ,dblAmount          = dblAmountForeignFrom    
              ,strAmountInWords     = dbo.fnConvertNumberToWord(A.dblAmountForeignFrom)    
              ,strMemo            = CASE WHEN ISNULL(A.strReferenceFrom,'') = '' THEN A.strDescription     
                                        WHEN ISNULL(A.strDescription,'') = '' THEN A.strReferenceFrom    
                                        ELSE A.strDescription + ' / ' + A.strReferenceFrom END    
              ,strReferenceNo        = ''    
              ,dtmCheckPrinted       = NULL    
              ,ysnCheckToBePrinted    = 0    
              ,ysnCheckVoid          = 0    
              ,ysnPosted            = 1    
              ,strLink              = A.strTransactionId    
              ,intFiscalPeriodId      = F.intGLFiscalYearPeriodId    
              ,ysnClr               = 0    
              ,intEntityId          = A.intEntityId    
              ,dtmDateReconciled      = NULL    
              ,intCreatedUserId      = A.intCreatedUserId    
              ,dtmCreated               = GETDATE()    
              ,intLastModifiedUserId   = A.intLastModifiedUserId    
              ,dtmLastModified       = GETDATE()    
              ,intConcurrencyId      = 1     
            FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt    
              ON A.intGLAccountIdFrom = GLAccnt.intAccountId      
              INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp    
              ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId    
            CROSS APPLY dbo.fnGLGetFiscalPeriod(A.dtmDate) F    
            WHERE A.strTransactionId = @strTransactionId    
              
            -- Bank Transaction Debit    
            UNION ALL    
            SELECT strTransactionId     = A.strTransactionId + @BANK_TRANSFER_DEP_PREFIX    
              ,intBankTransactionTypeId   = @BANK_TRANSFER_DEP    
              ,intBankAccountId      = A.intBankAccountIdTo    
              ,intCurrencyId        = @intCurrencyIdTo    
              ,intCurrencyExchangeRateTypeId  =intRateTypeIdAmountTo    
              ,dblExchangeRate       =  @dblRateAmountTo    
              ,dtmDate          = A.dtmDate    
              ,strPayee          = ''    
              ,intPayeeId         = NULL    
              ,strAddress         = ''    
              ,strZipCode         = ''    
              ,strCity          = ''    
              ,strState          = ''    
              ,strCountry         = ''    
              ,dblAmount          = dblAmountForeignTo    
              ,strAmountInWords      = dbo.fnConvertNumberToWord(dblAmountForeignTo)    
              ,strMemo          = CASE WHEN ISNULL(A.strReferenceTo,'') = '' THEN     
                              A.strDescription     
                              WHEN ISNULL(A.strDescription,'') = '' THEN    
                              A.strReferenceTo    
                              ELSE A.strDescription + ' / ' + A.strReferenceTo     
                              END    
              ,strReferenceNo        = ''    
              ,dtmCheckPrinted       = NULL    
              ,ysnCheckToBePrinted     = 0    
              ,ysnCheckVoid        = 0    
              ,ysnPosted          = 1    
              ,strLink          = A.strTransactionId    
              ,intFiscalPeriodId      = F.intGLFiscalYearPeriodId    
              ,ysnClr           = 0    
              ,intEntityId        = A.intEntityId    
              ,dtmDateReconciled      = NULL    
              ,intCreatedUserId      = A.intCreatedUserId    
              ,dtmCreated         = GETDATE()    
              ,intLastModifiedUserId    = A.intLastModifiedUserId    
              ,dtmLastModified       = GETDATE()    
              ,intConcurrencyId      = 1     
            FROM [dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt    
              ON A.intGLAccountIdFrom = GLAccnt.intAccountId      
              INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp    
              ON GLAccnt.intAccountGroupId = GLAccntGrp.intAccountGroupId    
                  
              CROSS APPLY dbo.fnGLGetFiscalPeriod(A.dtmDate) F    
              WHERE A.strTransactionId = @strTransactionId     
        
            IF @intBankTransferTypeId = 4
              EXEC uspCMCreateBankSwapLong @intTransactionId
        END  -- @ysnPostedInTransit = 1
      END    -- @ysnPost =1
    ELSE    
    BEGIN    
      IF @ysnPostedInTransit = 1 --@intBankTransferTypeId = 1 OR (@intBankTransferTypeId = 2 AND @ysnPosted = 1)  
      BEGIN  
        DELETE FROM tblCMBankTransaction    
        WHERE strLink = @strTransactionId    
        AND ysnClr = 0    
        AND intBankTransactionTypeId IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)    
      END  
    END    
    IF @@ERROR <> 0 GOTO Post_Rollback    

    -- SWAP IN TRANSACTION WILL CREATE SWAP OUT AFTER POSTING
    -- IF @intBankTransferTypeId = 4 AND @ysnPostedInTransit = 1
    -- BEGIN
    --   IF @ysnPost = 1
    --   BEGIN
    --   -- CREATE SWAP OUT HERE
    --   -- DISABLE SWAP IN WINDOW
    --   -- ENABLE SWAP OUT WINDOW
    --   END
    --   ELSE
    --   BEGIN
      
    --     -- IF SWAP OUT IS POSTED THROW ERROR 'UNPOST SWAP OUT BEFORE UNPOSTING SWAP IN'
        
    --     -- DELETE SWAP OUT   
    --     -- DISABLE SWAP IN WINDOW
    --     -- ENABLE SWAP OUT WINDOW
       
      
      
    --   END
      

    -- END
END    
--=====================================================================================================================================    
--  Check if process is only a RECAP    
---------------------------------------------------------------------------------------------------------------------------------------    
IF @ysnRecap = 1     
BEGIN     
  
 -- INSERT THE DATA FROM #tmpGLDetail TO @RecapTable    
 INSERT INTO @RecapTable (    
   [dtmDate]     
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
   ,[intJournalLineNo]    
   ,[ysnIsUnposted]    
   ,[intUserId]    
   ,[intEntityId]    
   ,[strTransactionId]    
   ,[intTransactionId]    
   ,[strTransactionType]    
   ,[strTransactionForm]    
   ,[strModuleName]    
   ,[intConcurrencyId]    
 )     
 SELECT [dtmDate]     
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
   ,[intJournalLineNo]    
   ,[ysnIsUnposted]    
   ,[intUserId]    
   ,[intEntityId]    
   ,[strTransactionId]    
   ,[intTransactionId]    
   ,[strTransactionType]    
   ,[strTransactionForm]    
   ,[strModuleName]    
   ,[intConcurrencyId]    
 FROM #tmpGLDetail    
 IF @@ERROR <> 0 GOTO Post_Rollback    
      
 GOTO Recap_Rollback    
END    
    
--=====================================================================================================================================    
--  EXIT ROUTINES    
---------------------------------------------------------------------------------------------------------------------------------------    
Post_Commit:    
 SET @message_id = 10000    
 SET @isSuccessful = 1    
 COMMIT TRANSACTION    
 GOTO Audit_Log    
 GOTO Post_Exit    
    
-- If error occured, undo changes to all tables affected    
Post_Rollback:    
 SET @isSuccessful = 0    
 ROLLBACK TRANSACTION                  
 GOTO Post_Exit    
     
Recap_Rollback:     
 SET @isSuccessful = 1    
 ROLLBACK TRANSACTION    
     
 --EXEC dbo.uspCMPostRecap @RecapTable    
 EXEC dbo.uspGLPostRecap     
   @RecapTable    
   ,@intEntityId    
   ,@ysnBatch    
 GOTO Post_Exit    
    
Audit_Log:    
 DECLARE @strDescription AS NVARCHAR(100)     
   ,@actionType AS NVARCHAR(50)    
    
 SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END     
       
 EXEC uspSMAuditLog     
    @keyValue = @intTransactionId       -- Primary Key Value of the Bank Deposit.     
    ,@screenName = 'CashManagement.view.BankTransfer'        -- Screen Namespace    
    ,@entityId = @intUserId     -- Entity Id.    
    ,@actionType = @actionType                             -- Action Type    
    ,@changeDescription = @strDescription     -- Description    
    ,@fromValue = ''          -- Previous Value    
    ,@toValue = ''           -- New Value    
     
-- Clean-up routines:    
-- Delete all temporary tables used during the post transaction.     
Post_Exit:    
 IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpGLDetail')) DROP TABLE #tmpGLDetail  
  