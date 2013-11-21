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
' Retrieves the next string ID from tblSMStartingNumber
'====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio DATE CREATED: November 20, 2013
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
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetStartingNumber]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[GetStartingNumber]
GO

CREATE PROCEDURE GetStartingNumber
	@intTransactionTypeID INT = NULL,
	@strID	NVARCHAR(40) = NULL OUTPUT

AS

-- Assemble the string ID. 
SELECT	@strID = strPrefix + CAST(intNumber AS NVARCHAR(20))
FROM	tblSMStartingNumber
WHERE	intTransactionTypeID = @intTransactionTypeID

-- Increment the next number
UPDATE	tblSMStartingNumber
SET		intNumber = ISNULL(intNumber, 0) + 1
WHERE	intTransactionTypeID = @intTransactionTypeID

GO