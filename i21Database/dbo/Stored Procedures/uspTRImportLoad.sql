CREATE PROCEDURE [dbo].[uspTRImportLoad]
	@guidImportIdentifier UNIQUEIDENTIFIER,
    @intUserId INT,
	@return INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT

	BEGIN TRY

		DECLARE @intImportLoadId INT,
			@intImportLoadDetailId INT = NULL,
			@strTruck NVARCHAR(50) = NULL,
			@strTerminal NVARCHAR(100) = NULL,
			@strCarrier NVARCHAR(100) = NULL,
			@strDriver NVARCHAR(100) = NULL,
			@strTrailer NVARCHAR(100) = NULL,
			@strSupplier NVARCHAR(100) = NULL,
			@strDestination NVARCHAR(100) = NULL,
			@strPullProduct NVARCHAR(100) = NULL,
			@strDropProduct NVARCHAR(100) = NULL,
		    @ysnValid BIT = NULL,
			@strMessage NVARCHAR(MAX) = NULL,
			@strBillOfLading NVARCHAR(200) = NULL,
			@dtmPullDate DATETIME = NULL
	
		DECLARE @CursorTran AS CURSOR

		SET @CursorTran = CURSOR FOR
		SELECT D.intImportLoadDetailId
			, D.strTruck
			, D.strTerminal
			, D.strCarrier
			, D.strDriver
			, D.strTrailer
			, D.strSupplier
			, D.strDestination
			, D.strPullProduct
			, D.strDropProduct 
			, D.ysnValid
			, D.strMessage
			, D.strBillOfLading
			, D.dtmPullDate
		FROM tblTRImportLoad L 
		INNER JOIN tblTRImportLoadDetail D ON D.intImportLoadId = L.intImportLoadId
		WHERE L.guidImportIdentifier = @guidImportIdentifier AND D.ysnValid = 1 

		BEGIN TRANSACTION

		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportLoadDetailId, @strTruck, @strTerminal, @strCarrier, @strDriver, @strTrailer, @strSupplier, @strDestination, @strPullProduct, @strDropProduct, @ysnValid, @strMessage, @strBillOfLading, @dtmPullDate 
		WHILE @@FETCH_STATUS = 0
		BEGIN	

			-- BOL AND LOAD DATETIME
			IF EXISTS(SELECT TOP 1 1 FROM tblTRLoadHeader LH INNER JOIN tblTRLoadReceipt LR ON LR.intLoadHeaderId = LH.intLoadHeaderId
			WHERE LH.dtmLoadDateTime = @dtmPullDate
			AND LR.strBillOfLading = @strBillOfLading)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Load has already been imported')
			END

			-- SHIP VIA / CARRIER
			DECLARE @intCarrierId INT = NULL
			SELECT @intCarrierId = CRB.intCarrierId
			FROM tblTRCrossReferenceBol CRB 
			WHERE CRB.strType = 'Carrier' AND CRB.strImportValue = @strCarrier

			IF(@intCarrierId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Carrier')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intCarrierId = @intCarrierId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

			 -- DRIVER
            DECLARE @intDriverId INT = NULL
			SELECT @intDriverId = CRB.intDriverId
			FROM tblTRCrossReferenceBol CRB 
			WHERE CRB.strType = 'Driver' AND CRB.strImportValue = @strDriver

            IF (@intDriverId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Driver')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intDriverId = @intDriverId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

			-- TRUCK
			DECLARE @intTruckId INT = NULL
			SELECT @intTruckId  = CRB.intTruckId
			FROM tblTRCrossReferenceBol CRB 
			WHERE CRB.strType = 'Truck' AND CRB.strImportValue = @strTruck

            IF (@intTruckId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Truck')	
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intTruckId = @intTruckId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

			-- TRAILER
            DECLARE @intTrailerId INT = NULL
			SELECT @intTrailerId  = CRB.intTrailerId
			FROM tblTRCrossReferenceBol CRB 
			WHERE CRB.strType = 'Trailer' AND CRB.strImportValue = @strTrailer

            IF (@intTrailerId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Trailer')	
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intTrailerId = @intTrailerId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

			-- SUPLLIER / VENDOR
            DECLARE @intVendorId INT = NULL
			DECLARE @intSupplyPointId INT = NULL
			DECLARE @intVendorCompanyLocationId INT = NULL
			
			SELECT @intVendorId = CRB.intSupplierId, @intSupplyPointId = CRB.intSupplyPointId, @intVendorCompanyLocationId = CRB.intCompanyLocationId
			FROM tblTRCrossReferenceBol CRB 
			WHERE CRB.strType = 'Supplier' AND CRB.strImportValue = @strSupplier

            IF (@intVendorId IS NULL)
			BEGIN
				IF (@intVendorCompanyLocationId IS NULL)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Supplier')
				END
				ELSE
				BEGIN
					UPDATE tblTRImportLoadDetail SET intVendorCompanyLocationId = @intVendorCompanyLocationId WHERE intImportLoadDetailId = @intImportLoadDetailId
				END
			END
			ELSE
			BEGIN
				IF(@intSupplyPointId IS NULL)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Supply Point')
				END
				ELSE
				BEGIN
					UPDATE tblTRImportLoadDetail SET intVendorId = @intVendorId, intSupplyPointId = @intSupplyPointId, intVendorCompanyLocationId = @intVendorCompanyLocationId WHERE intImportLoadDetailId = @intImportLoadDetailId
				END
			END

			 -- CHECK IF HAS VALID DESTINATION
            DECLARE @intCustomerId INT = NULL
			DECLARE @intShipToId INT = NULL
			DECLARE @intCustomerCompanyLocationId INT = NULL

			SELECT @intCustomerId = CRB.intCustomerId, @intShipToId = CRB.intCustomerLocationId, @intCustomerCompanyLocationId = CRB.intCompanyLocationId
			FROM tblTRCrossReferenceBol CRB 
			WHERE CRB.strType = 'Destination' AND CRB.strImportValue = @strDestination

            IF (@intCustomerId IS NULL)
			BEGIN
				IF (@intCustomerCompanyLocationId IS NULL)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Destination')
				END
				ELSE
				BEGIN
					UPDATE tblTRImportLoadDetail SET intCustomerCompanyLocationId = @intCustomerCompanyLocationId WHERE intImportLoadDetailId = @intImportLoadDetailId
					
				END
			END
			ELSE
			BEGIN
				IF(@intShipToId IS NULL)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Customer Location')
				END
				ELSE
				BEGIN
					UPDATE tblTRImportLoadDetail SET intCustomerId = @intCustomerId, intShipToId = @intShipToId, intCustomerCompanyLocationId = @intCustomerCompanyLocationId WHERE intImportLoadDetailId = @intImportLoadDetailId
				END
			END


            -- PULLED PRODUCT
            DECLARE @intPullProductId INT = NULL

            SELECT @intPullProductId = CRB.intItemId
			FROM tblTRCrossReferenceBol CRB 
			WHERE CRB.strType = 'Item' AND CRB.strImportValue = @strPullProduct

            IF (@intPullProductId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Pulled Product')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intPullProductId = @intPullProductId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END


			-- DROPPED PRODUCT
            DECLARE @intDropProductId INT = NULL

            SELECT @intDropProductId = CRB.intItemId
			FROM tblTRCrossReferenceBol CRB 
			WHERE CRB.strType = 'Item' AND CRB.strImportValue = @strDropProduct

            IF (@intDropProductId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Dropped Product')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intDropProductId = @intDropProductId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

            IF(@ysnValid = 1)
			BEGIN			
				IF(ISNULL(@strMessage, '') != '')
				BEGIN
					UPDATE tblTRImportLoadDetail SET strMessage = @strMessage, ysnValid = 0 WHERE intImportLoadDetailId = @intImportLoadDetailId 
				END	
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET strMessage = @strMessage, ysnValid = 0 WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

			FETCH NEXT FROM @CursorTran INTO @intImportLoadDetailId, @strTruck, @strTerminal, @strCarrier, @strDriver, @strTrailer, @strSupplier, @strDestination, @strPullProduct, @strDropProduct, @ysnValid, @strMessage, @strBillOfLading, @dtmPullDate
		END
		CLOSE @CursorTran
		DEALLOCATE @CursorTran

		COMMIT TRANSACTION

		SELECT @return = intImportLoadId FROM tblTRImportLoad WHERE guidImportIdentifier = @guidImportIdentifier

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