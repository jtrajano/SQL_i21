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
			@intSellerId INT = NULL

		-- GET DEFAULT SELLER
		SELECT TOP 1 @intSellerId = intSellerId FROM tblTRCompanyPreference 

		BEGIN TRANSACTION

		OPEN @CursorHeaderTran
		FETCH NEXT FROM @CursorHeaderTran INTO @intTruckId, @intCarrierId, @intDriverId, @intTrailerId, @dtmPullDate
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- HEADER INFO

			-- GET STARTING NUMBER
			EXEC uspSMGetStartingNumber 54, @strTransactionNumber OUT
			
			-- TR HEADER
			INSERT INTO tblTRLoadHeader (dtmLoadDateTime, intShipViaId, intSellerId, intDriverId, intTruckDriverReferenceId, intTrailerId, strTransaction, intConcurrencyId)
			VALUES (@dtmPullDate, @intCarrierId, @intSellerId, @intDriverId, @intTruckId, @intTrailerId, @strTransactionNumber, 1)
			
			SET @intLoadHeaderId = @@identity

			UPDATE tblTRImportLoadDetail SET strMessage = @strTransactionNumber, intLoadHeaderId = @intLoadHeaderId
			WHERE intImportLoadId = @intImportLoadId AND intTruckId = @intTruckId AND intCarrierId = @intCarrierId AND intDriverId = @intDriverId AND intTrailerId = @intTrailerId AND dtmPullDate = @dtmPullDate

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
			FROM tblTRImportLoadDetail LD WHERE LD.ysnValid = 1 AND LD.intLoadHeaderId = @intLoadHeaderId
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
				@intLoadReceiptId INT = NULL

			OPEN @CursorReceiptTran
			FETCH NEXT FROM @CursorReceiptTran INTO @intVendorId, @intSupplyPointId, @intVendorCompanyLocationId, @intPullProductId, @dblDropGross, @dblDropNet, @strBillOfLading
			WHILE @@FETCH_STATUS = 0
			BEGIN

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
						,@intVendorId
						,@intPullProductId
						,@dblUnitCost OUTPUT
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
					1)

				SET @intLoadReceiptId = @@identity
	
				UPDATE tblTRImportLoadDetail SET intLoadReceiptId = @intLoadReceiptId, strReceiptLink = 'RL-'+ CONVERT(NVARCHAR(20), @intReceiptCounter)
				WHERE intImportLoadId = @intImportLoadId
				AND intVendorId = @intVendorId
				AND intSupplyPointId = @intSupplyPointId
				AND intVendorCompanyLocationId = @intVendorCompanyLocationId
				AND intPullProductId = @intPullProductId
				AND strBillOfLading = @strBillOfLading

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
				LD.intDropProductId,
				LD.dtmInvoiceDate
			FROM tblTRImportLoadDetail LD WHERE LD.ysnValid = 1 AND LD.intLoadHeaderId = @intLoadHeaderId

			DECLARE @intCustomerId INT = NULL,
				@intShipToId INT = NULL,
				@intCustomerCompanyLocationId INT = NULL,		
				@intDropProductId INT = NULL,
				@dtmInvoiceDate DATETIME = NULL,
				@intLoadDistributionHeaderId INT = NULL,
				@strDestination NVARCHAR(20) = NULL,
				@intSalePerson INT = NULL


			OPEN @CursorDistributionTran
			FETCH NEXT FROM @CursorDistributionTran INTO @intCustomerId, @intShipToId, @intCustomerCompanyLocationId, @intDropProductId, @dtmInvoiceDate
			WHILE @@FETCH_STATUS = 0
			BEGIN

				-- GET DESTINATION TYPE
				SET @strDestination = CASE WHEN @intCustomerId IS NULL THEN 'Location' ELSE 'Customer' END

				-- GET SALES PERSON
				SELECT @intSalePerson = intSalespersonId from tblARCustomer WHERE intEntityId = @intCustomerId
				
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
					@dtmInvoiceDate,
					1)

				SET @intLoadDistributionHeaderId = @@identity
						
				UPDATE tblTRImportLoadDetail SET intLoadDistributionHeaderId = @intLoadDistributionHeaderId
				WHERE intImportLoadId = @intImportLoadId AND intCustomerId = @intCustomerId 
				AND intShipToId = @intShipToId 
				AND intCustomerCompanyLocationId = @intCustomerCompanyLocationId 
				AND intDropProductId = @intDropProductId 
				AND dtmInvoiceDate = @dtmInvoiceDate

				-- DISTRIBUTION DETAIL - BLENDING - START
				DECLARE @CursorDistributionDetailTran AS CURSOR
				SET @CursorDistributionDetailTran = CURSOR FOR
				SELECT LD.intPullProductId,
					LD.intDropProductId,
					SUM(LD.dblDropGross) dblDropGross ,
					SUM(LD.dblDropNet) dblDropNet,
					LD.strBillOfLading
				FROM tblTRImportLoadDetail LD WHERE LD.ysnValid = 1 AND LD.intLoadHeaderId = @intLoadHeaderId 
				AND LD.intLoadDistributionHeaderId = @intLoadDistributionHeaderId
				AND LD.intPullProductId <> LD.intDropProductId
				GROUP BY LD.intPullProductId, LD.intDropProductId, LD.strBillOfLading

				DECLARE @intDDPullProductId INT = NULL,
					@intDDDropProductId INT = NULL,
					@dblDDDropGross NUMERIC(16,6) = NULL,
					@dblDDDropNet NUMERIC(18,6) = NULL,
					@strDDBillOfLading NVARCHAR(50) = NULL,
					@intDDLoadReceiptId INT = NULL,
					@intLoadDistributionDetailId INT = NULL,
					@ysnMain BIT = 1,
					@dblSum NUMERIC(18, 6) = 0

				OPEN @CursorDistributionDetailTran
				FETCH NEXT FROM @CursorDistributionDetailTran INTO @intDDPullProductId, @intDDDropProductId, @dblDDDropGross, @dblDDDropNet, @strDDBillOfLading
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
						WHERE intImportLoadId = @intImportLoadId AND intLoadDistributionHeaderId = @intLoadDistributionHeaderId
						AND intDropProductId = @intDDDropProductId

						SET @ysnMain = 0
					END
						
					DECLARE @dblPercentage NUMERIC(18, 6) = NULL,
						@intRecipeItemId INT = NULL
					SELECT @intRecipeItemId = RI.intRecipeItemId, @dblPercentage = RI.dblQuantity FROM tblMFRecipe R 
					INNER JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
					WHERE R.intItemId = @intDDDropProductId AND RI.intItemId = @intDDPullProductId AND R.ysnActive = 1
					AND RI.intRecipeItemTypeId = 1

					IF(@dblPercentage IS NOT NULL)
					BEGIN
						DECLARE @strReceiptLink NVARCHAR(50) = NULL,
							@dblPercentageValue NUMERIC(18,6) = NULL
						

						SET @dblPercentageValue = @dblDDDropGross * @dblPercentage

						SET @dblSum = @dblSum + @dblPercentageValue 

						SELECT DISTINCT @strReceiptLink = LR.strReceiptLink FROM tblTRImportLoadDetail LR 
						WHERE LR.intPullProductId = @intDDPullProductId 
						AND LR.intDropProductId = @intDDDropProductId
						AND LR.strBillOfLading = @strDDBillOfLading
						AND LR.intLoadHeaderId = @intLoadHeaderId
						
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
							@dblPercentageValue,
							1)
					END

					UPDATE tblTRLoadDistributionDetail SET dblUnits = @dblSum WHERE intLoadDistributionDetailId = @intLoadDistributionDetailId
					
					FETCH NEXT FROM @CursorDistributionDetailTran INTO @intDDPullProductId, @intDDDropProductId, @dblDDDropGross, @dblDDDropNet, @strDDBillOfLading
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
					LD.strReceiptLink
				FROM tblTRImportLoadDetail LD WHERE LD.ysnValid = 1 AND LD.intLoadHeaderId = @intLoadHeaderId 
				AND LD.intLoadDistributionHeaderId = @intLoadDistributionHeaderId
				AND LD.intPullProductId = LD.intDropProductId
				GROUP BY LD.intPullProductId, LD.intDropProductId, LD.strBillOfLading, LD.strReceiptLink
				
				DECLARE @intNonBlendPullProductId INT = NULL,
					@intNonBlendDropProductId INT = NULL,
					@dblNonBlendDropGross NUMERIC(16,6) = NULL,
					@dblNonBlendDropNet NUMERIC(18,6) = NULL,
					@strNonBlendBillOfLading NVARCHAR(50) = NULL,
					@strNonBlendReceiptLink NVARCHAR(50) = NULL,
					@intNonBlendLoadDistributionDetailId INT = NULL

				OPEN @CursorDistributionDetailNonBlendTran
				FETCH NEXT FROM @CursorDistributionDetailNonBlendTran INTO @intNonBlendPullProductId, @intNonBlendDropProductId, @dblNonBlendDropGross, @dblNonBlendDropNet, @strNonBlendBillOfLading, @strNonBlendReceiptLink
				WHILE @@FETCH_STATUS = 0
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
						@strNonBlendBillOfLading,
						@strNonBlendReceiptLink ,
						@intNonBlendDropProductId,
						@dblNonBlendDropGross,
						null,
						null,
						null,
						null,
						0,
						1)

					SET @intNonBlendLoadDistributionDetailId = @@identity

					UPDATE tblTRImportLoadDetail SET intLoadDistributionDetailId = @intNonBlendLoadDistributionDetailId
					WHERE intImportLoadId = @intImportLoadId AND intLoadDistributionHeaderId = @intLoadDistributionHeaderId
					AND intDropProductId = @intNonBlendDropProductId

					FETCH NEXT FROM @CursorDistributionDetailNonBlendTran INTO @intNonBlendPullProductId, @intNonBlendDropProductId, @dblNonBlendDropGross, @dblNonBlendDropNet, @strNonBlendBillOfLading, @strNonBlendReceiptLink
				END
				CLOSE @CursorDistributionDetailNonBlendTran
				DEALLOCATE @CursorDistributionDetailNonBlendTran
				-- DISTRIBUTION DETAIL - NON BLENDING - END

				FETCH NEXT FROM @CursorDistributionTran INTO @intCustomerId, @intShipToId, @intCustomerCompanyLocationId, @intDropProductId, @dtmInvoiceDate
			END
			CLOSE @CursorDistributionTran
			DEALLOCATE @CursorDistributionTran

			FETCH NEXT FROM @CursorHeaderTran INTO @intTruckId, @intCarrierId, @intDriverId, @intTrailerId, @dtmPullDate
		END

		CLOSE @CursorHeaderTran  
		DEALLOCATE @CursorHeaderTran

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