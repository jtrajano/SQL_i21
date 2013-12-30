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

This stored procedure will create a new payment and then post it. 

Parameters:
	@start				- The starting row to start the query
	@limit				- The # of rows to get from the starting row.
	@intBankAccountID	- The bank account id to filter the transactions
	@dtmDate			- The date to filter the transaction. 

DECLARE @count AS INT
EXEC dbo.PagedBankReconDepositAndCredit 
	@start = 1, 
	@limit = 1,
	@intBankAccountID = 24,
	@dtmDate = NULL,
	@count = @count OUTPUT

PRINT @count

'====================================================================================================================================='
SCRIPT CREATED BY: Feb Montefrio		DATE CREATED: December 27, 2013
-------------------------------------------------------------------------------------------------------------------------------------*/

--=====================================================================================================================================
-- 	DELETE THE STORED PROCEDURE IF IT EXISTS
---------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PagedBankReconDepositAndCredit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PagedBankReconDepositAndCredit]
GO

--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE PagedBankReconDepositAndCredit
	@start INT
	,@limit INT
	,@intBankAccountID INT
	,@dtmDate DATETIME
	,@count INT OUTPUT 
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @BANK_DEPOSIT INT = 1
			,@BANK_WITHDRAWAL INT = 2
			,@MISC_CHECKS INT = 3
			,@BANK_TRANSFER INT = 4
			,@BANK_TRANSACTION INT = 5
			,@CREDIT_CARD_CHARGE INT = 6
			,@CREDIT_CARD_RETURNS INT = 7
			,@CREDIT_CARD_PAYMENTS INT = 8
			,@BANK_TRANSFER_WD INT = 9
			,@BANK_TRANSFER_DEP INT = 10
			,@ORIGIN_DEPOSIT AS INT = 11
			,@ORIGIN_CHECKS AS INT = 12
			,@ORIGIN_EFT AS INT = 13
			,@ORIGIN_WITHDRAWAL AS INT = 14;

	WITH PagedBankTransactions AS 
	(
		SELECT	RowNumber = ROW_NUMBER() OVER (ORDER BY cntID)
				,*				
		FROM	tblCMBankTransaction
		WHERE	ysnPosted = 1
				AND intBankAccountID = ISNULL(@intBankAccountID, intBankAccountID)
				AND dblAmount <> 0
				AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
				AND (
					-- Filter date reconciled. 
					-- 1. Include only the bank transaction that is not permanently reconciled. 
					-- 2. Or if the bank transaction is reconciled on the provided statement date. 
					dtmDateReconciled IS NULL 
					OR CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
				)
				AND (
					-- Filter for all the bank deposits and credits:
					intBankTransactionTypeID IN (@BANK_DEPOSIT, @BANK_TRANSFER_DEP, @ORIGIN_DEPOSIT)
					OR ( dblAmount > 0 AND intBankTransactionTypeID = @BANK_TRANSACTION )
				)	
	)

	-- Get the paged data
	SELECT	*
	FROM	PagedBankTransactions
	WHERE	RowNumber BETWEEN @start AND @limit 

	-- Get the total number of records
	SELECT	@count = COUNT(1)
	FROM	tblCMBankTransaction
	WHERE	ysnPosted = 1
			AND intBankAccountID = ISNULL(@intBankAccountID, intBankAccountID)
			AND dblAmount <> 0
			AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
			AND (
				-- Filter date reconciled. 
				-- 1. Include only the bank transaction that is not permanently reconciled. 
				-- 2. Or if the bank transaction is reconciled on the provided statement date. 
				dtmDateReconciled IS NULL 
				OR CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
			)
			AND (
				-- Filter for all the bank deposits and credits:
				intBankTransactionTypeID IN (@BANK_DEPOSIT, @BANK_TRANSFER_DEP, @ORIGIN_DEPOSIT)
				OR ( dblAmount > 0 AND intBankTransactionTypeID = @BANK_TRANSACTION )
			)
END
GO
