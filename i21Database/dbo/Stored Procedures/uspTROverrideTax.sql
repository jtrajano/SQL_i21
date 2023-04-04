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
  
	DECLARE @intSetupReceiptTaxGroupId INT = NULL,  
	@intSetupDistributionTaxGroupId INT = NULL,  
	@intSetupSupplierId INT = NULL,  
	@intSetupSupplyPointId INT = NULL,  
	@strSetupReceiptState NVARCHAR(5) = NULL,  
	@intSetupCustomerId INT = NULL,  
	@intSetupCustomerShipToId INT = NULL,  
	@strSetupDistributionState NVARCHAR(5) = NULL,  
	@intSetupBulkLocationId INT = NULL,  
	@intSetupShipViaId INT = NULL,
    @intSetupId INT = NULL

	-- All Setup
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intSupplierId IS NOT NULL
	AND @intSupplyPointId IS NOT NULL
	AND @intCustomerId IS NOT NULL
	AND @intCustomerShipToId IS NOT NULL
	AND @intShipViaId IS NOT NULL
	AND @intDistributionBulkLocationId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND intSupplierId = @intSupplierId
			AND intSupplyPointId = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intCustomerId = @intCustomerId
			AND intCustomerShipToId = @intCustomerShipToId
			AND intBulkLocationId = @intDistributionBulkLocationId
			-- Ship Via
			AND intShipViaId = @intShipViaId
	END

	-- No Ship Via
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL
	AND @intSupplierId IS NOT NULL
	AND @intSupplyPointId IS NOT NULL
	AND @intCustomerId IS NOT NULL
	AND @intCustomerShipToId IS NOT NULL
	AND @intDistributionBulkLocationId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND intSupplierId = @intSupplierId
			AND intSupplyPointId = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intCustomerId = @intCustomerId
			AND intCustomerShipToId = @intCustomerShipToId
			AND intBulkLocationId = @intDistributionBulkLocationId
	END

	-- No Bulk Location
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL
	AND @intSupplierId IS NOT NULL
	AND @intSupplyPointId IS NOT NULL
	AND @intCustomerId IS NOT NULL
	AND @intCustomerShipToId IS NOT NULL
	AND @intShipViaId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND intSupplierId = @intSupplierId
			AND intSupplyPointId = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intCustomerId = @intCustomerId
			AND intCustomerShipToId = @intCustomerShipToId
			-- Ship Via
			AND intShipViaId = @intShipViaId
	END


	-- No Bulk, No Shipvia
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intSupplierId IS NOT NULL
	AND @intSupplyPointId IS NOT NULL
	AND @intCustomerId IS NOT NULL
	AND @intCustomerShipToId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND intSupplierId = @intSupplierId
			AND intSupplyPointId = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intCustomerId = @intCustomerId
			AND intCustomerShipToId = @intCustomerShipToId
	END


	-- No Customer, 
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intSupplierId IS NOT NULL
	AND @intSupplyPointId IS NOT NULL
	AND @intShipViaId IS NOT NULL
	AND @intDistributionBulkLocationId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND intSupplierId = @intSupplierId
			AND intSupplyPointId = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intBulkLocationId = @intDistributionBulkLocationId
			-- Ship Via
			AND intShipViaId = @intShipViaId
	END

	-- No Customer, No Bulk
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intSupplierId IS NOT NULL
	AND @intSupplyPointId IS NOT NULL
	AND @intShipViaId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND intSupplierId = @intSupplierId
			AND intSupplyPointId = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			-- Ship Via
			AND intShipViaId = @intShipViaId
	END

	-- No Customer, No Ship Via
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intSupplierId IS NOT NULL
	AND @intSupplyPointId IS NOT NULL
	AND @intDistributionBulkLocationId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND intSupplierId = @intSupplierId
			AND intSupplyPointId = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intBulkLocationId = @intDistributionBulkLocationId
	END



	-- No Customer, No Bulk, No Ship Via
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intSupplierId IS NOT NULL
	AND @intSupplyPointId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND intSupplierId = @intSupplierId
			AND intSupplyPointId = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
	END


	-- No Supplier
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intCustomerId IS NOT NULL
	AND @intCustomerShipToId IS NOT NULL
	AND @intShipViaId IS NOT NULL
	AND @intDistributionBulkLocationId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intCustomerId = @intCustomerId
			AND intCustomerShipToId = @intCustomerShipToId
			AND intBulkLocationId = @intDistributionBulkLocationId
			-- Ship Via
			AND intShipViaId = @intShipViaId
	END


	-- No Supplier, No Bulk
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intCustomerId IS NOT NULL
	AND @intCustomerShipToId IS NOT NULL
	AND @intShipViaId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intCustomerId = @intCustomerId
			AND intCustomerShipToId = @intCustomerShipToId
			-- Ship Via
			AND intShipViaId = @intShipViaId
	END

	-- No Supplier, No Ship Via
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intCustomerId IS NOT NULL
	AND @intCustomerShipToId IS NOT NULL
	AND @intDistributionBulkLocationId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intCustomerId = @intCustomerId
			AND intCustomerShipToId = @intCustomerShipToId
			AND intBulkLocationId = @intDistributionBulkLocationId
	END


	-- No Supplier, No Bulk, No Ship Via
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intCustomerId IS NOT NULL
	AND @intCustomerShipToId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intCustomerId = @intCustomerId
			AND intCustomerShipToId = @intCustomerShipToId
	END


	-- No Customer, No Supplier
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intShipViaId IS NOT NULL
	AND @intDistributionBulkLocationId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intBulkLocationId = @intDistributionBulkLocationId
			-- Ship Via
			AND intShipViaId = @intShipViaId
	END


	-- No Customer, No Supplier, No Ship Via
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intDistributionBulkLocationId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND intBulkLocationId = @intDistributionBulkLocationId
	END
	

	-- No Customer, No Supplier, No Bulk
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	AND @intShipViaId IS NOT NULL
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			-- Distribution
			AND strDistributionState = @strDistributionState
			-- Ship Via
			AND intShipViaId = @intShipViaId
	END


	-- No Customer, No Supplier, No Bulk, No Ship Via
	IF (@intSetupId IS NULL
	AND @strReceiptState IS NOT NULL 
	AND @strDistributionState IS NOT NULL 
	)
	BEGIN
		SELECT @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			-- Distribution
			AND strDistributionState = @strDistributionState
	END

	IF (@intSetupId IS NOT NULL)
	BEGIN
		SELECT @intSetupReceiptTaxGroupId = intReceiptTaxGroupId, 
			@intSetupDistributionTaxGroupId = intDistributionTaxGroupId
		FROM tblTROverrideTaxGroupDetail
		WHERE intOverrideTaxGroupDetailId = @intSetupId

		SELECT @strReceiptTaxGroup = strTaxGroup FROM tblSMTaxGroup WHERE intTaxGroupId = @intSetupReceiptTaxGroupId  
		SELECT @strDistributionTaxGroup = strTaxGroup FROM tblSMTaxGroup WHERE intTaxGroupId = @intSetupDistributionTaxGroupId  
		SET @intReceiptTaxGroupId = @intSetupReceiptTaxGroupId  
		SET @intDistributionTaxGroupId = @intSetupDistributionTaxGroupId  
	END
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