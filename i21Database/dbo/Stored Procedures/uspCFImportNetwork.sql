
CREATE PROCEDURE [dbo].[uspCFImportNetwork]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--================================================
		--     ONE TIME NETWORK SYNCHRONIZATION	
		--================================================
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time NETWORK Synchronization'

		DECLARE @originNetwork NVARCHAR(50)
		DECLARE @Counter								 INT = 0
		DECLARE @MasterPk								 INT

		DECLARE @strNetwork								 NVARCHAR(MAX)
		DECLARE @strNetworkType							 NVARCHAR(MAX)
		DECLARE @strNetworkDescription					 NVARCHAR(MAX)
		DECLARE @strPPFileImportType					 NVARCHAR(MAX)
		DECLARE @strRejectPath							 NVARCHAR(MAX)
		DECLARE @strParticipant							 NVARCHAR(MAX)
		DECLARE @strCFNFileVersion						 NVARCHAR(MAX)
		DECLARE @strExemptLCCode						 NVARCHAR(MAX)
		DECLARE @strLinkNetwork							 NVARCHAR(MAX)
		DECLARE @strImportPath							 NVARCHAR(MAX)
		DECLARE @dblFeeRateAmount						 NUMERIC(18, 6)
		DECLARE @dblFeePerGallon						 NUMERIC(18, 6)
		DECLARE @dblFeeTransactionPerGallon				 NUMERIC(18, 6)
		DECLARE @dblMonthlyCommisionFeeAmount			 NUMERIC(18, 6)
		DECLARE @dblVariableCommisionFeePerGallon		 NUMERIC(18, 6)
		DECLARE @dtmLastImportDate						 DATETIME
		DECLARE @intErrorBatchNumber					 INT
		DECLARE @intPPhostId							 INT
		DECLARE @intPPDistributionSite					 INT
		DECLARE @intCustomerId							 INT
		DECLARE @intCACustomerId						 INT
		DECLARE @intDebitMemoGLAccount					 INT
		DECLARE @intLocationId							 INT
		DECLARE @ysnRejectExportCard					 BIT
		DECLARE @ysnPassOnSSTFromRemotes				 BIT
		DECLARE @ysnExemptFETOnRemotes					 BIT
		DECLARE @ysnExemptSETOnRemotes					 BIT
		DECLARE @ysnExemptLCOnRemotes					 BIT

		--========================--
		--    DETAIL CARD TYPE    --
		--========================--
		--DECLARE @originCardType							 NVARCHAR(MAX)
		--DECLARE @strCardType							 NVARCHAR(MAX)
		--DECLARE @strCardTypeDescription					 NVARCHAR(MAX)

		--Import only those are not yet imported
		SELECT cfnet_network_id INTO #tmpcfnetmst
			FROM cfnetmst
				WHERE cfnet_network_id COLLATE Latin1_General_CI_AS NOT IN (select strNetwork from tblCFNetwork) 

		--DUPLICATE NETWORK ON i21--

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
		,strSetupName = 'Network'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate network on i21 Card Fueling networks list'
		,strOriginTable = 'cfnetmst'
		,strOriginIdentityId = cfnet_network_id
		,strI21Table = 'tblCFNetwork'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cfnetmst
		WHERE cfnet_network_id COLLATE Latin1_General_CI_AS IN (select strNetwork from tblCFNetwork) 
		
		--DUPLICATE NETWORK ON i21--

		WHILE (EXISTS(SELECT 1 FROM #tmpcfnetmst))
		BEGIN
				

			SELECT @originNetwork = cfnet_network_id FROM #tmpcfnetmst
			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					 @strNetwork						  = ISNULL(LTRIM(RTRIM(cfnet_network_id)),'')
					,@strNetworkType					  = (case
															 when RTRIM(LTRIM(cfnet_network_type)) = 'C' then 'CFN'
															 when RTRIM(LTRIM(cfnet_network_type)) = 'F' then 'Fuel Link'
															 when RTRIM(LTRIM(cfnet_network_type)) = 'P' then 'PacPride'
															 when RTRIM(LTRIM(cfnet_network_type)) = 'Z' then 'Non Network'
															else NULL
															end)
					,@strNetworkDescription				  =	ISNULL(LTRIM(RTRIM(cfnet_network_desc)),'')
					,@strPPFileImportType				  =	ISNULL(LTRIM(RTRIM(cfnet_pp_file_import_type)),'')
					,@strRejectPath						  =	ISNULL(LTRIM(RTRIM(cfnet_reject_path)),'')
					,@strParticipant					  =	ISNULL(LTRIM(RTRIM(cfnet_participant)),'')
					,@strCFNFileVersion					  =	ISNULL(LTRIM(RTRIM(cfnet_cfn_file_version)),'')
					,@strExemptLCCode					  =	ISNULL(LTRIM(RTRIM(cfnet_exempt_lc_code)),'')
					,@strLinkNetwork					  =	ISNULL(LTRIM(RTRIM(cfnet_lnk_network_id)),'')
					,@strImportPath						  =	ISNULL(LTRIM(RTRIM(cfnet_import_path)),'')
					,@dblFeeRateAmount					  =	cfnet_rt_fee_amt
					,@dblFeePerGallon					  =	cfnet_rt_fee_gal
					,@dblFeeTransactionPerGallon		  =	cfnet_ft_fee_gal
					,@dblMonthlyCommisionFeeAmount		  =	cfnet_monthly_comm_fee_amt
					,@dblVariableCommisionFeePerGallon	  =	cfnet_variable_comm_fee_gal
					,@dtmLastImportDate					  =	(case
															when LEN(RTRIM(LTRIM(ISNULL(cfnet_last_import_date,0)))) = 8 
															then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfnet_last_import_date)),1,4) 
																+ '/' + SUBSTRING (RTRIM(LTRIM(cfnet_last_import_date)),5,2) + '/' 
																+ SUBSTRING (RTRIM(LTRIM(cfnet_last_import_date)),7,2), 120)
															else NULL
															end)
					,@intErrorBatchNumber				  =	ISNULL(cfnet_error_batch_no,0)
					,@intPPhostId						  =	ISNULL(cfnet_pp_host_id,0)
					,@intPPDistributionSite				  =	ISNULL(cfnet_pp_sub_dist_site,0)
					,@intCustomerId						  =	(SELECT [intEntityId] 
															FROM tblARCustomer 
															WHERE strCustomerNumber = LTRIM(RTRIM(cfnet_ar_cus_no)) COLLATE Latin1_General_CI_AS)

					,@intCACustomerId					  =	(SELECT [intEntityId] 
															FROM tblARCustomer 
															WHERE strCustomerNumber = LTRIM(RTRIM(cfnet_ca_ar_cus_no)) COLLATE Latin1_General_CI_AS)

					,@intDebitMemoGLAccount				  =	ISNULL((SELECT intAccountId 
															FROM tblGLAccount 
															WHERE strAccountId = LTRIM(RTRIM(cfnet_db_gl_acct)) COLLATE Latin1_General_CI_AS),0)

					,@intLocationId						  =	null --LTRIM(RTRIM(cfnet_ft_loc_no))

					,@ysnRejectExportCard				  =	(case
															 when RTRIM(LTRIM(cfnet_export_card_rejects_yn)) = 'N' then 'FALSE'
															 when RTRIM(LTRIM(cfnet_export_card_rejects_yn)) = 'Y' then 'TRUE'
															else 'FALSE'
															end)

					,@ysnPassOnSSTFromRemotes			  =	(case
															 when RTRIM(LTRIM(cfnet_passon_sst_from_remotes)) = 'N' then 'FALSE'
															 when RTRIM(LTRIM(cfnet_passon_sst_from_remotes)) = 'Y' then 'TRUE'
															else 'FALSE'
															end)

					,@ysnExemptFETOnRemotes				  =	(case
															 when RTRIM(LTRIM(cfnet_exempt_fet_on_remotes_yn)) = 'N' then 'FALSE'
															 when RTRIM(LTRIM(cfnet_exempt_fet_on_remotes_yn)) = 'Y' then 'TRUE'
															else 'FALSE'
															end)

					,@ysnExemptSETOnRemotes				  =	(case
															 when RTRIM(LTRIM(cfnet_exempt_set_on_remotes_yn)) = 'N' then 'FALSE'
															 when RTRIM(LTRIM(cfnet_exempt_set_on_remotes_yn)) = 'Y' then 'TRUE'
															else 'FALSE'
															end)

					,@ysnExemptLCOnRemotes				  =	(case
															 when RTRIM(LTRIM(cfnet_exempt_lc_on_remotes_yn)) = 'N' then 'FALSE'
															 when RTRIM(LTRIM(cfnet_exempt_lc_on_remotes_yn)) = 'Y' then 'TRUE'
															else 'FALSE'
															end)
				FROM cfnetmst
				WHERE cfnet_network_id = @originNetwork

				--================================--
				--       INSERT MASTER RECORD     --
				--================================--
				INSERT [dbo].[tblCFNetwork](
					 [strNetwork]							
					,[strNetworkType]						
					,[strNetworkDescription]				
					,[strPPFileImportType]				
					,[strRejectPath]					
					,[strParticipant]						
					,[strCFNFileVersion]					
					,[strExemptLCCode]					
					,[strLinkNetwork]						
					,[strImportPath]						
					,[dblFeeRateAmount]					
					,[dblFeePerGallon]					
					,[dblFeeTransactionPerGallon]			
					,[dblMonthlyCommisionFeeAmount]		
					,[dblVariableCommisionFeePerGallon]	
					,[dtmLastImportDate]					
					,[intErrorBatchNumber]				
					,[intPPhostId]						
					,[intPPDistributionSite]				
					,[intCustomerId]						
					,[intCACustomerId]					
					,[intDebitMemoGLAccount]				
					,[intLocationId]					
					,[ysnRejectExportCard]				
					,[ysnPassOnSSTFromRemotes]		
					,[ysnExemptFETOnRemotes]				
					,[ysnExemptSETOnRemotes]				
					,[ysnExemptLCOnRemotes])
				VALUES(
					 @strNetwork							
					,@strNetworkType						
					,@strNetworkDescription				
					,@strPPFileImportType				
					,@strRejectPath						
					,@strParticipant						
					,@strCFNFileVersion					
					,@strExemptLCCode					
					,@strLinkNetwork						
					,@strImportPath						
					,@dblFeeRateAmount					
					,@dblFeePerGallon					
					,@dblFeeTransactionPerGallon			
					,@dblMonthlyCommisionFeeAmount		
					,@dblVariableCommisionFeePerGallon	
					,@dtmLastImportDate					
					,@intErrorBatchNumber				
					,@intPPhostId						
					,@intPPDistributionSite				
					,@intCustomerId						
					,@intCACustomerId					
					,@intDebitMemoGLAccount				
					,@intLocationId						
					,@ysnRejectExportCard				
					,@ysnPassOnSSTFromRemotes			
					,@ysnExemptFETOnRemotes				
					,@ysnExemptSETOnRemotes				
					,@ysnExemptLCOnRemotes)

				SELECT @MasterPk  = SCOPE_IDENTITY();

				--====================================--
				--		INSERT DETAIL CARD TYPE 	  --
				--			 REQUIRED FIELDS		  --
				--									  --
				--	1. intNetworkId					  --
				--									  --
			
				--SELECT cfcty_type INTO #tmpcfctymst
				--FROM cfctymst
				--WHERE cfcty_network_id COLLATE Latin1_General_CI_AS = @originNetwork			
					
				--WHILE (EXISTS(SELECT 1 FROM #tmpcfctymst))
				--BEGIN
					
				--	SELECT @originCardType = cfcty_type FROM #tmpcfctymst
					
				--	SELECT TOP 1
				--	 @strCardType					  = LTRIM(RTRIM(cfcty_type))
				--	,@strCardTypeDescription		  = LTRIM(RTRIM(cfcty_desc))
				--	FROM cfctymst
				--	WHERE cfcty_type = @originCardType
					
				--	INSERT [dbo].[tblCFCardType](
				--		 [intNetworkId]
				--		,[strCardType]	
				--		,[strDescription]	
				--	)
				--	VALUES(
				--		 @MasterPk
				--		,@strCardType	
				--		,@strCardTypeDescription	
				--	)
				--	CARDTYPELOOP:
				--	PRINT @originCardType
				--	DELETE FROM #tmpcfctymst WHERE cfcty_type = @originCardType
				--END
				--DROP TABLE #tmpcfctymst
				--====================================--

				COMMIT TRANSACTION
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
				   ,'Network'
				   ,1
				   ,''
				   ,'cfnetmst'
				   ,@originNetwork
				   ,'tblCFNetwork'
				   ,@MasterPk
				   ,''
				)
			END TRY
			BEGIN CATCH
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
				   ,'Network'
				   ,0
				   ,ERROR_MESSAGE()
				   ,'cfnetmst'
				   ,@originNetwork
				   ,'tblCFNetwork'
				   ,null
				   ,''
				)
				GOTO CONTINUELOOP;
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			DELETE FROM #tmpcfnetmst WHERE cfnet_network_id = @originNetwork
		END
		
			PRINT @TotalSuccess
			SELECT @TotalFailed = COUNT(*) - @TotalSuccess from cfnetmst
			PRINT @TotalFailed

	END