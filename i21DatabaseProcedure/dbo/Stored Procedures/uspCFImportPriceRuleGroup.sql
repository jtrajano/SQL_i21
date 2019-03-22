
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
		,strSetupName = 'Price Rule Group'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate price rule group on i21 Card Fueling price rule groups list'
		,strOriginTable = 'cfpgpmst'
		,strOriginIdentityId = cfpgp_prc_grp_id
		,strI21Table = 'tblCFPriceRuleGroup'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cfpgpmst
		WHERE cfpgp_prc_grp_id COLLATE Latin1_General_CI_AS IN (select strPriceGroup from tblCFPriceRuleGroup) 
		
		--DUPLICATE SITE ON i21--

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
					
				--*********************COMMIT TRANSACTION*****************--
				INSERT [dbo].[tblCFPriceRuleGroup](
				 [strPriceGroup]	
				,[strPriceGroupDescription])
				VALUES(
				 @strPriceGroup				
				,@strPriceGroupDescription)

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
						,'Price Rule Group'
						,1
						,''
						,'cfpgpmst'
						,@originPriceRuleGroup
						,'tblCFPriceRuleGroup'
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
					,'Price Rule Group'
					,0
					,ERROR_MESSAGE()
					,'cfpgpmst'
					,@originPriceRuleGroup
					,'tblCFPriceRuleGroup'
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
			DELETE FROM #tmpcfpgpmst WHERE cfpgp_prc_grp_id = @originPriceRuleGroup
		
			SET @Counter += 1;

		END
	
		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(*) - @TotalSuccess from cfpgpmst
		PRINT @TotalFailed

	END