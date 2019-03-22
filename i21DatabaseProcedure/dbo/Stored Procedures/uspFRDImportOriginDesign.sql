CREATE PROCEDURE [dbo].[uspFRDImportOriginDesign]
	@originglfsf_no VARCHAR (40),
	@result			NVARCHAR(MAX) = '' OUTPUT
AS
IF (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U')) = 0 AND (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glfsfmst]') AND type IN (N'U')) = 0
	RETURN 0