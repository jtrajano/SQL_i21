CREATE PROCEDURE [dbo].[uspGLImportOriginReallocation]
AS
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glragmst]') AND type IN (N'U')) 
	RETURN 'Reallocation origin table is not available'
