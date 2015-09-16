GO
IF (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U')) = 1 AND (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glfsfmst]') AND type IN (N'U')) = 1
BEGIN 

	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspFRDImportOriginDesign'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspFRDImportOriginDesign];
	')

	EXEC('
		CREATE PROCEDURE [dbo].[uspFRDImportOriginDesign]
			@originglfsf_no VARCHAR (40),
			@result			NVARCHAR(MAX) = '''' OUTPUT
	
		AS

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON

		BEGIN TRY
		BEGIN TRANSACTION;

		--=====================================================================================================================================
		-- 	DECLARE TEMPORARY TABLES
		---------------------------------------------------------------------------------------------------------------------------------------
		CREATE TABLE #irelyloaddesigncalc(
			[intRowId] [int] NOT NULL,
			[intRefNoId] [int] NOT NULL,
			[intRefNoCalc] [int] NULL,
			[strAction] [nchar](10) NULL,
			[intSort] [int] NULL,
			[introwdetailiddet] [int] NULL
		) ON [PRIMARY]
		CREATE TABLE #irelyloadFRRowDesign(
			[intRowDetailId] [int] IDENTITY(1,1) NOT NULL,
			[intRowId] [int] NOT NULL,
			[intRefNo] [int] NOT NULL,
			[strDescription] [nvarchar](250) NULL,
			[strRowType] [nvarchar](50) NULL,
			[strBalanceSide] [nvarchar](10) NULL,
			[strRelatedRows] [nvarchar](max) NULL,
			[strAccountsUsed] [nvarchar](max) NULL,
			[ysnShowCredit] [bit] NULL,
			[ysnShowDebit] [bit] NULL,
			[ysnShowOthers] [bit] NULL,
			[ysnLinktoGL] [bit] NULL,
			[dblHeight] [numeric](18, 6) NULL,
			[strFontName] [nchar](35) NULL,
			[strFontStyle] [nchar](20) NULL,
			[strFontColor] [nchar](20) NULL,
			[intFontSize] [int] NULL,
			[strOverrideFormatMask] [nvarchar](100) NULL,
			[ysnForceReversedExpense] [bit] NULL,
			[intSort] [int] NULL,
			[intConcurrencyId] [int] NOT NULL,
			[glfsf_action_type] [varchar](50) NULL,
			[glfsf_action_crl] [varchar](50) NULL,			
			[glfsf_tot_no] [int] NULL,
			[full_account] [varchar](50) NULL,
			[glfsf_grp_printall_yn] [nchar](10) NULL,
			[full_account_end] [varchar](50) NULL,
			[rowidupdated] [int] NULL,
			[isprimary] [varchar](50) NULL,
			[acct9_16] [varchar](50) NULL,
			[glfsf_no] [varchar](50) NULL,
			[glfsf_line_no] [varchar](50) NULL,
			[acct1_8] [varchar](50) NULL,
			[acct1_8end] [varchar](50) NULL,
			[acct9_16end] [varchar](50) NULL,
			CONSTRAINT [PK_irelyloadFRRowDesign_1] PRIMARY KEY CLUSTERED 
			(
				[intRowDetailId] ASC,
				[intRowId] ASC,
				[intRefNo] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]


		--=====================================================================================================================================
		-- 	CREATING HEADER
		---------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @hdr VARCHAR(10)
		DECLARE @introwiddet INT
		DECLARE @insertload VARCHAR(max)
		DECLARE @glfsf_stmt_type VARCHAR(50)
		DECLARE @@glfsf_no_to_convert VARCHAR(50)
		DECLARE @segmentLength INT = 1

		SET @result = ''Successful''
		SELECT @hdr= ''''''''+''HDR''+''''''''
		SELECT @@glfsf_no_to_convert = @originglfsf_no				--strDescription = @glfsf_no_to_convert

		SET @segmentLength = (select SUM(intLength) from tblGLAccountStructure where strType = ''Segment'')

		INSERT tblFRRow (strRowName,strDescription,intMapId,intConcurrencyId)
			SELECT DISTINCT (RTRIM(glfsf_report_title) + '' - '' + CONVERT(NVARCHAR(100),GETDATE(),9)) AS newTitle, glfsf_no, NULL, 1 FROM glfsfmst
				WHERE glfsf_line_no = 0 
				  AND glfsf_report_title IS NOT NULL
				  AND glfsf_no = @@glfsf_no_to_convert
				  AND CONVERT(varchar(20),glfsf_no) NOT IN (SELECT strDescription FROM tblFRRow)

		SELECT @introwiddet = intRowId FROM tblFRRow WHERE strDescription = @@glfsf_no_to_convert
		SELECT @glfsf_stmt_type = (select TOP 1 glfsf_stmt_type from glfsfmst where glfsf_no = @@glfsf_no_to_convert and glfsf_stmt_type IS NOT NULL group by glfsf_stmt_type)


		--=====================================================================================================================================
		-- 	BUILDING DETAILS
		---------------------------------------------------------------------------------------------------------------------------------------
		IF EXISTS(SELECT TOP 1 1 FROM glfsfmst INNER JOIN tblFRRow on tblFRRow.strDescription = CONVERT(VARCHAR(10),glfsfmst.glfsf_no) WHERE tblFRRow.intRowId NOT IN (SELECT intRowId FROM tblFRRowDesign))
		BEGIN
			INSERT #irelyloadFRRowDesign
			(	
				intRowId, intRefNo, strDescription, strRowType, strBalanceSide, strRelatedRows, strAccountsUsed, ysnShowCredit,
				ysnShowDebit, ysnShowOthers, ysnLinktoGL, dblHeight, strFontName, strFontStyle, strFontColor, intFontSize,
				strOverrideFormatMask, ysnForceReversedExpense, intSort, intConcurrencyId, glfsf_action_type, glfsf_action_crl, glfsf_tot_no, full_account, glfsf_grp_printall_yn,
				full_account_end, isprimary, acct9_16, glfsf_no, glfsf_line_no, acct1_8, acct1_8end, acct9_16end
			)
			SELECT
				tblFRRow.intRowId AS intRowId,
				glfsfmst.glfsf_line_no AS intRefNo,
				ISNULL(CONVERT(VARCHAR(50),glfsf_dsc_description) ,
					ISNULL(CONVERT(VARCHAR(50),glfsf_hdr_description),
					ISNULL(CONVERT(VARCHAR(50),glfsf_ftr_description),
					ISNULL(CONVERT(VARCHAR(50),glfsf_gra_desc),
					ISNULL(CONVERT(VARCHAR(50),glfsf_grp_desc),
					ISNULL(CONVERT(VARCHAR(50),glfsf_grp_indent_desc),
					ISNULL(CONVERT(VARCHAR(50),glfsf_aca_desc),
					ISNULL(CONVERT(VARCHAR(50),glfsf_acp_desc),
					ISNULL(CONVERT(VARCHAR(50),glfsf_prnt_desc),
					ISNULL(CONVERT(VARCHAR(50),glfsf_tot_desc),
					ISNULL(CONVERT(VARCHAR(50),glfsf_dsc_description),
					ISNULL(CONVERT(VARCHAR(50),glfsf_aca_desc),NULL)))))))))))) AS strDescription,
				CASE 
					WHEN glfsf_action_type=''HDR'' AND glfsf_action_crl =''C'' THEN ''Row Name - Center Align''
					WHEN glfsf_action_type=''HDR'' AND glfsf_action_crl =''L'' THEN ''Row Name - Left Align''
					WHEN glfsf_action_type=''HDR'' AND glfsf_action_crl =''R'' THEN ''Row Name - Right Align''
					WHEN glfsf_action_type=''DSC'' AND glfsf_action_crl =''C'' THEN ''Row Name - Center Align''
					WHEN glfsf_action_type=''DSC'' AND glfsf_action_crl =''L'' THEN ''Row Name - Left Align''
					WHEN glfsf_action_type=''DSC'' AND glfsf_action_crl =''R'' THEN ''Row Name - Right Align''
					WHEN glfsf_action_type=''ACA'' THEN ''Hidden''
					WHEN glfsf_action_type=''NET'' THEN ''Hidden''
					WHEN glfsf_action_type=''ACP'' AND glfsf_action_crl =''E'' THEN ''Filter Accounts''
					WHEN glfsf_action_type=''GRP'' AND glfsf_action_crl =''E'' AND glfsf_grp_printall_yn=''N'' THEN ''Filter Accounts''
					WHEN glfsf_action_type=''GRP'' AND glfsf_action_crl =''E'' AND glfsf_grp_printall_yn=''Y'' THEN ''Filter Accounts''
					WHEN glfsf_action_type=''GRP'' AND glfsf_action_crl =''A'' THEN ''Filter Accounts''
					WHEN glfsf_action_type=''GRP'' AND glfsf_action_crl =''F'' THEN ''Filter Accounts''
					WHEN glfsf_action_type=''GRP'' AND glfsf_action_crl =''L'' THEN ''Filter Accounts''
					WHEN glfsf_action_type=''BLN'' AND glfsf_action_crl =''K'' THEN ''None''
					WHEN glfsf_action_type=''PRN'' AND glfsf_action_crl =''T'' THEN ''Row Calculation''
					WHEN glfsf_action_type=''GRA'' AND glfsf_action_crl =''E'' THEN ''Hidden''
					WHEN glfsf_action_type=''GRA'' AND glfsf_action_crl =''A'' THEN ''Hidden''
					WHEN glfsf_action_type=''GRA'' AND glfsf_action_crl =''F'' THEN ''Hidden''
					WHEN glfsf_action_type=''GRA'' AND glfsf_action_crl =''L'' THEN ''Hidden''
					WHEN glfsf_action_type=''PAG'' THEN ''Page Break''
					WHEN glfsf_action_type=''TOT'' THEN ''Row Calculation''
					WHEN glfsf_action_type=''DL'' THEN ''Double Underscore''
					WHEN glfsf_action_type=''BLN'' THEN ''None''
					WHEN glfsf_action_type=''UL'' THEN ''Underscore''
					WHEN glfsf_action_type=''LGN'' THEN ''Column Name''
					ELSE NULL END AS strRowType,
				CASE 
					WHEN glfsf_action_type=''NET'' THEN ''Credit''
					ELSE
						ISNULL(glfsf_grp_dc,
							ISNULL(glfsf_grp_var_dc,
							ISNULL(glfsf_acp_dc,
							ISNULL(glfsf_acp_var_dc,
							ISNULL(glfsf_grp_dc,
							ISNULL(glfsf_prnt_dcr,
							ISNULL(glfsf_prnt_var_dc,
							ISNULL(glfsf_accm_dc,
							ISNULL(glfsf_tot_dc,
							ISNULL(glfsf_tot_var_dc,NULL))))))))))
					END AS strBalanceSide,
				NULL AS strRelatedRows,
				'''' AS strAccountsUsed,
				0 AS ysnShowCredit,
				0 AS ysnShowDebit,
				1 AS ysnShowOthers,
				0 AS ysnLinktoGL,
				3.000000 dblHeight,
				''Arial'' AS strFontName,
				''Normal'' AS strFontStyle,
				''Black'' AS strFontColor,
				8 AS intFontSize,
				'''' AS strOverrideFormatMask,
				0 AS ysnForceReversedExpense,
				1 AS intSort,
				1 AS intConcurrencyId,
				glfsf_action_type,
				glfsf_action_crl,
				glfsf_tot_no,
				'''',													--full account
				glfsf_grp_printall_yn,
				CASE											--FULL ACCOUNT END
					WHEN glfsf_action_type=''GRA'' THEN 
								CASE												
									WHEN glfsf_gra_sub9_16 LIKE ''%*%'' THEN CONVERT(VARCHAR(8), glfsf_gra_end1_8) + ''-'' + RIGHT(CONVERT(VARCHAR(8),''99999999''),@segmentLength)
									ELSE CONVERT(VARCHAR(8),glfsf_gra_end1_8) + ''-'' + RIGHT(CONVERT(VARCHAR(8),glfsf_gra_sub9_16),@segmentLength)
								END
					WHEN glfsf_action_type=''GRP'' THEN 
								CASE
									WHEN glfsf_grp_sub9_16 LIKE ''%*%'' THEN CONVERT(VARCHAR(8), glfsf_grp_end1_8) + ''-'' + RIGHT(CONVERT(VARCHAR(8),''99999999''),@segmentLength)
									ELSE CONVERT(VARCHAR(8),glfsf_grp_end1_8) + ''-'' + RIGHT(CONVERT(VARCHAR(8),glfsf_grp_sub9_16),@segmentLength)
								END
					WHEN glfsf_action_type=''ACA'' THEN 
								CONVERT(VARCHAR(8),glfsf_aca1_8) + ''-'' + RIGHT(CONVERT(VARCHAR(8),glfsf_aca9_16),@segmentLength)
					WHEN glfsf_action_type=''ACP'' THEN 
								CONVERT(VARCHAR(8),glfsf_acp1_8) + ''-'' + RIGHT(CONVERT(VARCHAR(8),glfsf_acp9_16),@segmentLength)
					END,
				CASE 
					WHEN glfsf_gra_sub9_16 like ''%*%'' THEN ''YES''
					WHEN glfsf_grp_sub9_16 like ''%*%'' THEN ''YES''
					WHEN glfsf_aca9_16 like ''%*%'' THEN ''YES''
					WHEN glfsf_acp9_16 like ''%*%'' THEN ''YES''
					ELSE ''NO''
					END,
				ISNULL(RTRIM(''00000000'' + glfsf_grp_sub9_16),
					ISNULL(RTRIM(''00000000'' + glfsf_gra_sub9_16),
					ISNULL(RTRIM(''00000000'' + glfsf_grp_sub9_16),
					ISNULL(RTRIM(''00000000'' + glfsf_aca9_16),
					ISNULL(RTRIM(''00000000'' + glfsf_acp9_16),
					ISNULL(RTRIM(''00000000'' + glfsf_net_sub9_16),''00000000'')))))),
				glfsf_no,
				glfsf_line_no,
				ISNULL(RTRIM(''00000000'' + glfsf_gra_beg1_8),		--1 to 8 beginning for building 
					ISNULL(RTRIM(''00000000'' + glfsf_grp_beg1_8),	--
					ISNULL(RTRIM(''00000000'' + glfsf_aca1_8),
					ISNULL(RTRIM(''00000000'' + glfsf_acp1_8),''00000000'')))),
				CASE												--1 to 8 end for ranges
					WHEN glfsf_action_type=''GRA'' THEN
						CONVERT(varchar(8),RTRIM(glfsf_gra_end1_8))
					WHEN glfsf_action_type=''GRP'' THEN
						CONVERT(varchar(8),RTRIM(glfsf_grp_end1_8))
					WHEN glfsf_action_type=''ACA'' THEN
						CONVERT(varchar(8),RTRIM(glfsf_aca1_8))
					WHEN glfsf_action_type=''ACP'' THEN
						CONVERT(varchar(8),RTRIM(glfsf_acp1_8))
					END,
				CASE												--9 to 16 end for ranges
					WHEN glfsf_action_type=''GRA'' THEN
						CASE
							WHEN glfsf_gra_sub9_16 LIKE ''%*%'' THEN CONVERT(VARCHAR(8),''99999999'')
							ELSE CONVERT(varchar(8),ISNULL(RTRIM(glfsf_gra_sub9_16),''0''))
						END
					WHEN glfsf_action_type=''GRP'' THEN
						CASE
							WHEN glfsf_grp_sub9_16 LIKE ''%*%'' THEN CONVERT(VARCHAR(8),''99999999'')
							ELSE CONVERT(varchar(8),ISNULL(RTRIM(glfsf_grp_sub9_16),''0''))
						END
					WHEN glfsf_action_type=''ACA'' THEN
						CONVERT(varchar(8),ISNULL(RTRIM(glfsf_aca9_16),''0''))
					WHEN glfsf_action_type=''ACP'' THEN
						CONVERT(varchar(8),ISNULL(RTRIM(glfsf_acp9_16),''0''))
					END

				FROM glfsfmst 
					INNER JOIN tblFRRow on tblFRRow.strDescription = CONVERT(VARCHAR(12),glfsfmst.glfsf_no)
						WHERE tblFRRow.intRowId NOT IN (SELECT intRowId FROM tblFRRowDesign)
								AND glfsf_action_type <> ''ACC''

			DECLARE @1_8size VARCHAR (10)
			DECLARE @9_16size VARCHAR (10)
			DECLARE @SQL VARCHAR(MAX)

			SELECT @1_8size = (SELECT MAX(LEN(glact_acct1_8)) FROM glactmst)		--SELECT * FROM glactmst
			SELECT @9_16size = (SELECT MAX(LEN(glact_acct9_16)) FROM glactmst)		--SELECT * FROM glactmst
			SELECT @SQL = ''update #irelyloadFRRowDesign set full_account=right('' + '''''''' + ''00000000'' + '''''''' + ''+acct1_8,'' + @1_8size + '')+'' + '''''''' + ''-'' + '''''''' + ''+right('' + '''''''' + ''00000000'' + '''''''' + ''+acct9_16,'' + @9_16size + '')''

			--SELECT @SQL --debug
			EXEC (@SQL)
			
			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			--								ACP / ACA / NET
			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

			SELECT @SQL= ''update #irelyloadFRRowDesign set strAccountsUsed='' + '''''''' + '' [ID] = '' + '''''''' + ''+'' +
							+ '''''''' + '''''''' + '''''''' + '''''''' + ''+'' + ''convert (varchar('' + @1_8size + ''),acct1_8) +'' + '''''''' + ''-'' + '''''''' + ''+ CASE WHEN LEN(acct9_16) = 1 THEN replicate(''''0'''',('' + @9_16size + '')-1)+acct9_16 ELSE convert (varchar('' + @9_16size + ''),acct9_16) END '' + ''+'' + '''''''' + '''''''' + '''''''' + '''''''' + 
							''WHERE glfsf_action_type in ('' + '''''''' + ''ACP'' + '''''''' + '','' + '''''''' + ''ACA'' + '''''''' + '')''
			--SELECT @SQL --debug
			EXEC (@SQL)

			SELECT @SQL= ''update #irelyloadFRRowDesign set strAccountsUsed='' + '''''''' + '' [Primary Account] = '' 
							+ '''''''' + ''+ convert (varchar('' + @1_8size + ''),acct1_8) ''
							+ ''WHERE glfsf_action_type='' + '''''''' + ''ACP'' + '''''''' + '' and acct9_16 like '' + '''''''' + ''%*%'' + ''''''''
			--SELECT @SQL --debug
			EXEC (@SQL)

			SELECT @SQL= ''update #irelyloadFRRowDesign set strAccountsUsed='' + '''''''' + ''[ID] Between '' + '''''''''''''''' + ''+'' + ''convert (varchar('' + @1_8size + ''),acct1_8)+ '' + '''''''' + ''-'' + '''''''' 
							+ ''+convert (varchar('' + @9_16size + ''),acct9_16) +'' + '''''''''''''''' + '' AND '' + '''''''''''''''' 
							+ ''+convert (varchar('' + @1_8size + ''),acct1_8end)+'' + '''''''' + ''-'' + '''''''' 
							+ ''+convert (varchar('' + @9_16size + ''),acct9_16) '' + '' + ''''''''''''''''''
							+ '' WHERE glfsf_action_type='' + '''''''' + ''ACA'' + '''''''' + '' AND acct9_16 like '' + '''''''' + ''%*%'' + ''''''''
			--SELECT @SQL --debug
			exec (@SQL)

			SELECT @SQL= ''update #irelyloadFRRowDesign set strAccountsUsed='' + '''''''' + '' [Type] = '' + '''''''''''' + ''Revenue'' + '''''''''''' + '' Or [Type] = '' + '''''''''''' + ''Expense'' + ''''''''''''''''
							+ '' WHERE glfsf_action_type='' + '''''''' + ''NET'' + ''''''''
			--SELECT @SQL --debug
			EXEC (@SQL)


			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			--									GRP / GRA
			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			SELECT @SQL= ''update #irelyloadFRRowDesign set strAccountsUsed='' + '''''''' + ''[Primary Account] Between '' 
							+ '''''''''''''''' + ''+'' + ''convert (varchar('' + @1_8size + ''),acct1_8)+ '' + '''''''''''''''' + '' AND ''
							+ '''''''''''''''' + ''+ convert (varchar('' + @1_8size + ''),acct1_8end)'' + '' + ''''''''''''''''''
							+ '' WHERE glfsf_action_type in ('' + '''''''' + ''GRP'' + '''''''' + '','' + '''''''' + ''GRA'' + '''''''' + '')'' + '' AND acct9_16 like '' + '''''''' + ''%*%'' + ''''''''			
			--SELECT @SQL --debug
			EXEC (@SQL)

			SELECT @SQL= ''update #irelyloadFRRowDesign set strAccountsUsed='' + '''''''' + ''[ID] Between '' + '''''''''''''''' + ''+'' + ''convert (varchar('' + @1_8size + ''),acct1_8)+ '' + '''''''' + ''-'' + '''''''' 
							+ ''+convert (varchar('' + @9_16size + ''),acct9_16) +'' + '''''''''''''''' + '' AND '' + '''''''''''''''' 
							+ ''+convert (varchar('' + @1_8size + ''),acct1_8end)+'' + '''''''' + ''-'' + '''''''' 
							+ ''+convert (varchar('' + @9_16size + ''),acct9_16) '' + '' + ''''''''''''''''''
							+ '' WHERE glfsf_action_type in ('' + '''''''' + ''GRP'' + '''''''' + '','' + '''''''' + ''GRA'' + '''''''' + '')'' + '' AND acct9_16 not like '' + '''''''' + ''%*%'' + ''''''''
			--SELECT @SQL --debug
			EXEC (@SQL)

			SELECT @SQL= ''update #irelyloadFRRowDesign set strAccountsUsed='' + '''''''' + '' [ID] = '' + '''''''''''''''' + ''+'' + ''full_account+ '' + '''''''''''''''''''' + 
							+ '' WHERE glfsf_action_type in ('' + '''''''' + ''GRP'' + '''''''' + '','' + '''''''' + ''GRA'' + '''''''' + '')'' + '' AND acct9_16 not like '' + '''''''' + ''%*%'' + '''''''' + '' AND '' +		
							+ '''''''''''' + ''+'' + ''convert (varchar('' + @1_8size + ''),acct1_8)+ '' + '''''''''''' + '' = ''
							+ '''''''''''' + ''+ convert (varchar('' + @1_8size + ''),acct1_8end)+ '' +  ''''''''''''							

			--SELECT @SQL --debug
			EXEC (@SQL)  


			--=====================================================================================================================================
			-- 	BUILDING DETAILS 2
			---------------------------------------------------------------------------------------------------------------------------------------
			--DECLARE @min1 int = 0
			--DECLARE @min1old int = 0
			--DECLARE @min1acct VARCHAR(20)
			--DECLARE @max1acct VARCHAR (20)
			--DECLARE @min1acctold VARCHAR(20) = ''0''
			--DECLARE @acct9_16 VARCHAR (10)

			--WHILE EXISTS (SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE glfsf_action_type = ''GRP'' AND glfsf_grp_printall_yn = ''Y'' AND intRowDetailId > @min1old)
			--BEGIN
			--	SELECT @min1=min(intRowDetailId) FROM #irelyloadFRRowDesign WHERE intRowDetailId > @min1old AND glfsf_action_type = ''GRP'' AND glfsf_grp_printall_yn = ''Y''

			--	SELECT @min1acct = full_account, 
			--		   @max1acct = full_account_end, 
			--		   @min1acctold=full_account, 
			--		   @acct9_16=acct9_16
			--	FROM #irelyloadFRRowDesign WHERE intRowDetailId = @min1
				
			--	WHILE @min1acct <= @max1acct
			--	BEGIN
			--		INSERT #irelyloadFRRowDesign
			--		(
			--			intRowId, intRefNo, strDescription, strRowType, strBalanceSide, strRelatedRows, strAccountsUsed, ysnShowCredit,
			--			ysnShowDebit, ysnShowOthers, ysnLinktoGL, dblHeight, strFontName, strFontStyle, strFontColor, intFontSize,
			--			strOverrideFormatMask, ysnForceReversedExpense, intSort, intConcurrencyId, glfsf_action_type, glfsf_tot_no, full_account, glfsf_grp_printall_yn,
			--			full_account_end, isprimary, acct9_16, glfsf_no, glfsf_line_no, acct1_8, acct1_8end, acct9_16end
			--		)
			--		SELECT 
			--			intRowId, intRefNo-.5, '''', ''Filter Accounts'', strBalanceSide, strRelatedRows, '' [ID] = '' + '''''''' + @min1acct + '''''''', ysnShowCredit,
			--			ysnShowDebit, ysnShowOthers, ysnLinktoGL, dblHeight, strFontName, strFontStyle, strFontColor, intFontSize,
			--			strOverrideFormatMask, ysnForceReversedExpense, intSort, intConcurrencyId, ''ACP'', glfsf_tot_no, @min1acct, ''N'',
			--			full_account_end, isprimary, acct9_16, glfsf_no, glfsf_line_no, acct1_8, acct1_8end, acct9_16end
			--		FROM #irelyloadFRRowDesign WHERE intRowDetailId = @min1

			--		SELECT @min1acctold = @min1acct

			--		IF @acct9_16 LIKE ''%*%''
			--		BEGIN
			--			SELECT @min1acct = MIN(strAccountId) FROM tblGLAccount WHERE strAccountId > @min1acctold
			--		END
			--		IF @acct9_16 NOT LIKE ''%*%''
			--		BEGIN
			--			SELECT @min1acct = MIN(strAccountId) FROM tblGLAccount WHERE strAccountId > @min1acctold AND SUBSTRING(strAccountId,7,4) = RIGHT(@acct9_16,4)	--- Account Replace		
			--		END
			--	END

			--SELECT @min1old = @min1

			--END

			UPDATE #irelyloadFRRowDesign SET rowidupdated = -1

			DECLARE @ROW INT = 0
			DECLARE @INTROWIDMOVER INT = 0
			DECLARE @rownumber INT
			DECLARE @intrefno1 INT

			WHILE EXISTS (SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE rowidupdated = -1)
			BEGIN
				SELECT @rownumber = MIN(intRowId) FROM #irelyloadFRRowDesign WHERE rowidupdated = -1

				WHILE EXISTS (SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE rowidupdated = -1 AND intRowId = @rownumber)
				BEGIN
					SELECT @intrefno1 = MIN(intRefNo) FROM #irelyloadFRRowDesign WHERE intRowId = @rownumber AND rowidupdated = -1
					SELECT @INTROWIDMOVER = MIN(intRowDetailId) FROM #irelyloadFRRowDesign WHERE rowidupdated = -1 AND intRowId = @rownumber AND @intrefno1 = intRefNo

				UPDATE #irelyloadFRRowDesign SET intRefNo = @ROW, rowidupdated = 1 WHERE intRowDetailId = @INTROWIDMOVER
				SELECT @ROW = @ROW + 1
				END
			END

			SELECT * into #irely FROM #irelyloadFRRowDesign ORDER BY intRowId, intRefNo
			DELETE FROM #irelyloadFRRowDesign

			INSERT #irelyloadFRRowDesign
			(
				intRowId, intRefNo, strDescription, strRowType, strBalanceSide, strRelatedRows, strAccountsUsed, ysnShowCredit,
				ysnShowDebit, ysnShowOthers, ysnLinktoGL, dblHeight, strFontName, strFontStyle, strFontColor, intFontSize,
				strOverrideFormatMask, ysnForceReversedExpense, intSort, intConcurrencyId, glfsf_action_type, glfsf_tot_no, full_account, glfsf_grp_printall_yn,
				full_account_end, isprimary, acct9_16, glfsf_no, glfsf_line_no, acct1_8, acct1_8end, acct9_16end
			)
			SELECT 
				intRowId, intRefNo, strDescription, strRowType, strBalanceSide, strRelatedRows, strAccountsUsed, ysnShowCredit,
				ysnShowDebit, ysnShowOthers, ysnLinktoGL, dblHeight, strFontName, strFontStyle, strFontColor, intFontSize,
				strOverrideFormatMask, ysnForceReversedExpense, intSort, intConcurrencyId, glfsf_action_type, glfsf_tot_no, full_account, glfsf_grp_printall_yn,
				full_account_end, isprimary, acct9_16, glfsf_no, glfsf_line_no, acct1_8, acct1_8end, acct9_16end 
			FROM #irely ORDER BY intRowId, intRefNo

			UPDATE #irelyloadFRRowDesign SET #irelyloadFRRowDesign.strDescription = tblGLAccount.strDescription
					FROM #irelyloadFRRowDesign INNER JOIN tblGLAccount ON #irelyloadFRRowDesign.full_account = tblGLAccount.strAccountId COLLATE SQL_Latin1_General_CP1_CS_AS
						WHERE #irelyloadFRRowDesign.strDescription IS NULL OR #irelyloadFRRowDesign.strDescription = ''''

			UPDATE #irelyloadFRRowDesign 
					SET #irelyloadFRRowDesign.strBalanceSide = 
						CASE 
							WHEN tblGLAccountGroup.strAccountType = ''Asset'' THEN ''Debit''
							WHEN tblGLAccountGroup.strAccountType = ''Equity'' THEN ''Credit''
							WHEN tblGLAccountGroup.strAccountType = ''Expense'' THEN ''Debit''
							WHEN tblGLAccountGroup.strAccountType = ''Liability'' THEN ''Credit''
							WHEN tblGLAccountGroup.strAccountType = ''Revenue'' THEN ''Credit''
							WHEN tblGLAccountGroup.strAccountType = ''Sales'' THEN ''Credit''
							WHEN tblGLAccountGroup.strAccountType = ''Cost of Goods Sold'' THEN ''Debit''
							ELSE NULL
						END
			FROM #irelyloadFRRowDesign 
				INNER JOIN tblGLAccount
					ON #irelyloadFRRowDesign.full_account = tblGLAccount.strAccountId COLLATE SQL_Latin1_General_CP1_CS_AS
				INNER JOIN tblGLAccountGroup 
					ON tblGLAccount.intAccountGroupId = tblGLAccountGroup.intAccountGroupId
			WHERE #irelyloadFRRowDesign.strBalanceSide IS NULL
		
			UPDATE #irelyloadFRRowDesign
					SET #irelyloadFRRowDesign.strBalanceSide = 
					CASE 
						WHEN tblGLAccountGroup.strAccountType = ''Asset'' THEN ''Debit''
						WHEN tblGLAccountGroup.strAccountType = ''Equity'' THEN ''Credit''
						WHEN tblGLAccountGroup.strAccountType = ''Expense'' THEN ''Debit''
						WHEN tblGLAccountGroup.strAccountType = ''Liability'' THEN ''Credit''
						WHEN tblGLAccountGroup.strAccountType = ''Revenue'' THEN ''Credit''
						WHEN tblGLAccountGroup.strAccountType = ''Sales'' THEN ''Credit''
						WHEN tblGLAccountGroup.strAccountType = ''Cost of Goods Sold'' THEN ''Debit''
						ELSE NULL
					END
			FROM #irelyloadFRRowDesign 
				INNER JOIN tblGLAccountSegment
					ON SUBSTRING(#irelyloadFRRowDesign.full_account,1,CONVERT(INT,@1_8size)) = tblGLAccountSegment.strCode COLLATE SQL_Latin1_General_CP1_CS_AS
				INNER JOIN tblGLAccountGroup 
					ON tblGLAccountSegment.intAccountGroupId = tblGLAccountGroup.intAccountGroupId
			WHERE #irelyloadFRRowDesign.strBalanceSide IS NULL

			UPDATE #irelyloadFRRowDesign
					SET #irelyloadFRRowDesign.strBalanceSide = 
					CASE 
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.acct1_8 AND vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.acct1_8end) = ''Asset'' THEN ''Debit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.acct1_8 AND vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.acct1_8end) = ''Equity'' THEN ''Credit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.acct1_8 AND vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.acct1_8end) = ''Expense'' THEN ''Debit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.acct1_8 AND vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.acct1_8end) = ''Liability'' THEN ''Credit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.acct1_8 AND vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.acct1_8end) = ''Revenue'' THEN ''Credit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.acct1_8 AND vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.acct1_8end) = ''Sales'' THEN ''Credit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.acct1_8 AND vyuGLAccountView.[Primary Account] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.acct1_8end) = ''Cost of Goods Sold'' THEN ''Debit''
						ELSE NULL
					END
			FROM #irelyloadFRRowDesign 
			WHERE #irelyloadFRRowDesign.strBalanceSide IS NULL AND #irelyloadFRRowDesign.isprimary = ''YES''

			UPDATE #irelyloadFRRowDesign
					SET #irelyloadFRRowDesign.strBalanceSide = 
					CASE 
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.full_account AND vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.full_account_end) = ''Asset'' THEN ''Debit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.full_account AND vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.full_account_end) = ''Equity'' THEN ''Credit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.full_account AND vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.full_account_end) = ''Expense'' THEN ''Debit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.full_account AND vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.full_account_end) = ''Liability'' THEN ''Credit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.full_account AND vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.full_account_end) = ''Revenue'' THEN ''Credit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.full_account AND vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.full_account_end) = ''Sales'' THEN ''Credit''
						WHEN (SELECT TOP 1 strAccountType FROM vyuGLAccountView WHERE vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS >= #irelyloadFRRowDesign.full_account AND vyuGLAccountView.[strAccountId] COLLATE SQL_Latin1_General_CP1_CS_AS <= #irelyloadFRRowDesign.full_account_end) = ''Cost of Goods Sold'' THEN ''Debit''
						ELSE NULL
					END
			FROM #irelyloadFRRowDesign 
			WHERE #irelyloadFRRowDesign.strBalanceSide IS NULL AND #irelyloadFRRowDesign.isprimary = ''NO''

			UPDATE #irelyloadFRRowDesign SET strDescription = ''none'' WHERE strDescription IS NULL AND strRowType IN (''Hidden'',''Row Calculation'',''Filter Accounts'')
			UPDATE #irelyloadFRRowDesign SET strBalanceSide = ''Debit'' WHERE strBalanceSide = ''D''
			UPDATE #irelyloadFRRowDesign SET strBalanceSide = ''Credit'' WHERE strBalanceSide = ''C''			

			--=====================================================================================================================================
			-- 	BUILDING DETAILS 3
			---------------------------------------------------------------------------------------------------------------------------------------
			DECLARE @chase INT = (SELECT MAX(intRowDetailId) FROM #irelyloadFRRowDesign)	
			DECLARE @current INT = 1

			WHILE @current < (@chase + 2)
			BEGIN
				IF (SELECT glfsf_action_type FROM #irelyloadFRRowDesign WHERE intRowDetailId = @current) = ''PRN''
				BEGIN
					IF (SELECT glfsf_action_type FROM #irelyloadFRRowDesign WHERE intRowDetailId = (@current-1)) = ''DL''
					BEGIN
						DELETE FROM #irelyloadFRRowDesign WHERE intRowDetailId = @current
						DELETE FROM #irelyloadFRRowDesign WHERE intRowDetailId = @current
					END
				END
				IF (SELECT glfsf_action_type FROM #irelyloadFRRowDesign WHERE intRowDetailId = @current) = ''PRN''
				BEGIN
					IF (SELECT glfsf_action_type FROM #irelyloadFRRowDesign WHERE intRowDetailId = (@current-1)) = ''GRP''
					BEGIN
						DELETE FROM #irelyloadFRRowDesign WHERE intRowDetailId = @current
						DELETE FROM #irelyloadFRRowDesign WHERE intRowDetailId = @current
					END
				END
				SELECT @current = (@current + 1)
			END

			--=====================================================================================================================================
			-- 	BUILDING DETAILS 4
			---------------------------------------------------------------------------------------------------------------------------------------
			DECLARE @net INT
			--WHILE EXISTS (SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE glfsf_action_type = ''NET'')
			--BEGIN
			--	SELECT @net = MIN(intRowDetailId) FROM #irelyloadFRRowDesign WHERE glfsf_action_type = ''NET''
			--	DELETE FROM #irelyloadFRRowDesign WHERE intRowDetailId = @net
			--	DELETE FROM #irelyloadFRRowDesign WHERE intRowDetailId = (@net + 1)
			--END
	
			--=====================================================================================================================================
			-- 	BUILDING DETAILS 5
			---------------------------------------------------------------------------------------------------------------------------------------
			DECLARE @min INT
			DECLARE @minprior INT = 0
			DECLARE @change INT
			DECLARE @intrefno INT
			DECLARE @increment INT
			DECLARE @introwdetailidint INT 
			DECLARE @rowcurr INT 
			DECLARE @strBalanceSide VARCHAR(50)
			DECLARE @TotalSide VARCHAR(50)
			DECLARE @min_previous INT = 0

			WHILE EXISTS (SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE intRowDetailId > @minprior AND glfsf_action_type = ''PRN'' AND strRelatedRows IS NULL)
			BEGIN
				SELECT @min = MIN(intRowDetailId) FROM #irelyloadFRRowDesign WHERE intRowDetailId > @minprior AND glfsf_action_type = ''PRN'' AND strRelatedRows IS NULL		
				SELECT @change = (@min - 1)
				SELECT @increment = 1
				SELECT @strBalanceSide = ''''
				SELECT @TotalSide = ''''	

				SELECT @introwdetailidint = MIN(intRowDetailId) FROM #irelyloadFRRowDesign WHERE intRowDetailId > @min_previous AND intRowDetailId <= @min AND (glfsf_action_type = ''GRA'' OR glfsf_action_type = ''ACA'' OR glfsf_action_type = ''NET'')

				WHILE EXISTS(SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE intRowDetailId >= @introwdetailidint AND intRowDetailId <= @min AND (glfsf_action_type = ''GRA'' OR glfsf_action_type = ''ACA'' OR glfsf_action_type = ''NET''))
				BEGIN
					SELECT @introwdetailidint = intRowDetailId, @intrefno = intRefNo, @min_previous = intRowDetailId, @strBalanceSide = strBalanceSide FROM #irelyloadFRRowDesign WHERE intRowDetailId = @introwdetailidint

					--SELECT * FROM #irelyloadFRRowDesign WHERE intRowDetailId = @introwdetailidint

					IF(@TotalSide = '''')
					BEGIN
						SET @TotalSide = @strBalanceSide
					END

					IF EXISTS (SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE intRowDetailId = @min AND strRelatedRows IS NOT NULL)
					BEGIN
						--INCOME STATEMENT CHANGING OF SIDE
						IF(@strBalanceSide = ''Debit'' AND @glfsf_stmt_type = ''I'')
						BEGIN
							UPDATE #irelyloadFRRowDesign SET strRelatedRows = strRelatedRows + '' -'' WHERE intRowDetailId = @min
						END
						ELSE
						BEGIN
							UPDATE #irelyloadFRRowDesign SET strRelatedRows = strRelatedRows  + '' +'' WHERE intRowDetailId = @min
						END			
					END

					IF(@TotalSide != @strBalanceSide)
					BEGIN
						SET @TotalSide = ''MIXED''
					END

					UPDATE #irelyloadFRRowDesign SET strRelatedRows = ISNULL(strRelatedRows,'''') + '' R'' + RTRIM(CONVERT(varchar(10),(@intrefno)))  WHERE intRowDetailId = @min
					SELECT @rowcurr = intRowId FROM #irelyloadFRRowDesign WHERE intRowDetailId = @min

					--INCOME STATEMENT CHANGING OF SIDE
					IF EXISTS (SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE intRowDetailId = @min)
					BEGIN
						IF(@strBalanceSide = ''Debit'' AND @glfsf_stmt_type = ''I'')
						BEGIN
							INSERT #irelyloaddesigncalc
							SELECT @rowcurr, @min, @intrefno, ''-'', @increment, @introwdetailidint
						END
						ELSE
						BEGIN
							INSERT #irelyloaddesigncalc
							SELECT @rowcurr, @min, @intrefno, ''+'', @increment, @introwdetailidint
						END
					END
					ELSE
					BEGIN
						INSERT #irelyloaddesigncalc
						SELECT @rowcurr, @min, @intrefno, ''+'', @increment, @introwdetailidint
					END
					
					SELECT @change = (@change - 1)
					SELECT @increment = (@increment + 1)
					SELECT @introwdetailidint = (@introwdetailidint + 1)
				END

				UPDATE #irelyloadFRRowDesign SET strRelatedRows = '''' WHERE intRowDetailId = @min AND strRelatedRows IS NULL

				IF(@TotalSide != ''MIXED'')
				BEGIN
					UPDATE #irelyloadFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,''-'',''+'') WHERE intRowDetailId = @min
					UPDATE #irelyloaddesigncalc SET strAction = REPLACE(strAction,''-'',''+'') WHERE intRowId = @rowcurr and intRefNoId = @min
				END

				SET @min_previous = @min

			END
 

			--=====================================================================================================================================
			-- 	BUILDING DETAILS 6
			---------------------------------------------------------------------------------------------------------------------------------------
			DECLARE @tot INT = 0
			DECLARE @tod INT = 0
			DECLARE @totno INT = 0
			DECLARE @rowold INT = 0
			DECLARE @introwid INT	
			DECLARE @adder INT
			DECLARE @adderintrowdetailid INT
			DECLARE @totprior INT 
			DECLARE @upper INT 
			DECLARE @maxbeforetot INT
			DECLARE @glfsf_tot_no INT			

			SELECT @ROW = 0

			WHILE EXISTS(SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE glfsf_action_type = ''TOT'' AND intRowDetailId > @tod)
			BEGIN
				SELECT @tod = @tot
				SELECT @tot = MIN(intRowDetailId) FROM #irelyloadFRRowDesign WHERE glfsf_action_type = ''TOT'' AND intRowDetailId > @tod
				SELECT @introwid = intRowId, @totno = glfsf_tot_no FROM #irelyloadFRRowDesign WHERE intRowDetailId = @tot

				SELECT @totprior = ISNULL(MAX(intRowDetailId),0) FROM #irelyloadFRRowDesign WHERE intRowDetailId < @tot AND glfsf_tot_no >= @totno
				SELECT @maxbeforetot = ISNULL(MAX(glfsf_tot_no),0) FROM #irelyloadFRRowDesign WHERE intRowDetailId > @totprior AND intRowDetailId < @tot

				SET @ROW = 0
				SET @rowold = 0
				SELECT @upper = 0
				SELECT @strBalanceSide = ''''
				SELECT @TotalSide = ''''

				WHILE EXISTS (SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE intRowDetailId < @tot AND intRowDetailId > @tod AND intRowDetailId > @ROW AND glfsf_action_type IN (''PRN'',''ACP'',''GRP''))
						OR EXISTS (SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE intRowDetailId < @tot				-- id less than the total id number
																			   AND intRowDetailId > @ROW				-- current row - WHERE it is
																			   AND glfsf_action_type IN (''TOT'')			-- sum tots not anything else
																			   AND intRowDetailId > @totprior			-- makes sure you do not go above an equal or greater tot number
																			)											-- prevents it FROM doing anything after total
				BEGIN
					SELECT @ROW = 0
					SELECT @ROW = MIN(intRowDetailId) FROM #irelyloadFRRowDesign WHERE ((glfsf_action_type IN (''PRN'',''ACP'',''GRP'') AND intRowDetailId > @tod) OR (glfsf_action_type = ''TOT'' AND glfsf_tot_no < @totno AND intRowDetailId > @totprior AND glfsf_tot_no=@maxbeforetot))
																					AND intRowDetailId > @rowold
																					AND intRowDetailId < @tot
																					AND intRowDetailId > @totprior
					SELECT @adder = NULL
					SELECT @adderintrowdetailid = NULL
					SELECT @adder = intRefNo, @adderintrowdetailid = intRowDetailId, @strBalanceSide = strBalanceSide, @glfsf_tot_no = glfsf_tot_no FROM #irelyloadFRRowDesign WHERE intRowDetailId = @ROW
					SELECT @maxbeforetot = ISNULL(MAX(glfsf_tot_no),0) FROM #irelyloadFRRowDesign WHERE intRowDetailId > @ROW AND intRowDetailId < @tot

					IF(@TotalSide = '''')
					BEGIN
						SET @TotalSide = @strBalanceSide
					END

					IF EXISTS(SELECT TOP 1 1 FROM #irelyloadFRRowDesign WHERE intRowDetailId = @tot AND strRelatedRows IS NOT NULL)
					BEGIN
						--INCOME STATEMENT CHANGING OF SIDE
						--IF((select top 1 strBalanceSide from #irelyloadFRRowDesign WHERE intRowDetailId = @tot) = ''Credit'' AND @glfsf_stmt_type = ''I'')
						IF(@strBalanceSide = ''Debit'' AND @glfsf_stmt_type = ''I'')
						BEGIN
							UPDATE #irelyloadFRRowDesign SET strRelatedRows = strRelatedRows + '' -'' WHERE intRowDetailId = @tot
						END
						ELSE
						BEGIN
							UPDATE #irelyloadFRRowDesign SET strRelatedRows = strRelatedRows + '' +'' WHERE intRowDetailId = @tot
						END						

						IF(@TotalSide != @strBalanceSide)
						BEGIN
							SET @TotalSide = ''MIXED''
						END

					END

					IF @adder IS NOT NULL
					BEGIN
						UPDATE #irelyloadFRRowDesign SET strRelatedRows = ISNULL(strRelatedRows,'''') + '' R'' + RTRIM(CONVERT(VARCHAR(10),@adder)) WHERE intRowDetailId = @tot
						SELECT @rowcurr= intRowId FROM #irelyloadFRRowDesign WHERE intRowDetailId = @tot

						--INCOME STATEMENT CHANGING OF SIDE
						SELECT @strBalanceSide = strBalanceSide FROM #irelyloadFRRowDesign WHERE intRowDetailId = (SELECT MIN(intRowDetailId) FROM #irelyloadFRRowDesign WHERE ((glfsf_action_type IN (''PRN'',''ACP'',''GRP'',''GRA'') AND intRowDetailId > @tod) OR (glfsf_action_type = ''TOT'' AND glfsf_tot_no < @totno AND intRowDetailId > @totprior AND glfsf_tot_no=@maxbeforetot))
																															AND intRowDetailId > @ROW
																															AND intRowDetailId < @tot
																															AND intRowDetailId > @totprior)
						IF(@strBalanceSide = ''Debit'' AND @glfsf_stmt_type = ''I'')
						BEGIN
							INSERT #irelyloaddesigncalc
								SELECT @rowcurr, @tot, @adder, ''-'', @upper, @adderintrowdetailid
						END
						ELSE
						BEGIN
							INSERT #irelyloaddesigncalc
								SELECT @rowcurr, @tot, @adder, ''+'', @upper, @adderintrowdetailid
						END						
					END

					SELECT @rowold = @ROW
					SELECT @upper = (@upper + 1)
				END

				IF(@TotalSide != ''MIXED'')
				BEGIN
					UPDATE #irelyloadFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,''-'',''+'') WHERE intRowDetailId = @tot				
					UPDATE #irelyloaddesigncalc SET strAction = REPLACE(strAction,''-'',''+'') WHERE intRowId = @rowcurr and intRefNoId = @tot
				END

			END

			DELETE FROM #irelyloadFRRowDesign WHERE intRefNo = 0

			INSERT tblFRRowDesign 
			(
				intRowId, intRefNo, strDescription, strRowType, strBalanceSide, strRelatedRows, strAccountsUsed, ysnShowCredit,
				ysnShowDebit, ysnShowOthers, ysnLinktoGL, dblHeight, strFontName, strFontStyle, strFontColor, intFontSize,
				strOverrideFormatMask, ysnForceReversedExpense, intSort, intConcurrencyId
			)
			SELECT 
				intRowId, intRefNo, strDescription, strRowType, strBalanceSide, strRelatedRows, strAccountsUsed, ysnShowCredit,
				ysnShowDebit, ysnShowOthers, ysnLinktoGL, dblHeight, strFontName, strFontStyle, strFontColor, intFontSize,
				strOverrideFormatMask, ysnForceReversedExpense, intSort, intConcurrencyId
			FROM #irelyloadFRRowDesign ORDER BY intRowId, intRefNo
						

			--=====================================================================================================================================
			-- 	BUILDING DETAILS 7
			---------------------------------------------------------------------------------------------------------------------------------------
			SELECT @SQL = ''INSERT dbo.tblFRRowDesignFilterAccount 
							(
								intRowId,
								intRefNoId,
								strName,
								strCondition,
								strCriteria,
								strCriteriaBetween,strJoin,
								intRowDetailId
							)
							SELECT 
								intRowId,
								intRefNo,''
								+ '''''''' +
								''ID''
								+ '''''''' + '','' +
								'''''''' +
								''='' + '''''''' +
								'',substring(LTRIM(strAccountsUsed),9,'' + CONVERT(VARCHAR(2),(CONVERT(INT,@1_8size) + 1 + CONVERT(INT,@9_16size))) + ''),'' +
								'''''''' + '''''''' + '','' +
								'''''''' + '''''''' + '','' + ''
								intRowDetailId
							FROM tblFRRowDesign
							WHERE intRowId='' + CONVERT(VARCHAR(10),@introwiddet) + '' and
							strAccountsUsed like'' + '''''''' + ''%ID%'' + '''''''' + ''
							and strAccountsUsed not like'' + '''''''' + ''%Betwee%'' + ''''''''

			--SELECT @SQL --debug
			EXEC (@SQL)

			--=====================================================================================================================================
			-- 	BUILDING DETAILS 8
			---------------------------------------------------------------------------------------------------------------------------------------
			SELECT @SQL = ''INSERT dbo.tblFRRowDesignFilterAccount 
							(
								intRowId,
								intRefNoId,
								strName,
								strCondition,
								strCriteria,
								strCriteriaBetween,strJoin,
								intRowDetailId
							)
							SELECT 
								intRowId,
								intRefNo,''
								+ '''''''' +
								''ID'' +
								'''''''' + '','' + ''''''''
								+ ''Between'' + '''''''' + '',''
								+ ''substring(LTRIM(strAccountsUsed),15,'' + CONVERT(VARCHAR(10),(CONVERT(INT,@1_8size) + 1 + CONVERT(INT,@9_16size))) + ''),''
								+ ''substring(LTRIM(strAccountsUsed),15 + '' + CONVERT(VARCHAR(10),(CONVERT(INT,@1_8size) + 1 + CONVERT(INT,@9_16size))) + '' + 7,'' + CONVERT(VARCHAR(10),(CONVERT(INT,@1_8size) + 1 + CONVERT(INT,@9_16size))) + ''),''
								+ '''''''' + '''''''' + '' ,
								intRowDetailId
							FROM tblFRRowDesign
							WHERE intRowId = '' + CONVERT(VARCHAR(10),@introwiddet) + '' 
							and strAccountsUsed like'' + '''''''' + ''%[ID]%'' + '''''''' + ''
							and strAccountsUsed not like'' + '''''''' + ''%Primary%'' + '''''''' + ''
							and strAccountsUsed like'' + '''''''' + ''%Betw%'' + ''''''''

			--SELECT @SQL --debug
			EXEC (@SQL)

			--=====================================================================================================================================
			-- 	BUILDING DETAILS 9
			---------------------------------------------------------------------------------------------------------------------------------------
			SELECT @SQL = ''INSERT dbo.tblFRRowDesignFilterAccount
							(
								intRowId,
								intRefNoId,
								strName,
								strCondition,
								strCriteria,
								strCriteriaBetween,strJoin,
								intRowDetailId
							)
							SELECT 
								intRowId,
								intRefNo,'' +
								'''''''' + ''Primary Account'' + '''''''' + '','' +
								'''''''' + ''Between'' + '''''''' + '',
								substring(LTRIM(strAccountsUsed),28,'' + @1_8size + ''),
								substring(LTRIM(strAccountsUsed),'' + CONVERT(VARCHAR(2),35 + CONVERT(INT,(@1_8size))) + '','' + @1_8size + ''),''
								+ '''''''' + '''''''' + '' ,
								intRowDetailId
							FROM tblFRRowDesign
							WHERE intRowId = '' + CONVERT(VARCHAR(10),@introwiddet) + '' and strAccountsUsed like'' + '''''''' + ''%Primary%Betwee%'' + ''''''''

			--SELECT @SQL --debug
			EXEC (@SQL)

			--=====================================================================================================================================
			-- 	BUILDING DETAILS 10
			---------------------------------------------------------------------------------------------------------------------------------------
			SELECT @SQL = ''INSERT dbo.tblFRRowDesignFilterAccount
							(
								intRowId,
								intRefNoId,
								strName,
								strCondition,
								strCriteria,
								strCriteriaBetween,strJoin,
								intRowDetailId
							)
							SELECT 
								intRowId,
								intRefNo,''
								+ '''''''' +
								''Location''
								+ '''''''' + '','' +
								'''''''' +
								''='' + '''''''' +
								'',REPLACE(SUBSTRING(LTRIM(strAccountsUsed),CHARINDEX(''''Or'''',LTRIM(strAccountsUsed)) + 16,100),'''''''''''''''',''''''''),'' +								
								'''''''' + '''''''' + '','' +
								'''''''' + '''''''' + '','' + ''
								intRowDetailId
							FROM tblFRRowDesign
							WHERE intRowId = '' + CONVERT(VARCHAR(10),@introwiddet) + '' and strAccountsUsed like'' + '''''''' + ''%Primary%Betwee%Or%'' + ''''''''

			--SELECT @SQL --debug
			EXEC (@SQL)

			--=====================================================================================================================================
			-- 	BUILDING DETAILS 11 - NET
			---------------------------------------------------------------------------------------------------------------------------------------
			SELECT @SQL = ''INSERT dbo.tblFRRowDesignFilterAccount
							(
								intRowId,
								intRefNoId,
								strName,
								strCondition,
								strCriteria,
								strCriteriaBetween,strJoin,
								intRowDetailId
							)
							SELECT 
								intRowId,
								intRefNo,''
								+ '''''''' +
								''Type''
								+ '''''''' + '','' +
								'''''''' +
								''='' + '''''''' +
								'',''''Revenue'''','' +								
								'''''''' + '''''''' + '','' +
								'''''''' + '''''''' + '','' + ''
								intRowDetailId
							FROM tblFRRowDesign
							WHERE strAccountsUsed like ''''%Type%Revenue%Type%Expense%''''''

			--SELECT @SQL --debug
			EXEC (@SQL)

			SELECT @SQL = ''INSERT dbo.tblFRRowDesignFilterAccount
							(
								intRowId,
								intRefNoId,
								strName,
								strCondition,
								strCriteria,
								strCriteriaBetween,strJoin,
								intRowDetailId
							)
							SELECT 
								intRowId,
								intRefNo,''
								+ '''''''' +
								''Type''
								+ '''''''' + '','' +
								'''''''' +
								''='' + '''''''' +
								'',''''Expense'''','' +								
								'''''''' + '''''''' + '','' +
								'''''''' + '''''''' + '','' + ''
								intRowDetailId
							FROM tblFRRowDesign
							WHERE strAccountsUsed like ''''%Type%Revenue%Type%Expense%''''''

			--SELECT @SQL --debug
			EXEC (@SQL)			

			--=====================================================================================================================================
			-- 	BUILDING DETAILS 12
			---------------------------------------------------------------------------------------------------------------------------------------
			INSERT tblFRRowDesignCalculation
				SELECT tblFRRowDesign.intRowDetailId,
						calc.intRowDetailId,
						tblFRRowDesign.intRowId,
						0,
						#irelyloaddesigncalc.intRefNoCalc,
						#irelyloaddesigncalc.strAction,
						#irelyloaddesigncalc.intSort,
						1
				FROM #irelyloaddesigncalc
					INNER JOIN #irelyloadFRRowDesign 
						ON #irelyloadFRRowDesign.intRowDetailId = #irelyloaddesigncalc.intRefNoId
					INNER JOIN tblFRRowDesign 
						ON tblFRRowDesign.intRowId = #irelyloadFRRowDesign.intRowId AND tblFRRowDesign.intRefNo = #irelyloadFRRowDesign.intRefNo
					INNER JOIN tblFRRowDesign AS calc
						ON calc.intRowId = #irelyloaddesigncalc.intRowId AND calc.intRefNo = #irelyloaddesigncalc.intRefNoCalc
	
			--=====================================================================================================================================
			-- 	CLEAN-UP
			---------------------------------------------------------------------------------------------------------------------------------------
			UPDATE tblFRRowDesign SET strDescription = '''' WHERE strDescription IS NULL
			UPDATE tblFRRowDesign SET strBalanceSide = '''' WHERE strBalanceSide IS NULL
			UPDATE tblFRRowDesign SET strRelatedRows = '''' WHERE strRelatedRows IS NULL
			UPDATE tblFRRowDesign SET strAccountsUsed = '''' WHERE strAccountsUsed IS NULL
			UPDATE tblFRRowDesign SET strBalanceSide = '''' WHERE strRowType = ''Row Calculation''
			UPDATE tblFRRowDesign SET strSource = ''Column'' WHERE strRowType IN (''Hidden'',''Filter Accounts'',''Cash Flow Activity'',''Percentage'')
			UPDATE tblFRRowDesign SET strSource = '''' WHERE strRowType NOT IN (''Hidden'',''Filter Accounts'',''Cash Flow Activity'',''Percentage'')
			UPDATE tblFRRowDesignFilterAccount SET strJoin = ''Or'' WHERE strJoin = ''''
 
			SELECT * INTO #TempRowDesign FROM tblFRRowDesign where intRowId = @introwiddet order by intRefNo
 
			DECLARE @Sort INT = 1
 
			WHILE EXISTS(SELECT 1 FROM #TempRowDesign)
			BEGIN
				DECLARE @intRowDetailId INT = (SELECT TOP 1 intRowDetailId FROM #TempRowDesign order by intRefNo)
				UPDATE tblFRRowDesign SET intSort = @Sort WHERE intRowDetailId = @intRowDetailId
				SET @Sort = @Sort + 1
				DELETE #TempRowDesign WHERE intRowDetailId = @intRowDetailId
			END

		END

		END TRY

		--=====================================================================================================================================
		-- 	FINALIZING STAGE
		---------------------------------------------------------------------------------------------------------------------------------------

		BEGIN CATCH
			SELECT @result = ERROR_MESSAGE()
			IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		END CATCH

		IF @@TRANCOUNT > 0 COMMIT TRANSACTION;

		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id(''tempdb..#irelyloaddesigncalc'')) DROP TABLE #irelyloaddesigncalc
		IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = object_id(''tempdb..#irelyloadFRRowDesign'')) DROP TABLE #irelyloadFRRowDesign


		--GO
	')

END 


----=====================================================================================================================================
---- 	SCRIPT EXECUTION 
-----------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @res AS NVARCHAR(MAX)

--EXEC [dbo].[uspFRDImportOriginDesign]
--			@originglfsf_no	 = '1',					-- ORIGIN ID
--			@result = @res OUTPUT					-- OUTPUT PARAMETER THAT RETURNS TOTAL NUMBER OF SUCCESSFUL RECORDS
				
--SELECT @res


