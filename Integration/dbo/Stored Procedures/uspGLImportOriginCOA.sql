﻿GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glactmst]') AND type IN (N'U'))
BEGIN 

	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLImportOriginCOA'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspGLImportOriginCOA];
	')

	EXEC('
		CREATE PROCEDURE  [dbo].[uspGLImportOriginCOA]
		@ysnStructure	BIT = 0,
		@ysnPrimary		BIT = 0,
		@ysnSegment		BIT = 0,
		@ysnUnit		BIT = 0,
		@ysnOverride	BIT = 0,
		@ysnBuild		BIT = 0,
		@result			NVARCHAR(500) = '''' OUTPUT
		AS
		DECLARE @SegmentStructureId INT, @PrimaryStructureId INT

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET XACT_ABORT ON
		SET NOCOUNT ON
		BEGIN TRY
		
		BEGIN TRANSACTION
		IF NOT EXISTS(SELECT * FROM glactmst)
		BEGIN
			RAISERROR (''Origin account table (glactmst) is empty'',11,1);
		END
			
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference A JOIN tblSMCurrency B on A.intDefaultCurrencyId = B.intCurrencyID)
		BEGIN
			RAISERROR(''Functional Currency is not setup properly. Please set it up in Company Configuration Screen.'', 16, 1);
		END

		
		IF (EXISTS(SELECT SegmentCode FROM (SELECT glact_acct1_8 AS SegmentCode,max(glact_desc) AS CodeDescription,glact_type FROM glactmst GROUP BY glact_acct1_8,glact_type) tblX group by SegmentCode HAVING COUNT(*) > 1) and @ysnOverride = 0)
		BEGIN
			SET @result = ''invalid-1''
		END
		
		ELSE IF (EXISTS(SELECT TOP 1 1 FROM glactmst WHERE glact_acct9_16 NOT IN (SELECT glprc_sub_acct FROM glprcmst)) and @ysnOverride = 0)
		BEGIN	
			SET @result = ''invalid-3''
		END
		ELSE
		BEGIN
			-- IMPORT ACCOUNT STRUCTURE
			IF @ysnStructure = 1
			BEGIN
				DECLARE  @PrimaryLength		NUMERIC (18,6)
						,@SegmentLength		NUMERIC (18,6)
		
				SET @PrimaryLength = (SELECT MAX(LEN(glact_acct1_8)) glact_acct1_8 FROM glactmst)
				SET @SegmentLength = (SELECT MAX(LEN(glact_acct9_16)) glact_acct9_16 FROM glactmst)	
				
				
				DELETE tblGLCOATemplateDetail
				DELETE tblGLCOATemplate
				DELETE tblGLAccountSegment
				DELETE tblGLAccountStructure
		
				INSERT tblGLAccountStructure (intStructureType,strStructureName,strType,intLength,strMask,intSort,ysnBuild,intStartingPosition)
										VALUES (1,''Primary Account'',''Primary'', @PrimaryLength,''0'',0,0,9 - @PrimaryLength)							
				INSERT tblGLAccountStructure (intStructureType,strStructureName,strType,intLength,strMask,intSort,ysnBuild,intStartingPosition)
										VALUES (2,''Hypen/Separator'',''Divider'', 1,''-'',1,0,0)							
				INSERT tblGLAccountStructure (intStructureType,strStructureName,strType,intLength,strMask,intSort,ysnBuild,intStartingPosition)
										VALUES (3,''Location'',''Segment'', @SegmentLength,''0'',2,0,9 - @SegmentLength)
			END	

			-- IMPORT PRIMARY ACCOUNT
			IF @ysnPrimary = 1
			BEGIN
				IF NOT EXISTS(SELECT * FROM tblGLAccountGroup)
				BEGIN
					RAISERROR (N''Account Group table is empty'',11,1);
				END

				DECLARE @primarylen INT
				SELECT @primarylen  = max(len(glact_acct1_8))from glactmst 
					INSERT INTO [dbo].[tblGLOriginAccounts]
						   ([glact_acct1_8]
						   ,[glact_acct9_16]
						   ,[glact_desc]
						   ,[glact_type]
						   ,[glact_normal_value]
						   ,[glact_saf_cat]
						   ,[glact_flow_cat]
						   ,[glact_uom]
						   ,[glact_verify_flag]
						   ,[glact_active_yn]
						   ,[glact_sys_acct_yn]
						   ,[glact_desc_lookup]
						   ,[glact_user_fld_1]
						   ,[glact_user_fld_2]
						   ,[glact_user_id]
						   ,[glact_user_rev_dt]
						   ,[glact_acct1_8_new]
						   ,A4GLIdentity
						   )
					SELECT [glact_acct1_8]
						   ,[glact_acct9_16]
						   ,[glact_desc]
						   ,[glact_type]
						   ,[glact_normal_value]
						   ,[glact_saf_cat]
						   ,[glact_flow_cat]
						   ,[glact_uom]
						   ,[glact_verify_flag]
						   ,[glact_active_yn]
						   ,[glact_sys_acct_yn]
						   ,[glact_desc_lookup]
						   ,[glact_user_fld_1]
						   ,[glact_user_fld_2]
						   ,[glact_user_id]
						   ,[glact_user_rev_dt]
						   ,[glact_acct1_8]
						   ,A4GLIdentity
							FROM glactmst
						WHERE A4GLIdentity NOT IN (SELECT A4GLIdentity FROM [tblGLOriginAccounts])
				

				
				IF ((SELECT COUNT(*) FROM (SELECT DISTINCT(LEN(glact_acct1_8_new)) AS SegmentCode FROM tblGLOriginAccounts) tblSegment) > 1 and @ysnOverride = 0)
				BEGIN
					
					IF EXISTS(SELECT TOP 1 1 FROM tblGLOriginAccounts where LEN(glact_acct1_8_new) < @primarylen and CAST(glact_acct1_8_new AS  VARCHAR) + REPLICATE(''0'',@primarylen-LEN(glact_acct1_8_new)) 
					IN (SELECT glact_acct1_8 FROM tblGLOriginAccounts))
					BEGIN
						SET @result = ''invalid-2,'' + cast(  @primarylen as varchar)
						COMMIT TRANSACTION
						RETURN
					END
					UPDATE [tblGLOriginAccounts] set glact_acct1_8_new =  cast(glact_acct1_8_new  as varchar) + replicate(''0'',@primarylen-len( glact_acct1_8_new))
				END
				DECLARE	@Length		INT
						,@query		VARCHAR(500)	
						,@generalCategoryId INT
				SELECT TOP 1 @SegmentStructureId = intAccountStructureId FROM tblGLAccountStructure WHERE strType = ''Segment''
				SELECT TOP 1 @PrimaryStructureId = intAccountStructureId FROM tblGLAccountStructure WHERE strType = ''Primary''
				SELECT @generalCategoryId=intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = ''General''
				SET @Length = ISNULL((SELECT intLength FROM tblGLAccountStructure WHERE strType = ''Primary''),0)
				SET @query = ''SELECT glact_acct1_8_new AS SegmentCode,max(glact_desc) AS CodeDescription,glact_type FROM [tblGLOriginAccounts] WHERE LEN(glact_acct1_8_new) = '' + CAST(@Length AS NVARCHAR(10)) + '' GROUP BY glact_acct1_8_new,glact_type''		
				
				DECLARE @tblQuery TABLE
				(
					 SegmentCode			NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
					,CodeDescription		NVARCHAR(300) COLLATE Latin1_General_CI_AS NOT NULL
					,glact_type				NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
				)
		
				IF @ysnOverride = 1
				BEGIN
					SET @query = ''SELECT glact_acct1_8_new AS SegmentCode,max(glact_desc) AS CodeDescription,glact_type = (SELECT TOP 1 glact_type FROM [tblGLOriginAccounts] AS tempType WHERE tempType.glact_acct1_8_new = tempCode.glact_acct1_8_new GROUP BY glact_type) FROM [tblGLOriginAccounts] AS tempCode WHERE LEN(glact_acct1_8_new) = '' + CAST(@Length AS NVARCHAR(10)) + '' GROUP BY glact_acct1_8_new''
				END

				INSERT INTO @tblQuery EXEC (@query)			

				UPDATE @tblQuery
				SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = ''Asset'' and intParentGroupId = 0)
				WHERE glact_type = ''A''

				UPDATE @tblQuery
				SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = ''Expense'' and intParentGroupId = 0)
				WHERE glact_type = ''E''

				UPDATE @tblQuery
				SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = ''Liability'' and intParentGroupId = 0)
				WHERE glact_type = ''L''

				UPDATE @tblQuery
				SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = ''Expense'' and strAccountGroup = ''Cost of Goods Sold'')
				WHERE glact_type = ''C''

				UPDATE @tblQuery
				SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = ''Revenue'' and strAccountGroup = ''Sales'')
				WHERE glact_type = ''I''

				UPDATE @tblQuery
				SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = ''Equity'' and intParentGroupId = 0)
				WHERE glact_type = ''Q''
						
				DELETE tblGLAccountSegment where intAccountStructureId = @PrimaryStructureId		
		
				INSERT tblGLAccountSegment
					(strCode
					,strDescription
					,intAccountStructureId
					,intAccountGroupId
					,ysnActive
					,ysnSelected
					,intAccountCategoryId)
				SELECT
					SegmentCode
					,CodeDescription
					,@PrimaryStructureId
					,glact_type = CASE WHEN glact_type = '''' THEN NULL ELSE glact_type END
					,1
					,0
					,@generalCategoryId
				FROM @tblQuery
				WHERE SegmentCode not in (SELECT strCode FROM tblGLAccountSegment WHERE intAccountStructureId = @PrimaryStructureId)
		
			END
		
			-- IMPORT SEGMENT ACCOUNT
			IF @ysnSegment = 1
			BEGIN	
				SELECT TOP 1 @SegmentStructureId = intAccountStructureId FROM tblGLAccountStructure WHERE strType = ''Segment''
				SELECT TOP 1 @PrimaryStructureId = intAccountStructureId FROM tblGLAccountStructure WHERE strType = ''Primary''										
				SELECT glprc_sub_acct AS SegmentCode
						  ,glprc_desc = ISNULL((SELECT glprc_desc FROM glprcmst WHERE glprc_sub_acct = tblC.glprc_sub_acct),'''')
					INTO #segments
					 FROM (
						SELECT * FROM (
								SELECT glprc_sub_acct FROM glprcmst WHERE LEN(glprc_sub_acct) = (SELECT LEN(MAX(glact_acct9_16)) FROM glactmst)
								) tblA
							UNION ALL SELECT * FROM (
										SELECT glact_acct9_16 as glprc_sub_acct FROM glactmst GROUP BY glact_acct9_16
										) tblB
						) tblC
					WHERE LEN(glprc_sub_acct) <= (SELECT LEN(MAX(glact_acct9_16)) FROM glactmst)
					GROUP BY glprc_sub_acct									
									
			
				DELETE tblGLAccountSegment where intAccountStructureId = @SegmentStructureId
		
				INSERT tblGLAccountSegment
					(strCode
					,strDescription
					,intAccountStructureId
					,intAccountGroupId
					,ysnActive
					,ysnSelected)
				SELECT
					REPLICATE(''0'', (select len(max(SegmentCode)) from #segments) - len(SegmentCode)) + '''' + CAST(SegmentCode AS NVARCHAR(50)) SegmentCode
					,glprc_desc
					,@SegmentStructureId
					,null
					,1
					,0
				FROM #segments
				WHERE SegmentCode not in (SELECT strCode FROM tblGLAccountSegment WHERE intAccountStructureId = @SegmentStructureId)
		
				DROP TABLE #segments		
			END
	
			-- IMPORT UNIT OF MEASURE
			IF @ysnUnit = 1
			BEGIN	
				DELETE tblGLAccountUnit
		
				INSERT tblGLAccountUnit (strUOMCode,strUOMDesc,dblLbsPerUnit,intConcurrencyId)
					SELECT gluom_code,gluom_desc,gluom_lbs_per_unit,1 FROM gluommst	
			END	
		
			-- BUILD COA
			IF @ysnBuild = 1
			BEGIN
				INSERT INTO tblGLTempAccountToBuild
				SELECT
					intAccountSegmentId
					,0
					,dtmCreated = getDate()
				FROM
				tblGLAccountSegment			
				
				--select * from tblGLTempAccountToBuild	
		
				EXEC uspGLBuildOriginAccount  0
				EXEC uspGLBuildAccount 0			
				EXEC uspGLConvertAccountGroupToCategory		
				--commented until further notice
				--EXEC uspGLUpdateCategoryFromOrigin		
			END	
			SET @result = ''SUCCESSFULLY IMPORTED''
			
		END
		END TRY
		BEGIN CATCH
    		SELECT @result = ERROR_MESSAGE()
			IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		END CATCH
		IF @@TRANCOUNT > 0 COMMIT TRANSACTION;')
END 