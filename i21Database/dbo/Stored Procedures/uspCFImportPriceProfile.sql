﻿
CREATE PROCEDURE [dbo].[uspCFImportPriceProfile]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--====================================================--
		--     ONE TIME PRICE PROFILE SYNCHRONIZATION	  --
		--====================================================--
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time PRICE PROFILE Synchronization'

		DECLARE @originPriceProfile NVARCHAR(50)
		DECLARE @originPriceProfileDetail NVARCHAR(50)

		DECLARE @Counter						INT = 0
		DECLARE @MasterPk						INT


		--========================--
		--     MASTER FIELDS	  --
		--========================--			
		DECLARE @strPriceProfile				NVARCHAR(MAX)
		DECLARE @strDescription					NVARCHAR(MAX)
		DECLARE @strType						NVARCHAR(MAX)
		DECLARE @dblMinimumMargin				NUMERIC(18,6)
		
		--========================--
		--     DETAIL FIELDS	  --
		--========================--
		DECLARE @intPriceProfileHeaderId		INT
		DECLARE @intItemId						INT
		DECLARE @intNetworkId					INT
		DECLARE @intSiteGroupId					INT
		DECLARE @intSiteId						INT
		DECLARE @intLocalPricingIndex			INT
		DECLARE @dblRate						NUMERIC(18,6)
		DECLARE @strBasis						NVARCHAR(250)

		--Import only those are not yet imported
		SELECT cfpph_prc_prf_id INTO #tmpcfpphmst
			FROM cfpphmst
				WHERE cfpph_prc_prf_id COLLATE Latin1_General_CI_AS NOT IN (select strPriceProfile from tblCFPriceProfileHeader) 

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
		,strSetupName = 'Price Profile'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate price profile on i21 Card Fueling price profiles list'
		,strOriginTable = 'cfpphmst'
		,strOriginIdentityId = cfpph_prc_prf_id
		,strI21Table = 'tblCFPriceProfileHeader'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cfpphmst
		WHERE cfpph_prc_prf_id COLLATE Latin1_General_CI_AS  IN (select strPriceProfile from tblCFPriceProfileHeader) 
		
		--DUPLICATE SITE ON i21--

		WHILE (EXISTS(SELECT 1 FROM #tmpcfpphmst))
		BEGIN
				

			SELECT @originPriceProfile = cfpph_prc_prf_id FROM #tmpcfpphmst

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					 @strPriceProfile			= LTRIM(RTRIM(cfpph_prc_prf_id))
					,@strDescription			= LTRIM(RTRIM(cfpph_prc_prf_desc))
					,@strType					= (case
													when RTRIM(LTRIM(cfpph_type)) = 'R' then 'Remote'
													when RTRIM(LTRIM(cfpph_type)) = 'E' then 'Extended Remote'
													when RTRIM(LTRIM(cfpph_type)) = 'L' then 'Local/Network'
													else NULL
												  end)
					,@dblMinimumMargin			= LTRIM(RTRIM(cfpph_min_margin))
				FROM cfpphmst
				WHERE cfpph_prc_prf_id = @originPriceProfile
					
				--================================--
				--		INSERT MASTER RECORD	  --
				--*******COMMIT TRANSACTION*******--
				--================================--
				INSERT [dbo].[tblCFPriceProfileHeader](
				 [strPriceProfile]
				,[strDescription]	
				,[strType]			
				,[dblMinimumMargin]
				)
				VALUES(
				 @strPriceProfile
				,@strDescription	
				,@strType			
				,@dblMinimumMargin)

				--================================--
				--		INSERT DETAIL RECORDS	  --
				--================================--
				SELECT @MasterPk  = SCOPE_IDENTITY();

				SELECT cfppd_prc_prf_id INTO #tmpcfppdmst
				FROM cfppdmst
				WHERE cfppd_prc_prf_id COLLATE Latin1_General_CI_AS = @strPriceProfile
				
				WHILE (EXISTS(SELECT 1 FROM #tmpcfppdmst))
				BEGIN

					SELECT @originPriceProfileDetail = cfppd_prc_prf_id FROM #tmpcfppdmst

					SELECT TOP 1
					@intItemId						= (SELECT TOP 1 intItemId 
															  FROM tblICItem 
															  WHERE strItemNo = LTRIM(RTRIM(cfppd_ar_itm_no))
																				 COLLATE Latin1_General_CI_AS)
					,@intNetworkId					= ISNULL((SELECT intNetworkId 
															  FROM tblCFNetwork 
															  WHERE strNetwork = LTRIM(RTRIM(cfppd_netwrok_id))
																				 COLLATE Latin1_General_CI_AS),0)

					,@intSiteGroupId				= ISNULL((SELECT intSiteGroupId 
															  FROM tblCFSiteGroup 
															  WHERE strSiteGroup = LTRIM(RTRIM(cfppd_site_grp_id)) 
																				   COLLATE Latin1_General_CI_AS),0)

					,@intSiteId						= ISNULL((SELECT intSiteId 
															  FROM tblCFSite 
															  WHERE strSiteNumber = LTRIM(RTRIM(cfppd_site_no)) 
																					COLLATE Latin1_General_CI_AS),0)

					,@intLocalPricingIndex			= ISNULL((SELECT intPriceIndexId 
															  FROM tblCFPriceIndex 
															  WHERE strPriceIndex = LTRIM(RTRIM(cfppd_local_idx))
																					COLLATE Latin1_General_CI_AS),0)

					,@dblRate						= LTRIM(RTRIM(cfppd_rt))

					,@strBasis						= (case
														when RTRIM(LTRIM(cfppd_basis)) = 'FR' then 'Full Retail'
														when RTRIM(LTRIM(cfppd_basis)) = 'DP' then 'Discounted Price'
														when RTRIM(LTRIM(cfppd_basis)) = 'TC' then 'Transfer Cost'
														when RTRIM(LTRIM(cfppd_basis)) = 'TP' then 'Transfer Price'
														when RTRIM(LTRIM(cfppd_basis)) = 'RPI' then 'Remote Pricing Index'
														when RTRIM(LTRIM(cfppd_basis)) = 'LRI' then 'Local Index Retail'
														when RTRIM(LTRIM(cfppd_basis)) = 'LIC' then 'Local Index Cost'
														when RTRIM(LTRIM(cfppd_basis)) = 'PPA' then 'Pump Price Adjustment'
														else NULL
													  end)

					FROM cfppdmst
					WHERE cfppd_prc_prf_id = @originPriceProfileDetail

					INSERT [dbo].[tblCFPriceProfileDetail](
					 [intPriceProfileHeaderId]
					,[intItemId]				
					,[intNetworkId]			
					,[intSiteGroupId]			
					,[intSiteId]				
					,[intLocalPricingIndex]	
					,[dblRate]				
					,[strBasis]				
					)
					VALUES(
					@MasterPk
					,@intItemId				
					,@intNetworkId			
					,@intSiteGroupId			
					,@intSiteId				
					,@intLocalPricingIndex	
					,@dblRate				
					,@strBasis				
					)
					
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
						,'Price Profile Detail'
						,1
						,''
						,'cffprmst'
						,@originPriceProfileDetail
						,'tblCFPriceProfileDetail'
						,null
						,''
					)

					DELETE FROM #tmpcfppdmst WHERE cfppd_prc_prf_id = @originPriceProfileDetail
				END

				DROP TABLE #tmpcfppdmst

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
						,'Price Profile'
						,1
						,''
						,'cfppdmst'
						,@originPriceProfile
						,'tblCFPriceProfile'
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
					,'Price Profile'
					,0
					,ERROR_MESSAGE()
					,'cfppdmst'
					,@originPriceProfile
					,'tblCFPriceProfile'
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
			DELETE FROM #tmpcfpphmst WHERE cfpph_prc_prf_id = @originPriceProfile
		
			SET @Counter += 1;

		END
	
		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(*) - @TotalSuccess from cfpphmst
		PRINT @TotalFailed

	END