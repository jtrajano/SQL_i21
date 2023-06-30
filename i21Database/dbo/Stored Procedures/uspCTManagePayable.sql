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
				IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTransaction a WHERE a.intRecordId = @intContractHeaderId AND a.intScreenId = @intScreenId AND a.strApprovalStatus IN ('Approved', 'No Need for Approval', 'Approved with Modifications'))
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
SELECT * FROM dbo.fnCTCreateVoucherPayable(@id, @type, 1, @remove) where intEntityVendorId is not null;

IF NOT EXISTS(SELECT TOP 1 1 FROM @voucherPayables)
BEGIN	
	IF @type = 'header' AND @remove = 0
	BEGIN
		EXEC uspCTDeleteBasisUnAccruedPayable @id
	END	
	RETURN
END

IF @remove = 0
BEGIN

	/*CT-5329 (Pass only those payables that are exists in tblAPVoucherPayable)*/

	DECLARE @updateVoucherPayables AS VoucherPayable;
	insert into @updateVoucherPayables (
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
	select distinct
		 a.[intEntityVendorId]    
		 ,a.[intTransactionType]    
		 ,a.[intLocationId]    
		 ,a.[intShipToId]    
		 ,a.[intShipFromId]    
		 ,a.[intShipFromEntityId]    
		 ,a.[intPayToAddressId]    
		 ,a.[intCurrencyId]    
		 ,a.[dtmDate]    
		 ,a.[strVendorOrderNumber]    
		 ,a.[strReference]    
		 ,a.[strSourceNumber]    
		 ,a.[intPurchaseDetailId]    
		 ,a.[intContractHeaderId]    
		 ,a.[intContractDetailId]    
		 ,a.[intContractSeqId]    
		 ,a.[intContractCostId]    
		 ,a.[intScaleTicketId]    
		 ,a.[intInventoryReceiptItemId]    
		 ,a.[intInventoryReceiptChargeId]    
		 ,a.[intInventoryShipmentItemId]    
		 ,a.[intInventoryShipmentChargeId]    
		 ,a.[intLoadShipmentId]    
		 ,a.[intLoadShipmentDetailId]    
		 ,a.[intItemId]          
		 ,a.[intPurchaseTaxGroupId]       
		 ,a.[strMiscDescription]    
		 ,a.[dblOrderQty]    
		 ,a.[dblOrderUnitQty]    
		 ,a.[intOrderUOMId]    
		 ,a.[dblQuantityToBill]    
		 ,a.[dblQtyToBillUnitQty]    
		 ,a.[intQtyToBillUOMId]    
		 ,a.[dblCost]         
		 ,a.[dblCostUnitQty]    
		 ,a.[intCostUOMId]    
		 ,a.[dblNetWeight]    
		 ,a.[dblWeightUnitQty]    
		 ,a.[intWeightUOMId]    
		 ,a.[intCostCurrencyId]    
		 ,a.[dblTax]    
		 ,a.[dblDiscount]    
		 ,a.[intCurrencyExchangeRateTypeId]    
		 ,a.[dblExchangeRate]    
		 ,a.[ysnSubCurrency]    
		 ,a.[intSubCurrencyCents]    
		 ,a.[intAccountId]    
		 ,a.[intShipViaId]    
		 ,a.[intTermId]       
		 ,a.[strBillOfLading]       
		 ,a.[ysnReturn] 
	from
		@voucherPayables a
		,tblAPVoucherPayable b
	where
		b.intContractHeaderId = a.intContractHeaderId
		and b.intContractDetailId = a.intContractDetailId
		and b.intContractCostId = a.intContractCostId

	EXEC uspAPUpdateVoucherPayableQty @voucherPayable = @updateVoucherPayables, @voucherPayableTax = @voucherPayableTax

END
ELSE
BEGIN
	EXEC uspAPRemoveVoucherPayable @voucherPayables, DEFAULT, DEFAULT
END

IF @type = 'header' AND @remove = 0
BEGIN
	EXEC uspCTDeleteBasisUnAccruedPayable @id

	SELECT @intContractDetailId = intContractDetailId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @id
	
	UPDATE	tblCTContractCost
	SET		intPrevConcurrencyId = intConcurrencyId
	WHERE	intContractDetailId	=	@intContractDetailId
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