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

		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- DATA FIX (FROM DATAFIX SCRIPT)
		--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		
		--=====================================================================================================================================
		-- 	ROW: CORRECT ORPHAN REFNO CALC
		---------------------------------------------------------------------------------------------------------------------------------------

		UPDATE tblFRRowDesignCalculation SET intRefNoCalc = (SELECT TOP 1 intRefNo FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo)
												,intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo)
									WHERE intRowDetailRefNo IN (SELECT intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo) 
									   AND intRefNoCalc NOT IN (SELECT intRefNo FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo)


		--=====================================================================================================================================
		-- 	ROW: HIDDEN OPTION
		---------------------------------------------------------------------------------------------------------------------------------------

		UPDATE tblFRRowDesign SET ysnHidden = 0 WHERE strRowType <> ''Hidden'' AND ysnHidden IS NULL
		UPDATE tblFRRowDesign SET ysnHidden = 1 WHERE strRowType = ''Hidden'' AND ysnHidden IS NULL
		UPDATE tblFRRowDesign SET strRowType = ''Filter Accounts'' WHERE strRowType = ''Hidden''


		--=====================================================================================================================================
		-- 	COLUMN: OFFSET DATE
		---------------------------------------------------------------------------------------------------------------------------------------

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


		--=====================================================================================================================================
		-- 	ROW: DEFAULT DATA FOR ROW ACCOUNTS TYPE (strAccountsType)
		---------------------------------------------------------------------------------------------------------------------------------------

		CREATE TABLE #tempFRDGLAccount (
				[strAccountType]	NVARCHAR(MAX)
			);

		SELECT * INTO #tempFRDRowDesign FROM tblFRRowDesign WHERE strAccountsType IS NULL AND LEN(strAccountsUsed) > 3

		WHILE EXISTS(SELECT 1 FROM #tempFRDRowDesign)
			BEGIN
				DECLARE @RowDetailID INT  = (SELECT TOP 1 intRowDetailId FROM #tempFRDRowDesign)
				DECLARE @AccountsUsed NVARCHAR(MAX)  = (SELECT TOP 1 strAccountsUsed FROM #tempFRDRowDesign)
				DECLARE @queryString NVARCHAR(MAX) = ''''

				SET @queryString = ''SELECT TOP 1 strAccountType FROM vyuGLAccountView where '' + REPLACE(REPLACE(REPLACE(REPLACE(@AccountsUsed,''[ID]'',''strAccountId''),''[Group]'',''strAccountGroup''),''[Type]'',''strAccountType''),''[Description]'',''strDescription'') + '' ORDER BY strAccountId''

				BEGIN TRY
					INSERT INTO #tempFRDGLAccount
					EXEC (@queryString)
				END TRY
				BEGIN CATCH
				END CATCH;

				IF((ISNULL((SELECT TOP 1 1 FROM #tempFRDGLAccount),0) < 1) and (CHARINDEX(''strAccountGroup'',@queryString) > 0) and (CHARINDEX('' Or '',@queryString) < 1))
				BEGIN
					SET @queryString = ''SELECT TOP 1 strAccountType FROM tblGLAccountGroup where '' + REPLACE(REPLACE(REPLACE(REPLACE(@AccountsUsed,''[ID]'',''strAccountId''),''[Group]'',''strAccountGroup''),''[Type]'',''strAccountType''),''[Description]'',''strDescription'')

					BEGIN TRY
						INSERT INTO #tempFRDGLAccount
						EXEC (@queryString)
					END TRY
					BEGIN CATCH
					END CATCH;
				END
		
				IF(ISNULL((SELECT TOP 1 1 FROM #tempFRDGLAccount),0) < 1)
				BEGIN
					UPDATE tblFRRowDesign SET strAccountsType = ''BS'' WHERE intRowDetailId = @RowDetailID
				END

				WHILE EXISTS(SELECT 1 FROM #tempFRDGLAccount)
				BEGIN
					DECLARE @strAccountType NVARCHAR(MAX) = ''''
					SELECT TOP 1 @strAccountType = [strAccountType] FROM #tempFRDGLAccount

					IF(@strAccountType = ''Asset'')
					BEGIN
						UPDATE tblFRRowDesign SET strAccountsType = ''BS'' WHERE intRowDetailId = @RowDetailID
					END
					ELSE IF(@strAccountType = ''Equity'')
					BEGIN
						UPDATE tblFRRowDesign SET strAccountsType = ''BS'' WHERE intRowDetailId = @RowDetailID
					END
					ELSE IF(@strAccountType = ''Expense'')
					BEGIN
						UPDATE tblFRRowDesign SET strAccountsType = ''IS'' WHERE intRowDetailId = @RowDetailID
					END
					ELSE IF(@strAccountType = ''Liability'')
					BEGIN
						UPDATE tblFRRowDesign SET strAccountsType = ''BS'' WHERE intRowDetailId = @RowDetailID
					END
					ELSE IF(@strAccountType = ''Revenue'')
					BEGIN
						UPDATE tblFRRowDesign SET strAccountsType = ''IS'' WHERE intRowDetailId = @RowDetailID
					END
					ELSE
					BEGIN
						UPDATE tblFRRowDesign SET strAccountsType = '''' WHERE intRowDetailId = @RowDetailID
					END
			
					DELETE #tempFRDGLAccount
				END

				DELETE #tempFRDRowDesign WHERE intRowDetailId = @RowDetailID
			END
	
		DROP TABLE #tempFRDRowDesign
		DROP TABLE #tempFRDGLAccount

		--=====================================================================================================================================
		-- 	ROW: CHANGE Current Year Earnings and  Retained Earnings to  Filter Accounts
		---------------------------------------------------------------------------------------------------------------------------------------

		UPDATE tblFRRowDesign SET strRowType = ''Filter Accounts'' WHERE strRowType IN (''Current Year Earnings'',''Retained Earnings'')

		
		SELECT @result = @GUID

	')

END