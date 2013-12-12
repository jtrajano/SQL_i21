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

This stored procedure will retrieve the total CLEARED bank payments/debits. 

Parameters:
	@intBankAccountID	- The PK of the bank account id from the tblCMBankAccount
	@dtmStatementDate	- The balance of the bank account 'as of' this date. 
	

EXEC dbo.GetClearedBankDebits @intBankAccountID = 2, @dtmStatementDate = NULL


'====================================================================================================================================='
SCRIPT CREATED BY: Feb Montefrio		DATE CREATED: November 28, 2013
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
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetClearedBankDebits]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GetClearedBankDebits]
GO

--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetClearedBankDebits
	@intBankAccountID INT = NULL,
	@dtmStatementDate AS DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @BANK_DEPOSIT INT = 1,
		@BANK_WITHDRAWAL INT = 2,
		@MISC_CHECKS INT = 3,
		@BANK_TRANSFER INT = 4,
		@BANK_TRANSACTION INT = 5,
		@CREDIT_CARD_CHARGE INT = 6,
		@CREDIT_CARD_RETURNS INT = 7,
		@CREDIT_CARD_PAYMENTS INT = 8,
		@BANK_TRANSFER_WD INT = 9,
		@BANK_TRANSFER_DEP INT = 10
		
SELECT	totalCount = ISNULL(COUNT(1), 0)
		,totalAmount = ISNULL(SUM(ABS(ISNULL(dblAmount, 0))), 0)
FROM	tblCMBankTransaction 
WHERE	ysnPosted = 1
		AND ysnClr = 1
		AND intBankAccountID = @intBankAccountID
		AND dblAmount <> 0		
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDate) AS FLOAT)) AS DATETIME)
		AND (
			-- Filter date reconciled. 
			-- 1. Include only bank transaction if not permanently reconciled. 
			-- 2. Or if the bank transaction is reconciled on the provided statement date. 
			dtmDateReconciled IS NULL 
			OR CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDate) AS FLOAT)) AS DATETIME)
		)
		AND (
			-- Filter for all the bank payments and debits:
			intBankTransactionTypeID = @BANK_WITHDRAWAL
			OR intBankTransactionTypeID = @MISC_CHECKS
			OR intBankTransactionTypeID = @BANK_TRANSFER_WD
			OR ( dblAmount < 0 AND intBankTransactionTypeID = @BANK_TRANSACTION )
		)
GO
