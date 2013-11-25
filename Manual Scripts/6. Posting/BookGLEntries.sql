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
 '====================================================================================================================================='
 ' SCRIPT RULES TO FOLLOW:
 ' 1. Use 4-space indentation for statements within a nested block of code.
 ' 2. Capitalize all T-SQL keywords including T-SQL functions.
 ' 3. Create temporary tables early in the routine, and explicitly drop them at the end.
 ' 4. Use only CURSORS if updating small amount of data.
 ' 5. All temporary tables should start with #tmp<TableName>.
 ' 6. Delete all temporary tables after posting is finished.
 ' 7. Use *//*** start and ***//* end when commenting a code.
 ' 8. SET NOCOUNT ON on all scripts.
        - eliminates SQL Server sending DONE_IN_PROC messages to the client for each statement in s Stored Proc.
 ' 9. SET QUOTED_IDENTIFIER OFF
        - Causes Microsoft® SQL Server™ to follow the SQL-92 rules regarding quotation mark delimiting identifiers and literal strings.
        - Data with single quote can be processed using ''. Ex INSERT INTO tablename(fields) VALUES ('Ryan''s')
 ' 10. SET ANSI_NULLS ON
        - Allows for the comparison operators to return TRUE or FALSE when comparing against null values.
 ' 11. SET XACT_ABORT ON
		- Specifies whether SQL Server automatically rolls back the current transaction when a Transact-SQL statement raises a run-time error.                
 ' 12. Check the Currency Setup of each account ID used in the posting. 
 '====================================================================================================================================='
 ' Handles the Posting, Unposting, and updating of G/L entries.  
 ' The #tmpGLDetail temporary table is expected to have all the G/L entries needed to post or unpost a SINGLE transaction. 
 '
 ' REQUIRED PARAMETERS:
 '
 ' Parameter			Description
 ' ------------------------------------------------------------------------------------------------------------------------------------
 ' ysnPost              = Determines whether the transaction will be Posted or Unposted/Reversed.
 '                      ysnPost = 1 (Post the transaction)
 '                      ysnPost = 0 (Unpost/Reverse the transaction)
 '
 ' ysnRecap             = Determines whether the transaction will be committed or previewed/Recapped.
 '                      ysnRecap = 1 (Commit the transaction)
 '                      ysnRecap = 0 (Preview/Recap the transaction)
 '
 ' isSuccessful			= A booelan that determines whether an error occured. 
						Returns TRUE if no error is found. Returns FALSE when error was found. 
 '						OUTPUT 
 '
 ' message_id      		= A number code returned by this stored procedure. 
 '                      OUTPUT
 '
 ' Example on how to use:      
 '		[dbo].[BookGLEntries] 1, 1, @isSuccessful OUTPUT, @message_id OUTPUT
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio		DATE CREATED: November 19, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
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

/*=====================================================================================================================================
	DELETE STORED PROCEDURE IF EXISTS.
*/------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[BookGLEntries]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[BookGLEntries]
GO

/*=====================================================================================================================================
	CREATE THE STORED PROCEDURE
*/------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE BookGLEntries
	@ysnPost		BIT	= 0
	,@ysnRecap		BIT	= 0
	,@isSuccessful	BIT = 0 OUTPUT
	,@message_id	INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARATION 
--------------------------------------------------------------------------------------------------------------------------------------

DECLARE @dblDebitCreditBalance NUMERIC(18,2)

--------------------------------------------------------------------------------------------------------------------------------------
--  END OF VALIDATION
--=====================================================================================================================================

--=====================================================================================================================================
-- 	START OF THE VALIDATION
--------------------------------------------------------------------------------------------------------------------------------------

-- Check if the required temporary table is not missing. If missing, throw an error. 
IF NOT EXISTS (	SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID(N'[TEMPDB]..[#tmpGLDetail]'))
BEGIN 
	-- 'Invalid G/L temp table.'
	RAISERROR (50002,11,1)
	GOTO Exit_BookGLEntries_WithErrors
END

