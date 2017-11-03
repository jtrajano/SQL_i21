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
IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1)
	RAISERROR('Import Subledger Procedure is not available', 16, 1);