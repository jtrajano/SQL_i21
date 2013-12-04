/*
{*******************************************************************}
{                                                                   }
{       i21 iRely Suite Posting Script								}
{                                                                   }
{       Copyright © 2004-2014 iRely, LLC							}
{       All Rights Reserved                                         }
{                                                                   }
{   The entire contents of this file is protected by U.S. and       }
{   International Copyright Laws. Unauthorized reproduction,        }
{   reverse-engineering, and distribution of all or any portion of  }
{   the code contained in this file is strictly prohibited and may  }
{   result in severe civil and criminal penalties and will be       }
{   prosecuted to the maximum extent possible under the law.        }
{                                                                   }
{   RESTRICTIONS                                                    }
{                                                                   }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES           }
{   ARE CONFIDENTIAL AND PROPRIETARY TRADE SECRETS OF               }
{   IRELY, LLC. THE REGISTERED DEVELOPER IS							}
{   LICENSED TO DISTRIBUTE THE PRODUCT AND ALL ACCOMPANYING .NET    }
{   CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.                 }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT  }
{   AND PERMISSION FROM IRELY, LLC.									}
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}
'====================================================================================================================================='
' ACCOUNTING RULES TO FOLLOW:
' 1. Debit and Credit side should be equal.
' 2. Check first if accounting period is not closed before posting.
'====================================================================================================================================='
' SCRIPT RULES TO FOLLOW:
' 1. Use 4-space indentation for statements within a nested block of code.
' 2. Capitalize all T-SQL keywords including T-SQL functions.
' 3. Create temporary tables early in the routine, and explicitly drop them at the end.
' 4. Use only CURSORS if updating small amount of data.
' 5. All temporary tables should start with #tmp<TableName>.
' 6. Delete all temporary tables after posting is finished.
' 7. Journal transaction code is 'GJ'.
' 8. Use *//*** start and ***//* end when commenting a code.
' 9. SET NOCOUNT ON on all scripts.
    - eliminates SQL Server sending DONE_IN_PROC messages to the client for each statement in s Stored Proc.
' 10. SET QUOTED_IDENTIFIER OFF
    - Causes Microsoft® SQL Server™ to follow the SQL-92 rules regarding quotation mark delimiting identifiers and literal strings.
    - Data with single quote can be processed using ''. Ex INSERT INTO tablename(fields) VALUES ('Ryan''s')
' 11. SET ANSI_NULLS ON
    - Allows for the comparison operators to return TRUE or FALSE when comparing against null values.
' 12. SET XACT_ABORT ON
	- Specifies whether SQL Server automatically rolls back the current transaction when a Transact-SQL statement raises a run-time error.
'====================================================================================================================================='
' HEADNOTES:
' 1. BEGIN TRANSACTION represents a point at which the data referenced by a connection is logically and physically consistent. If errors are encountered, 
  all data modifications made after the BEGIN TRANSACTION can be rolled back to return the data to this known state of consistency. Each transaction 
  lasts until either it completes without errors and COMMIT TRANSACTION is issued to make the modifications a permanent part of the database, or errors 
  are encountered and all modifications are erased with a ROLLBACK TRANSACTION statement.
' 2. COMMIT TRANSACTION
  Marks the end of a successful implicit or user-defined transaction. If @@TRANCOUNT is 1, COMMIT TRANSACTION makes all data modifications performed 
  since the start of the transaction a permanent part of the database, frees the resources held by the connection, and decrements @@TRANCOUNT to 0. If 
  @@TRANCOUNT is greater than 1, COMMIT TRANSACTION decrements @@TRANCOUNT only by 1.
' 3. ROLLBACK TRANSACTION
  Rolls back an explicit or implicit transaction to the beginning of the transaction, or to a savepoint inside a transaction.
' 4. RAISERROR
  Generates an error message and initiates error processing for the session. RAISERROR can either reference a user-defined message stored in the sys.messages
  catalog view or build a message dynamically. The message is returned as a server error message to the calling application or to an associated CATCH block 
  of a TRY…CATCH construct.
'====================================================================================================================================='
' REQUIRED PARAMETERS:
'
' Part					Description
' -------------------------------------------------------------------------------------------------------------------------------------
' ysnPost              - Determines whether the transaction will be Posted or Unposted/Reversed.
'                           ysnPost = 1 (Post the transaction)
'                           ysnPost = 0 (Unpost/Reverse the transaction)
' ysnRecap             - Determines whether the transaction will be committed or previewed/Recapped.
'                           ysnRecap = 1 (Commit the transaction)
'                           ysnRecap = 0 (Preview/Recap the transaction)
' strTransactionID		- The bank transfer transaction ID. 
' isSuccessful			- Returns TRUE when posting is successful. Returns FALSE when it failed. 
'							OUTPUT
' message_id			- Message number returned by the posting process. 
'                          OUTPUT
'
' Example: 

	DECLARE @successProperty BIT, @message_ID INT 
	EXEC [dbo].PostCMBankTransfer 
				@ysnPost = 0, 
				@ysnRecap = 1, 
				@strTransactionID = 'BTFR-8', 
				@isSuccessful = @successProperty OUTPUT, 
				@message_id = @message_ID OUTPUT	

	SELECT Success = @successProperty, MessageID = @message_ID				
				
'====================================================================================================================================='
SCRIPT CREATED BY: Feb Montefrio		DATE CREATED: November 20, 2013
--------------------------------------------------------------------------------------------------------------------------------------						
Last Modified By    :	1. 
						:
						n.

Last Modified Date  :	1. 
						:
						n.

Synopsis            :	1. 
						:
						n.
*/

