CREATE PROCEDURE [dbo].[uspCTManagePayable]
	@id INT,
	@type NVARCHAR(10),
	@remove BIT = 0,
	@userId INT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @intScreenId			INT = 0,
			@intContractHeaderId	INT = 0,
			@intContractDetailId	INT = 0,
			@requireApproval		BIT = 0,
			@entityId				INT			

	IF (@remove = 0)
	BEGIN
		IF (@type = 'header')
		BEGIN
			SET @intContractHeaderId = @id
			
			SELECT @entityId = intEntityId FROM tblCTContractHeader WHERE intContractHeaderId = @id

			EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
			@type = N'ContractManagement.view.Contract',
			@transactionEntityId = @entityId,
			@currentUserEntityId = @userId,
			@locationId = 0,
			@amount = 0,
			@requireApproval = @requireApproval OUTPUT

		END
		ELSE IF (@type = 'detail')
		BEGIN
			SET @intContractDetailId = @id
			SET @intContractHeaderId = (SELECT TOP 1 intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId);
		END
		ELSE IF (@type = 'cost')
		BEGIN
			SET @intContractDetailId = (SELECT TOP 1 intContractDetailId FROM tblCTContractCost WHERE intContractCostId = @id);
			SET @intContractHeaderId = (SELECT TOP 1 intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId);
		END

		IF @requireApproval = 1
		BEGIN
			IF (@intContractHeaderId IS NOT NULL AND @intContractHeaderId > 0)
			BEGIN
				SET @intScreenId = (SELECT TOP 1 intScreenId FROM tblSMScreen WHERE strModule = 'Contract Management' AND strNamespace = 'ContractManagement.view.Contract');
				IF NOT EXISTS (SELECT * FROM tblSMTransaction a WHERE a.intRecordId = @intContractHeaderId AND a.intScreenId = @intScreenId AND a.strApprovalStatus IN ('Approved', 'No Need for Approval'))
				BEGIN
					/*Don't add to Payables IF the contract is NOT yet approved.*/
					RETURN
				END
			END
			ELSE
			BEGIN
				RETURN
			END
		END		
	END

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
SELECT * FROM dbo.fnCTCreateVoucherPayable(@id, @type, 1, @remove);

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

	UPDATE	CC
	SET		CC.intPrevConcurrencyId = CC.intConcurrencyId
	FROM	tblCTContractCost	CC
	JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
	WHERE	CD.intContractHeaderId	=	@id
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