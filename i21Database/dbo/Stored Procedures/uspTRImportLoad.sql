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
			@strMessage NVARCHAR(MAX) = NULL
	
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
		FROM tblTRImportLoad L 
		INNER JOIN tblTRImportLoadDetail D ON D.intImportLoadId = L.intImportLoadId
		WHERE L.guidImportIdentifier = @guidImportIdentifier AND D.ysnValid = 1 

		BEGIN TRANSACTION

		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportLoadDetailId, @strTruck, @strTerminal, @strCarrier, @strDriver, @strTrailer, @strSupplier, @strDestination, @strPullProduct, @strDropProduct, @ysnValid, @strMessage
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
            -- CHECK IF HAS VALID TRUCK
			DECLARE @intTruckId INT = NULL

			SELECT TOP 1 @intTruckId = intTruckDriverReferenceId FROM tblSCTruckDriverReference 
            WHERE strData = @strTruck
			IF (@intTruckId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Truck')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intTruckId = @intTruckId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

            -- CHECK IF HAS VALID CARRIER
            DECLARE @intCarrierId INT = NULL

            SELECT @intCarrierId = intEntityId FROM tblSMShipVia 
            WHERE strShipVia = @strCarrier
            
            IF (@intCarrierId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Carrier')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intCarrierId = @intCarrierId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

            -- CHECK IF HAS VALID DRIVER
            DECLARE @intDriverId INT = NULL

            SELECT @intDriverId = S.intEntityId FROM tblARSalesperson S 
            INNER JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
            WHERE S.strType = 'Driver' AND E.strName = @strDriver

            IF (@intDriverId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Driver')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intDriverId = @intDriverId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

            -- CHECK IF HAS VALID TRAILER
            DECLARE @intTrailerId INT = NULL

            SELECT @intTrailerId = intEntityShipViaTrailerId FROM tblSMShipViaTrailer T 
            WHERE T.strTrailerNumber = @strTrailer AND T.intEntityShipViaId = @intCarrierId

            IF (@intTrailerId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Trailer')	
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intTrailerId = @intTrailerId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

            -- CHECK IF HAS VALID SUPLLIER
            DECLARE @intSupplierId INT = NULL

            SELECT @intSupplierId = V.intEntityId FROM tblAPVendor V
            INNER JOIN tblEMEntity E ON E.intEntityId = V.intEntityId
            WHERE ysnTransportTerminal = 1 AND E.strName = @strSupplier

            IF (@intSupplierId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Supplier')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intSupplierId = @intSupplierId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

            -- CHECK IF HAS VALID TERMINAL
            DECLARE @intTerminalId INT = NULL

            SELECT @intTerminalId = EL.intEntityLocationId FROM tblEMEntityLocation EL
            INNER JOIN tblEMEntity E ON E.intEntityId = EL.intEntityId
            where EL.intEntityId = @intSupplierId AND EL.strLocationName = @strTerminal 

            IF (@intTerminalId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Terminal')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intTerminalId = @intTerminalId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

            -- CHECK IF HAS VALID DESTINATION
            DECLARE @intDestinationId INT = NULL


            -- CHECK IF HAS VALID PULLED PRODUCT
            DECLARE @intPullProductId INT = NULL

            SELECT @intPullProductId = I.intItemId FROM vyuICItemLocation IL
            INNER JOIN tblICItem I ON I.intItemId = IL.intItemId
            INNER JOIN tblSMUserSecurity U ON U.intCompanyLocationId = IL.intLocationId
            WHERE U.intEntityId = @intUserId AND I.strItemNo = @strPullProduct

            IF (@intPullProductId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Pulled Product')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intPullProductId = @intPullProductId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END

            -- CHECK IF HAS VALID DROPPED PRODUCT
            DECLARE @intDropProductId INT = NULL

            SELECT @intPullProductId = I.intItemId FROM vyuICItemLocation IL
            INNER JOIN tblICItem I ON I.intItemId = IL.intItemId
            INNER JOIN tblSMUserSecurity U ON U.intCompanyLocationId = IL.intLocationId
            WHERE U.intEntityId = @intUserId AND I.strItemNo = @strDropProduct

            IF (@intPullProductId IS NULL)
			BEGIN
				SELECT @strMessage = dbo.fnTRMessageConcat(@strMessage, 'Invalid Dropped Product')
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET intDropProductId = @intDropProductId WHERE intImportLoadDetailId = @intImportLoadDetailId
			END


			IF((@strMessage IS NULL OR @strMessage = '') AND @ysnValid = 1)
			BEGIN
				UPDATE tblTRImportLoadDetail SET ysnValid = 1 WHERE intImportLoadDetailId = @intImportLoadDetailId 
			END
			ELSE
			BEGIN
				UPDATE tblTRImportLoadDetail SET strMessage = @strMessage, ysnValid = 0 WHERE intImportLoadDetailId = @intImportLoadDetailId 
			END

			FETCH NEXT FROM @CursorTran INTO @intImportLoadDetailId, @strTruck, @strTerminal, @strCarrier, @strDriver, @strTrailer, @strSupplier, @strDestination, @strPullProduct, @strDropProduct, @ysnValid, @strMessage
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