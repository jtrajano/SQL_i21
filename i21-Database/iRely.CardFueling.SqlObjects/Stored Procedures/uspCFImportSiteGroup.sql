
CREATE PROCEDURE [dbo].[uspCFImportSiteGroup]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--============================================--
		--     ONE TIME SITE GROUP SYNCHRONIZATION	  --
		--============================================--
		
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time SITE GROUP Synchronization'

		DECLARE @originSiteGroup				NVARCHAR(50)
		DECLARE @MasterPk						INT

		DECLARE @Counter						INT = 0

		DECLARE @strSiteGroup					NVARCHAR(250)
		DECLARE @strDescription					NVARCHAR(250)
		DECLARE @strType						NVARCHAR(250)


		--=============================================--
		--			DETAIL SITE GROUP ADJUSTMENT	   --
		--=============================================--
		DECLARE @originSiteGroupAdjId			NVARCHAR(250)
		DECLARE @originSiteGroupAdjItem			NVARCHAR(250)
		DECLARE @intSiteGroupPriceAdjustmentId	INT
		DECLARE @intSiteGroupId					INT
		DECLARE @intARItemId					INT
		DECLARE @intPriceGroupId				INT
		DECLARE @dtmStartEffectiveDate			DATETIME
		DECLARE @dtmEndEffectiveDate			DATETIME
		DECLARE @dblRate						NUMERIC(18,6)

		--Import only those are not yet imported
		SELECT cfsgp_site_grp_id INTO #tmpcfsgpmst
		FROM cfsgpmst 
		WHERE LTRIM(RTRIM(cfsgp_site_grp_id )) COLLATE Latin1_General_CI_AS NOT IN (SELECT strSiteGroup FROM tblCFSiteGroup)
		
		--DUPLICATE SITE ON i21--

		INSERT INTO tblCFImportResult(
				dtmImportDate
				,strSetupName
				,ysnSuccessful
				,strFailedReason
				,strOriginTable
				,strOriginIdentityId
				,strI21Table
				,intI21IdentityId
				,strUserId
			)
		SELECT 
		dtmImportDate = GETDATE()
		,strSetupName = 'Site Group'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate site group on i21 Card Fueling site groups list'
		,strOriginTable = 'cfsgpmst'
		,strOriginIdentityId = cfsgp_site_grp_id
		,strI21Table = 'tblCFSiteGroup'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cfsgpmst 
		WHERE LTRIM(RTRIM(cfsgp_site_grp_id )) COLLATE Latin1_General_CI_AS IN (SELECT strSiteGroup FROM tblCFSiteGroup)
		
		--DUPLICATE SITE ON i21--

		WHILE (EXISTS(SELECT 1 FROM #tmpcfsgpmst))
		BEGIN
			
			SELECT @originSiteGroup = cfsgp_site_grp_id FROM #tmpcfsgpmst
			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					 @strSiteGroup				 = RTRIM(LTRIM(cfsgp_site_grp_id))
					,@strDescription			 = RTRIM(LTRIM(cfsgp_site_grp_desc))
					,@strType					 = RTRIM(LTRIM(cfsgp_type))
				FROM cfsgpmst
				WHERE cfsgp_site_grp_id = @originSiteGroup
					
				--================================--
				--		INSERT MASTER RECORD	  --
				--*******COMMIT TRANSACTION*******--
				--================================--
				INSERT [dbo].[tblCFSiteGroup](
				 [strSiteGroup]	
				,[strDescription]
				,[strType])
				VALUES(
				@strSiteGroup	
				,@strDescription
				,@strType)

				SELECT @MasterPk  = SCOPE_IDENTITY();
				--============================================--
				--		INSERT DETAIL SITE GROUP ADJUSTMENT	  --
				--			      REQUIRED FIELDS			  --
				--											  --
				--	1. intSiteGroupId						  --
				--											  --
				--Import only those are not yet imported
				SELECT cfsga_site_grp_id,cfsga_ar_itm_no INTO #tmpcfsgamst
				FROM cfsgamst WHERE cfsga_site_grp_id = @originSiteGroup

				WHILE (EXISTS(SELECT 1 FROM #tmpcfsgamst))
				BEGIN
			
					SELECT @originSiteGroupAdjId	  = cfsga_site_grp_id FROM #tmpcfsgamst
					SELECT @originSiteGroupAdjItem	  = cfsga_ar_itm_no FROM #tmpcfsgamst

					SELECT TOP 1
					 @intARItemId					  =ISNULL((SELECT intItemId 
													    FROM tblICItem 
													    WHERE strItemNo =  LTRIM(RTRIM(cfsga_ar_itm_no)) 
													    COLLATE Latin1_General_CI_AS),0)
													  
					,@intPriceGroupId				  =(SELECT intPriceRuleGroupId 
													    FROM tblCFPriceRuleGroup 
													    WHERE strPriceGroup = LTRIM(RTRIM(cfsga_prc_grp_id)) 
													    COLLATE Latin1_General_CI_AS)
													  
					,@dtmStartEffectiveDate			  =(case
													  	when LEN(RTRIM(LTRIM(ISNULL(cfsga_eff_start_dt,0)))) = 8 
													  	then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfsga_eff_start_dt)),1,4) 
													  		+ '/' + SUBSTRING (RTRIM(LTRIM(cfsga_eff_start_dt)),5,2) + '/' 
													  		+ SUBSTRING (RTRIM(LTRIM(cfsga_eff_start_dt)),7,2), 120)
													  	else NULL
													   end)
													  
					,@dtmEndEffectiveDate			  =(case
													  	when LEN(RTRIM(LTRIM(ISNULL(cfsga_eff_end_dt,0)))) = 8 
													  	then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfsga_eff_end_dt)),1,4) 
													  		+ '/' + SUBSTRING (RTRIM(LTRIM(cfsga_eff_end_dt)),5,2) + '/' 
													  		+ SUBSTRING (RTRIM(LTRIM(cfsga_eff_end_dt)),7,2), 120)
													  	else NULL
													   end)
													  
					,@dblRate						  =cfsga_rt
					FROM cfsgamst
					WHERE cfsga_site_grp_id = @originSiteGroupAdjId
					AND cfsga_ar_itm_no = @originSiteGroupAdjItem

					INSERT [dbo].[tblCFSiteGroupPriceAdjustment](
					[intSiteGroupId]
					,[intARItemId]			
					,[intPriceGroupId]		
					,[dtmStartEffectiveDate]	
					,[dtmEndEffectiveDate]	
					,[dblRate])
					VALUES(
					 @MasterPk
					,@intARItemId			
					,@intPriceGroupId		
					,@dtmStartEffectiveDate	
					,@dtmEndEffectiveDate	
					,@dblRate)

					INSERT INTO tblCFImportResult(
						 dtmImportDate
						,strSetupName
						,ysnSuccessful
						,strFailedReason
						,strOriginTable
						,strOriginIdentityId
						,strI21Table
						,intI21IdentityId
						,strUserId
					)
					VALUES(
						GETDATE()
						,'Site Group Adjustment'
						,1
						,''
						,'cfsgamst'
						,@originSiteGroupAdjItem
						,'tblCFSiteGroupPriceAdjustment'
						,null
						,''
					)
					
					DELETE FROM #tmpcfsgamst 
					WHERE cfsga_site_grp_id = @originSiteGroupAdjId
					AND cfsga_ar_itm_no = @originSiteGroupAdjItem

				END
				DROP TABLE #tmpcfsgamst
										COMMIT TRANSACTION
				--*********************COMMIT TRANSACTION*****************--
				SET @TotalSuccess += 1;
				INSERT INTO tblCFImportResult(
					dtmImportDate
					,strSetupName
					,ysnSuccessful
					,strFailedReason
					,strOriginTable
					,strOriginIdentityId
					,strI21Table
					,intI21IdentityId
					,strUserId
				)
				VALUES(
					GETDATE()
					,'Site Group'
					,1
					,''
					,'cfsgpmst'
					,@originSiteGroup
					,'tblCFSiteGroup'
					,@MasterPk
					,''
				)
			END TRY
			BEGIN CATCH
				--*********************ROLLBACK TRANSACTION*****************--
				ROLLBACK TRANSACTION
				SET @TotalFailed += 1;
				
				INSERT INTO tblCFImportResult(
					 dtmImportDate
					,strSetupName
					,ysnSuccessful
					,strFailedReason
					,strOriginTable
					,strOriginIdentityId
					,strI21Table
					,intI21IdentityId
					,strUserId
				)
				VALUES(
					GETDATE()
					,'Site Group'
					,0
					,ERROR_MESSAGE()
					,'cfsgpmst'
					,@originSiteGroup
					,'tblCFSiteGroup'
					,null
					,''
				)
				GOTO CONTINUELOOP;
				--*********************ROLLBACK TRANSACTION*****************--
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			DELETE FROM #tmpcfsgpmst WHERE cfsgp_site_grp_id = @originSiteGroup
		
			SET @Counter += 1;

		END
	
		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(*) - @TotalSuccess from cfsgpmst
		PRINT @TotalFailed

	END