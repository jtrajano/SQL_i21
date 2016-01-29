﻿
CREATE PROCEDURE [dbo].[uspCFImportFeeProfile]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--====================================================--
		--     ONE TIME FEE PROFILE SYNCHRONIZATION	  --
		--====================================================--
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time Fee Profile Synchronization'

		DECLARE @originFeeProfile NVARCHAR(50)
		DECLARE @originFeeProfileDetail NVARCHAR(50)

		DECLARE @Counter						INT = 0
		DECLARE @MasterPk						INT

		
		--========================--
		--     MASTER FIELDS	  --
		--========================--			
		DECLARE @strFeeProfileId				NVARCHAR(MAX)
		DECLARE @strDescription					NVARCHAR(MAX)
		DECLARE @strInvoiceFormat				NVARCHAR(MAX)

		--========================--
		--     DETAIL FIELDS	  --
		--========================--
		DECLARE @intFeeId						INT
		DECLARE @strDetailDescription			NVARCHAR(MAX)
		DECLARE @dtmEndDate						DATETIME
		DECLARE @dtmStartDate					DATETIME

		--Import only those are not yet imported;

		SELECT DISTINCT cffpr_id INTO #tmpcff
		FROM cffprmst
		WHERE cffpr_id COLLATE Latin1_General_CI_AS NOT IN (select strFeeProfileId from tblCFFeeProfile) 

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
		,strSetupName = 'Fee Profile'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate fee profile on i21 Card Fueling fee profiles list'
		,strOriginTable = 'cffprmst'
		,strOriginIdentityId = cffpr_id
		,strI21Table = 'tblCFFeeProfile'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cffprmst
		WHERE cffpr_id COLLATE Latin1_General_CI_AS IN (select strFeeProfileId from tblCFFeeProfile) 
		
		--DUPLICATE SITE ON i21--

				
		WHILE (EXISTS(SELECT 1 FROM #tmpcff))
		BEGIN
				
			SELECT @originFeeProfile = cffpr_id FROM #tmpcff 

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					 @strFeeProfileId		   = LTRIM(RTRIM(cffpr_id))
					,@strDescription		   = LTRIM(RTRIM(cffpr_desc))
					,@strInvoiceFormat		   = (case
													when RTRIM(LTRIM(cffpr_ivc_formt)) = 'D' then 'Detail'
													when RTRIM(LTRIM(cffpr_ivc_formt)) = 'T' then 'Total'
													else 'FALSE'
												  end)
				FROM cffprmst
				WHERE cffpr_id = @originFeeProfile
				
					
				--================================--
				--		INSERT MASTER RECORD	  --
				--*******COMMIT TRANSACTION*******--
				--================================--
				INSERT [dbo].[tblCFFeeProfile](
				 [strFeeProfileId]
				,[strDescription]	
				,[strInvoiceFormat])
				VALUES(
				 @strFeeProfileId
				,@strDescription	
				,@strInvoiceFormat)

				--================================--
				--		INSERT DETAIL RECORDS	  --
				--================================--
				SELECT @MasterPk  = SCOPE_IDENTITY();

				SELECT cffpr_fee_id INTO #tmpcffprdmst
				FROM cffprmst
				WHERE cffpr_id COLLATE Latin1_General_CI_AS = @originFeeProfile
				
				WHILE (EXISTS(SELECT 1 FROM #tmpcffprdmst))
				BEGIN

					SELECT @originFeeProfileDetail = cffpr_fee_id FROM #tmpcffprdmst

					SELECT TOP 1
					 @intFeeId								=ISNULL((SELECT intFeeId 
																FROM tblCFFee 
																WHERE strFee = LTRIM(RTRIM(cffpr_fee_id))
																COLLATE Latin1_General_CI_AS),0)

					,@strDetailDescription					=LTRIM(RTRIM(cffpr_desc))
					,@dtmStartDate							=(case
																when LEN(RTRIM(LTRIM(ISNULL(cffpr_start_dt,0)))) = 8 
																then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cffpr_start_dt)),1,4) 
																	+ '/' + SUBSTRING (RTRIM(LTRIM(cffpr_start_dt)),5,2) + '/' 
																	+ SUBSTRING (RTRIM(LTRIM(cffpr_start_dt)),7,2), 120)
																else NULL
															  end)
					,@dtmEndDate							=(case
																when LEN(RTRIM(LTRIM(ISNULL(cffpr_end_dt,0)))) = 8 
																then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cffpr_end_dt)),1,4) 
																	+ '/' + SUBSTRING (RTRIM(LTRIM(cffpr_end_dt)),5,2) + '/' 
																	+ SUBSTRING (RTRIM(LTRIM(cffpr_end_dt)),7,2), 120)
																else NULL
															  end)
					FROM cffprmst
					WHERE cffpr_fee_id = @originFeeProfileDetail
					
					INSERT [dbo].[tblCFFeeProfileDetail](
					 [intFeeProfileId]
					,[intFeeId]
					,[strDescription]
					,[dtmEndDate]
					,[dtmStartDate]
					)
					VALUES(
					 @MasterPk
					,@intFeeId				
					,@strDetailDescription	
					,@dtmEndDate			
					,@dtmStartDate				
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
						,'Fee Profile Detail'
						,1
						,''
						,'cffprmst'
						,@originFeeProfileDetail
						,'tblCFFeeProfileDetail'
						,null
						,''
					)

					DELETE FROM #tmpcffprdmst WHERE cffpr_fee_id = @originFeeProfileDetail
				END

				DROP TABLE #tmpcffprdmst

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
						,'Fee Profile'
						,1
						,''
						,'cffprmst'
						,@originFeeProfile
						,'tblCFFeeProfile'
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
					,'Fee Profile'
					,0
					,ERROR_MESSAGE()
					,'cffprmst'
					,@originFeeProfile
					,'tblCFFeeProfile'
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
			PRINT @originFeeProfile
			DELETE FROM #tmpcff  WHERE cffpr_id = @originFeeProfile
		
			SET @Counter += 1;

		END
	
		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(*) - @TotalSuccess from cffprmst
		PRINT @TotalFailed

	END