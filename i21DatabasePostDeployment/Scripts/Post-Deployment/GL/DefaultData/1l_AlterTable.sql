/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLTempCOASegment') 
	IF EXISTS(SELECT * 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_NAME='PK_tblGLTempCOASegment' )
	BEGIN
		ALTER TABLE dbo.[tblGLTempCOASegment]
		DROP CONSTRAINT PK_tblGLTempCOASegment

	END
	ALTER TABLE dbo.[tblGLTempCOASegment] ADD CONSTRAINT [PK_tblGLTempCOASegment] PRIMARY KEY ([intAccountId])
GO