
CREATE PROCEDURE [dbo].[uspCFImportCard]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--====================================================--
		--     ONE TIME CARD SYNCHRONIZATION	  --
		--====================================================--
		--TRUNCATE TABLE tblCFDiscountScheduleFailedImport
		--TRUNCATE TABLE tblCFDiscountScheduleSuccessImport
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time Card Synchronization'

		DECLARE @originCard NVARCHAR(50)

		DECLARE @Counter						INT = 0
		
		DECLARE @intNetworkId					INT
		DECLARE @strCardNumber					NVARCHAR(MAX)
		DECLARE @strCardDescription				NVARCHAR(MAX)
		DECLARE @intAccountId					INT
		DECLARE @strCardForOwnUse				NVARCHAR(MAX)
		DECLARE @intExpenseItemId				INT
		DECLARE @intDefaultFixVehicleNumber		INT
		DECLARE @intDepartmentId				INT
		DECLARE @dtmLastUsedDated				DATETIME
		DECLARE @intCardTypeId					INT
		DECLARE @dtmIssueDate					DATETIME
		DECLARE @ysnActive						BIT
		DECLARE @ysnCardLocked					BIT
		DECLARE @strCardPinNumber				NVARCHAR(MAX)
		DECLARE @dtmCardExpiratioYearMonth		DATETIME
		DECLARE @strCardValidationCode			NVARCHAR(MAX)
		DECLARE @intNumberOfCardsIssued			INT
		DECLARE @intCardLimitedCode				INT
		DECLARE @intCardFuelCode				INT
		DECLARE @strCardTierCode				NVARCHAR(MAX)
		DECLARE @strCardOdometerCode			NVARCHAR(MAX)
		DECLARE @strCardWCCode					NVARCHAR(MAX)
		DECLARE @strSplitNumber					NVARCHAR(MAX)
		DECLARE @intCardManCode					INT
		DECLARE @intCardShipCat					INT
		DECLARE @intCardProfileNumber			INT
		DECLARE @intCardPositionSite			INT
		DECLARE @intCardvehicleControl			INT
		DECLARE @intCardCustomPin				INT
		DECLARE @intCreatedUserId				INT
		DECLARE @dtmCreated						DATETIME
		DECLARE @intLastModifiedUserId			INT
		DECLARE @dtmLastModified				DATETIME
		DECLARE @ysnCardForOwnUse				BIT
		DECLARE @ysnIgnoreCardTransaction		BIT
		
    
		--Import only those are not yet imported
		SELECT cfcus_card_no INTO #tmpcfcusmst
			FROM cfcusmst
				WHERE cfcus_card_no COLLATE Latin1_General_CI_AS NOT IN (select strCardNumber from tblCFCard) 

		WHILE (EXISTS(SELECT 1 FROM #tmpcfcusmst))
		BEGIN
				

			SELECT @originCard = cfcus_card_no FROM #tmpcfcusmst

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
				 @intNetworkId							   = ISNULL((SELECT intNetworkId 
																	FROM tblCFNetwork 
																	WHERE strNetwork = LTRIM(RTRIM(cfcus_network_id))
																	COLLATE Latin1_General_CI_AS),0)
				,@strCardNumber							   = LTRIM(RTRIM(cfcus_card_no))
				,@strCardDescription					   = LTRIM(RTRIM(cfcus_card_desc))
				,@intAccountId							   = ISNULL((SELECT cfAcct.intAccountId 
																    FROM tblCFAccount cfAcct
																    INNER JOIN tblARCustomer arAcct
																    ON cfAcct.intCustomerId = arAcct.intEntityCustomerId
																    WHERE arAcct.strCustomerNumber = LTRIM(RTRIM(cfcus_ar_cus_no))
																    COLLATE Latin1_General_CI_AS),0)
				--,@strCardForOwnUse						   = LTRIM(RTRIM())
				,@intExpenseItemId						   = ISNULL((SELECT intAccountId 
																	FROM tblGLAccount 
																	WHERE strAccountId = LTRIM(RTRIM(cfcus_exp_itm_no))
																	COLLATE Latin1_General_CI_AS),0)
				,@intDefaultFixVehicleNumber			   = ISNULL((SELECT intVehicleId 
																	FROM tblCFVehicle 
																	WHERE strVehicleNumber = LTRIM(RTRIM(cfcus_def_fix_veh_no))
																	COLLATE Latin1_General_CI_AS),0)
				,@intDepartmentId						   = ISNULL((SELECT intDepartmentId 
																	FROM tblCFDepartment 
																	WHERE strDepartment = LTRIM(RTRIM(cfcus_dept))
																	COLLATE Latin1_General_CI_AS),0)
				,@dtmLastUsedDated						   = (case
																when LEN(RTRIM(LTRIM(ISNULL(cfcus_date_last_used,0)))) = 8 
																then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfcus_date_last_used)),1,4) 
																	+ '/' + SUBSTRING (RTRIM(LTRIM(cfcus_date_last_used)),5,2) + '/' 
																	+ SUBSTRING (RTRIM(LTRIM(cfcus_date_last_used)),7,2), 120)
																else NULL
															 end)
				,@intCardTypeId							   = ISNULL((SELECT intCardTypeId 
																	FROM tblCFCardType 
																	WHERE strCardType = LTRIM(RTRIM(cfcus_card_type))
																	COLLATE Latin1_General_CI_AS),0)
				,@dtmIssueDate							   = (case
																when LEN(RTRIM(LTRIM(ISNULL(cfcus_issue_date,0)))) = 8 
																then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfcus_issue_date)),1,4) 
																	+ '/' + SUBSTRING (RTRIM(LTRIM(cfcus_issue_date)),5,2) + '/' 
																	+ SUBSTRING (RTRIM(LTRIM(cfcus_issue_date)),7,2), 120)
																else NULL
															 end)
				,@ysnActive								   = (case
															 when RTRIM(LTRIM(cfcus_active_yn)) = 'N' then 'FALSE'
															 when RTRIM(LTRIM(cfcus_active_yn)) = 'Y' then 'TRUE'
															 else 'FALSE'
															 end)
				,@ysnCardLocked							   = (case
															 when RTRIM(LTRIM(cfcus_card_locked_yn)) = 'N' then 'FALSE'
															 when RTRIM(LTRIM(cfcus_card_locked_yn)) = 'Y' then 'TRUE'
															 else 'FALSE'
															 end)
				,@strCardPinNumber						   = LTRIM(RTRIM(cfcus_card_pin_no))
				,@dtmCardExpiratioYearMonth				   = (case
																when LEN(RTRIM(LTRIM(ISNULL(cfcus_card_exp_yymm,0)))) = 8 
																then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfcus_card_exp_yymm)),1,4) 
																	+ '/' + SUBSTRING (RTRIM(LTRIM(cfcus_card_exp_yymm)),5,2) + '/' 
																	+ SUBSTRING (RTRIM(LTRIM(cfcus_card_exp_yymm)),7,2), 120)
																else NULL
															 end)
				,@strCardValidationCode					   = LTRIM(RTRIM(cfcus_card_valid_vnid))
				,@intNumberOfCardsIssued				   = LTRIM(RTRIM(cfcus_card_no_cards))
				,@intCardLimitedCode					   = LTRIM(RTRIM(cfcus_card_limited_code))
				,@intCardFuelCode						   = LTRIM(RTRIM(cfcus_card_fuel_code))
				,@strCardTierCode						   = LTRIM(RTRIM(cfcus_card_tier_code))
				,@strCardOdometerCode					   = LTRIM(RTRIM(cfcus_card_odom_code))
				,@strCardWCCode							   = LTRIM(RTRIM(cfcus_card_wc_code))
				--,@strSplitNumber						   = LTRIM(RTRIM())
				,@intCardManCode						   = LTRIM(RTRIM(cfcus_card_man_code))
				,@intCardShipCat						   = LTRIM(RTRIM(cfcus_card_ship_cat))
				,@intCardProfileNumber					   = LTRIM(RTRIM(cfcus_card_profile_no))
				,@intCardPositionSite					   = LTRIM(RTRIM(cfcus_card_pos_site))
				,@intCardvehicleControl					   = LTRIM(RTRIM(cfcus_card_veh_control))
				,@intCardCustomPin						   = LTRIM(RTRIM(cfcus_card_custom_pin))
				,@ysnCardForOwnUse						   = (case
															 when RTRIM(LTRIM(cfcus_own_use_yn)) = 'N' then 'FALSE'
															 when RTRIM(LTRIM(cfcus_own_use_yn)) = 'Y' then 'TRUE'
															 else 'FALSE'
															 end)
				,@ysnIgnoreCardTransaction				   = (case
															 when RTRIM(LTRIM(cfcus_own_use_yn)) = 'N' then 'FALSE'
															 when RTRIM(LTRIM(cfcus_own_use_yn)) = 'Y' then 'TRUE'
															 else 'FALSE'
															 end)
				,@intCreatedUserId						   = 0		
				,@dtmCreated							   = CONVERT(VARCHAR(10), GETDATE(), 120)				
				,@intLastModifiedUserId					   = 0
				,@dtmLastModified						   = CONVERT(VARCHAR(10), GETDATE(), 120)

				FROM cfcusmst
				WHERE cfcus_card_no = @originCard
					
				--================================--
				--		INSERT MASTER RECORD	  --
				--================================--
				INSERT [dbo].[tblCFCard](
					 [intNetworkId]			
					,[strCardNumber]			
					,[strCardDescription]		
					,[intAccountId]			
					,[strCardForOwnUse]		
					,[intExpenseItemId]		
					,[intDefaultFixVehicleNumber]
					,[intDepartmentId]		
					,[dtmLastUsedDated]		
					,[intCardTypeId]			
					,[dtmIssueDate]			
					,[ysnActive]				
					,[ysnCardLocked]			
					,[strCardPinNumber]		
					,[dtmCardExpiratioYearMonth]
					,[strCardValidationCode]	
					,[intNumberOfCardsIssued]	
					,[intCardLimitedCode]		
					,[intCardFuelCode]		
					,[strCardTierCode]		
					,[strCardOdometerCode]	
					,[strCardWCCode]			
					,[strSplitNumber]		
					,[intCardManCode]			
					,[intCardShipCat]			
					,[intCardProfileNumber]	
					,[intCardPositionSite]	
					,[intCardvehicleControl]	
					,[intCardCustomPin]		
					,[intCreatedUserId]		
					,[dtmCreated]				
					,[intLastModifiedUserId]	
					,[dtmLastModified]		
					,[ysnCardForOwnUse]		
					,[ysnIgnoreCardTransaction])
				VALUES(
					 @intNetworkId			
					,@strCardNumber			
					,@strCardDescription		
					,@intAccountId			
					,@strCardForOwnUse		
					,@intExpenseItemId		
					,@intDefaultFixVehicleNumber
					,@intDepartmentId		
					,@dtmLastUsedDated		
					,@intCardTypeId			
					,@dtmIssueDate			
					,@ysnActive				
					,@ysnCardLocked			
					,@strCardPinNumber		
					,@dtmCardExpiratioYearMonth
					,@strCardValidationCode	
					,@intNumberOfCardsIssued	
					,@intCardLimitedCode		
					,@intCardFuelCode		
					,@strCardTierCode		
					,@strCardOdometerCode	
					,@strCardWCCode			
					,@strSplitNumber			
					,@intCardManCode			
					,@intCardShipCat			
					,@intCardProfileNumber	
					,@intCardPositionSite	
					,@intCardvehicleControl	
					,@intCardCustomPin		
					,@intCreatedUserId		
					,@dtmCreated				
					,@intLastModifiedUserId	
					,@dtmLastModified		
					,@ysnCardForOwnUse		
					,@ysnIgnoreCardTransaction)

				COMMIT TRANSACTION
				SET @TotalSuccess += 1;
				--INSERT INTO tblCFDiscountScheduleSuccessImport(strDiscountScheduleId)					
				--VALUES(@originCard)			
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @TotalFailed += 1;
				PRINT 'IMPORTING CARDS' + ERROR_MESSAGE()
				--INSERT INTO tblCFDiscountScheduleFailedImport(strDiscountScheduleId,strReason)					
				--VALUES(@originCard,ERROR_MESSAGE())					
				--PRINT 'Failed to imports' + @originCustomer; --@@ERROR;
				GOTO CONTINUELOOP;
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			PRINT @originCard
			DELETE FROM #tmpcfcusmst WHERE cfcus_card_no = @originCard
		
			SET @Counter += 1;

		END
	
		--SET @Total = @Counter

	END