-- When doing a post or unpost, check for any invalid G/L Account ids. 
-- When doing a recap, ignore any invalid G/L account id's. 
IF EXISTS (SELECT TOP 1 1 FROM #tmpGLDetail WHERE intAccountID IS NULL AND @ysnRecap = 0)
BEGIN 
	-- 'Failed. Invalid G/L account id found.'
	RAISERROR (50002,11,1)
	GOTO Exit_BookGLEntries_WithErrors
END		

-- Check if the debit and credit amounts are balanced. 
SELECT	@dblDebitCreditBalance = SUM(dblDebit) - SUM(dblCredit) 
FROM	#tmpGLDetail

IF ISNULL(@dblDebitCreditBalance, 0) <> 0 AND @ysnRecap = 0 
BEGIN
	-- If not balanced, throw an error. 
	RAISERROR (50003,11,1)
	GOTO Exit_BookGLEntries_WithErrors	
END 

-- Check if the debit and credit amounts are balanced. 
-- This time join the temporary table with the GL Account table. 
-- It ensures the amounts are using valid account id's (existing and active account id's)
SELECT	@dblDebitCreditBalance = SUM(dblDebit) - SUM(dblCredit) 
FROM	#tmpGLDetail INNER JOIN tblGLAccount
			ON #tmpGLDetail.intAccountID = tblGLAccount.intAccountID
WHERE	ISNULL(tblGLAccount.ysnActive, 0) = 1

IF ISNULL(@dblDebitCreditBalance, 0) <> 0
BEGIN
	-- Debit and credit amounts are not balanced.
	RAISERROR (50003,11,1)
	GOTO Exit_BookGLEntries_WithErrors	
END 

-- TODO: Check if the currency is invalid. 
-- TODO: Check for invalid unit of measure (for unit accounting)

