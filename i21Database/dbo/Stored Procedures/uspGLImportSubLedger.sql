/*
 '====================================================================================================================================='
   Stub stored procedure
  -------------------------------------------------------------------------------------------------------------------------------------						
	A stub is created in case GL module is not enabled in origin. 
	The real stored procedure is in the integration project. 
*/

CREATE PROCEDURE  [dbo].[uspGLImportSubLedger]
	 @startingPeriod	INT,
	 @endingPeriod		INT,
	 @intCurrencyId		INT, 
	 @intUserId			INT, 
	 @version			VARCHAR(20),
	 @importLogId		INT OUTPUT
AS
