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

This stored procedure will retrieve the G/L balance of a bank account. 
Under normal conditions, the G/L balances will match the bank balance 

Parameters:
	@intBankAccountID	- The PK of the bank account id from the tblCMBankAccount
	@dtmDate			- The balance of the bank account 'as of' this date. 

EXEC dbo.GetBankGLBalance @intBankAccountID = 2, @dtmDate = NULL

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
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetBankGLBalance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GetBankGLBalance]
GO

--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GetBankGLBalance
	@intBankAccountID INT = NULL,
	@dtmDate AS DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
			
SELECT	totalDebit = SUM(ISNULL(dblDebit, 0))
		,totalCredit = SUM(ISNULL(dblCredit, 0))
		,totalGL = SUM(ISNULL(dblDebit, 0)) - SUM(ISNULL(dblCredit, 0))
FROM	tblGLDetail INNER JOIN tblCMBankAccount
			ON tblGLDetail.intAccountID = tblCMBankAccount.intGLAccountID
WHERE	tblCMBankAccount.intBankAccountID = @intBankAccountID
		AND CAST(FLOOR(CAST(tblGLDetail.dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, tblGLDetail.dtmDate) AS FLOAT)) AS DATETIME)
GO
