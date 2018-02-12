﻿/*
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
GO
	PRINT ('Started updating strChartDes column in tblGLAccountSegment')
GO
	UPDATE dbo.tblGLAccountSegment SET strChartDesc = strDescription WHERE strChartDesc IS NULL
GO
	PRINT ('Finished updating strChartDes column in tblGLAccountSegment')
GO
