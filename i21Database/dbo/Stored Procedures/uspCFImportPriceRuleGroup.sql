
CREATE PROCEDURE [dbo].[uspCFImportPriceRuleGroup]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--====================================================--
		--     ONE TIME PRICE RULE GROUP SYNCHRONIZATION	  --
		--====================================================--
		
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time PRICE RULE GROUP Synchronization'

		DECLARE @originPriceRuleGroup			NVARCHAR(50)

		DECLARE @Counter						INT = 0

		DECLARE @strPriceGroup					NVARCHAR(MAX)
		DECLARE @strPriceGroupDescription		NVARCHAR(MAX)

		--Import only those are not yet imported
		SELECT cfpgp_prc_grp_id INTO #tmpcfpgpmst
			FROM cfpgpmst
				WHERE cfpgp_prc_grp_id COLLATE Latin1_General_CI_AS NOT IN (select strPriceGroup from tblCFPriceRuleGroup) 

		WHILE (EXISTS(SELECT 1 FROM #tmpcfpgpmst))
		BEGIN
			
			SELECT @originPriceRuleGroup = cfpgp_prc_grp_id FROM #tmpcfpgpmst

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					 @strPriceGroup						  = LTRIM(RTRIM(cfpgp_prc_grp_id))
					,@strPriceGroupDescription			  = LTRIM(RTRIM(cfpgp_prc_grp_desc))
				FROM cfpgpmst
				WHERE cfpgp_prc_grp_id = @originPriceRuleGroup
					
				
				INSERT [dbo].[tblCFPriceRuleGroup](
				 [strPriceGroup]	
				,[strPriceGroupDescription])
				VALUES(
				 @strPriceGroup				
				,@strPriceGroupDescription)
				COMMIT TRANSACTION
				SET @TotalSuccess += 1;
				
			END TRY
			BEGIN CATCH
				PRINT 'IMPORTING PRICE RULE GROUP' + ERROR_MESSAGE()
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
			PRINT @originPriceRuleGroup
			DELETE FROM #tmpcfpgpmst WHERE cfpgp_prc_grp_id = @originPriceRuleGroup
		
			SET @Counter += 1;

		END
	
		--SET @Total = @Counter

	END