CREATE PROCEDURE uspCMCreateBankTransactionEntries    
 @BankTransactionEntries BankTransactionTable READONLY,    
 @BankTransactionDetailEntries BankTransactionDetailTable READONLY,    
 @intTransactionId INT = NULL OUTPUT    
AS    
    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS ON    
SET NOCOUNT ON    
SET XACT_ABORT ON    
SET ANSI_WARNINGS OFF    
    
--=====================================================================================================================================    
--  VALIDATION    
------------------------------------------------------------------------------------------------------------------------------------    
--BEGIN     
-- EXEC dbo.uspCMValidateBankTransactionEntries @BankTransactionEntries;    
-- IF @@ERROR <> 0 GOTO Exit_Procedure;    
--END     
--;    
--=====================================================================================================================================    
--  CREATE THE BANK TRANSACTION ENTRIES TO THE tblCMBankTransaction table.    
--------------------------------------------------------------------------------------------------------------------------------------    
BEGIN     
 -- Add the Bank Transaction entries from the temporary table to the permanent table (tblCMBankTransaction)    
 INSERT INTO tblCMBankTransaction(    
  [strTransactionId],    
  [intBankTransactionTypeId],    
  [intBankAccountId],    
  [intCurrencyId],    
  [dblExchangeRate],    
  [dtmDate],    
  [intFiscalPeriodId],    
  [intTaskId],  
  [strPayee],    
  [intPayeeId],    
  [strAddress],    
  [strZipCode],    
  [strCity],    
  [strState],    
  [strCountry],    
  [dblAmount],    
  [strAmountInWords],    
  [strMemo],    
  [strReferenceNo],    
  [ysnCheckToBePrinted],    
  [ysnCheckVoid],    
  [ysnPosted],    
  [strLink],    
  [ysnClr],    
  [ysnPOS],   
  [ysnCCEntry],
  [dtmDateReconciled],    
  [intEntityId],    
  [intCreatedUserId],    
  [intCompanyLocationId],    
  [dtmCreated],    
  [intLastModifiedUserId],    
  [dtmLastModified],    
  [intConcurrencyId]    
 )    
 SELECT     
  [strTransactionId],    
  [intBankTransactionTypeId],    
  [intBankAccountId],    
  [intCurrencyId],    
  [dblExchangeRate],    
  [dtmDate],    
  [intFiscalPeriodId] = F.intGLFiscalYearPeriodId, -- remove this in 20.1    
  [intTaskId],  
  [strPayee],    
  [intPayeeId],    
  [strAddress],    
  [strZipCode],    
  [strCity],    
  [strState],    
  [strCountry],    
  [dblAmount],    
  [strAmountInWords] = dbo.fnConvertNumberToWord([dblAmount]),    
  [strMemo],    
  [strReferenceNo],    
  [ysnCheckToBePrinted],    
  [ysnCheckVoid],    
  [ysnPosted],    
  [strLink],    
  [ysnClr],    
  [ysnPOS],   
  [ysnCCEntry],
  [dtmDateReconciled],    
  [intEntityId],    
  [intCreatedUserId],    
  [intCompanyLocationId],    
  [dtmCreated],    
  [intLastModifiedUserId],    
  [dtmLastModified],    
  [intConcurrencyId]    
 FROM @BankTransactionEntries BankTransactionEntries    
 CROSS APPLY dbo.fnGLGetFiscalPeriod([dtmDate]) F  -- remove this in 20.1    
    
 SET @intTransactionId = SCOPE_IDENTITY()    
END    
;    
    
--=====================================================================================================================================    
--  CREATE THE BANK TRANSACTION DETAIL ENTRIES TO THE tblCMBankTransactionDetail table.    
--------------------------------------------------------------------------------------------------------------------------------------    
IF EXISTS(SELECT TOP 1 1 FROM @BankTransactionDetailEntries)    
BEGIN     
    
 --======================================================    
 --VALIDATION FOR DETAIL    
 --======================================================    
 --validation sp goes here    
    
 -- Add the Bank Transaction Detail entries from the temporary table to the permanent table (tblCMBankTransactionDetail)    
 INSERT INTO [dbo].[tblCMBankTransactionDetail]    
  ([intTransactionId]    
  ,[dtmDate]    
  ,[intGLAccountId]    
  ,[strDescription]    
  ,[dblDebit]    
  ,[dblCredit]    
  ,[intUndepositedFundId]    
  ,[intEntityId]   
  ,[intCreatedUserId]    
  ,[dtmCreated]    
  ,[intLastModifiedUserId]    
  ,[dtmLastModified]    
  ,[intConcurrencyId])    
 SELECT    
  @intTransactionId    
  ,[dtmDate]    
  ,[intGLAccountId]    
  ,[strDescription]    
  ,[dblDebit]    
  ,[dblCredit]    
  ,[intUndepositedFundId]    
  ,[intEntityId]    
  ,[intCreatedUserId]    
  ,[dtmCreated]    
  ,[intLastModifiedUserId]    
  ,[dtmLastModified]    
  ,[intConcurrencyId]    
 FROM @BankTransactionDetailEntries BankTransactionDetailEntries    
END    
;    
--=====================================================================================================================================    
--  EXIT ROUTINES     
---------------------------------------------------------------------------------------------------------------------------------------    
Exit_Procedure: 