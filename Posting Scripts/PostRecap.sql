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
	@ysnPost			BIT = 0
	,@intTransactionID	INT = NULL
	,@strTransactionID	NVARCHAR(40) = NULL
AS

-- CREATE A TEMPORARY TABLE VARIABLE. 
-- TEMPORARY TABLE VARIABLES ARE UNAFFECTED BY ROLLBACKS. 
DECLARE @RecapTable TABLE (
	[strTransactionID]		[nvarchar](40) NULL
	,[intTransactionID]		[int] NULL
	,[dtmDate]				[datetime] NOT NULL
	,[strBatchID]			[nvarchar](20) NULL
	,[intAccountID]			[int] NULL
	,[strAccountGroup]		[nvarchar](30) NULL
	,[dblDebit]				[numeric](18, 6) NULL
	,[dblCredit]			[numeric](18, 6) NULL
	,[dblDebitUnit]			[numeric](18, 6) NULL
	,[dblCreditUnit]		[numeric](18, 6) NULL
	,[strDescription]		[nvarchar](250) NULL
	,[strCode]				[nvarchar](40) NULL
	,[strReference]			[nvarchar](255) NULL
	,[strJobID]				[nvarchar](40) NULL
	,[intCurrencyID]		[int] NULL
	,[dblExchangeRate]		[numeric](38, 20) NOT NULL
	,[dtmDateEntered]		[datetime] NOT NULL
	,[dtmTransactionDate]	[datetime] NULL
	,[ysnIsUnposted]		[bit] NOT NULL
	,[intConcurrencyID]		[int] NULL
	,[intUserID]			[int] NULL
	,[strTransactionForm]	[nvarchar](255) NULL
	,[strModuleName]		[nvarchar](255) NULL
	,[strUOMCode]			[char](6) NULL
)

-- INSERT THE DATA FROM #tmpGLDetail TO @RecapTable
INSERT INTO @RecapTable (
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
SELECT	@strTransactionID
		,@intTransactionID		
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
FROM	#tmpGLDetail
WHERE	#tmpGLDetail.strTransactionID = @strTransactionID OR 
		#tmpGLDetail.intTransactionID = @intTransactionID

-- NOW THAT WE HAVE THE RECAP DATA, CALL THE ROLLBACK. 
ROLLBACK TRANSACTION

-- DELETE OLD RECAP DATA (IF IT EXISTS)
DELETE tblGLDetailRecap
FROM	tblGLDetailRecap INNER JOIN #tmpGLDetail
			ON (
				tblGLDetailRecap.strTransactionID = #tmpGLDetail.strTransactionID
				OR tblGLDetailRecap.intTransactionID = #tmpGLDetail.intTransactionID
			)
			AND  tblGLDetailRecap.strCode = #tmpGLDetail.strCode
WHERE	#tmpGLDetail.strTransactionID = @strTransactionID OR 
		#tmpGLDetail.intTransactionID = @intTransactionID			

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

