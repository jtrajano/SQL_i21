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

This stored procedure will retrieve the amount balance of a bank account. 
Under normal conditions, the bank account balance will match to its G/L account balance. 

Parameters:
	@intBankAccountID	- The PK of the bank account id from the tblCMBankAccount
	@dtmDate			- The balance of the bank account 'as of' this date. 

EXEC dbo.GetBankBalance @intBankAccountID = 2, @dtmDate = '2013-11-16T00:00:00'
EXEC dbo.GetBankBalance @intBankAccountID = null, @dtmDate = null

'====================================================================================================================================='
SCRIPT CREATED BY: Feb Montefrio		DATE CREATED: November 28, 2013
-------------------------------------------------------------------------------------------------------------------------------------*/

--=====================================================================================================================================
-- 	DELETE THE STORED PROCEDURE IF IT EXISTS
---------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetBankBalance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GetBankBalance]
GO

--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetBankBalance
	@intBankAccountID INT = NULL,
	@dtmDate AS DATETIME = NULL
AS

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
		,@ORIGIN_WITHDRAWAL AS INT = 14
		
DECLARE @returnBalance AS NUMERIC(18,6)		

-- Get bank amounts from Misc Check and Bank Transfer (WD)
SELECT	@returnBalance = SUM(ISNULL(dblAmount, 0) * -1)
FROM	tblCMBankTransaction
WHERE	ysnPosted = 1
		AND dblAmount <> 0 
		AND intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate,dtmDate) AS FLOAT)) AS DATETIME)		
		AND intBankTransactionTypeID IN (@MISC_CHECKS, @BANK_TRANSFER_WD, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL)

-- Get bank amounts from Bank Transactions 		
SELECT	@returnBalance = ISNULL(@returnBalance, 0) + ISNULL(SUM(ISNULL(B.dblCredit, 0)), 0) - ISNULL(SUM(ISNULL(B.dblDebit, 0)), 0)
FROM	tblCMBankTransaction A INNER JOIN tblCMBankTransactionDetail B
			ON A.strTransactionID = B.strTransactionID
WHERE	A.ysnPosted = 1
		AND A.intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(A.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, A.dtmDate) AS FLOAT)) AS DATETIME)		
		AND A.intBankTransactionTypeID IN (@BANK_TRANSACTION, @BANK_WITHDRAWAL)
HAVING	ISNULL(SUM(ISNULL(B.dblCredit, 0)), 0) - ISNULL(SUM(ISNULL(B.dblDebit, 0)), 0) <> 0

-- Get bank amounts for the rest of the transactions like deposits, transferd (dep), and etc.
SELECT	@returnBalance = ISNULL(@returnBalance, 0) + ISNULL(SUM(ISNULL(dblAmount, 0)), 0)
FROM	tblCMBankTransaction
WHERE	ysnPosted = 1
		AND dblAmount <> 0 
		AND intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate,dtmDate) AS FLOAT)) AS DATETIME)		
		AND intBankTransactionTypeID NOT IN (@MISC_CHECKS, @BANK_TRANSFER_WD, @BANK_TRANSACTION, @BANK_WITHDRAWAL, @ORIGIN_CHECKS, @ORIGIN_EFT, @ORIGIN_WITHDRAWAL)		

SELECT	intBankAccountID = @intBankAccountID,
		dblBalance = ISNULL(@returnBalance, 0)

GO
