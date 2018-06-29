
CREATE PROCEDURE [dbo].[uspCFImportPriceIndex]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--============================================--
		--     ONE TIME PRICE INDEX SYNCHRONIZATION	  --
		--============================================--
		
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time Price Index Synchronization'

		DECLARE @originPriceIndex				NVARCHAR(50)

		DECLARE @Counter						INT = 0

		DECLARE @strPriceIndex					NVARCHAR(250)
		DECLARE @strDescription					NVARCHAR(250)

		--Import only those are not yet imported
		SELECT cfpix_idx_id INTO #tmpcfpixmst
			FROM cfpixmst
				WHERE cfpix_idx_id COLLATE Latin1_General_CI_AS NOT IN (select strPriceIndex from tblCFPriceIndex) 

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
		,strSetupName = 'Price Index'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate price index on i21 Card Fueling price indexes list'
		,strOriginTable = 'cfpixmst'
		,strOriginIdentityId = cfpix_idx_id
		,strI21Table = 'tblCFPriceIndex'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cfpixmst
		WHERE cfpix_idx_id COLLATE Latin1_General_CI_AS IN (select strPriceIndex from tblCFPriceIndex) 
		
		--DUPLICATE SITE ON i21--

		WHILE (EXISTS(SELECT 1 FROM #tmpcfpixmst))
		BEGIN
			
			SELECT @originPriceIndex = cfpix_idx_id FROM #tmpcfpixmst

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					@strPriceIndex				 = RTRIM(LTRIM(cfpix_idx_id))
					,@strDescription			 = RTRIM(LTRIM(cfpix_idx_desc))
				FROM cfpixmst
				WHERE cfpix_idx_id = @originPriceIndex
					
				--*********************COMMIT TRANSACTION*****************--
				INSERT [dbo].[tblCFPriceIndex](
				 [strPriceIndex]	
				,[strDescription])
				VALUES(
				@strPriceIndex	
				,@strDescription)

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
						,'Price Index'
						,1
						,''
						,'cfpixmst'
						,@originPriceIndex
						,'tblCFPriceIndex'
						,SCOPE_IDENTITY()
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
					,'Price Index'
					,0
					,ERROR_MESSAGE()
					,'cfpixmst'
					,@originPriceIndex
					,'tblCFPriceIndex'
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
			DELETE FROM #tmpcfpixmst WHERE cfpix_idx_id = @originPriceIndex
		
			SET @Counter += 1;

		END
	
		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(*) - @TotalSuccess from cfpixmst
		PRINT @TotalFailed

	END