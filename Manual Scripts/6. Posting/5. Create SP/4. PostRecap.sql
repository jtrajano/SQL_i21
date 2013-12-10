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
' Insert the G/L entries to the recap table. 
' The recap form is expected to query the data from the recap table. 
' It is more optimal to show the recap data using a buffered store and grid. 
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

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PostRecap]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PostRecap]
GO

CREATE PROCEDURE PostRecap
	@RecapTable RecapTableType READONLY 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- DELETE OLD RECAP DATA (IF IT EXISTS)
DELETE tblGLDetailRecap
FROM	tblGLDetailRecap A INNER JOIN @RecapTable B
			ON (
				A.strTransactionID = B.strTransactionID
				OR A.intTransactionID = B.intTransactionID
			)
			AND  A.strCode = B.strCode

-- INSERT THE RECAP DATA. 
-- THE RECAP DATA WILL BE STORED IN A PERMANENT TABLE SO THAT WE CAN QUERY IT LATER USING A BUFFERED STORE. 
INSERT INTO tblGLDetailRecap (
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
-- RETRIEVE THE DATA FROM THE TABLE VARIABLE. 
SELECT	[strTransactionID]		
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
FROM	@RecapTable

GO

