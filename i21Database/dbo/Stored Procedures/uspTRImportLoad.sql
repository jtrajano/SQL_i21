CREATE PROCEDURE [dbo].[uspTRImportLoad]
	@guidImportIdentifier UNIQUEIDENTIFIER,
    @intUserId INT,
	@return INT OUTPUT,
	@ysnReprocess BIT = 0
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
			@dtmPullDate DATETIME = NULL,
			@strSource NVARCHAR(20) = NULL,
			@ysnDefault BIT = NULL
		BEGIN TRANSACTION

		DECLARE @CursorTran AS CURSOR

		IF(@ysnReprocess = 1)
		BEGIN
			UPDATE D SET D.ysnValid = 1, D.strMessage = '' FROM tblTRImportLoadDetail D 
				INNER JOIN tblTRImportLoad L
					ON L.intImportLoadId = D.intImportLoadId
			WHERE L.guidImportIdentifier = @guidImportIdentifier AND D.ysnValid = 0 AND ISNULL(D.ysnProcess, 0) = 0

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
				, L.strSource
			FROM tblTRImportLoad L 
			INNER JOIN tblTRImportLoadDetail D ON D.intImportLoadId = L.intImportLoadId
			WHERE L.guidImportIdentifier = @guidImportIdentifier AND D.ysnValid = 1 AND ISNULL(D.ysnProcess, 0) = 0
		END
		ELSE
		BEGIN
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
				, L.strSource
			FROM tblTRImportLoad L 
			INNER JOIN tblTRImportLoadDetail D ON D.intImportLoadId = L.intImportLoadId
			WHERE L.guidImportIdentifier = @guidImportIdentifier AND D.ysnValid = 1 
		END
		

		
		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportLoadDetailId, @strTruck, @strTerminal, @strCarrier, @strDriver, @strTrailer, @strSupplier, @strDestination, @strPullProduct, @strDropProduct, @ysnValid, @strMessage, @strBillOfLading, @dtmPullDate, @strSource 
		WHILE @@FETCH_STATUS = 0
		BEGIN	

			-- BOL AND LOAD DATETIME
			IF EXISTS(SELECT TOP 1 1 FROM tblTRLoadHeader LH INNER JOIN tblTRLoadReceipt LR ON LR.intLoadHeaderId = LH.intLoadHeaderId
			WHERE LH.dtmLoadDateTime = @dtmPullDate
			AND LR.strBillOfLading = @strBillOfLading)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Load has already been imported')
				UPDATE tblTRImportLoadDetail SET strStatus = 'Duplicate' WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

			-- SHIP VIA / CARRIER
			DECLARE @intCarrierId INT = NULL
			IF(@strSource = 'API')
			BEGIN
				SELECT TOP 1 @intCarrierId = intEntityId 
				FROM tblSMShipVia WHERE strShipVia = @strCarrier
			END
			ELSE
			BEGIN
				SELECT @intCarrierId = CRB.intCarrierId
				FROM tblTRCrossReferenceBol CRB 
				WHERE CRB.strType = 'Carrier' AND CRB.strImportValue = @strCarrier
			END

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
			IF(@strSource = 'API')
			BEGIN
				SELECT TOP 1 @intDriverId = E.intEntityId FROM tblARSalesperson S 
				INNER JOIN tblEMEntity E ON E.intEntityId = S.intEntityId 
				WHERE E.strName = @strDriver 
			END
			ELSE
			BEGIN
				SELECT @intDriverId = CRB.intDriverId
				FROM tblTRCrossReferenceBol CRB 
				WHERE CRB.strType = 'Driver' AND CRB.strImportValue = @strDriver
			END		

            IF (@intDriverId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Driver')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intDriverId = @intDriverId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

			-- TRUCK
			IF(@strTruck != '')
			BEGIN
				DECLARE @intTruckId INT = NULL

				IF(@strSource = 'API')
				BEGIN
					--SELECT TOP 1 @intTruckId = E.intEntityId FROM tblSCTruckDriverReference D 
					--INNER JOIN tblEMEntity E ON E.intEntityId = D.intEntityId 
					--WHERE E.strName = @strTruck
					SELECT TOP 1 @intTruckId = T.intEntityShipViaTruckId FROM tblSMShipViaTruck T 
					INNER JOIN tblSMShipVia SV ON SV.intEntityId = T.intEntityShipViaId 
					WHERE T.strTruckNumber = @strTruck
				END
				ELSE
				BEGIN
					SELECT @intTruckId = CRB.intTruckId
					FROM tblTRCrossReferenceBol CRB 
					WHERE CRB.strType = 'Truck' AND CRB.strImportValue = @strTruck
				END
				
				IF (@intTruckId IS NULL)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Truck')	
				END
				ELSE
				BEGIN
					UPDATE tblTRImportLoadDetail SET intTruckId = @intTruckId WHERE intImportLoadDetailId = @intImportLoadDetailId
				END
			END

			-- TRAILER
			IF(@strTrailer != '')
			BEGIN
				DECLARE @intTrailerId INT = NULL
				IF(@strSource = 'API')
				BEGIN
					SELECT TOP 1 @intTrailerId = intEntityShipViaTrailerId 
					FROM tblSMShipViaTrailer 
					WHERE strTrailerNumber = @strTrailer
				END
				ELSE
				BEGIN
					SELECT @intTrailerId = CRB.intTrailerId
					FROM tblTRCrossReferenceBol CRB 
					WHERE CRB.strType = 'Trailer' AND CRB.strImportValue = @strTrailer
				END			

				IF (@intTrailerId IS NULL)
				BEGIN
					SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Trailer')	
				END
				ELSE
				BEGIN
					UPDATE tblTRImportLoadDetail SET intTrailerId = @intTrailerId WHERE intImportLoadDetailId = @intImportLoadDetailId
				END
			END

			-- SUPLLIER / VENDOR
            DECLARE @intVendorId INT = NULL
			DECLARE @intSupplyPointId INT = NULL
			DECLARE @intVendorCompanyLocationId INT = NULL
			IF(@strSource = 'API')
			BEGIN
				SELECT TOP 1 @intVendorId = V.intEntityId, @intSupplyPointId = S.intSupplyPointId, @intVendorCompanyLocationId = C.intCompanyLocationId FROM tblAPVendor V INNER JOIN tblEMEntity E ON E.intEntityId = V.intEntityId
				INNER JOIN tblTRSupplyPoint S ON S.intEntityVendorId = E.intEntityId
				INNER JOIN tblEMEntityLocation L ON L.intEntityLocationId = S.intEntityLocationId AND L.intEntityId = E.intEntityId
				CROSS APPLY tblSMCompanyLocation C
				WHERE  E.strName + '_' + L.strLocationName + '_' + C.strLocationName = @strSupplier
				IF(@intVendorId IS NULL)
				BEGIN
					SELECT TOP 1 @intVendorCompanyLocationId = intCompanyLocationId 
					FROM tblSMCompanyLocation 
					WHERE strLocationName = @strSupplier
				END
			END
			ELSE
			BEGIN
				SELECT @intVendorId = CRB.intSupplierId, @intSupplyPointId = CRB.intSupplyPointId, @intVendorCompanyLocationId = CRB.intCompanyLocationId
				FROM tblTRCrossReferenceBol CRB 
				WHERE CRB.strType = 'Supplier' AND CRB.strImportValue = @strSupplier
			END

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

			IF(@strSource = 'API')
			BEGIN
				SELECT TOP 1 @intCustomerId = C.intEntityId, @intShipToId = L.intEntityLocationId, @intCustomerCompanyLocationId = CL.intCompanyLocationId
				FROM tblARCustomer C INNER JOIN tblEMEntity E ON E.intEntityId = C.intEntityId
				INNER JOIN tblEMEntityLocation L ON L.intEntityId = C.intEntityId
				CROSS APPLY tblSMCompanyLocation CL
				WHERE E.strName + '_' + L.strLocationName + '_' + CL.strLocationName = @strDestination
				IF (@intCustomerId IS NULL)
				BEGIN
					SELECT TOP 1 @intCustomerCompanyLocationId = intCompanyLocationId 
					FROM tblSMCompanyLocation 
					WHERE strLocationName = @strDestination
				END
			END
			ELSE
			BEGIN
				SELECT @intCustomerId = CRB.intCustomerId, @intShipToId = CRB.intCustomerLocationId, @intCustomerCompanyLocationId = CRB.intCompanyLocationId
				FROM tblTRCrossReferenceBol CRB
				WHERE CRB.strType = 'Destination' AND CRB.strImportValue = @strDestination AND ISNULL(ysnDefault, 0) = 0

				IF (ISNULL(@intCustomerId, 0) = 0)
				BEGIN
					SELECT TOP 1 @intCustomerId = CRB.intCustomerId, @intShipToId = CRB.intCustomerLocationId, @intCustomerCompanyLocationId = CRB.intCompanyLocationId
					FROM tblTRCrossReferenceBol CRB
					WHERE CRB.strType = 'Destination' AND ISNULL(ysnDefault, 0) = 1
				END
			END

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

			IF(@strSource = 'API')
			BEGIN
				SELECT TOP 1 @intPullProductId = intItemId 
				FROM tblICItem WHERE strItemNo = @strPullProduct
			END
			ELSE
			BEGIN
				SELECT @intPullProductId = CRB.intItemId
				FROM tblTRCrossReferenceBol CRB 
				WHERE CRB.strType = 'Item' AND CRB.strImportValue = @strPullProduct
			END

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

			IF(@strSource = 'API')
			BEGIN
				SELECT TOP 1 @intDropProductId = intItemId 
				FROM tblICItem WHERE strItemNo = @strDropProduct
			END
			ELSE
			BEGIN
				SELECT @intDropProductId = CRB.intItemId
				FROM tblTRCrossReferenceBol CRB 
				WHERE CRB.strType = 'Item' AND CRB.strImportValue = @strDropProduct
			END
            

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

			IF(ISNULL(@strMessage, '') != '')
			BEGIN
				IF(NOT EXISTS(SELECT TOP 1 1 FROM tblTRImportLoadDetail WHERE intImportLoadDetailId = @intImportLoadDetailId AND strStatus = 'Duplicate'))
				BEGIN
					UPDATE tblTRImportLoadDetail SET strStatus = 'Failure' WHERE intImportLoadDetailId = @intImportLoadDetailId
				END
			END

			FETCH NEXT FROM @CursorTran INTO @intImportLoadDetailId, @strTruck, @strTerminal, @strCarrier, @strDriver, @strTrailer, @strSupplier, @strDestination, @strPullProduct, @strDropProduct, @ysnValid, @strMessage, @strBillOfLading, @dtmPullDate, @strSource
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