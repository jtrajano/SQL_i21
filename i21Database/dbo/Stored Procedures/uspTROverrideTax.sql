CREATE PROCEDURE [dbo].[uspTROverrideTax]
	@intSupplierId INT,
	 @intSupplyPointId INT,
	 @strReceiptState NVARCHAR(5),
	 @intCustomerId INT,
	 @intCustomerShipToId INT,
	 @intShipViaId INT,
	 @strDistributionState NVARCHAR(5),
	 @intDistributionBulkLocationId INT,
	 @intReceiptTaxGroupId INT OUTPUT,
	 @strReceiptTaxGroup NVARCHAR(100) OUTPUT,
	 @intDistributionTaxGroupId INT OUTPUT,
	 @strDistributionTaxGroup NVARCHAR(100) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN TRY

	DECLARE @CursorOverrideSetup AS CURSOR,
		@intSetupReceiptTaxGroupId INT = NULL,
		@intSetupDistributionTaxGroupId INT = NULL,
		@intSetupSupplierId INT = NULL,
		@intSetupSupplyPointId INT = NULL,
		@strSetupReceiptState NVARCHAR(5) = NULL,
		@intSetupCustomerId INT = NULL,
		@intSetupCustomerShipToId INT = NULL,
		@strSetupDistributionState NVARCHAR(5) = NULL,
		@intSetupBulkLocationId INT = NULL,
		@intSetupShipViaId INT = NULL

	SET @CursorOverrideSetup = CURSOR FOR
	SELECT OTGD.intReceiptTaxGroupId, 
		OTGD.intDistributionTaxGroupId,
		OTGD.intSupplierId,
		OTGD.intSupplyPointId,
		OTGD.strReceiptState,
		OTGD.intCustomerId,
		OTGD.intCustomerShipToId,
		OTGD.strDistributionState,
		OTGD.intBulkLocationId,
		OTGD.intShipViaId
	FROM tblTROverrideTaxGroupDetail OTGD
	ORDER BY intOverrideTaxGroupDetailId

	DECLARE @ynsMatch BIT = 0

	OPEN @CursorOverrideSetup
	FETCH NEXT FROM @CursorOverrideSetup INTO @intSetupReceiptTaxGroupId, @intSetupDistributionTaxGroupId, @intSetupSupplierId, @intSetupSupplyPointId, @strSetupReceiptState, @intSetupCustomerId, @intSetupCustomerShipToId, @strSetupDistributionState, @intSetupBulkLocationId, @intSetupShipViaId
	WHILE @@FETCH_STATUS = 0
	BEGIN

		-- RECEIPT SIDE
		DECLARE @ysnReceipt BIT = 0
		IF(@intSupplierId IS NOT NULL AND @intSupplyPointId IS NOT NULL)
		BEGIN
			IF(@intSetupSupplierId = @intSupplierId AND @intSetupSupplyPointId = @intSupplyPointId)
			BEGIN
				SET @ysnReceipt = 1
			END
		END	

		IF (ISNULL(@strReceiptState, '') != '' AND @ysnReceipt = 0)
		BEGIN
			IF(ISNULL(@strSetupReceiptState, '') = ISNULL(@strReceiptState, ''))
			BEGIN
				SET @ysnReceipt = 1
			END
		END


		--DECLARE @ysnReceipt BIT = 0
		--IF(@intSupplierId IS NOT NULL AND @intSupplyPointId IS NOT NULL)
		--BEGIN
		--	IF(@intSetupSupplierId = @intSupplierId AND @intSetupSupplyPointId = @intSupplyPointId)
		--	BEGIN
		--		SET @ysnReceipt = 1
		--	END
		--END	
		--ELSE IF (ISNULL(@strReceiptState, '') != '' AND @ysnReceipt = 0)
		--BEGIN
		--	IF(ISNULL(@strSetupReceiptState, '') = ISNULL(@strReceiptState, ''))
		--	BEGIN
		--		SET @ysnReceipt = 1
		--	END
		--END
		

		-- DISTRIBUTION SIDE
		DECLARE @ysnDistribution BIT = 0

		IF(@intCustomerId IS NOT NULL AND @intCustomerShipToId IS NOT NULL)
		BEGIN
			IF(@intSetupCustomerId = @intCustomerId AND @intSetupCustomerShipToId = @intCustomerShipToId)
			BEGIN
				SET @ysnDistribution = 1
			END
			ELSE IF (ISNULL(@strSetupDistributionState, '') = ISNULL(@strDistributionState, ''))
			BEGIN
				SET @ysnDistribution = 1
			END
		END

		--IF (ISNULL(@strDistributionState, '') != '' AND @ysnDistribution = 0)
		--BEGIN
		--	IF(ISNULL(@strSetupDistributionState, '') = ISNULL(@strDistributionState, ''))
		--	BEGIN
		--		SET @ysnDistribution = 1
		--	END
		--END

		ELSE IF (@intDistributionBulkLocationId IS NOT NULL)
		BEGIN
			IF(@intSetupBulkLocationId = @intDistributionBulkLocationId)
			BEGIN
				SET @ysnDistribution = 1
			END
			ELSE IF (ISNULL(@strSetupDistributionState, '') = ISNULL(@strDistributionState, ''))
			BEGIN
				SET @ysnDistribution = 1
			END
		END



		--ELSE IF (ISNULL(@strDistributionState, '') != '')
		--BEGIN
		--	IF (@intDistributionBulkLocationId IS NOT NULL)
		--	BEGIN
		--		IF(@intSetupBulkLocationId = @intDistributionBulkLocationId)
		--		BEGIN
		--			SET @ysnDistribution = 1
		--		END
		--	END
		--	ELSE IF(ISNULL(@strSetupDistributionState, '') = ISNULL(@strDistributionState, ''))
		--	BEGIN
		--		SET @ysnDistribution = 1
		--	END
		--END


		--IF(@intSetupCustomerId IS NOT NULL AND @intSetupCustomerShipToId IS NOT NULL)
		--BEGIN
		--	IF(@intSetupCustomerId = @intCustomerId AND @intSetupCustomerShipToId = @intCustomerShipToId)
		--	BEGIN
		--		SET @ysnDistribution = 1
		--	END
		--END
		--ELSE IF (ISNULL(@strSetupDistributionState, '') != '' AND @ysnDistribution = 0)
		--BEGIN
		--	IF(ISNULL(@strSetupDistributionState, '') = ISNULL(@strDistributionState, ''))
		--	BEGIN
		--		SET @ysnDistribution = 1
		--	END
		--END

		
		DECLARE @ysnShipVia BIT = 1
		IF(@intShipViaId IS NOT NULL)
		BEGIN
			IF(@intSetupShipViaId != @intShipViaId)
			BEGIN
				SET @ysnShipVia = 0
			END
		END

		IF(@ysnReceipt = 1 AND @ysnDistribution = 1 AND @ysnShipVia = 1)
		BEGIN
			SELECT @strReceiptTaxGroup = strTaxGroup FROM tblSMTaxGroup WHERE intTaxGroupId = @intSetupReceiptTaxGroupId
			SELECT @strDistributionTaxGroup = strTaxGroup FROM tblSMTaxGroup WHERE intTaxGroupId = @intSetupDistributionTaxGroupId
			SET @intReceiptTaxGroupId = @intSetupReceiptTaxGroupId
			SET @intDistributionTaxGroupId = @intSetupDistributionTaxGroupId
			BREAK 
		END

		FETCH NEXT FROM @CursorOverrideSetup INTO @intSetupReceiptTaxGroupId, @intSetupDistributionTaxGroupId, @intSetupSupplierId, @intSetupSupplyPointId, @strSetupReceiptState, @intSetupCustomerId, @intSetupCustomerShipToId, @strSetupDistributionState, @intSetupBulkLocationId, @intSetupShipViaId
	END

	CLOSE @CursorOverrideSetup
	DEALLOCATE @CursorOverrideSetup

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorState INT,
			@errorMessage NVARCHAR(MAX)

	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @errorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
