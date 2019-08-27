CREATE PROCEDURE [dbo].[uspCTManagePayable]
	@id INT,
	@type NVARCHAR(10),
	@remove BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	declare @intScreenId int = 0;
	declare @intContractHeaderId int = 0;
	declare @intContractDetailId int = 0;

	if (@remove = 0)
	begin
		if (@type = 'header')
		begin
			set @intContractHeaderId = @id;
		end
		if (@type = 'detail')
		begin
			set @intContractDetailId = @id;
			set @intContractHeaderId = (select top 1 intContractHeaderId from tblCTContractDetail where intContractDetailId = @intContractDetailId);
		end
		if (@type = 'cost')
		begin
			set @intContractDetailId = (select top 1 intContractDetailId from tblCTContractCost where intContractCostId = @id);
			set @intContractHeaderId = (select top 1 intContractHeaderId from tblCTContractDetail where intContractDetailId = @intContractDetailId);
		end

		if (@intContractHeaderId is not null and @intContractHeaderId > 0)
		begin
			set @intScreenId = (select top 1 intScreenId from tblSMScreen where strModule = 'Contract Management' and strNamespace = 'ContractManagement.view.Contract');
			if not exists (select * from tblSMTransaction a where a.intRecordId = @intContractHeaderId and a.intScreenId = @intScreenId and a.strApprovalStatus in ('Approved', 'No Need for Approval'))
			begin
				/*Don't add to Payables if the contract is not yet approved.*/
				return;
			end
		end
		else
		begin
			return;
		end
	end

DECLARE @voucherPayables AS VoucherPayable;
DECLARE @voucherPayableTax AS VoucherDetailTax;

INSERT INTO @voucherPayables(
	[intEntityVendorId]
	,[intTransactionType]
	,[intLocationId]
	,[intShipToId]
	,[intShipFromId]
	,[intShipFromEntityId]
	,[intPayToAddressId]
	,[intCurrencyId]
	,[dtmDate]
	,[strVendorOrderNumber]
	,[strReference]
	,[strSourceNumber]
	,[intPurchaseDetailId]
	,[intContractHeaderId]
	,[intContractDetailId]
	,[intContractSeqId]
	,[intContractCostId]
	,[intScaleTicketId]
	,[intInventoryReceiptItemId]
	,[intInventoryReceiptChargeId]
	,[intInventoryShipmentItemId]
	,[intInventoryShipmentChargeId]
	,[intLoadShipmentId]
	,[intLoadShipmentDetailId]
	,[intItemId]						
	,[intPurchaseTaxGroupId]			
	,[strMiscDescription]
	,[dblOrderQty]
	,[dblOrderUnitQty]
	,[intOrderUOMId]
	,[dblQuantityToBill]
	,[dblQtyToBillUnitQty]
	,[intQtyToBillUOMId]
	,[dblCost]					
	,[dblCostUnitQty]
	,[intCostUOMId]
	,[dblNetWeight]
	,[dblWeightUnitQty]
	,[intWeightUOMId]
	,[intCostCurrencyId]
	,[dblTax]
	,[dblDiscount]
	,[intCurrencyExchangeRateTypeId]
	,[dblExchangeRate]
	,[ysnSubCurrency]
	,[intSubCurrencyCents]
	,[intAccountId]
	,[intShipViaId]
	,[intTermId]			
	,[strBillOfLading]			
	,[ysnReturn]						
)
SELECT * FROM dbo.fnCTCreateVoucherPayable(@id, @type, 1);

IF NOT EXISTS(SELECT * FROM @voucherPayables)
BEGIN	
	IF @type = 'header' AND @remove = 0
	BEGIN
		EXEC uspCTDeleteBasisUnAccruedPayable @id
	END	
	RETURN
END

IF @remove = 0
BEGIN
	EXEC uspAPUpdateVoucherPayableQty @voucherPayable = @voucherPayables, @voucherPayableTax = @voucherPayableTax
END
ELSE
BEGIN
	EXEC uspAPRemoveVoucherPayable @voucherPayables, DEFAULT, DEFAULT
END

IF @type = 'header' AND @remove = 0
BEGIN
	EXEC uspCTDeleteBasisUnAccruedPayable @id
END

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH