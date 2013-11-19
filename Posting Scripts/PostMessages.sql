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
' Creates and populates the error message used by i21 iRely Suite Stored procedures. 
' System used error messages are inserted to the sys.messages table. 
' To use a message, you need to call RAISERROR with the error code. For example: 
'
'		RAISERROR (50002,11,1)
'
' It will call error code 50002 (Invalid G/L temporary table.)
'
' The advantage of using SQL Server errors: 
' 1. Customizable. We can alter this stored procedure to support localization. 
' 2. Maintainable. All error used by the stored procedures can be found here. 
' 3. Helpful in debugging. The error thrown by the stored procedure seen wherever it was called. It is thrown back to the calling app 
' or even inside the SQL Management studio.
'
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
*/

/***************************************************************************************************************/
-- ERROR MESSAGES, Message IDs 50001 - 59999
/***************************************************************************************************************/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PostMessages]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PostMessages]
GO

CREATE PROCEDURE PostMessages
AS

DECLARE @strmessage AS NVARCHAR(MAX)

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50001) EXEC sp_dropmessage 50001, 'us_english'	
SET @strmessage = 'Invalid G/L account id found.'
EXEC sp_addmessage 50001,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50002) EXEC sp_dropmessage 50002, 'us_english'	
SET @strmessage = 'Invalid G/L temporary table.'
EXEC sp_addmessage 50002,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50003) EXEC sp_dropmessage 50003, 'us_english'	
SET @strmessage = 'Debit and credit amounts are not balanced.'
EXEC sp_addmessage 50003,11,@strmessage,'us_english','False'

GO

EXEC PostMessages

GO