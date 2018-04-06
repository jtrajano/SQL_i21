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
GO
PRINT 'Begin removing unreferenced entry in tblGLCrossReferenceMapping'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblGLCrossReferenceMapping]') AND type in (N'U')) 
	DELETE FROM tblGLCrossReferenceMapping WHERE intAccountSystemId NOT IN(SELECT intAccountSystemId FROM tblGLAccountSystem)
GO
PRINT 'Finished removing unreferenced entry in tblGLCrossReferenceMapping'
GO

GO
PRINT 'Begin cleaning tblGLCurrentFiscalYear'
GO