-- Validate the date against the FY Periods
IF EXISTS (SELECT 1 FROM #tmpGLDetail WHERE [dbo].isOpenAccountingDate(#tmpGLDetail.dtmDate) = 0)
BEGIN 
	-- Unable to find an open fiscal year period to match the transaction date.
	RAISERROR(50005, 11, 1)
	GOTO Exit_BookGLEntries_WithErrors
END

--------------------------------------------------------------------------------------------------------------------------------------
--  END OF VALIDATION
--=====================================================================================================================================

--=====================================================================================================================================
-- 	START OF THE INITIALIZATION																										 
--------------------------------------------------------------------------------------------------------------------------------------

-- Process the switching of the debit and credit sides.
-- 1. Negative Credit goes as Positive Debit. 
-- 2. Negative Debit goes as positive Credit. 
-- 3. When debit is negative, change it to zero. When credit is negative, change it to zero. 
UPDATE #tmpGLDetail
SET	dblDebit	= CASE	WHEN dblCredit < 0 THEN ABS(dblCredit)
						WHEN dblDebit < 0 THEN 0
						ELSE dblDebit 
				END 
	,dblCredit	= CASE	WHEN dblDebit < 0 THEN ABS(dblDebit)
						WHEN dblCredit < 0 THEN 0
						ELSE dblCredit
				END			

--------------------------------------------------------------------------------------------------------------------------------------
--  END OF INITIALIZATION
--=====================================================================================================================================

--=====================================================================================================================================
-- 	BOOK THE G/L ENTRIES TO THE tblGLDetail table.
--------------------------------------------------------------------------------------------------------------------------------------

-- TODO: Account Allocation
-- TODO: Update the summary tables. 

-- Add the G/L entries from the temporary table to the permanent table (tblGLDetail)
INSERT INTO tblGLDetail (
		strBatchID
		,dtmDate	
		,intAccountID
		,strAccountGroup
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,strDescription
		,strCode
		,strTransactionID
		,strReference
		,strJobID
		,intCurrencyID
		,dblExchangeRate
		,dtmDateEntered
		,dtmTransactionDate
		,strProductID
		,strWarehouseID
		,strNum
		,strCompanyName
		,strBillInvoiceNumber
		,strJournalLineDescription
		,ysnIsUnposted
		,intUserID
		,strTransactionForm
		,strModuleName
		,strUOMCode
		,intConcurrencyID	
)
SELECT 
		strBatchID
		,dtmDate	
		,intAccountID
		,strAccountGroup
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,strDescription
		,strCode
		,strTransactionID
		,strReference
		,strJobID
		,intCurrencyID
		,dblExchangeRate
		,dtmDateEntered
		,dtmTransactionDate
		,strProductID
		,strWarehouseID
		,strNum
		,strCompanyName
		,strBillInvoiceNumber
		,strJournalLineDescription
		,ysnIsUnposted
		,intUserID
		,strTransactionForm
		,strModuleName
		,strUOMCode
		,intConcurrencyID	
FROM	#tmpGLDetail
WHERE	@ysnRecap = 0

--=====================================================================================================================================
-- 	UPDATE THE SUMMARY TABLE. 
---------------------------------------------------------------------------------------------------------------------------------------

UPDATE	tblGLSummary 
SET		dblDebit = ISNULL(tblGLSummary.dblDebit, 0) + ISNULL(tmpGLDetailGrouped.dblDebit, 0)
		,dblCredit = ISNULL(tblGLSummary.dblCredit, 0) + ISNULL(tmpGLDetailGrouped.dblCredit, 0)
		,intConcurrencyID = ISNULL(intConcurrencyID, 0) + 1
FROM	(
			SELECT	dblDebit	= SUM(ISNULL(B.dblDebit, 0))
					,dblCredit	= SUM(ISNULL(B.dblCredit, 0))
					,A.intAccountID
					,dtmDate	= ISNULL(CONVERT(VARCHAR(10), B.dtmDate, 112), '') 								
			FROM	tblGLSummary A INNER JOIN #tmpGLDetail B
						ON CONVERT(VARCHAR(10), A.dtmDate, 112) = CONVERT(VARCHAR(10), B.dtmDate, 112)
						AND A.intAccountID = B.intAccountID			
			WHERE	@ysnRecap = 0 
			GROUP BY	ISNULL(CONVERT(VARCHAR(10), B.dtmDate, 112), ''), 
						A.intAccountID
		) AS tmpGLDetailGrouped
WHERE	tblGLSummary.intAccountID = tmpGLDetailGrouped.intAccountID
		AND ISNULL(CONVERT(VARCHAR(10), tblGLSummary.dtmDate, 112), '') = ISNULL(CONVERT(VARCHAR(10), tmpGLDetailGrouped.dtmDate, 112), '')
		AND @ysnRecap = 0

-- INSERT RECORDS TO THE SUMMARY TABLE
INSERT INTO tblGLSummary (
		intAccountID
		,dtmDate
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,intConcurrencyID
)
SELECT	#tmpGLDetail.intAccountID
		,ISNULL(CONVERT(VARCHAR(10), #tmpGLDetail.dtmDate, 112), '')
		,SUM(#tmpGLDetail.dblDebit)
		,SUM(#tmpGLDetail.dblCredit)
		,SUM(#tmpGLDetail.dblDebitUnit)
		,SUM(#tmpGLDetail.dblCreditUnit)
		,1
FROM	#tmpGLDetail
WHERE	NOT EXISTS (
			SELECT	TOP 1 1
			FROM	tblGLSummary
			WHERE	ISNULL(CONVERT(VARCHAR(10), #tmpGLDetail.dtmDate, 112), '') = ISNULL(CONVERT(VARCHAR(10), tblGLSummary.dtmDate, 112), '') 
					AND #tmpGLDetail.intAccountID = tblGLSummary.intAccountID
		)
		AND @ysnRecap = 0
GROUP BY	ISNULL(CONVERT(VARCHAR(10), #tmpGLDetail.dtmDate, 112), ''), 
			#tmpGLDetail.intAccountID


--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------

Exit_Successfully:
	SET @isSuccessful = 1
	GOTO Exit_BookGLEntries

Exit_BookGLEntries_WithErrors:
	SET @isSuccessful = 0		
	GOTO Exit_BookGLEntries	
	
Exit_BookGLEntries:

-- Clean up. Remove any disposable temporary tables here.
-- None

GO