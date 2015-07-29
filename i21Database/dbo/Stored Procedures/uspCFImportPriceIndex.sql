
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
		PRINT '1 Time DISCOUNT SCHEDULE Synchronization'

		DECLARE @originPriceIndex				NVARCHAR(50)

		DECLARE @Counter						INT = 0

		DECLARE @strPriceIndex					NVARCHAR(250)
		DECLARE @strDescription					NVARCHAR(250)

		--Import only those are not yet imported
		SELECT cfpix_idx_id INTO #tmpcfpixmst
			FROM cfpixmst
				WHERE cfpix_idx_id COLLATE Latin1_General_CI_AS NOT IN (select strPriceIndex from tblCFPriceIndex) 

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
					
				
				INSERT [dbo].[tblCFPriceIndex](
				 [strPriceIndex]	
				,[strDescription])
				VALUES(
				@strPriceIndex	
				,@strDescription)

				COMMIT TRANSACTION
				SET @TotalSuccess += 1;
				
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @TotalFailed += 1;
				GOTO CONTINUELOOP;
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			PRINT @originPriceIndex
			DELETE FROM #tmpcfpixmst WHERE cfpix_idx_id = @originPriceIndex
		
			SET @Counter += 1;

		END
	
		--SET @Total = @Counter

	END