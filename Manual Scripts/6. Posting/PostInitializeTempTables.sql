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
' Initializes the temporary tables used in the posting stored procedures. 
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

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PostInitializeTempTables]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PostInitializeTempTables]
GO

CREATE PROCEDURE PostInitializeTempTables
AS

IF EXISTS (SELECT 1 FROM TEMPDB..SYSOBJECTS WHERE ID = OBJECT_ID('TEMPDB..#tmpGLDetail')) DROP TABLE #tmpGLDetail

CREATE TABLE #tmpGLDetail (
	[strTransactionID]			[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intTransactionID]			[int] NULL
	,[dtmDate]					[datetime] NOT NULL
	,[strBatchID]				[nvarchar](20)  COLLATE Latin1_General_CI_AS NULL
	,[intAccountID]				[int] NULL
	,[strAccountGroup]			[nvarchar](30)  COLLATE Latin1_General_CI_AS NULL
	,[dblDebit]					[numeric](18, 6) NULL
	,[dblCredit]				[numeric](18, 6) NULL
	,[dblDebitUnit]				[numeric](18, 6) NULL
	,[dblCreditUnit]			[numeric](18, 6) NULL
	,[strDescription]			[nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
	,[strCode]					[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[strReference]				[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strJobID]					[nvarchar](40)  COLLATE Latin1_General_CI_AS NULL
	,[intCurrencyID]			[int] NULL
	,[dblExchangeRate]			[numeric](38, 20) NOT NULL
	,[dtmDateEntered]			[datetime] NOT NULL
	,[dtmTransactionDate]		[datetime] NULL
	,[strProductID]				[nvarchar](50)  COLLATE Latin1_General_CI_AS NULL
	,[strWarehouseID]			[nvarchar](30)  COLLATE Latin1_General_CI_AS NULL
	,[strNum]					[nvarchar](100)  COLLATE Latin1_General_CI_AS NULL
	,[strCompanyName]			[nvarchar](150)  COLLATE Latin1_General_CI_AS NULL
	,[strBillInvoiceNumber]		[nvarchar](35)  COLLATE Latin1_General_CI_AS NULL
	,[strJournalLineDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL
	,[ysnIsUnposted]			[bit] NOT NULL
	,[intConcurrencyID]			[int] NULL
	,[intUserID]				[int] NULL
	,[strTransactionForm]		[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strModuleName]			[nvarchar](255)  COLLATE Latin1_General_CI_AS NULL
	,[strUOMCode]				[char](6)  COLLATE Latin1_General_CI_AS NULL
)

CREATE NONCLUSTERED INDEX IX_tmpGLDetail ON #tmpGLDetail (strTransactionID, intTransactionID)
GO

