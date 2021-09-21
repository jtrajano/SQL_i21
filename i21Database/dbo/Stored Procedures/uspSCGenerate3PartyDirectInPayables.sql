CREATE PROCEDURE [dbo].[uspSCGenerate3PartyDirectInPayables]
	@DirectVoucherLineItem AS ScaleDirectToVoucherItem READONLY
	,@intUserId INT
	
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @voucherPayable VoucherPayable
DECLARE @voucherPayableTax VoucherDetailTax 
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @defaultCurrency INT;
DECLARE @currentDateFilter DATETIME = (SELECT CONVERT(char(10), GETDATE(),126));


BEGIN

	---TICKET FREIGHT
	BEGIN
		INSERT INTO @voucherPayable(
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
			,[intScaleTicketId]					
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]		
			,[intInventoryShipmentItemId]		
			,[intInventoryShipmentChargeId]		
			,[strLoadShipmentNumber]
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
			,[dblDiscount]
			,[intAccountId]						
			,[intShipViaId]						
			,[intTermId]						
			,[strBillOfLading]					
			,intSubLocationId 
			,intStorageLocationId
			,intTicketDistributionAllocationId						
		)
		SELECT 
			[intEntityVendorId]	= SC.intHaulerId
			,[intTransactionType] = 1
			,[intLocationId] = SC.intProcessingLocationId
			,[intShipToId] = NULL	
			,[intShipFromId] = NULL	 		
			,[intShipFromEntityId] = NULL
			,[intPayToAddressId] = NULL
			,[intCurrencyId] = SC.intCurrencyId
			,[dtmDate] = SC.dtmTicketDateTime				
			,[strVendorOrderNumber] = 'TKT-' + SC.strTicketNumber
			,[strReference]	= 'TKT-' + SC.strTicketNumber					
			,[strSourceNumber]	= SC.strTicketNumber			
			,[intPurchaseDetailId] = NULL				
			,[intContractHeaderId] = NULL
			,[intContractDetailId] =  A.intContractDetailId		
			,[intContractSeqId] = NULL				
			,[intScaleTicketId]	= SC.intTicketId				
			,[intInventoryReceiptItemId] = NULL	
			,[intInventoryReceiptChargeId] = NULL
			,[intInventoryShipmentItemId] = NULL		
			,[intInventoryShipmentChargeId] = NULL		
			,[strLoadShipmentNumber] = NULL 
			,[intLoadShipmentId] = NULL				
			,[intLoadShipmentDetailId] = A.intLoadDetailId			
			,[intItemId] = SCSetup.intFreightItemId						 
			,[intPurchaseTaxGroupId] = NULL		
			,[strMiscDescription] = IC.strDescription				
			,[dblOrderQty]	= A.dblQuantity						
			,[dblOrderUnitQty] = A.dblUnitQty					
			,[intOrderUOMId] = A.intUnitItemUOMId
			,[dblQuantityToBill] = A.dblQuantity			
			,[dblQtyToBillUnitQty] = A.dblUnitQty				
			,[intQtyToBillUOMId] = A.intUnitItemUOMId
			,[dblCost] = (SC.dblFreightRate * ISNULL(SC.dblContractCostConvertedUOM,1)) --- if cost have different UOM
			,[dblCostUnitQty] = A.dblCostUnitQty
			,[intCostUOMId]	= A.intUnitItemUOMId
			,[dblNetWeight]	= CAST(0 AS DECIMAL(38,20))
			,[dblWeightUnitQty]	= CAST(1 AS DECIMAL(38,20))				
			,[intWeightUOMId] = NULL
			,[intCostCurrencyId] = SC.intCurrencyId
			,[dblDiscount] = 0
			,[intAccountId] = [dbo].[fnGetItemGLAccount](SCSetup.intFreightItemId, SC.intProcessingLocationId, 'AP Clearing')					
			,[intShipViaId]	= NULL						
			,[intTermId] = NULL 			
			,[strBillOfLading] = NULL
			,intSubLocationId =	SC.intSubLocationId
			,intStorageLocationId = SC.intStorageLocationId
			,intTicketDistributionAllocationId = A.intTicketDistributionAllocationId
		FROM @DirectVoucherLineItem A	
		INNER JOIN tblSCTicket SC
			ON A.intScaleTicketId = SC.intTicketId
		INNER JOIN tblSCScaleSetup SCSetup 
			ON SCSetup.intScaleSetupId = SC.intScaleSetupId
		INNER JOIN tblICItem IC 
			ON SCSetup.intFreightItemId = IC.intItemId
		INNER JOIN tblICItemUOM ICUOM
			ON SC.intItemUOMIdTo = ICUOM.intItemUOMId
		WHERE SCSetup.intFreightItemId IS NOT NULL
			AND SC.intHaulerId IS NOT NULL
			AND SC.intItemUOMIdTo IS NOT NULL
			AND A.intEntityId <> SC.intHaulerId
			AND SC.dblFreightRate <> 0
	END



	---CONTRACT COST
	BEGIN
		INSERT INTO @voucherPayable(
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
			,[intScaleTicketId]					
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]		
			,[intInventoryShipmentItemId]		
			,[intInventoryShipmentChargeId]		
			,[strLoadShipmentNumber]
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
			,[dblDiscount]
			,[intAccountId]						
			,[intShipViaId]						
			,[intTermId]						
			,[strBillOfLading]					
			,intSubLocationId 
			,intStorageLocationId
			,intTicketDistributionAllocationId
		)
		SELECT 
			[intEntityVendorId]	= CTC.intVendorId		
			,[intTransactionType] = 1
			,[intLocationId] = SC.intProcessingLocationId
			,[intShipToId] = NULL	
			,[intShipFromId] = NULL	 		
			,[intShipFromEntityId] = NULL
			,[intPayToAddressId] = NULL
			,[intCurrencyId] = SC.intCurrencyId
			,[dtmDate] = SC.dtmTicketDateTime				
			,[strVendorOrderNumber] = 'TKT-' + SC.strTicketNumber
			,[strReference]	= 'TKT-' + SC.strTicketNumber					
			,[strSourceNumber]	= SC.strTicketNumber			
			,[intPurchaseDetailId] = NULL				
			,[intContractHeaderId] = CTD.intContractHeaderId				
			,[intContractDetailId] =  CTD.intContractDetailId			
			,[intContractSeqId] = CTD.intContractSeq					
			,[intScaleTicketId]	= SC.intTicketId				
			,[intInventoryReceiptItemId] = NULL	
			,[intInventoryReceiptChargeId] = NULL
			,[intInventoryShipmentItemId] = NULL		
			,[intInventoryShipmentChargeId] = NULL		
			,[strLoadShipmentNumber] = NULL 
			,[intLoadShipmentId] = NULL				
			,[intLoadShipmentDetailId] = NULL			
			,[intItemId] = CTC.intItemId						 
			,[intPurchaseTaxGroupId] = NULL		
			,[strMiscDescription] = IC.strDescription				
			,[dblOrderQty]	= A.dblQuantity						
			,[dblOrderUnitQty] = A.dblUnitQty					
			,[intOrderUOMId] = A.intUnitItemUOMId
			,[dblQuantityToBill] = A.dblQuantity			
			,[dblQtyToBillUnitQty] = A.dblUnitQty				
			,[intQtyToBillUOMId] = A.intUnitItemUOMId
			,[dblCost] = CTC.dblRate
			,[dblCostUnitQty] = A.dblCostUnitQty
			,[intCostUOMId]	= CTC.intItemUOMId
			,[dblNetWeight]	= CAST(0 AS DECIMAL(38,20))
			,[dblWeightUnitQty]	= CAST(1 AS DECIMAL(38,20))				
			,[intWeightUOMId] = NULL
			,[intCostCurrencyId] = CTC.intCurrencyId
			,[dblDiscount] = 0
			,[intAccountId] = [dbo].[fnGetItemGLAccount](A.intItemId, SC.intProcessingLocationId, 'AP Clearing')					
			,[intShipViaId]	= NULL						
			,[intTermId] = NULL 			
			,[strBillOfLading] = NULL
			,intSubLocationId =	SC.intSubLocationId
			,intStorageLocationId = SC.intStorageLocationId
			,intTicketDistributionAllocationId = A.intTicketDistributionAllocationId
		FROM @DirectVoucherLineItem A	
		INNER JOIN tblSCTicket SC
			ON A.intScaleTicketId = SC.intTicketId
		INNER JOIN tblSCScaleSetup SCSetup 
			ON SCSetup.intScaleSetupId = SC.intScaleSetupId
		INNER JOIN tblCTContractDetail CTD
			ON SC.intContractId = CTD.intContractDetailId
		INNER JOIN tblCTContractHeader CTH
			ON CTD.intContractHeaderId = CTH.intContractHeaderId
		INNER JOIN tblCTContractCost CTC
			ON CTD.intContractDetailId = CTC.intContractDetailId
		INNER JOIN tblICItem IC 
			ON IC.intItemId = CTC.intItemId
		INNER JOIN tblICItemUOM ICUOM
			ON CTC.intItemUOMId = ICUOM.intItemUOMId
		WHERE CTD.intItemId IS NOT NULL
			AND A.intEntityId <> CTC.intVendorId
			AND CTC.intItemId <> SCSetup.intFreightItemId
			AND CTC.intItemUOMId IS NOT NULL
			AND CTC.dblRate <> 0
			AND CTC.ysnBasis <> 1
	END

	----LOAD COST
	BEGIN
		INSERT INTO @voucherPayable(
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
			,[intScaleTicketId]					
			,[intInventoryReceiptItemId]		
			,[intInventoryReceiptChargeId]		
			,[intInventoryShipmentItemId]		
			,[intInventoryShipmentChargeId]		
			,[strLoadShipmentNumber]
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
			,[dblDiscount]
			,[intAccountId]						
			,[intShipViaId]						
			,[intTermId]						
			,[strBillOfLading]					
			,intSubLocationId 
			,intStorageLocationId	
			,intTicketDistributionAllocationId
		)
		SELECT 
			[intEntityVendorId]	= LGC.intVendorId		
			,[intTransactionType] = 1
			,[intLocationId] = SC.intProcessingLocationId
			,[intShipToId] = NULL	
			,[intShipFromId] = NULL	 		
			,[intShipFromEntityId] = NULL
			,[intPayToAddressId] = NULL
			,[intCurrencyId] = SC.intCurrencyId
			,[dtmDate] = SC.dtmTicketDateTime				
			,[strVendorOrderNumber] = 'TKT-' + SC.strTicketNumber
			,[strReference]	= 'TKT-' + SC.strTicketNumber					
			,[strSourceNumber]	= SC.strTicketNumber			
			,[intPurchaseDetailId] = NULL				
			,[intContractHeaderId] = CTD.intContractHeaderId				
			,[intContractDetailId] =  CTD.intContractDetailId			
			,[intContractSeqId] = CTD.intContractSeq					
			,[intScaleTicketId]	= SC.intTicketId				
			,[intInventoryReceiptItemId] = NULL	
			,[intInventoryReceiptChargeId] = NULL
			,[intInventoryShipmentItemId] = NULL		
			,[intInventoryShipmentChargeId] = NULL		
			,[strLoadShipmentNumber] = NULL 
			,[intLoadShipmentId] = NULL				
			,[intLoadShipmentDetailId] = LGD.intLoadDetailId
			,[intItemId] = LGC.intItemId						 
			,[intPurchaseTaxGroupId] = NULL		
			,[strMiscDescription] = IC.strDescription				
			,[dblOrderQty]	= A.dblQuantity						
			,[dblOrderUnitQty] = A.dblUnitQty					
			,[intOrderUOMId] = A.intUnitItemUOMId
			,[dblQuantityToBill] = A.dblQuantity			
			,[dblQtyToBillUnitQty] = A.dblUnitQty				
			,[intQtyToBillUOMId] = A.intUnitItemUOMId
			,[dblCost] = LGC.dblRate
			,[dblCostUnitQty] = A.dblCostUnitQty
			,[intCostUOMId]	= LGC.intItemUOMId
			,[dblNetWeight]	= CAST(0 AS DECIMAL(38,20))
			,[dblWeightUnitQty]	= CAST(1 AS DECIMAL(38,20))				
			,[intWeightUOMId] = NULL
			,[intCostCurrencyId] = LGC.intCurrencyId
			,[dblDiscount] = 0
			,[intAccountId] = [dbo].[fnGetItemGLAccount](A.intItemId, SC.intProcessingLocationId, 'AP Clearing')					
			,[intShipViaId]	= NULL						
			,[intTermId] = NULL 			
			,[strBillOfLading] = NULL
			,intSubLocationId =	SC.intSubLocationId
			,intStorageLocationId = SC.intStorageLocationId
			,intTicketDistributionAllocationId = A.intTicketDistributionAllocationId
		FROM @DirectVoucherLineItem A	
		INNER JOIN tblSCTicket SC
			ON A.intScaleTicketId = SC.intTicketId
		INNER JOIN tblSCScaleSetup SCSetup 
			ON SCSetup.intScaleSetupId = SC.intScaleSetupId
		INNER JOIN tblLGLoadDetail LGD
			ON A.intLoadDetailId = LGD.intLoadDetailId
		INNER JOIN tblLGLoad LGH
			ON LGD.intLoadId = LGH.intLoadId
		INNER JOIN tblLGLoadCost LGC
			ON LGH.intLoadId = LGC.intLoadId
		INNER JOIN tblICItem IC 
			ON IC.intItemId = LGC.intItemId
		INNER JOIN tblICItemUOM ICUOM
			ON LGC.intItemUOMId = ICUOM.intItemUOMId
		LEFT JOIN tblCTContractDetail CTD
			ON LGD.intPContractDetailId = CTD.intContractDetailId
		LEFT JOIN tblCTContractCost CTC
			ON LGD.intPContractDetailId = CTC.intContractDetailId
		WHERE LGC.intItemId IS NOT NULL
			AND LGC.intItemId <> SCSetup.intFreightItemId
			AND NOT (CTC.intItemId = LGC.intItemId
					AND CTC.intVendorId = LGC.intVendorId
					AND CTC.ysnBasis <> 1
					AND CTC.ysnAccrue = 1)
			AND LGC.dblRate <> 0
			-- AND LGC.ysnAccrue = 1
	END
		

		


	EXEC uspAPAddVoucherPayable @voucherPayable, @voucherPayableTax, 1, @ErrorMessage 

	INSERT INTO tblSCTicketDirectAddPayable(
		[intTicketId]
		,[intEntityVendorId]
		,[intItemId]
		,[intContractDetailId]
		,[intLoadDetailId] 
	)
	SELECT
		[intTicketId] = A.intScaleTicketId
		,[intEntityVendorId] = A.intEntityVendorId
		,[intItemId] = A.intItemId
		,[intContractDetailId] = A.intContractDetailId
		,[intLoadDetailId] = intLoadShipmentDetailId
	FROM @voucherPayable A
		
END
GO