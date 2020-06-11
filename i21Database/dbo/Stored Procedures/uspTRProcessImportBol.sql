CREATE PROCEDURE [dbo].[uspTRProcessImportBol]
	@intImportLoadId INT
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	BEGIN TRY

		DECLARE @CursorHeaderTran AS CURSOR
		SET @CursorHeaderTran = CURSOR FOR
		SELECT DISTINCT 
			LD.intTruckId,  
			LD.intCarrierId, 
			LD.intDriverId, 
			LD.intTrailerId, 
			LD.dtmPullDate
		FROM tblTRImportLoadDetail LD WHERE LD.ysnValid = 1 AND LD.intImportLoadId = @intImportLoadId

		DECLARE @intTruckId INT = NULL,
			@intCarrierId INT = NULL,
			@intDriverId INT = NULL,
			@intTrailerId INT = NULL,
			@dtmPullDate DATETIME = NULL,
			@strTransactionNumber NVARCHAR(50) = NULL,
			@intLoadHeaderId INT = NULL,
			@intSellerId INT = NULL,
			@intFreightItemId INT = NULL

		-- GET DEFAULT SELLER
		SELECT TOP 1 @intSellerId = intSellerId, @intFreightItemId = intItemForFreightId FROM tblTRCompanyPreference 

		BEGIN TRANSACTION

		OPEN @CursorHeaderTran
		FETCH NEXT FROM @CursorHeaderTran INTO @intTruckId, @intCarrierId, @intDriverId, @intTrailerId, @dtmPullDate
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- HEADER INFO

			-- GET STARTING NUMBER
			EXEC uspSMGetStartingNumber 54, @strTransactionNumber OUT
			
			-- TR HEADER
			INSERT INTO tblTRLoadHeader (dtmLoadDateTime, intShipViaId, intSellerId, intDriverId, intTruckDriverReferenceId, intTrailerId, strTransaction, intFreightItemId, intConcurrencyId)
			VALUES (@dtmPullDate, @intCarrierId, @intSellerId, @intDriverId, @intTruckId, @intTrailerId, @strTransactionNumber, @intFreightItemId, 1)
			
			SET @intLoadHeaderId = @@identity

			UPDATE tblTRImportLoadDetail SET strMessage = @strTransactionNumber, intLoadHeaderId = @intLoadHeaderId
			WHERE intImportLoadId = @intImportLoadId 
			AND intTruckId = @intTruckId 
			AND intCarrierId = @intCarrierId 
			AND intDriverId = @intDriverId 
			AND intTrailerId = @intTrailerId 
			AND dtmPullDate = @dtmPullDate
			AND ysnValid = 1

			-- RECEIPT
			DECLARE @CursorReceiptTran AS CURSOR
			SET @CursorReceiptTran = CURSOR FOR
			SELECT LD.intVendorId, 
				LD.intSupplyPointId, 
				LD.intVendorCompanyLocationId,
				LD.intPullProductId,
				SUM(LD.dblDropGross) dblDropGross, 
				SUM(LD.dblDropNet) dblDropNet,
				LD.strBillOfLading
			FROM tblTRImportLoadDetail LD 
			WHERE LD.ysnValid = 1 AND LD.intLoadHeaderId = @intLoadHeaderId
			GROUP BY LD.intVendorId, LD.intSupplyPointId, LD.intVendorCompanyLocationId, LD.intPullProductId, LD.strBillOfLading

			DECLARE @intVendorId INT = NULL,
				@intSupplyPointId INT = NULL,
				@intVendorCompanyLocationId INT = NULL,
				@intPullProductId INT = NULL,		
				@dblDropGross NUMERIC(18,6) = NULL,
				@dblDropNet NUMERIC(18,6) = NULL,
				@strOrigin NVARCHAR(20) = NULL,
				@dblUnitCost NUMERIC(18,6) = NULL,
				@strBillOfLading NVARCHAR(50) = NULL,
				@intReceiptCounter INT = 0,
				@intLoadReceiptId INT = NULL,
				@intReceiptTaxGroupId INT = NULL,
				@strReceiptZipCode NVARCHAR(50) = NULL,
				@strGrossNet NVARCHAR(20) = NULL

			OPEN @CursorReceiptTran
			FETCH NEXT FROM @CursorReceiptTran INTO @intVendorId, @intSupplyPointId, @intVendorCompanyLocationId, @intPullProductId, @dblDropGross, @dblDropNet, @strBillOfLading
			WHILE @@FETCH_STATUS = 0
			BEGIN

				SELECT @intReceiptTaxGroupId = EL.intTaxGroupId, @strReceiptZipCode = EL.strZipCode, @strGrossNet = ISNULL(SP.strGrossOrNet, 'Gross') FROM tblTRSupplyPoint SP
				INNER JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = SP.intEntityLocationId 
				WHERE ISNULL(SP.intSupplyPointId, 0) = ISNULL(@intSupplyPointId, 0) 
				AND ISNULL(EL.intEntityId, 0) = ISNULL(@intVendorId, 0)

				-- RECEIPT COUNTER
				SET @intReceiptCounter = @intReceiptCounter + 1
				
				--GET ORIGIN TYPE
				SET @strOrigin = CASE WHEN @intVendorId IS NULL THEN 'Location' ELSE 'Terminal' END

				-- GET UNIT COST
				IF(@strOrigin = 'Terminal')
				BEGIN
					EXECUTE [dbo].[uspTRGetRackPrice] 
						@dtmPullDate
						,0
						,@intSupplyPointId
						,@intPullProductId
						,@dblUnitCost OUTPUT
				END
				ELSE
				BEGIN
					SET @strGrossNet = 'Gross'

					SELECT @dblUnitCost = dblReceiveLastCost 
					FROM vyuICGetItemStock WHERE intItemId = @intPullProductId 
					AND intLocationId = @intVendorCompanyLocationId 
					AND strType NOT IN ('Other Charge','Bundle','Kit','Service','Sofware')
				END

				-- RECEIPT
				INSERT INTO tblTRLoadReceipt (intLoadHeaderId, 
					strOrigin, 
					intTerminalId, 
					intSupplyPointId, 
					intCompanyLocationId, 
					strBillOfLading, 
					intItemId, 
					dblGross, 
					dblNet, 
					dblUnitCost, 
					dblFreightRate, 
					dblPurSurcharge, 
					strReceiptLine,
					intTaxGroupId,
					intConcurrencyId)
				VALUES (@intLoadHeaderId, 
					@strOrigin, 
					@intVendorId, 
					@intSupplyPointId,
					@intVendorCompanyLocationId,
					@strBillOfLading,
					@intPullProductId,
					@dblDropGross,
					@dblDropNet,
					@dblUnitCost,
					NULL,
					NULL,
					'RL-'+ CONVERT(NVARCHAR(20), @intReceiptCounter),
					@intReceiptTaxGroupId,
					1)

				SET @intLoadReceiptId = @@identity
	
				UPDATE tblTRImportLoadDetail SET intLoadReceiptId = @intLoadReceiptId, 
					strReceiptLink = 'RL-'+ CONVERT(NVARCHAR(20), @intReceiptCounter), 
					strReceiptZipCode = @strReceiptZipCode,
					strGrossNet = @strGrossNet
				WHERE intImportLoadId = @intImportLoadId
				AND ISNULL(intVendorId, 0) = ISNULL(@intVendorId, 0)
				AND ISNULL(intSupplyPointId, 0) = ISNULL(@intSupplyPointId, 0)
				AND ISNULL(intVendorCompanyLocationId, 0) = ISNULL(@intVendorCompanyLocationId, 0)
				AND intPullProductId = @intPullProductId
				AND strBillOfLading = @strBillOfLading
				AND ysnValid = 1

				FETCH NEXT FROM @CursorReceiptTran INTO @intVendorId, @intSupplyPointId, @intVendorCompanyLocationId, @intPullProductId, @dblDropGross, @dblDropNet, @strBillOfLading
			END

			CLOSE @CursorReceiptTran  
			DEALLOCATE @CursorReceiptTran

			-- DISTRIBUTION HEADER
			DECLARE @CursorDistributionTran AS CURSOR
			SET @CursorDistributionTran = CURSOR FOR
			SELECT DISTINCT
				LD.intCustomerId, 
				LD.intShipToId, 
				LD.intCustomerCompanyLocationId,
				LD.intDropProductId
			FROM tblTRImportLoadDetail LD WHERE LD.ysnValid = 1 
			AND LD.intLoadHeaderId = @intLoadHeaderId

			DECLARE @intCustomerId INT = NULL,
				@intShipToId INT = NULL,
				@intCustomerCompanyLocationId INT = NULL,		
				@intDropProductId INT = NULL,
				@intLoadDistributionHeaderId INT = NULL,
				@strDestination NVARCHAR(20) = NULL,
				@intSalePerson INT = NULL,
				@ysnToBulkPlant BIT = NULL,
				@intCustomerOrLocation INT = NULL,
				@intShipToOrLocation INT = NULL


			OPEN @CursorDistributionTran
			FETCH NEXT FROM @CursorDistributionTran INTO @intCustomerId, @intShipToId, @intCustomerCompanyLocationId, @intDropProductId
			WHILE @@FETCH_STATUS = 0
			BEGIN

				-- GET DESTINATION TYPE
				SET @strDestination = CASE WHEN @intCustomerId IS NULL THEN 'Location' ELSE 'Customer' END
			
				-- BULK LOCATION
				SET @ysnToBulkPlant =  CASE WHEN @intCustomerId IS NULL THEN 1 ELSE 0 END

				-- SET CUSTOMER OR COMPANY LOCATION
				SET @intCustomerOrLocation = CASE WHEN @strDestination = 'Customer' THEN @intCustomerId ELSE @intCustomerCompanyLocationId END  

				-- SET SHIP TO OR COMPANY LOCATION
				SET @intShipToOrLocation = CASE WHEN @strDestination = 'Customer' THEN @intShipToId ELSE @intCustomerCompanyLocationId END
		
				-- GET SALES PERSON
				SELECT @intSalePerson = intSalespersonId from vyuEMEntityCustomerSearch WHERE intEntityId = @intCustomerId
				
				INSERT INTO tblTRLoadDistributionHeader (intLoadHeaderId, 
					strDestination, 
					intEntityCustomerId, 
					intShipToLocationId, 
					intCompanyLocationId, 
					intEntitySalespersonId, 
					dtmInvoiceDateTime,
					intConcurrencyId)
				VALUES (@intLoadHeaderId,
					@strDestination,
					@intCustomerId,
					@intShipToId,
					@intCustomerCompanyLocationId,
					@intSalePerson,
					@dtmPullDate,
					1)

				SET @intLoadDistributionHeaderId = @@identity
						
				UPDATE tblTRImportLoadDetail SET intLoadDistributionHeaderId = @intLoadDistributionHeaderId
				WHERE intImportLoadId = @intImportLoadId 
				AND ISNULL(intCustomerId, 0) = ISNULL(@intCustomerId, 0) 
				AND ISNULL(intShipToId, 0) = ISNULL(@intShipToId, 0) 
				AND ISNULL(intCustomerCompanyLocationId, 0) = ISNULL(@intCustomerCompanyLocationId, 0) 
				AND ISNULL(intDropProductId, 0) = ISNULL(@intDropProductId, 0) 
				AND dtmPullDate = @dtmPullDate
				AND ysnValid = 1

				-- DISTRIBUTION DETAIL - BLENDING - START
				DECLARE @CursorDistributionDetailTran AS CURSOR
				SET @CursorDistributionDetailTran = CURSOR FOR
				SELECT LD.intPullProductId,
					LD.intDropProductId,
					SUM(LD.dblDropGross) dblDropGross ,
					SUM(LD.dblDropNet) dblDropNet,
					LD.strBillOfLading,
					LD.strReceiptZipCode,
					LD.strGrossNet
				FROM tblTRImportLoadDetail LD WHERE LD.ysnValid = 1 
				AND LD.intLoadHeaderId = @intLoadHeaderId 
				AND LD.intLoadDistributionHeaderId = @intLoadDistributionHeaderId
				AND LD.intPullProductId <> LD.intDropProductId
				GROUP BY LD.intPullProductId, LD.intDropProductId, LD.strBillOfLading, LD.strReceiptZipCode, LD.strGrossNet

				DECLARE @intDDPullProductId INT = NULL,
					@intDDDropProductId INT = NULL,
					@dblDDDropGross NUMERIC(16,6) = NULL,
					@dblDDDropNet NUMERIC(18,6) = NULL,
					@strDDBillOfLading NVARCHAR(50) = NULL,
					@intDDLoadReceiptId INT = NULL,
					@intLoadDistributionDetailId INT = NULL,
					@strBlendReceiptZipCode NVARCHAR(50) = NULL,
					@strDDGrossNet NVARCHAR(20) = NULL,
					@ysnMain BIT = 1,
					@dblSum NUMERIC(18, 6) = 0

				OPEN @CursorDistributionDetailTran
				FETCH NEXT FROM @CursorDistributionDetailTran INTO @intDDPullProductId, @intDDDropProductId, @dblDDDropGross, @dblDDDropNet, @strDDBillOfLading, @strBlendReceiptZipCode, @strDDGrossNet
				WHILE @@FETCH_STATUS = 0
				BEGIN	
					IF(@ysnMain = 1)
					BEGIN
						INSERT INTO tblTRLoadDistributionDetail(intLoadDistributionHeaderId, 
							strBillOfLading, 
							strReceiptLink,
							intItemId, 
							dblUnits, 
							dblPrice, 
							dblFreightRate, 
							dblDistSurcharge, 
							intTaxGroupId, 
							ysnBlendedItem, 
							intConcurrencyId)
						VALUES(@intLoadDistributionHeaderId,
							'',
							'',
							@intDDDropProductId,
							null,
							null,
							null,
							null,
							null,
							1,
							1)

						SET @intLoadDistributionDetailId = @@identity

						UPDATE tblTRImportLoadDetail SET intLoadDistributionDetailId = @intLoadDistributionDetailId
						WHERE intImportLoadId = @intImportLoadId 
						AND intLoadDistributionHeaderId = @intLoadDistributionHeaderId
						AND intDropProductId = @intDDDropProductId
						AND ysnValid = 1

						SET @ysnMain = 0
					END
					
					DECLARE @dblPercentage NUMERIC(18, 6) = NULL,
						@intRecipeItemId INT = NULL
						
					SELECT @intRecipeItemId = RI.intRecipeItemId, @dblPercentage = RI.dblQuantity FROM tblMFRecipe R 
					INNER JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
					WHERE R.intItemId = @intDDDropProductId 
					AND RI.intItemId = @intDDPullProductId 
					AND R.ysnActive = 1
					AND RI.intRecipeItemTypeId = 1
					AND R.intLocationId = @intCustomerCompanyLocationId

					IF(@dblPercentage IS NOT NULL)
					BEGIN
						DECLARE @strReceiptLink NVARCHAR(50) = NULL,
							@dblRawValue NUMERIC(18,6) = NULL
						
						SET @dblRawValue = CASE WHEN @strDDGrossNet = 'Gross' THEN @dblDDDropGross ELSE @dblDDDropNet END

						SET @dblSum = @dblSum + @dblRawValue 

						SELECT DISTINCT @strReceiptLink = LR.strReceiptLink FROM tblTRImportLoadDetail LR 
						WHERE LR.intPullProductId = @intDDPullProductId 
						AND LR.intDropProductId = @intDDDropProductId
						AND LR.strBillOfLading = @strDDBillOfLading
						AND LR.intLoadHeaderId = @intLoadHeaderId
						AND LR.ysnValid = 1
						
						INSERT INTO tblTRLoadBlendIngredient (intLoadDistributionDetailId, 
							strBillOfLading, 
							strReceiptLink, 
							intRecipeItemId, 
							dblQuantity, 
							intConcurrencyId)
						VALUES (@intLoadDistributionDetailId,
							@strDDBillOfLading,
							@strReceiptLink,
							@intRecipeItemId,
							@dblRawValue,
							1)
					END

					IF(@intRecipeItemId IS NULL)
					BEGIN
						DECLARE @strDistributionLocationName NVARCHAR(500) = NULL,
							@strDistributionItemName NVARCHAR(500) = NULL
						
						SELECT @strDistributionLocationName = strLocationName from tblSMCompanyLocation where intCompanyLocationId = @intCustomerCompanyLocationId
						SELECT @strDistributionItemName = strItemNo FROM tblICItem WHERE intItemId = @intDDDropProductId

						DECLARE @strMessageNoBlend NVARCHAR(100) = 'There is no Recipe for Distribution Bulk Location ' + @strDistributionLocationName + ' for Item ' + @strDistributionItemName

						UPDATE tblTRImportLoadDetail SET strMessage = CASE WHEN @intRecipeItemId IS NULL THEN 
						(CASE WHEN strMessage like '%There is no Recipe for Distribution Bulk Location%' THEN strMessage ELSE dbo.fnTRMessageConcat(strMessage, @strMessageNoBlend)  END) ELSE 
							strMessage
						END
						WHERE intImportLoadId = @intImportLoadId 
						AND intLoadDistributionHeaderId = @intLoadDistributionHeaderId
						AND intDropProductId = @intDDDropProductId
						AND ysnValid = 1
					END
					
					-- FREIGHT RATE & SURCHARGE - RECEIPT
					DECLARE @dblBlendReceiptGallon DECIMAL(18,6) = NULL,
						@dblBlendFreightRateDistribution DECIMAL(18,6),
						@dblBlendFreightRateReceipt DECIMAL(18,6),
						@dblBlendSurchargeReceipt DECIMAL(18,6),
						@dblBlendSurchargeDistribution DECIMAL(18,6),
						@ysnBlendFreightInPrice BIT,
						@ysnBlendFreightOnly BIT

					EXECUTE [dbo].[uspTRGetCustomerFreight]
						@intCustomerOrLocation -- Customer / Company Location
						,@intDDDropProductId -- Distribution Item
						,@strBlendReceiptZipCode -- Supply Point
						,@intCarrierId -- Ship Via
						,@intShipToOrLocation -- Ship To
						,@dblRawValue -- Receipt Qty
						,@dblSum -- Distiribution Qty
						,@dtmPullDate
						,@dtmPullDate
						,@ysnToBulkPlant
						,@dblBlendFreightRateDistribution OUTPUT
						,@dblBlendFreightRateReceipt OUTPUT
						,@dblBlendSurchargeReceipt OUTPUT
						,@dblBlendSurchargeDistribution OUTPUT
						,@ysnBlendFreightInPrice OUTPUT
						,@ysnBlendFreightOnly OUTPUT

					UPDATE tblTRLoadDistributionDetail SET dblUnits = @dblSum, dblFreightRate = @dblBlendFreightRateDistribution 
					WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId

					UPDATE tblTRLoadReceipt SET dblFreightRate = @dblBlendFreightRateReceipt, dblPurSurcharge = @dblBlendSurchargeReceipt 
					WHERE intLoadHeaderId = @intLoadHeaderId 
					AND intItemId = @intDDPullProductId

					FETCH NEXT FROM @CursorDistributionDetailTran INTO @intDDPullProductId, @intDDDropProductId, @dblDDDropGross, @dblDDDropNet, @strDDBillOfLading, @strBlendReceiptZipCode, @strDDGrossNet
				END
				CLOSE @CursorDistributionDetailTran
				DEALLOCATE @CursorDistributionDetailTran
				-- DISTRIBUTION DETAIL - BLENDING - END


				-- DISTRIBUTION DETAIL - NON BLENDING - START
				DECLARE @CursorDistributionDetailNonBlendTran AS CURSOR
				SET @CursorDistributionDetailNonBlendTran = CURSOR FOR
				SELECT LD.intPullProductId,
					LD.intDropProductId,
					SUM(LD.dblDropGross) dblDropGross ,
					SUM(LD.dblDropNet) dblDropNet,
					LD.strBillOfLading,
					LD.strReceiptLink,
					LD.strReceiptZipCode,
					LD.strGrossNet
				FROM tblTRImportLoadDetail LD 
				WHERE LD.ysnValid = 1 
				AND LD.intLoadHeaderId = @intLoadHeaderId 
				AND LD.intLoadDistributionHeaderId = @intLoadDistributionHeaderId
				AND LD.intPullProductId = LD.intDropProductId
				GROUP BY LD.intPullProductId, LD.intDropProductId, LD.strBillOfLading, LD.strReceiptLink, LD.strReceiptZipCode, LD.strGrossNet
				
				DECLARE @intNonBlendPullProductId INT = NULL,
					@intNonBlendDropProductId INT = NULL,
					@dblNonBlendDropGross NUMERIC(16,6) = NULL,
					@dblNonBlendDropNet NUMERIC(18,6) = NULL,
					@strNonBlendBillOfLading NVARCHAR(50) = NULL,
					@strNonBlendReceiptLink NVARCHAR(50) = NULL,
					@intNonBlendLoadDistributionDetailId INT = NULL,
					@strNonBlendReceiptZipCode NVARCHAR(50) = NULL,
					@strNonBlendGrossNet NVARCHAR(50) = NULL,
					@intNonBlendTaxGroupId INT = NULL

				OPEN @CursorDistributionDetailNonBlendTran
				FETCH NEXT FROM @CursorDistributionDetailNonBlendTran INTO @intNonBlendPullProductId, @intNonBlendDropProductId, @dblNonBlendDropGross, @dblNonBlendDropNet, @strNonBlendBillOfLading, @strNonBlendReceiptLink, @strNonBlendReceiptZipCode, @strNonBlendGrossNet
				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- GET TAX GROUP 
					IF(@intShipToId IS NOT NULL)
					BEGIN
						SELECT @intNonBlendTaxGroupId = EL.intTaxGroupId FROM tblEMEntityLocation EL
						WHERE EL.intEntityLocationId = @intShipToId
					END
					ELSE
					BEGIN
						SELECT @intNonBlendTaxGroupId = intTaxGroupId FROM tblSMCompanyLocation 
						WHERE intCompanyLocationId = @intCustomerCompanyLocationId 
					END

					-- FREIGHT RATE & SURCHARGE - RECEIPT
					DECLARE @dblReceiptGallon DECIMAL(18,6) = NULL,
						@dblFreightRateDistribution DECIMAL(18,6),
						@dblFreightRateReceipt DECIMAL(18,6),
						@dblSurchargeReceipt DECIMAL(18,6),
						@dblSurchargeDistribution DECIMAL(18,6),
						@ysnFreightInPrice BIT,
						@ysnFreightOnly BIT

					IF(@intNonBlendDropProductId IS NOT NULL AND @intCarrierId IS NOT NULL)
					BEGIN

						IF(@strNonBlendGrossNet = 'Gross')
						BEGIN
							SET @dblReceiptGallon = @dblDropGross
						END
						ELSE
						BEGIN
							SET @dblReceiptGallon = @dblDropNet
						END

						EXECUTE [dbo].[uspTRGetCustomerFreight]
							@intCustomerOrLocation  -- Customer / Company Location
							,@intDropProductId -- Receipt Item
							,@strNonBlendReceiptZipCode -- Supply Point
							,@intCarrierId -- Ship Via
							,@intShipToOrLocation -- Ship To
							,@dblReceiptGallon
							,@dblReceiptGallon
							,@dtmPullDate
							,@dtmPullDate
							,@ysnToBulkPlant
							,@dblFreightRateDistribution OUTPUT
							,@dblFreightRateReceipt OUTPUT
							,@dblSurchargeReceipt OUTPUT
							,@dblSurchargeDistribution OUTPUT
							,@ysnFreightInPrice OUTPUT
							,@ysnFreightOnly OUTPUT
					END

					UPDATE tblTRLoadReceipt SET dblFreightRate = @dblFreightRateReceipt, dblPurSurcharge = @dblSurchargeReceipt
					WHERE intLoadHeaderId = @intLoadHeaderId
					AND strReceiptLine = @strNonBlendReceiptLink

					-- GET PRICE
					DECLARE @dblNonBlendUnit NUMERIC(18,6) = 0,
						@dblNonBlendPrice NUMERIC(18,6) = 0
					SET @dblNonBlendUnit = CASE WHEN @strNonBlendGrossNet = 'Gross' THEN @dblNonBlendDropGross ELSE @dblNonBlendDropNet END
 					
					EXEC [uspARGetItemPrice] 
						@TransactionDate = @dtmPullDate
						,@ItemId = @intNonBlendDropProductId 
						,@CustomerId = @intCustomerId   
						,@LocationId = @intCustomerCompanyLocationId    
						,@Quantity = @dblNonBlendUnit    
						,@ShipToLocationId=@intShipToId	
						,@InvoiceType=N'Transport Delivery'		
						,@Price = @dblNonBlendPrice OUTPUT	

					INSERT INTO tblTRLoadDistributionDetail(intLoadDistributionHeaderId, 
						strBillOfLading, 
						strReceiptLink,
						intItemId, 
						dblUnits, 
						dblPrice, 
						dblFreightRate, 
						dblDistSurcharge, 
						intTaxGroupId, 
						ysnBlendedItem, 
						intConcurrencyId)
					VALUES(@intLoadDistributionHeaderId,
						@strNonBlendBillOfLading,
						@strNonBlendReceiptLink ,
						@intNonBlendDropProductId,
						CASE WHEN @strNonBlendGrossNet = 'Gross' THEN @dblNonBlendDropGross ELSE @dblNonBlendDropNet END,
						@dblNonBlendPrice,
						@dblFreightRateDistribution,
						@dblSurchargeDistribution,
						@intNonBlendTaxGroupId,
						0,
						1)

					SET @intNonBlendLoadDistributionDetailId = @@identity

					UPDATE tblTRImportLoadDetail SET intLoadDistributionDetailId = @intNonBlendLoadDistributionDetailId
					WHERE intImportLoadId = @intImportLoadId 
					AND intLoadDistributionHeaderId = @intLoadDistributionHeaderId
					AND intDropProductId = @intNonBlendDropProductId
					AND ysnValid = 1

					FETCH NEXT FROM @CursorDistributionDetailNonBlendTran INTO @intNonBlendPullProductId, @intNonBlendDropProductId, @dblNonBlendDropGross, @dblNonBlendDropNet, @strNonBlendBillOfLading, @strNonBlendReceiptLink, @strNonBlendReceiptZipCode, @strNonBlendGrossNet
				END
				CLOSE @CursorDistributionDetailNonBlendTran
				DEALLOCATE @CursorDistributionDetailNonBlendTran
				-- DISTRIBUTION DETAIL - NON BLENDING - END

				FETCH NEXT FROM @CursorDistributionTran INTO @intCustomerId, @intShipToId, @intCustomerCompanyLocationId, @intDropProductId
			END
			CLOSE @CursorDistributionTran
			DEALLOCATE @CursorDistributionTran

			FETCH NEXT FROM @CursorHeaderTran INTO @intTruckId, @intCarrierId, @intDriverId, @intTrailerId, @dtmPullDate
		END

		CLOSE @CursorHeaderTran  
		DEALLOCATE @CursorHeaderTran

		-- OVERRIDE TAX GROUP
		DECLARE @CursorOverrideTax AS CURSOR,
			@intOVLoadReceiptId INT = NULL,
			@intOVLoadDistributionDetailId INT = NULL,
			@intOVTerminalId INT = NULL,
			@intOVSupplyPointId INT = NULL,
			@strOVReceiptState NVARCHAR(5) = NULL,
			@intOVEntityCustomerId INT = NULL,
			@intOVShipToLocationId INT = NULL,
			@strOVDistributionState NVARCHAR(5) = NULL,
			@intOVBulkLocationId INT = NULL,
			@intShipViaId INT = NULL

		SET @CursorOverrideTax = CURSOR FOR
		SELECT DISTINCT LR.intLoadReceiptId, LDD.intLoadDistributionDetailId, LR.intTerminalId, LR.intSupplyPointId, RCL.strStateProvince strReceiptState,
			LDH.intEntityCustomerId, LDH.intShipToLocationId, CASE WHEN LDH.strDestination = 'Location' THEN DCL.strStateProvince ELSE CPL.strState END strDistributionState,
			LR.intCompanyLocationId, LH.intShipViaId
		FROM tblTRImportLoadDetail ILD 
		INNER JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = ILD.intLoadHeaderId
		INNER JOIN tblTRLoadReceipt LR ON LR.intLoadReceiptId = ILD.intLoadReceiptId
		INNER JOIN tblTRLoadDistributionHeader LDH ON LDH.intLoadDistributionHeaderId = ILD.intLoadDistributionHeaderId
		INNER JOIN tblTRLoadDistributionDetail LDD ON LDD.intLoadDistributionDetailId = ILD.intLoadDistributionDetailId
		LEFT JOIN tblSMCompanyLocation RCL ON RCL.intCompanyLocationId = LR.intCompanyLocationId
		LEFT JOIN tblEMEntityLocation CPL ON CPL.intEntityLocationId = LDH.intShipToLocationId AND CPL.intEntityId = LDH.intEntityCustomerId
		LEFT JOIN tblSMCompanyLocation DCL ON DCL.intCompanyLocationId = LDH.intCompanyLocationId
		WHERE ILD.intImportLoadId = @intImportLoadId AND ILD.ysnValid = 1

		OPEN @CursorOverrideTax
		FETCH NEXT FROM @CursorOverrideTax INTO @intOVLoadReceiptId, @intOVLoadDistributionDetailId, @intOVTerminalId, @intOVSupplyPointId, @strOVReceiptState,
			@intOVEntityCustomerId, @intOVShipToLocationId, @strOVDistributionState, @intOVBulkLocationId, @intShipViaId

		WHILE @@FETCH_STATUS = 0
		BEGIN
					
			DECLARE @intOVReceiptTaxGroupId INT = NULL,
				@strOVReceiptTaxGroup NVARCHAR(100) = NULL,
				@intOVDistributionTaxGroupId INT = NULL,
				@strOVDistributionTaxGroup NVARCHAR(100) = NULL
			
			EXEC [dbo].[uspTROverrideTax]
				@intSupplierId = @intOVTerminalId,
				@intSupplyPointId = @intOVSupplyPointId,
				@strReceiptState = @strOVReceiptState,
				@intCustomerId = @intOVEntityCustomerId,
				@intCustomerShipToId = @intOVShipToLocationId,
				@intShipViaId = @intShipViaId,
				@strDistributionState = @strOVDistributionState,
				@intDistributionBulkLocationId = @intOVBulkLocationId,
				@intReceiptTaxGroupId = @intOVReceiptTaxGroupId OUTPUT,
				@strReceiptTaxGroup = @strOVReceiptTaxGroup OUTPUT,
				@intDistributionTaxGroupId = @intOVDistributionTaxGroupId OUTPUT,
				@strDistributionTaxGroup = @strOVDistributionTaxGroup OUTPUT

			IF(@intOVReceiptTaxGroupId IS NOT NULL)
			BEGIN
				UPDATE tblTRLoadReceipt SET intTaxGroupId = @intOVReceiptTaxGroupId WHERE intLoadReceiptId = @intOVLoadReceiptId
			END

			IF(@intOVDistributionTaxGroupId IS NOT NULL)
			BEGIN
				UPDATE tblTRLoadDistributionDetail SET intTaxGroupId = @intOVDistributionTaxGroupId WHERE intLoadDistributionDetailId = @intOVLoadDistributionDetailId
			END

			FETCH NEXT FROM @CursorOverrideTax INTO @intOVLoadReceiptId, @intOVLoadDistributionDetailId, @intOVTerminalId, @intOVSupplyPointId, @strOVReceiptState,
				@intOVEntityCustomerId, @intOVShipToLocationId, @strOVDistributionState, @intOVBulkLocationId, @intShipViaId
		END
		CLOSE @CursorOverrideTax
		DEALLOCATE @CursorOverrideTax

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		)
	END CATCH

END