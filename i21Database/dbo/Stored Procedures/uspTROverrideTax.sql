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
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND ISNULL(intSupplierId, 0) = @intSupplierId
			AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND ISNULL(intCustomerId, 0) = @intCustomerId
			AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NOT NULL
			AND intSupplyPointId IS NOT NULL
			AND intCustomerId IS NOT NULL
			AND intCustomerShipToId IS NOT NULL
			AND intBulkLocationId IS NOT NULL
			AND intShipViaId IS NOT NULL

			--print 1
	END


	-- Ignore Bulk
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND ISNULL(intSupplierId, 0) = @intSupplierId
			AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND ISNULL(intCustomerId, 0) = @intCustomerId
			AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			--AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NOT NULL
			AND intSupplyPointId IS NOT NULL
			AND intCustomerId IS NOT NULL
			AND intCustomerShipToId IS NOT NULL
			AND intBulkLocationId IS NULL
			AND intShipViaId IS NOT NULL

			--print 2
	END


	-- Ignore Ship Via
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND ISNULL(intSupplierId, 0) = @intSupplierId
			AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND ISNULL(intCustomerId, 0) = @intCustomerId
			AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			--AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NOT NULL
			AND intSupplyPointId IS NOT NULL
			AND intCustomerId IS NOT NULL
			AND intCustomerShipToId IS NOT NULL
			AND intBulkLocationId IS NOT NULL
			AND intShipViaId IS NULL

			--print 3
	END

	-- Ignore Bulk, Ship Via
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND ISNULL(intSupplierId, 0) = @intSupplierId
			AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND ISNULL(intCustomerId, 0) = @intCustomerId
			AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			--AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			--AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NOT NULL
			AND intSupplyPointId IS NOT NULL
			AND intCustomerId IS NOT NULL
			AND intCustomerShipToId IS NOT NULL
			AND intBulkLocationId IS NULL
			AND intShipViaId IS NULL

			--print 4
	END


	-- Ignore Customer
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND ISNULL(intSupplierId, 0) = @intSupplierId
			AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			--AND ISNULL(intCustomerId, 0) = @intCustomerId
			--AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NOT NULL
			AND intSupplyPointId IS NOT NULL
			AND intCustomerId IS NULL
			AND intCustomerShipToId IS NULL
			AND intBulkLocationId IS NOT NULL
			AND intShipViaId IS NOT NULL

			--print 5
	END


	-- Ignore Customer, Bulk
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND ISNULL(intSupplierId, 0) = @intSupplierId
			AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			--AND ISNULL(intCustomerId, 0) = @intCustomerId
			--AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			--AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NOT NULL
			AND intSupplyPointId IS NOT NULL
			AND intCustomerId IS NULL
			AND intCustomerShipToId IS NULL
			AND intBulkLocationId IS NULL
			AND intShipViaId IS NOT NULL

			--print 6
	END


	-- Ignore Customer, Ship Via
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND ISNULL(intSupplierId, 0) = @intSupplierId
			AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			--AND ISNULL(intCustomerId, 0) = @intCustomerId
			--AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			--AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NOT NULL
			AND intSupplyPointId IS NOT NULL
			AND intCustomerId IS NULL
			AND intCustomerShipToId IS NULL
			AND intBulkLocationId IS NOT NULL
			AND intShipViaId IS NULL

			--print 7
	END


	-- Ignore Customer, Bulk, Ship Via
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			AND ISNULL(intSupplierId, 0) = @intSupplierId
			AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			--AND ISNULL(intCustomerId, 0) = @intCustomerId
			--AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			--AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			--AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NOT NULL
			AND intSupplyPointId IS NOT NULL
			AND intCustomerId IS NULL
			AND intCustomerShipToId IS NULL
			AND intBulkLocationId IS NULL
			AND intShipViaId IS NULL

			--print 8
	END

	
	-- Ignore Supplier
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			--AND ISNULL(intSupplierId, 0) = @intSupplierId
			--AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND ISNULL(intCustomerId, 0) = @intCustomerId
			AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NULL
			AND intSupplyPointId IS NULL
			AND intCustomerId IS NOT NULL
			AND intCustomerShipToId IS NOT NULL
			AND intBulkLocationId IS NOT NULL
			AND intShipViaId IS NOT NULL

			--print 9
	END
	

	-- Ignore Supplier, Bulk
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			--AND ISNULL(intSupplierId, 0) = @intSupplierId
			--AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND ISNULL(intCustomerId, 0) = @intCustomerId
			AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			--AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NULL
			AND intSupplyPointId IS NULL
			AND intCustomerId IS NOT NULL
			AND intCustomerShipToId IS NOT NULL
			AND intBulkLocationId IS NULL
			AND intShipViaId IS NOT NULL

			--print 10
	END


	-- Ignore Supplier, Ship Via
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			--AND ISNULL(intSupplierId, 0) = @intSupplierId
			--AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND ISNULL(intCustomerId, 0) = @intCustomerId
			AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			--AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NULL
			AND intSupplyPointId IS NULL
			AND intCustomerId IS NOT NULL
			AND intCustomerShipToId IS NOT NULL
			AND intBulkLocationId IS NOT NULL
			AND intShipViaId IS NULL

			--print 11
	END


	-- Ignore Supplier, Ship Via, Bulk
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			--AND ISNULL(intSupplierId, 0) = @intSupplierId
			--AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			AND ISNULL(intCustomerId, 0) = @intCustomerId
			AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			--AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			--AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NULL
			AND intSupplyPointId IS NULL
			AND intCustomerId IS NOT NULL
			AND intCustomerShipToId IS NOT NULL
			AND intBulkLocationId IS NULL
			AND intShipViaId IS NULL

			--print 12
	END
	

	-- Ignore Customer, Supplier
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			--AND ISNULL(intSupplierId, 0) = @intSupplierId
			--AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			--AND ISNULL(intCustomerId, 0) = @intCustomerId
			--AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NULL
			AND intSupplyPointId IS NULL
			AND intCustomerId IS NULL
			AND intCustomerShipToId IS NULL
			AND intBulkLocationId IS NOT NULL
			AND intShipViaId IS NOT NULL

			--print 13
	END


	-- Ignore Customer, No Supplier, No Ship Via
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			--AND ISNULL(intSupplierId, 0) = @intSupplierId
			--AND ISNULL(intSupplyPointId, 0) = @intSupplyPointId
			-- Distribution
			AND strDistributionState = @strDistributionState
			--AND ISNULL(intCustomerId, 0) = @intCustomerId
			--AND ISNULL(intCustomerShipToId, 0) = @intCustomerShipToId
			AND ISNULL(intBulkLocationId, 0) = @intDistributionBulkLocationId
			-- Ship Via
			--AND ISNULL(intShipViaId, 0) = @intShipViaId

			AND intSupplierId IS NULL
			AND intSupplyPointId IS NULL
			AND intCustomerId IS NULL
			AND intCustomerShipToId IS NULL
			AND intBulkLocationId IS NOT NULL
			AND intShipViaId IS NULL

			--print 14
	END


	-- Ignore Supplier, Customer, Ship Via, Bulk
	IF (@intSetupId IS NULL)
	BEGIN
		SELECT TOP 1 @intSetupId = intOverrideTaxGroupDetailId
		FROM tblTROverrideTaxGroupDetail 
		WHERE
			-- Receipt
			strReceiptState = @strReceiptState 
			-- Distribution
			AND strDistributionState = @strDistributionState

			AND intSupplierId IS NULL
			AND intSupplyPointId IS NULL
			AND intCustomerId IS NULL
			AND intCustomerShipToId IS NULL
			AND intBulkLocationId IS NULL
			AND intShipViaId IS NULL

			--print 15
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