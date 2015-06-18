GO
IF (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U')) = 1 AND (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glfsfmst]') AND type IN (N'U')) = 1
BEGIN 

	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspFRDProcessOriginImport'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspFRDProcessOriginImport];
	')

	EXEC('
		CREATE PROCEDURE  [dbo].[uspFRDProcessOriginImport]
			@result			NVARCHAR(MAX) = '''' OUTPUT
		AS

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON	

		DECLARE @GUID NVARCHAR(MAX) = NEWID()

		SELECT * INTO #TempOrigin FROM (select DISTINCT glfsf_report_title, glfsf_no from glfsfmst WHERE glfsf_line_no = 0 AND glfsf_report_title IS NOT NULL AND CONVERT(varchar(20),glfsf_no) NOT IN (SELECT strDescription FROM tblFRRow)) tblA
  
		WHILE EXISTS(SELECT 1 FROM #TempOrigin)
		BEGIN
			DECLARE @ID INT
			DECLARE @TITLE NVARCHAR(MAX)
			DECLARE @res AS NVARCHAR(MAX)

			SELECT TOP 1 @ID = glfsf_no, @TITLE = RTRIM(glfsf_report_title) FROM #TempOrigin				

			EXEC [dbo].[uspFRDImportOriginDesign] @originglfsf_no = @ID, @result = @res OUTPUT
									
			INSERT tblFRImportLog (guidSessionId,strTitle,strDescription,dtmAdded, intConcurrencyId)
				SELECT @GUID, @TITLE, @res, GETDATE(), @ID

			DELETE #TempOrigin WHERE glfsf_no = @ID
		END
		
		SELECT @result = @GUID

	')

END