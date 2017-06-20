/*
Post-Deployment Script Template							
------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
------------------------------------------------------------------------------------
*/
PRINT '*Start Panel Owner Migration*'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanel')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanelOwner')

	INSERT INTO tblDBPanelOwner
		SELECT C.intPanelId, C.intUserId, 1 as intConcurrencyId 
		FROM 
		(SELECT A.intPanelId, A.intUserId, B.intPanelOwnerId 
			FROM tblDBPanel A LEFT JOIN tblDBPanelOwner B
				ON A.intPanelId = B.intPanelId AND A.intUserId = B.intUserId
			WHERE A.intUserId > 0
		) C 
		WHERE C.intPanelOwnerId IS NULL

PRINT '*End Panel Owner Migration*'
