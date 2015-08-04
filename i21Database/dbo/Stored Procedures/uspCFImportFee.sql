
CREATE PROCEDURE [dbo].[uspCFImportFee]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--====================================================--
		--     ONE TIME FEE GROUP SYNCHRONIZATION	  --
		--====================================================--
		
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time Fee Synchronization'

		DECLARE @originFee						NVARCHAR(50)

		DECLARE @Counter						INT = 0

		DECLARE @strFee							NVARCHAR(MAX)
		DECLARE @strFeeDescription				NVARCHAR(MAX)
		DECLARE @strCalculationType				NVARCHAR(MAX)
		DECLARE @strCalculationCard				NVARCHAR(MAX)
		DECLARE @strCalculationFrequency		NVARCHAR(MAX)
		DECLARE @ysnExtendedRemoteTrans			BIT
		DECLARE @ysnRemotesTrans				BIT
		DECLARE @ysnLocalTrans					BIT
		DECLARE @ysnForeignTrans				BIT
		DECLARE @intNetworkId					INT
		DECLARE @intCardTypeId					INT
		DECLARE @intMinimumThreshold			INT
		DECLARE @intMaximumThreshold			INT
		DECLARE @dblFeeRate						NUMERIC(18,6)
		DECLARE @intGLAccountId					INT
		DECLARE @intRestrictedByProduct			INT

		--Import only those are not yet imported
		SELECT cffee_id INTO #tmpcffeemst
			FROM cffeemst
				WHERE cffee_id COLLATE Latin1_General_CI_AS NOT IN (select strFee from tblCFFee) 

		WHILE (EXISTS(SELECT 1 FROM #tmpcffeemst))
		BEGIN
			
			SELECT @originFee = cffee_id FROM #tmpcffeemst

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					  @strFee					= LTRIM(RTRIM(cffee_id))
					 ,@strFeeDescription		= LTRIM(RTRIM(cffee_desc))
					 ,@strCalculationType		= (case
													when RTRIM(LTRIM(cffee_calc_type)) = 'P' then 'Percentage'
													when RTRIM(LTRIM(cffee_calc_type)) = 'F' then 'Flat'
													when RTRIM(LTRIM(cffee_calc_type)) = 'T' then 'Transaction'
													when RTRIM(LTRIM(cffee_calc_type)) = 'C' then 'Card'
													when RTRIM(LTRIM(cffee_calc_type)) = 'U' then 'Unit'
													else ''
													end)
					 ,@strCalculationCard		= (case
													when RTRIM(LTRIM(cffee_calc_card)) = 'P' then 'All Cards'
													when RTRIM(LTRIM(cffee_calc_card)) = 'W' then 'Active Cards'
													when RTRIM(LTRIM(cffee_calc_card)) = 'N' then 'New Cards'
													else ''
													end)
					 ,@strCalculationFrequency	= (case
													when RTRIM(LTRIM(cffee_calc_frequency)) = 'B' then 'Billing Cycle'
													when RTRIM(LTRIM(cffee_calc_frequency)) = 'M' then 'Monthly'
													when RTRIM(LTRIM(cffee_calc_frequency)) = 'A' then 'Annual'
													else ''
													end)
					 ,@ysnExtendedRemoteTrans	= (case
													when RTRIM(LTRIM(cffee_ext_remote_yn)) = 'N' then 'FALSE'
													when RTRIM(LTRIM(cffee_ext_remote_yn)) = 'Y' then 'TRUE'
													else 'FALSE'
													end)
					 ,@ysnRemotesTrans			= (case
													when RTRIM(LTRIM(cffee_remote_yn)) = 'N' then 'FALSE'
													when RTRIM(LTRIM(cffee_remote_yn)) = 'Y' then 'TRUE'
													else 'FALSE'
													end)
					 ,@ysnLocalTrans			= (case
													when RTRIM(LTRIM(cffee_local_yn)) = 'N' then 'FALSE'
													when RTRIM(LTRIM(cffee_local_yn)) = 'Y' then 'TRUE'
													else 'FALSE'
													end)
					 ,@ysnForeignTrans			= (case
													when RTRIM(LTRIM(cffee_foreign_yn)) = 'N' then 'FALSE'
													when RTRIM(LTRIM(cffee_foreign_yn)) = 'Y' then 'TRUE'
													else 'FALSE'
													end)
					 ,@intNetworkId				= ISNULL((SELECT intNetworkId 
												  FROM tblCFNetwork 
												  WHERE strNetwork = LTRIM(RTRIM(cffee_network_id))
												  COLLATE Latin1_General_CI_AS),0)
					 ,@intCardTypeId			= ISNULL((SELECT intCardTypeId 
												  FROM tblCFCardType 
												  WHERE strCardType = LTRIM(RTRIM(cffee_card_type))
												  COLLATE Latin1_General_CI_AS),0)
					 ,@intMinimumThreshold		= LTRIM(RTRIM(cffee_un_min_thres))
					 ,@intMaximumThreshold		= LTRIM(RTRIM(cffee_un_max_thres))
					 ,@dblFeeRate				= LTRIM(RTRIM(cffee_rt))
					 ,@intGLAccountId			= 0--LTRIM(RTRIM(cffee_acct1_8))
					 --,@intRestrictedByProduct	= LTRIM(RTRIM())
				FROM cffeemst
				WHERE cffee_id = @originFee
					
				
				INSERT [dbo].[tblCFFee](
					 [strFee]					
					,[strFeeDescription]		
					,[strCalculationType]		
					,[strCalculationCard]		
					,[strCalculationFrequency]	
					,[ysnExtendedRemoteTrans]	
					,[ysnRemotesTrans]			
					,[ysnLocalTrans]			
					,[ysnForeignTrans]			
					,[intNetworkId]				
					,[intCardTypeId]			
					,[intMinimumThreshold]		
					,[intMaximumThreshold]		
					,[dblFeeRate]				
					,[intGLAccountId]			
					,[intRestrictedByProduct]	
				)
				VALUES(
					@strFee					
					,@strFeeDescription		
					,@strCalculationType		
					,@strCalculationCard		
					,@strCalculationFrequency	
					,@ysnExtendedRemoteTrans	
					,@ysnRemotesTrans			
					,@ysnLocalTrans			
					,@ysnForeignTrans			
					,@intNetworkId				
					,@intCardTypeId			
					,@intMinimumThreshold		
					,@intMaximumThreshold		
					,@dblFeeRate				
					,@intGLAccountId			
					,@intRestrictedByProduct)
				COMMIT TRANSACTION
				SET @TotalSuccess += 1;
				
			END TRY
			BEGIN CATCH
				PRINT 'IMPORTING FEES' + ERROR_MESSAGE()
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
			PRINT @originFee
			DELETE FROM #tmpcffeemst WHERE cffee_id = @originFee
		
			SET @Counter += 1;

		END
	
		--SET @Total = @Counter

	END