--=====================================================================================================================================
-- 	DELETE THE STORED PROCEDURE IF IT EXISTS
---------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PostCMBankTransfer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PostCMBankTransfer]
GO

--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE PostCMBankTransfer
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@strTransactionID		NVARCHAR(40) = NULL 
	,@isSuccessful			BIT		= 0 OUTPUT 
	,@message_id			INT		= 0 OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Start the transaction 
BEGIN TRANSACTION

-- CREATE THE TEMPORARY TABLE 
CREATE TABLE #tmpGLDetail (
	[strTransactionID]			[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intTransactionID]			[int] NULL
	,[dtmDate]					[datetime] NOT NULL
	,[strBatchID]				[nvarchar](20)  COLLATE Latin1_General_CI_AS NULL
	,[intAccountID]				[int] NULL
	,[strAccountGroup]			[nvarchar](30)  COLLATE Latin1_General_CI_AS NULL
	,[dblDebit]					[numeric](18, 6) NULL
	,[dblCredit]				[numeric](18, 6) NULL
	,[dblDebitUnit]				[numeric](18, 6) NULL
	,[dblCreditUnit]			[numeric](18, 6) NULL
	,[strDescription]			[nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
	,[strCode]					[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[strReference]				[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strJobID]					[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intCurrencyID]			[int] NULL
	,[dblExchangeRate]			[numeric](38, 20) NOT NULL
	,[dtmDateEntered]			[datetime] NOT NULL
	,[dtmTransactionDate]		[datetime] NULL
	,[strProductID]				[nvarchar](50)  COLLATE Latin1_General_CI_AS NULL
	,[strWarehouseID]			[nvarchar](30)  COLLATE Latin1_General_CI_AS NULL
	,[strNum]					[nvarchar](100)  COLLATE Latin1_General_CI_AS NULL
	,[strCompanyName]			[nvarchar](150)  COLLATE Latin1_General_CI_AS NULL
	,[strBillInvoiceNumber]		[nvarchar](35)  COLLATE Latin1_General_CI_AS NULL
	,[strJournalLineDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
	,[ysnIsUnposted]			[bit] NOT NULL
	,[intConcurrencyID]			[int] NULL
	,[intUserID]				[int] NULL
	,[strTransactionForm]		[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strModuleName]			[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strUOMCode]				[char](6)  COLLATE Latin1_General_CI_AS NULL
)

-- Declare the variables 
DECLARE 
	-- Constant Variables. 
	@BANK_TRANSACTION_TYPE_ID AS INT			= 4 -- Bank Transfer Type ID is 4 (See tblCMBankTransactionType). 
	,@STARTING_NUM_TRANSACTION_TYPE_ID AS INT	= 3	-- Starting number for GL Detail table. Ex: 'BATCH-1234',
	,@GL_DETAIL_CODE AS NVARCHAR(10)			= 'BTFR' -- String code used in GL Detail table. 
	,@MODULE_NAME AS NVARCHAR(100)				= 'Cash Management' -- Module where this posting code belongs.
	,@BANK_TRANSFER_WD AS INT					= 9 -- Transaction code for Bank Transfer Withdrawal. It also refers to as Bank Transfer FROM.
	,@BANK_TRANSFER_DEP AS INT					= 10 -- Transaction code for Bank Transfer Deposit. It also refers to as Bank Transfer TO. 
	,@BANK_TRANSFER_WD_PREFIX AS NVARCHAR(3)	= '-WD'
	,@BANK_TRANSFER_DEP_PREFIX AS NVARCHAR(4)	= '-DEP'
	
	-- Local Variables
	,@cntID AS INT
	,@dtmDate AS DATETIME
	,@dblAmount AS NUMERIC(18,6)
	,@strBatchID AS NVARCHAR(40)
	,@intUserID AS INT
	,@ysnTransactionPostedFlag AS BIT
	,@ysnTransactionClearedFlag AS BIT
	
	-- Table Variables
	,@RecapTable AS RecapTableType	
	-- Note: Table variables are unaffected by COMMIT or ROLLBACK TRANSACTION.	
	
IF @@ERROR <> 0	GOTO Post_Rollback		

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Read bank transfer table 
SELECT	TOP 1 
		@cntID = cntID,
		@dtmDate = dtmDate,
		@dblAmount = dblAmount,
		@intUserID = intLastModifiedUserID,
		@ysnTransactionPostedFlag = ysnPosted
FROM	[dbo].tblCMBankTransfer 
WHERE	strTransactionID = @strTransactionID 
IF @@ERROR <> 0	GOTO Post_Rollback		
		
--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Validate if the bank transfer id exists. 
IF @cntID IS NULL
BEGIN 
	-- Cannot find the transaction.
	RAISERROR(50004, 11, 1)
	GOTO Post_Rollback
END 

-- Validate the date against the FY Periods
IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDate(@dtmDate) = 0)
BEGIN 
	-- Unable to find an open fiscal year period to match the transaction date.
	RAISERROR(50005, 11, 1)
	GOTO Post_Rollback
END

-- Check if the transaction is already posted
IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1
BEGIN 
	-- The transaction is already posted.
	RAISERROR(50007, 11, 1)
	GOTO Post_Rollback
END 

-- Check if the transaction is already posted
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0
BEGIN 
	-- The transaction is already unposted.
	RAISERROR(50008, 11, 1)
	GOTO Post_Rollback
END 

-- Check if the transaction is already reconciled
IF @ysnPost = 0 AND @ysnRecap = 0
BEGIN
	SELECT TOP 1 @ysnTransactionClearedFlag = 1
	FROM	tblCMBankTransaction 
	WHERE	strLink = @strTransactionID
			AND ysnClr = 1
			AND intBankTransactionTypeID IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)
			
	IF @ysnTransactionClearedFlag = 1
	BEGIN
		-- 'The transaction is already cleared.'
		RAISERROR(50009, 11, 1)
		GOTO Post_Rollback
	END
