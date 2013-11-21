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
 ' intJournalID			- Journal ID to post.
 ' isSuccessful			- Returns TRUE when posting is successful. Returns FALSE when it failed. 
 '							OUTPUT
 ' message_id			- Message number returned by the posting process. 
 '                          OUTPUT
 '
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio		DATE CREATED: November 20, 2013
  --------------------------------------------------------------------------------------------------------------------------------------						
   Last Modified By    : 1. 
                         :
                         n.

   Last Modified Date  : 1. 
                         :
                         n.

   Synopsis            : 1. 
                         :
                         n.
*/

--=====================================================================================================================================
-- 	DELETE THE STORED PROCEDURE IF IT EXISTS
---------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PostGLJournal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PostGLJournal]
GO

--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE PostGLJournal
	@ysnPost				BIT		= 0
	,@ysnRecap				BIT		= 0
	,@intJournalID			INT		= NULL
	,@isSuccessful			BIT		= 0 OUTPUT 
	,@message_id			INT		= 0 OUTPUT 
WITH ENCRYPTION
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

--=====================================================================================================================================
-- 	DECLARATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Start the transaction 
BEGIN TRANSACTION

-- Call PostInitialization to generate the temporary tables. 
EXEC PostInitializeTempTables

--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- TODO: Validate if the Journal id exists. 
-- TODO: Validate if the Journal ID is valid (existing and with the proper posting flags). 
-- TODO: Validate the Accounting period date and FY
-- TODO: Check the Journal balance. 
-- TODO: Check the affected special books

--=====================================================================================================================================
-- 	PROCESSING OF THE G/L ENTRIES. 
---------------------------------------------------------------------------------------------------------------------------------------

-- TODO: Get the batch post id. 
-- TODO: Insert the G/L Entries (Posting routine)
-- TODO: Unposting routine

IF @@ERROR <> 0	GOTO Post_Rollback

--=====================================================================================================================================
-- 	Book the G/L ENTRIES to tblGLDetail (The G/L Ledger detail table)
---------------------------------------------------------------------------------------------------------------------------------------
EXEC [dbo].[BookGLEntries] @ysnPost, @ysnRecap, @isSuccessful OUTPUT, @message_id OUTPUT
IF @isSuccessful = 0 GOTO Post_Rollback

--=====================================================================================================================================
-- 	Check if process is only a RECAP
---------------------------------------------------------------------------------------------------------------------------------------
IF @ysnRecap = 1 
BEGIN
	EXEC PostRecap @ysnPost, @intJournalID, NULL 
	
	-- Recap will do the ROLLBACK, simply exit the SPROC
	SET @message_id = 10000
	GOTO Post_Exit
END

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
Post_Commit:
	SET @message_id = 10000
	COMMIT TRANSACTION
	GOTO Post_Exit

-- If error occured, undo changes to all tables affected
Post_Rollback:
	ROLLBACK TRANSACTION		            
	GOTO Post_Exit
	
-- Clean-up routines:
-- Delete all temporary tables used during the post transaction. 
Post_Exit:
	IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpGLDetail')) DROP TABLE #tmpGLDetail
  
GO

