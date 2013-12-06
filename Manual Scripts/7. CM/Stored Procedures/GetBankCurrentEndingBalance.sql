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

This stored procedure will retrieve the current ending balance

Parameters:
	@intBankAccountID	- The PK of the bank account id from the tblCMBankAccount
	@dtmStatementDate   - The bank statement's date. 
	
DECLARE @dblEndingBalance NUMERIC(18,6)
EXEC dbo.GetBankCurrentEndingBalance @intBankAccountID = 2, @dtmStatementDate = '2013-12-05T00:00:00', @dblEndingBalance = @dblEndingBalance OUTPUT

PRINT @dblEndingBalance

EXEC dbo.GetBankCurrentEndingBalance NULL

'====================================================================================================================================='
SCRIPT CREATED BY: Feb Montefrio		DATE CREATED: December 05, 2013
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
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetBankCurrentEndingBalance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GetBankCurrentEndingBalance]
GO

--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetBankCurrentEndingBalance
	@intBankAccountID INT = NULL,
	@dtmStatementDate DATETIME = NULL,	
	@dblEndingBalance AS NUMERIC(18, 6) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
	
SELECT	TOP 1 
		@dblEndingBalance = ISNULL(dblStatementEndingBalance, 0)
FROM	tblCMCurrentBankReconciliation
WHERE	intBankAccountID = @intBankAccountID

SELECT	TOP 1 
		@dblEndingBalance = ISNULL(dblStatementEndingBalance, @dblEndingBalance)
FROM	tblCMBankReconciliation 
WHERE	intBankAccountID = @intBankAccountID 
		AND CAST(FLOOR(CAST(dtmDateReconciled AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(ISNULL(@dtmStatementDate, dtmDateReconciled) AS FLOAT)) AS DATETIME)
		AND @dtmStatementDate IS NOT NULL

SELECT	intBankAccountID = @intBankAccountID,
		dblEndingBalance = ISNULL(@dblEndingBalance, 0)

GO
