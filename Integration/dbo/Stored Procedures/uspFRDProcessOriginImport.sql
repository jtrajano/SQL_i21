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

		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- GL COA VS ORIGIN CHECKING
		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
		DECLARE @intOriginReportId INT

		-- PRIMARY #1
		SET @intOriginReportId = (SELECT TOP 1 glfsf_no FROM glfsfmst 
				WHERE glfsf_grp_beg1_8 IS NOT NULL AND glfsf_grp_sub9_16 LIKE ''*%''
				AND CAST(glfsf_grp_beg1_8 as NVARCHAR(100)) NOT IN (SELECT strCode FROM tblGLAccountSegment WHERE intAccountStructureId = (SELECT intAccountStructureId FROM tblGLAccountStructure WHERE strType = ''Primary'')))

		IF (@intOriginReportId IS NOT NULL)
		BEGIN
			SET @result = (SELECT TOP 1 ''INVALID_'' + glfsf_report_title FROM glfsfmst WHERE glfsf_no = @intOriginReportId AND glfsf_report_title IS NOT NULL)
			GOTO Post_Exit;
		END

		-- PRIMARY #2
		SET @intOriginReportId = (SELECT TOP 1 glfsf_no FROM glfsfmst 
				WHERE glfsf_grp_end1_8 IS NOT NULL AND glfsf_grp_sub9_16 LIKE ''*%''
				AND CAST(glfsf_grp_end1_8 as NVARCHAR(100)) NOT IN (SELECT strCode FROM tblGLAccountSegment WHERE intAccountStructureId = (SELECT intAccountStructureId FROM tblGLAccountStructure WHERE strType = ''Primary'')))

		IF (@intOriginReportId IS NOT NULL)
		BEGIN
			SET @result = (SELECT TOP 1 ''INVALID_'' + glfsf_report_title FROM glfsfmst WHERE glfsf_no = @intOriginReportId AND glfsf_report_title IS NOT NULL)
			GOTO Post_Exit;
		END

		-- PRIMARY #3
		SET @intOriginReportId = (SELECT TOP 1 glfsf_no FROM (
		SELECT DISTINCT convert(varchar(20),glfsf_grp_beg1_8) + ''-'' + SUBSTRING(glfsf_grp_sub9_16,LEN(glfsf_grp_sub9_16) - (SELECT MAX(LEN(glact_acct9_16)) - 1 FROM glactmst),(SELECT MAX(LEN(glact_acct9_16)) FROM glactmst)) as strOriginAccountId, glfsf_no FROM glfsfmst 
				WHERE glfsf_grp_end1_8 IS NOT NULL AND glfsf_grp_sub9_16 NOT LIKE ''*%''
				) tblX WHERE strOriginAccountId COLLATE Latin1_General_CI_AS NOT IN (SELECT strAccountId FROM tblGLAccount))

		IF (@intOriginReportId IS NOT NULL)
		BEGIN
			SET @result = (SELECT TOP 1 ''INVALID_'' + glfsf_report_title FROM glfsfmst WHERE glfsf_no = @intOriginReportId AND glfsf_report_title IS NOT NULL)
			GOTO Post_Exit;
		END


		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- IMPORTING PROCESS
		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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
	

		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- 	ROW: CORRECT ORPHAN REFNO CALC
		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		UPDATE tblFRRowDesignCalculation SET intRefNoCalc = (SELECT TOP 1 intRefNo FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo)
												,intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo)
									WHERE intRowDetailRefNo IN (SELECT intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo) 
									   AND intRefNoCalc NOT IN (SELECT intRefNo FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo)


		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- 	ROW: HIDDEN OPTION
		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		UPDATE tblFRRowDesign SET ysnHidden = 0 WHERE strRowType <> ''Hidden'' AND ysnHidden IS NULL
		UPDATE tblFRRowDesign SET ysnHidden = 1 WHERE strRowType = ''Hidden'' AND ysnHidden IS NULL
		UPDATE tblFRRowDesign SET strRowType = ''Filter Accounts'' WHERE strRowType = ''Hidden''


		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- 	COLUMN: OFFSET DATE
		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		update tblFRColumn set dtmRunDate = GETDATE() WHERE dtmRunDate IS NULL

		UPDATE tblFRColumnDesign SET strStartOffset = ''Custom'', strEndOffset = ''Custom'' WHERE strFilterType = ''Custom'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''0'' WHERE strFilterType = ''As Of'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''EOY-1yr'' WHERE strFilterType = ''As Of Previous Fiscal Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''EOY'' WHERE strFilterType = ''As Of Fiscal Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''12'' WHERE strFilterType = ''As Of Next Fiscal Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''-3'' WHERE strFilterType = ''As Of Previous Quarter'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''3'' WHERE strFilterType = ''As Of Next Quarter'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''0'' WHERE strFilterType = ''As Of This Quarter'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOY-1yr'', strEndOffset = ''EOY-1yr'' WHERE strFilterType = ''Previous Fiscal Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOY'', strEndOffset = ''EOY'' WHERE strFilterType = ''Fiscal Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''12'', strEndOffset = ''12'' WHERE strFilterType = ''Next Fiscal Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''-1'' WHERE strFilterType = ''As Of Previous Month'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''0'' WHERE strFilterType = ''As Of This Month'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''1'' WHERE strFilterType = ''As Of Next Month'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''EOY-1yr'' WHERE strFilterType = ''As Of Previous Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''EOY'' WHERE strFilterType = ''As Of This Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOT'', strEndOffset = ''12'' WHERE strFilterType = ''As Of Next Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''-1'', strEndOffset = ''-1'' WHERE strFilterType = ''Previous Month'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''This Month'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''1'', strEndOffset = ''1'' WHERE strFilterType = ''Next Month'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOY-1yr'', strEndOffset = ''EOY-1yr'' WHERE strFilterType = ''Previous Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOY'', strEndOffset = ''EOY'' WHERE strFilterType = ''This Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''12'', strEndOffset = ''12'' WHERE strFilterType = ''Next Year'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOY-1yr'', strEndOffset = ''-12'' WHERE strFilterType = ''Previous Fiscal Year To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOY'', strEndOffset = ''0'' WHERE strFilterType = ''Fiscal Year To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''12'', strEndOffset = ''12'' WHERE strFilterType = ''Next Fiscal Year To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''-12'', strEndOffset = ''-12'' WHERE strFilterType = ''Previous Year Quarter To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''Quarter To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''12'', strEndOffset = ''12'' WHERE strFilterType = ''Next Year Quarter To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOY-1yr'', strEndOffset = ''-12'' WHERE strFilterType = ''Previous Year To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''BOY'', strEndOffset = ''0'' WHERE strFilterType = ''Year To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''12'', strEndOffset = ''12'' WHERE strFilterType = ''Next Year To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''-12'', strEndOffset = ''-12'' WHERE strFilterType = ''Previous Year Month To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''Month To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''12'', strEndOffset = ''12'' WHERE strFilterType = ''Next Year Month To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''As Of Previous Period'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''As Of This Period'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''As Of Next Period'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''Previous Period'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''This Period'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''Next Period'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''Previous Year Period To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''Period To Date'' AND strStartOffset IS NULL
		UPDATE tblFRColumnDesign SET strStartOffset = ''0'', strEndOffset = ''0'' WHERE strFilterType = ''Next Year Period To Date'' AND strStartOffset IS NULL
		 

		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- 	ROW: CHANGE Current Year Earnings and  Retained Earnings to  Filter Accounts
		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		UPDATE tblFRRowDesign SET strRowType = ''Filter Accounts'' WHERE strRowType IN (''Current Year Earnings'',''Retained Earnings'')
						
		
		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- 	FINALIZING STAGE
		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		SELECT @result = @GUID

		Post_Exit:


	')

END