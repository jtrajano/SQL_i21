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
' Reads the tblGLDetail table and reverses the G/L entries from the prior G/L batch in the specified transaction. 
' Marks all the other batch from the transaction as unposted. 
'====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio DATE CREATED: November 19, 2013
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

***********************************************************************************************************************************/

--=====================================================================================================================================
-- 	DELETE THE STORED PROCEDURE IF IT EXISTS
---------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ReverseGLEntries]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[ReverseGLEntries]
GO

--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ReverseGLEntries
	@strTransactionID	NVARCHAR(40) = NULL
	,@strCode			NVARCHAR(10) = NULL
	,@dtmDateReverse	DATETIME = NULL 
	,@intUserID			INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--=====================================================================================================================================
-- 	DECLARATION 
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE 
	-- Local variables 
	@strBatchID AS NVARCHAR(40)

--=====================================================================================================================================
-- 	INITIALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- Retrieve the GL Batch ID in tblGLDetail for the transaction to Unpost/Reverse. 
SELECT	@strBatchID = MAX(strBatchID)
FROM	tblGLDetail
WHERE	strTransactionID = @strTransactionID
		AND ysnIsUnposted = 0
		AND strCode = ISNULL(@strCode, strCode)


--=====================================================================================================================================
-- 	VALIDATION 
---------------------------------------------------------------------------------------------------------------------------------------

-- None

--=====================================================================================================================================
-- 	REVERSE THE G/L ENTRIES
---------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO #tmpGLDetail (
		[strTransactionID]
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
SELECT	[strTransactionID]
		,dtmDate			= ISNULL(@dtmDateReverse, [dtmDate]) -- If date is provided, use date reverse as the date for unposting the transaction.
		,[strBatchID]
		,[intAccountID]
		,[strAccountGroup]
		,dblDebit			= [dblCredit]		-- (Debit -> Credit)
		,dblCredit			= [dblDebit]		-- (Debit <- Credit)
		,dblDebitUnit		= [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
		,dblCreditUnit		= [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
		,[strDescription]
		,[strCode]
		,[strReference]
		,[strJobID]
		,[intCurrencyID]
		,[dblExchangeRate]
		,dtmDateEntered		= GETDATE()
		,[dtmTransactionDate]
		,[strProductID]
		,[strWarehouseID]
		,[strNum]
		,[strCompanyName]
		,[strBillInvoiceNumber]
		,[strJournalLineDescription]
		,ysnIsUnposted		= 1
		,[intConcurrencyID]
		,[intUserID]		= @intUserID
		,[strTransactionForm]
		,[strModuleName]
		,[strUOMCode]
FROM	tblGLDetail 
WHERE	strBatchID = @strBatchID
ORDER BY intGLDetailID

--=====================================================================================================================================
-- 	UPDATE THE Is Unposted Flag IN THE tblGLDetail TABLE. 
---------------------------------------------------------------------------------------------------------------------------------------
UPDATE	tblGLDetail
SET		ysnIsUnposted = 1
WHERE	strTransactionID = @strTransactionID

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------

Exit_ReverseGLEntries:
-- Clean up. Remove any disposable temporary tables here.
-- None

GO

