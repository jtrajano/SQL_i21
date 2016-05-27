﻿CREATE PROCEDURE [dbo].[uspCFImportTransaction]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--====================================================--
		--     ONE TIME TRANSACTION SYNCHRONIZATION	  --
		--====================================================--
		--TRUNCATE TABLE tblCFDiscountScheduleFailedImport
		--TRUNCATE TABLE tblCFDiscountScheduleSuccessImport
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time Transaction Synchronization'

		DECLARE @originTransaction				INT
		DECLARE @Counter						INT

		DECLARE @strSiteId						NVARCHAR(MAX)
		DECLARE @strCardId						NVARCHAR(MAX)
		DECLARE @strVehicleId					NVARCHAR(MAX)
		DECLARE @strProductId					NVARCHAR(MAX)
		DECLARE @strNetworkId					NVARCHAR(MAX)	= NULL
		DECLARE @intSiteId						INT				= 0
		DECLARE @intNetworkId					INT				= 0
		DECLARE @intTransTime					INT				= 0
		DECLARE @intOdometer					INT				= 0
		DECLARE @intPumpNumber					INT				= 0
		DECLARE @intContractId					INT				= 0
		DECLARE @intSalesPersonId				INT				= NULL
		DECLARE @dtmBillingDate					DATETIME		= NULL
		DECLARE @dtmTransactionDate				DATETIME		= NULL
		DECLARE @strSequenceNumber				NVARCHAR(MAX)	= NULL
		DECLARE @strPONumber					NVARCHAR(MAX)	= NULL
		DECLARE @strMiscellaneous				NVARCHAR(MAX)	= NULL
		DECLARE @strPriceMethod					NVARCHAR(MAX)	= NULL
		DECLARE @strPriceBasis					NVARCHAR(MAX)	= NULL
		DECLARE @strTransactionType				NVARCHAR(MAX)	= NULL
		DECLARE @strDeliveryPickupInd			NVARCHAR(MAX)	= NULL
		DECLARE @dblQuantity					NUMERIC(18,6)	= 0.000000
		DECLARE @dblTransferCost				NUMERIC(18,6)	= 0.000000
		DECLARE @dblOriginalTotalPrice			NUMERIC(18,6)	= 0.000000
		DECLARE @dblCalculatedTotalPrice		NUMERIC(18,6)	= 0.000000
		DECLARE @dblOriginalGrossPrice			NUMERIC(18,6)	= 0.000000
		DECLARE @dblCalculatedGrossPrice		NUMERIC(18,6)	= 0.000000
		DECLARE @dblCalculatedNetPrice			NUMERIC(18,6)	= 0.000000
		DECLARE @dblOriginalNetPrice			NUMERIC(18,6)	= 0.000000
		DECLARE @dblCalculatedPumpPrice			NUMERIC(18,6)	= 0.000000
		DECLARE @dblOriginalPumpPrice			NUMERIC(18,6)	= 0.000000
		DECLARE @guid							NVARCHAR(MAX)
		DECLARE @processDate					NVARCHAR(MAX)


		SET @guid = NEWID()
		SET @processDate = CONVERT(VARCHAR(10), GETDATE(), 101)

		--Import only those are not yet imported
		SELECT A4GLIdentity INTO #tmpcftrxmst
			FROM cftrxmst

		WHILE (EXISTS(SELECT 1 FROM #tmpcftrxmst))
		BEGIN
				

			SELECT @originTransaction = A4GLIdentity FROM #tmpcftrxmst

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
				 @strSiteId							= cftrx_site
				,@strCardId							= cftrx_card_no
				,@strVehicleId						= cftrx_vehl_no
				,@strProductId						= cftrx_card_itm_no
				,@strNetworkId						= cftrx_network_id
				,@intOdometer						= cftrx_odometer
				,@intPumpNumber						= cftrx_pump_no
				--,@intSiteId						= null
				--,@intNetworkId					= null
				--,@intTransTime					= not sure 
				--,@intContractId					= not sure 
				--,@intSalesPersonId				= not sure 
				,@dtmBillingDate					= (CASE
														WHEN LEN(RTRIM(LTRIM(ISNULL(cftrx_billing_dt,0)))) = 8 
														THEN CONVERT(DATETIME, SUBSTRING (RTRIM(LTRIM(cftrx_billing_dt)),1,4) 
															+ '/' + SUBSTRING (RTRIM(LTRIM(cftrx_billing_dt)),5,2) + '/' 
															+ SUBSTRING (RTRIM(LTRIM(cftrx_billing_dt)),7,2), 120)
														ELSE NULL
													  END)
				,@dtmTransactionDate				= (CASE
														WHEN LEN(RTRIM(LTRIM(ISNULL(cftrx_billing_dt,0)))) = 8 
														THEN CONVERT(DATETIME, SUBSTRING (RTRIM(LTRIM(cftrx_billing_dt)),1,4) 
															+ '/' + SUBSTRING (RTRIM(LTRIM(cftrx_billing_dt)),5,2) + '/' 
															+ SUBSTRING (RTRIM(LTRIM(cftrx_billing_dt)),7,2), 120)
														ELSE NULL
													  END) 
				,@strSequenceNumber					= cftrx_seq_no
				,@strPONumber						= cftrx_po_no
				,@strMiscellaneous					= cftrx_misc
				--,@strPriceMethod					= not sure 
				--,@strPriceBasis					= not sure 
				--,@strTransactionType				= not sure 
				,@strDeliveryPickupInd				= cftrx_dlvry_pickup_ind
				,@dblQuantity						= cftrx_qty
				--,@dblTransferCost					= not sure 
				--,@dblOriginalTotalPrice			= ot sure 
				--,@dblCalculatedTotalPrice			= not sure 
				,@dblOriginalGrossPrice				= cftrx_prc
				--,@dblCalculatedGrossPrice			= not sure 
				--,@dblCalculatedNetPrice			= not sure 
				--,@dblOriginalNetPrice				= not sure 
				--,@dblCalculatedPumpPrice			= not sure 
				--,@dblOriginalPumpPrice			= not sure 


				FROM cftrxmst
				WHERE A4GLIdentity = @originTransaction
				
				
				--================================--
				--		INSERT MASTER RECORD	  --
				--================================--
				exec dbo.uspCFInsertTransactionRecord 
				 @strSiteId					= @strSiteId
				,@strCardId					= @strCardId
				,@strVehicleId				= @strVehicleId
				,@strProductId				= @strProductId
				,@strNetworkId				= @strNetworkId
				,@intSiteId					= @intSiteId
				,@intNetworkId				= @intNetworkId
				,@intTransTime				= @intTransTime
				,@intOdometer				= @intOdometer
				,@intPumpNumber				= @intPumpNumber
				,@intContractId				= @intContractId
				,@intSalesPersonId			= @intSalesPersonId
				,@dtmBillingDate			= @dtmBillingDate
				,@dtmTransactionDate		= @dtmTransactionDate
				,@strSequenceNumber			= @strSequenceNumber
				,@strPONumber				= @strPONumber
				,@strMiscellaneous			= @strMiscellaneous
				,@strPriceMethod			= @strPriceMethod
				,@strPriceBasis				= @strPriceBasis
				,@strTransactionType		= @strTransactionType
				,@strDeliveryPickupInd		= @strDeliveryPickupInd
				,@dblQuantity				= @dblQuantity
				,@dblTransferCost			= @dblTransferCost
				,@dblOriginalTotalPrice		= @dblOriginalTotalPrice
				,@dblCalculatedTotalPrice	= @dblCalculatedTotalPrice
				,@dblOriginalGrossPrice		= @dblOriginalGrossPrice
				,@dblCalculatedGrossPrice	= @dblCalculatedGrossPrice
				,@dblCalculatedNetPrice		= @dblCalculatedNetPrice
				,@dblOriginalNetPrice		= @dblOriginalNetPrice
				,@dblCalculatedPumpPrice	= @dblCalculatedPumpPrice
				,@dblOriginalPumpPrice		= @dblOriginalPumpPrice
				,@ysnOriginHistory			= 1
				,@strGUID					= @guid
				,@strProcessDate			= @processDate


				COMMIT TRANSACTION
				SET @TotalSuccess += 1;
				--INSERT INTO tblCFDiscountScheduleSuccessImport(strDiscountScheduleId)					
				--VALUES(@originCard)			
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @TotalFailed += 1;
				PRINT 'IMPORTING TRANSACTION' + ERROR_MESSAGE()
				--INSERT INTO tblCFDiscountScheduleFailedImport(strDiscountScheduleId,strReason)					
				--VALUES(@originCard,ERROR_MESSAGE())					
				--PRINT 'Failed to imports' + CONVERT(@originTransaction,NVARCHAR); --@@ERROR;
				GOTO CONTINUELOOP;
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			PRINT @originTransaction
			DELETE FROM #tmpcftrxmst WHERE A4GLIdentity = @originTransaction
		
			SET @Counter += 1;

		END
	
		--SET @Total = @Counter

	END