
CREATE PROCEDURE [dbo].[uspCFImportPricingBySiteGroup]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
		
		--====================================================--
		--     ONE TIME PRICING BY SITE GROUP SYNCHRONIZATION --
		--====================================================--
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time PRICING BY SITE GROUP Synchronization'

		DECLARE @originPK1			NVARCHAR(50)
		DECLARE @originPK2			NVARCHAR(50)
		DECLARE @originDetailPK		NVARCHAR(50)

		DECLARE @Counter						INT = 0
		DECLARE @MasterPk						INT


		--========================--
		--     MASTER FIELDS	  --
		--========================--
		DECLARE @intIndexPricingBySiteGroupHeaderId		INT
		DECLARE @intPriceIndexId						INT
		DECLARE @dtmDate								DATETIME
		DECLARE @intSiteGroupId							INT

		--========================--
		--     DETAIL FIELDS	  --
		--========================--
		DECLARE @intDetailIndexPricingBySiteGroupId			INT
		DECLARE @intDetailIndexPricingBySiteGroupHeaderId	INT
		DECLARE @intARItemID								INT
		DECLARE @intTime									INT
		DECLARE @dblIndexPrice								NUMERIC(18,6)
		
    
		--Import only those are not yet imported
		SELECT DISTINCT cfips_idx_id , cfips_site_grp_id 
		INTO #tmpcfipsmst
		FROM cfipsmst
		
		WHILE (EXISTS(SELECT 1 FROM #tmpcfipsmst))
		BEGIN

		SELECT DISTINCT 
		 @originPK1 = cfips_idx_id
		,@originPK2 = cfips_site_grp_id 
		FROM #tmpcfipsmst

		DECLARE @DetailRecord TABLE (
			intARItemID		INT						
			,intTime			INT						
			,dblIndexPrice		NUMERIC(18,6)							
		)

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					  @intPriceIndexId = (SELECT TOP 1 intPriceIndexId 
											FROM tblCFPriceIndex 
											WHERE strPriceIndex COLLATE Latin1_General_CI_AS = cfips_idx_id COLLATE Latin1_General_CI_AS)
					 ,@dtmDate		   = (case
											when LEN(RTRIM(LTRIM(ISNULL(cfips_rev_dt,0)))) = 8 
											then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfips_rev_dt)),1,4) 
												+ '/' + SUBSTRING (RTRIM(LTRIM(cfips_rev_dt)),5,2) + '/' 
												+ SUBSTRING (RTRIM(LTRIM(cfips_rev_dt)),7,2), 120)
											else NULL
										 end)
					 ,@intSiteGroupId  = (SELECT TOP 1 intSiteGroupId 
											FROM tblCFSiteGroup 
											WHERE strSiteGroup COLLATE Latin1_General_CI_AS = cfips_site_grp_id COLLATE Latin1_General_CI_AS)

					 --,@intARItemID	   = (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = cfips_ar_itm_no COLLATE Latin1_General_CI_AS )
					 --,@dblIndexPrice   = cfips_idx_prc

				FROM cfipsmst
				WHERE cfips_idx_id = @originPK1 
				AND cfips_site_grp_id = @originPK2
					
				--================================--
				--		INSERT MASTER RECORD	  --
				--*******COMMIT TRANSACTION*******--
				--================================--
				INSERT [dbo].[tblCFIndexPricingBySiteGroupHeader](
				 [intPriceIndexId]
				,[dtmDate]
				,[intSiteGroupId])
				VALUES(
				 @intPriceIndexId	
				,@dtmDate		
				,@intSiteGroupId)

				----================================--
				----		INSERT DETAIL RECORDS	  --
				----================================--
				--SELECT @MasterPk  = SCOPE_IDENTITY();

				--INSERT [dbo].[tblCFIndexPricingBySiteGroup](
				-- [intIndexPricingBySiteGroupHeaderId]
				--,[intARItemID]
				--,[dblIndexPrice])					
				--VALUES(
				-- @MasterPk
				--,@intARItemID					
				--,@dblIndexPrice)


				----==================================--
				----		INSERT DETAIL RECORDS	  --
				----==================================--
				SELECT @MasterPk  = SCOPE_IDENTITY();

				SELECT A4GLIdentity INTO #tmpcfipsmstdetail
				FROM cfipsmst
				WHERE cfips_idx_id = @originPK1 
				AND cfips_site_grp_id = @originPK2
				
				WHILE (EXISTS(SELECT 1 FROM #tmpcfipsmstdetail))
				BEGIN

					SELECT @originDetailPK = A4GLIdentity FROM #tmpcfipsmstdetail

					SELECT TOP 1
					 @intARItemID	   = (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = cfips_ar_itm_no COLLATE Latin1_General_CI_AS )
					 ,@dblIndexPrice   = cfips_idx_prc
					FROM cfipsmst
					WHERE A4GLIdentity = @originDetailPK
					
					INSERT [dbo].[tblCFIndexPricingBySiteGroup](
					 [intIndexPricingBySiteGroupHeaderId]
					,[intARItemID]
					,[dblIndexPrice])					
					VALUES(
					 @MasterPk
					,@intARItemID					
					,@dblIndexPrice)

					PRINT @originDetailPK
					DELETE FROM #tmpcfipsmstdetail WHERE A4GLIdentity = @originDetailPK
				END

				DROP TABLE #tmpcfipsmstdetail


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
					,'Index Pricing By Site Group'
					,1
					,''
					,'cfipsmst'
					,'Index - ' + @originPK1 + ' , ' + 'Site group - '+ @originPK2
					,'tblCFIndexPricingBySiteGroupHeader'
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
					,'Index Pricing By Site Group'
					,0
					,ERROR_MESSAGE()
					,'cfipsmst'
					,'Index - ' + @originPK1 + ' , ' + 'Site group - '+ @originPK2
					,'tblCFIndexPricingBySiteGroupHeader'
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
			DELETE FROM #tmpcfipsmst WHERE cfips_idx_id = @originPK1 AND cfips_site_grp_id = @originPK2
		
			SET @Counter += 1;

		END
	
		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(*) - @TotalSuccess from cfdscmst
		PRINT @TotalFailed

	END