END

-- TODO: Check for cleared transaction. 

--=====================================================================================================================================
-- 	PROCESSING OF THE G/L ENTRIES. 
---------------------------------------------------------------------------------------------------------------------------------------

-- Get the batch post id. 
EXEC [dbo].GetStartingNumber @STARTING_NUM_TRANSACTION_TYPE_ID, @strBatchID OUTPUT 
IF @@ERROR <> 0	GOTO Post_Rollback

IF @ysnPost = 1
BEGIN
	-- Create the G/L Entries for Bank Transfer. 
	-- 1. CREDIT SIDE (SOURCE FUND)
	INSERT INTO #tmpGLDetail (
			[strTransactionID]
			,[intTransactionID]
			,[dtmDate]
			,[strBatchID]
			,[intAccountID]
			,[strAccountGroup]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[strJobID]
			,[intCurrencyID]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strProductID]
			,[strWarehouseID]
			,[strNum]
			,[strCompanyName]
			,[strBillInvoiceNumber]
			,[strJournalLineDescription]
			,[ysnIsUnposted]
			,[intConcurrencyID]
			,[intUserID]
			,[strTransactionForm]
			,[strModuleName]
			,[strUOMCode]
	)
	SELECT	[strTransactionID]		= @strTransactionID
			,[intTransactionID]		= NULL
			,[dtmDate]				= @dtmDate
			,[strBatchID]			= @strBatchID
			,[intAccountID]			= GLAccnt.intAccountID
			,[strAccountGroup]		= GLAccntGrp.strAccountGroup
			,[dblDebit]				= 0
			,[dblCredit]			= A.dblAmount
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strDescription
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strReferenceFrom
			,[strJobID]				= NULL
			,[intCurrencyID]		= NULL
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strProductID]			= NULL
			,[strWarehouseID]		= NULL
			,[strNum]				= NULL
			,[strCompanyName]		= NULL
			,[strBillInvoiceNumber] = NULL 
			,[strJournalLineDescription] = NULL 
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyID]		= 1
			,[intUserID]			= A.intLastModifiedUserID
			,[strTransactionForm]	= A.strTransactionID
			,[strModuleName]		= @MODULE_NAME
			,[strUOMCode]			= NULL 
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIDFrom = GLAccnt.intAccountID		
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
	WHERE	A.strTransactionID = @strTransactionID
	
	
	-- 2. DEBIT SIDE (TARGET OF THE FUND)
	UNION ALL 
	SELECT	[strTransactionID]		= @strTransactionID
			,[intTransactionID]		= NULL
			,[dtmDate]				= @dtmDate
			,[strBatchID]			= @strBatchID
			,[intAccountID]			= GLAccnt.intAccountID
			,[strAccountGroup]		= GLAccntGrp.strAccountGroup
			,[dblDebit]				= A.dblAmount
			,[dblCredit]			= 0
			,[dblDebitUnit]			= 0
			,[dblCreditUnit]		= 0
			,[strDescription]		= A.strDescription
			,[strCode]				= @GL_DETAIL_CODE
			,[strReference]			= A.strReferenceFrom
			,[strJobID]				= NULL
			,[intCurrencyID]		= NULL
			,[dblExchangeRate]		= 1
			,[dtmDateEntered]		= GETDATE()
			,[dtmTransactionDate]	= A.dtmDate
			,[strProductID]			= NULL
			,[strWarehouseID]		= NULL
			,[strNum]				= NULL
			,[strCompanyName]		= NULL
			,[strBillInvoiceNumber] = NULL 
			,[strJournalLineDescription] = NULL 
			,[ysnIsUnposted]		= 0 
			,[intConcurrencyID]		= 1
			,[intUserID]			= A.intLastModifiedUserID
			,[strTransactionForm]	= A.strTransactionID
			,[strModuleName]		= @MODULE_NAME
			,[strUOMCode]			= NULL 
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIDTo = GLAccnt.intAccountID		
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
	WHERE	A.strTransactionID = @strTransactionID
	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransfer
	SET		ysnPosted = 1
			,intConcurrencyID += 1 
	WHERE	strTransactionID = @strTransactionID
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Create new records in tblCMBankTransaction	
	INSERT INTO tblCMBankTransaction (
		strTransactionID
		,intBankTransactionTypeID
		,intBankAccountID
		,intCurrencyID
		,dblExchangeRate
		,dtmDate
		,strPayee
		,intPayeeID
		,strAddress
		,strZipCode
		,strCity
		,strState
		,strCountry
		,dblAmount
		,strAmountInWords
		,strMemo
		,intReferenceNo
		,ysnCheckPrinted
		,ysnCheckToBePrinted
		,ysnCheckVoid
		,ysnPosted
		,strLink
		,ysnClr
		,dtmDateReconciled
		,intCreatedUserID
		,dtmCreated
		,intLastModifiedUserID
		,dtmLastModified
		,intConcurrencyID	
	)
	-- Bank Transaction Credit
	SELECT	strTransactionID			= A.strTransactionID + @BANK_TRANSFER_WD_PREFIX
			,intBankTransactionTypeID	= @BANK_TRANSFER_WD
			,intBankAccountID			= A.intBankAccountIDFrom
			,intCurrencyID				= NULL
			,dblExchangeRate			= 1
			,dtmDate					= A.dtmDate
			,strPayee					= ''
			,intPayeeID					= NULL
			,strAddress					= ''
			,strZipCode					= ''
			,strCity					= ''
			,strState					= ''
			,strCountry					= ''
			,dblAmount					= A.dblAmount
			,strAmountInWords			= dbo.fn_ConvertNumberToWord(A.dblAmount)
			,strMemo					= A.strReferenceFrom
			,intReferenceNo				= 0
			,ysnCheckPrinted			= 0
			,ysnCheckToBePrinted		= 0
			,ysnCheckVoid				= 0
			,ysnPosted					= 1
			,strLink					= A.strTransactionID
			,ysnClr						= 0
			,dtmDateReconciled			= NULL
			,intCreatedUserID			= A.intCreatedUserID
			,dtmCreated					= GETDATE()
			,intLastModifiedUserID		= A.intLastModifiedUserID
			,dtmLastModified			= GETDATE()
			,intConcurrencyID			= 1	
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIDFrom = GLAccnt.intAccountID		
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
	WHERE	A.strTransactionID = @strTransactionID
	
	-- Bank Transaction Debit
	UNION ALL
	SELECT	strTransactionID			= A.strTransactionID + @BANK_TRANSFER_DEP_PREFIX
			,intBankTransactionTypeID	= @BANK_TRANSFER_DEP
			,intBankAccountID			= A.intBankAccountIDTo
			,intCurrencyID				= NULL
			,dblExchangeRate			= 1
			,dtmDate					= A.dtmDate
			,strPayee					= ''
			,intPayeeID					= NULL
			,strAddress					= ''
			,strZipCode					= ''
			,strCity					= ''
			,strState					= ''
			,strCountry					= ''
			,dblAmount					= A.dblAmount
			,strAmountInWords			= dbo.fn_ConvertNumberToWord(A.dblAmount)
			,strMemo					= A.strReferenceTo
			,intReferenceNo				= 0
			,ysnCheckPrinted			= 0
			,ysnCheckToBePrinted		= 0
			,ysnCheckVoid				= 0
			,ysnPosted					= 1
			,strLink					= A.strTransactionID
			,ysnClr						= 0
			,dtmDateReconciled			= NULL
			,intCreatedUserID			= A.intCreatedUserID
			,dtmCreated					= GETDATE()
			,intLastModifiedUserID		= A.intLastModifiedUserID
			,dtmLastModified			= GETDATE()
			,intConcurrencyID			= 1	
	FROM	[dbo].tblCMBankTransfer A INNER JOIN [dbo].tblGLAccount GLAccnt
				ON A.intGLAccountIDFrom = GLAccnt.intAccountID		
			INNER JOIN [dbo].tblGLAccountGroup GLAccntGrp
				ON GLAccnt.intAccountGroupID = GLAccntGrp.intAccountGroupID
	WHERE	A.strTransactionID = @strTransactionID	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
