/*
{*******************************************************************}
{                                                                   }
{       i21 iRely Suite Cash Management Script						}
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

This stored procedure will create a new deposit and then post it. 

Parameters:
	@intBankAccountID	- The PK of the bank account id from the tblCMBankAccount
	@dtmDate			- The transaction date
	@intGLAccountID		- The counter G/L Account ID to use as detail to the deposit transaction. 
	@dblAmount			- The amount of the deposit
	@strDescription		- The description to use for the deposit
	@intUserID			- The id of the user who created the deposit. 

EXEC dbo.AddDeposit @intBankAccountID = 2, @dtmDate = '2013-11-16T00:00:00', @intGLAccountID = 1, @dblAmount = 100, @strDescription = 'This is the description', @intUserID = 1

'====================================================================================================================================='
SCRIPT CREATED BY: Feb Montefrio		DATE CREATED: December 06, 2013
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
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AddDeposit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[AddDeposit]
GO

--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE AddDeposit
	@intBankAccountID INT
	,@dtmDate DATETIME 
	,@intGLAccountID INT	
	,@dblAmount NUMERIC(18,6)
	,@strDescription NVARCHAR(250)
	,@intUserID INT
	,@isAddSuccessful BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

DECLARE @BANK_DEPOSIT INT = 1,
		@BANK_WITHDRAWAL INT = 2,
		@MISC_CHECKS INT = 3,
		@BANK_TRANSFER INT = 4,
		@BANK_TRANSACTION INT = 5,
		@CREDIT_CARD_CHARGE INT = 6,
		@CREDIT_CARD_RETURNS INT = 7,
		@CREDIT_CARD_PAYMENTS INT = 8,
		@BANK_TRANSFER_WD INT = 9,
		@BANK_TRANSFER_DEP INT = 10,
		
		@strTransactionID NVARCHAR(40),
		@msg_id INT


-- Initialize the transaction id. 
SELECT	@strTransactionID = strTransactionPrefix + '-' + CAST(intTransactionNo AS NVARCHAR(20))
FROM	tblCMBankTransactionType
WHERE	intBankTransactionTypeID = @BANK_DEPOSIT
IF @@ERROR <> 0	GOTO AddDeposit_Rollback

-- Increment the next transaction number
UPDATE	tblCMBankTransactionType
SET		intTransactionNo += 1
WHERE	intBankTransactionTypeID = @BANK_DEPOSIT
IF @@ERROR <> 0	GOTO AddDeposit_Rollback

-- Create the Bank Deposit HEADER
INSERT INTO tblCMBankTransaction(
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
SELECT	strTransactionID			= @strTransactionID
		,intBankTransactionTypeID	= @BANK_DEPOSIT
		,intBankAccountID			= @intBankAccountID
		,intCurrencyID				= NULL
		,dblExchangeRate			= 1
		,dtmDate					= @dtmDate
		,strPayee					= ''
		,intPayeeID					= NULL
		,strAddress					= ''
		,strZipCode					= ''
		,strCity					= ''
		,strState					= ''
		,strCountry					= ''
		,dblAmount					= @dblAmount
		,strAmountInWords			= dbo.fn_ConvertNumberToWord(@dblAmount)
		,strMemo					= ISNULL(@strDescription, '')
		,intReferenceNo				= 0
		,ysnCheckPrinted			= 0
		,ysnCheckToBePrinted		= 0
		,ysnCheckVoid				= 0
		,ysnPosted					= 0
		,strLink					= ''
		,ysnClr						= 0
		,dtmDateReconciled			= NULL
		,intCreatedUserID			= @intUserID
		,dtmCreated					= GETDATE()
		,intLastModifiedUserID		= @intUserID
		,dtmLastModified			= GETDATE()
		,intConcurrencyID			= 1
IF @@ERROR <> 0	GOTO AddDeposit_Rollback

-- Create the Bank Deposit DETAIL
INSERT INTO tblCMBankTransactionDetail(
	strTransactionID
	,dtmDate
	,intGLAccountID
	,strDescription
	,dblDebit
	,dblCredit
	,intUndepositedFundID
	,intEntityID
	,intCreatedUserID
	,dtmCreated
	,intLastModifiedUserID
	,dtmLastModified
	,intConcurrencyID
)
SELECT	strTransactionID		= @strTransactionID
		,dtmDate				= @dtmDate
		,intGLAccountID			= @intGLAccountID
		,strDescription			= tblGLAccount.strDescription
		,dblDebit				= 0
		,dblCredit				= @dblAmount
		,intUndepositedFundID	= 0
		,intEntityID			= NULL
		,intCreatedUserID		= @intUserID
		,dtmCreated				= GETDATE()
		,intLastModifiedUserID	= @intUserID
		,dtmLastModified		= GETDATE()
		,intConcurrencyID		= 1
FROM	tblGLAccount 
WHERE	intAccountID = @intGLAccountID
IF @@ERROR <> 0	GOTO AddDeposit_Rollback

-- Post the transaction 
BEGIN TRY
	EXEC dbo.PostCMBankDeposit 	
			@ysnPost = 1
			,@ysnRecap = 0
			,@strTransactionID = @strTransactionID
			,@isSuccessful = @isAddSuccessful OUTPUT
			,@message_id = @msg_id OUTPUT
			
	IF @@ERROR <> 0	GOTO AddDeposit_Rollback	
	GOTO AddDeposit_Commit
END TRY
BEGIN CATCH
	GOTO AddDeposit_Exit
END CATCH

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
AddDeposit_Commit:
	SET @isAddSuccessful = 1
	COMMIT TRANSACTION
	GOTO AddDeposit_Exit
	
AddDeposit_Rollback:
	SET @isAddSuccessful = 0
	ROLLBACK TRANSACTION 
	
AddDeposit_Exit:	

GO
