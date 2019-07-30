CREATE PROCEDURE [dbo].[uspTRProcessImportBol]
	@intImportLoadId INT
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

		DECLARE @intImportLoadDetailId INT = NULL,
			@intTruckId INT = NULL,
			@intVendorId INT = NULL,
			@intSupplyPointId INT = NULL,
			@intVendorCompanyLocationId INT = NULL,
			@intCustomerId INT = NULL, 
			@intShipToId INT = NULL, 
			@intCustomerCompanyLocationId INT = NULL,
			@intCarrierId INT = NULL,
			@intDriverId INT = NULL,
			@intTrailerId INT = NULL,
			@intPullProductId INT = NULL,
			@intDropProductId INT = NULL,
			@dblDropGross NUMERIC(18,6) = NULL,
			@dblDropNet NUMERIC(18,6) = NULL,
			@dtmPullDate DATETIME = NULL,
			@dtmInvoiceDate DATETIME = NULL, 
			@dtmDropDate DATETIME = NULL, 
			@ysnValid BIT = NULL, 
			@strMessage NVARCHAR(MAX) = NULL

		
		DECLARE @CursorTran AS CURSOR

		SET @CursorTran = CURSOR FOR
		SELECT LD.intImportLoadDetailId, 
			LD.intTruckId, 
			LD.intVendorId, 
			LD.intSupplyPointId, 
			LD.intVendorCompanyLocationId,
			LD.intCustomerId, 
			LD.intShipToId, 
			LD.intCustomerCompanyLocationId, 
			LD.intCarrierId, 
			LD.intDriverId, 
			LD.intTrailerId, 
			LD.intPullProductId, 
			LD.intDropProductId, 
			LD.dblDropGross, 
			LD.dblDropNet,
			LD.dtmPullDate,
			LD.dtmInvoiceDate, 
			LD.dtmDropDate, 
			LD.ysnValid, 
			LD.strMessage
		FROM tblTRImportLoadDetail LD where LD.ysnValid = 1 and LD.intImportLoadId = @intImportLoadId

		BEGIN TRANSACTION

		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intImportLoadDetailId, @intTruckId, @intVendorId, @intSupplyPointId,
			@intVendorCompanyLocationId,
			@intCustomerId, 
			@intShipToId, 
			@intCustomerCompanyLocationId,
			@intCarrierId,
			@intDriverId,
			@intTrailerId,
			@intPullProductId,
			@intDropProductId,
			@dblDropGross,
			@dblDropNet,
			@dtmPullDate,
			@dtmInvoiceDate, 
			@dtmDropDate, 
			@ysnValid, 
			@strMessage
		WHILE @@FETCH_STATUS = 0
		BEGIN	
			

			FETCH NEXT FROM @CursorTran INTO
		END

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