END
ELSE IF @ysnPost = 0
BEGIN
	-- Reverse the G/L entries
	EXEC [dbo].ReverseGLEntries @strTransactionID, @GL_DETAIL_CODE, NULL, @intUserID	
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Update the posted flag in the transaction table
	UPDATE tblCMBankTransfer
	SET		ysnPosted = 0
			,intConcurrencyID += 1 
	WHERE	strTransactionID = @strTransactionID
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	-- Delete the records in tblCMBankTransaction
	DELETE FROM tblCMBankTransaction
	WHERE	strLink = @strTransactionID
			AND ysnClr = 0
			AND intBankTransactionTypeID IN (@BANK_TRANSFER_WD, @BANK_TRANSFER_DEP)
	IF @@ERROR <> 0	GOTO Post_Rollback
END

--=====================================================================================================================================
-- 	Book the G/L ENTRIES to tblGLDetail (The General Ledger Detail table)
---------------------------------------------------------------------------------------------------------------------------------------
EXEC [dbo].[BookGLEntries] @ysnPost, @ysnRecap, @isSuccessful OUTPUT, @message_id OUTPUT
IF @isSuccessful = 0 GOTO Post_Rollback

--=====================================================================================================================================
-- 	Check if process is only a RECAP
---------------------------------------------------------------------------------------------------------------------------------------
IF @ysnRecap = 1 
BEGIN	
	-- INSERT THE DATA FROM #tmpGLDetail TO @RecapTable
	INSERT INTO @RecapTable (
			[strTransactionID]		
			,[intTransactionID]		
			,[dtmDate]				
			,[strBatchID]			
			,[intAccountID]			
			,[strAccountGroup]		
			,[dblDebit]				
			,[dblCredit]			
			,[dblDebitUnit]			
			,[dblCreditUnit]		
			,[strDescription]		
			,[strCode]				
			,[strReference]			
			,[strJobID]				
			,[intCurrencyID]		
			,[dblExchangeRate]		
			,[dtmDateEntered]		
			,[dtmTransactionDate]	
			,[ysnIsUnposted]		
			,[intConcurrencyID]		
			,[intUserID]			
			,[strTransactionForm]	
			,[strModuleName]		
			,[strUOMCode]			
	)	
	SELECT	@strTransactionID
			,NULL
			,[dtmDate]				
			,[strBatchID]			
			,[intAccountID]			
			,[strAccountGroup]		
			,[dblDebit]				
			,[dblCredit]			
			,[dblDebitUnit]			
			,[dblCreditUnit]		
			,[strDescription]		
			,[strCode]				
			,[strReference]			
			,[strJobID]				
			,[intCurrencyID]		
			,[dblExchangeRate]		
			,[dtmDateEntered]		
			,[dtmTransactionDate]	
			,[ysnIsUnposted]		
			,[intConcurrencyID]		
			,[intUserID]			
			,[strTransactionForm]	
			,[strModuleName]		
			,[strUOMCode]	
	FROM	#tmpGLDetail
	IF @@ERROR <> 0	GOTO Post_Rollback
	
	GOTO Recap_Rollback
END

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	SET @message_id = 10000
	SET @isSuccessful = 1
	COMMIT TRANSACTION
	GOTO Post_Exit

-- If error occured, undo changes to all tables affected
Post_Rollback:
	SET @isSuccessful = 0
	ROLLBACK TRANSACTION		            
	GOTO Post_Exit
	
Recap_Rollback: 
	SET @isSuccessful = 1
	ROLLBACK TRANSACTION 
	EXEC PostRecap @RecapTable
	GOTO Post_Exit
	
-- Clean-up routines:
-- Delete all temporary tables used during the post transaction. 
Post_Exit:
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpGLDetail')) DROP TABLE #tmpGLDetail
  
GO

