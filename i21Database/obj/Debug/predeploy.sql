/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/


--:r .\1_CM.sql

GO
	PRINT N'BEGIN CLEAN UP PREFERENCES - update null intUserID to 0'
GO
	UPDATE tblSMPreferences
	SET intUserID = 0 
	WHERE intUserID is null
GO
	PRINT N'END CLEAN UP PREFERENCES - update null intUserID to 0'
GO
-- CONSOLIDATED DELETE SCRIPTS


PRINT N' BEGIN CONSOLIDATED DELETE PATH: 13.4 to 14.1'



PRINT N' END CONSOLIDATED DELETE PATH: 13.4 to 14.1'
GO
