CREATE FUNCTION [dbo].[fnSCGetLoadNoneFreightItemCharges]
(
	@ReceiptStagingTable  ReceiptStagingTable READONLY
	,@ysnPrice BIT
	,@ysnAccrue BIT
	,@intFreightItemId INT
	,@intLoadCostId INT
	,@ysnReferenceOnly BIT
)
RETURNS @OtherCharges TABLE(
	[intEntityVendorId] INT NULL 
	,[strBillOfLadding] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,[strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
	,[intLocationId] INT NOT NULL 
	,[intShipViaId] INT NULL 
	,[intShipFromId] INT NOT NULL
	,[intCurrencyId] INT NULL
	,[intCostCurrencyId] INT NULL 	
	,[intChargeId] INT NULL
	,[intForexRateTypeId] INT NULL	
	,[dblForexRate] NUMERIC(18, 6) NULL
	,[ysnInventoryCost] BIT
	,[strCostMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Per Unit')
	,[dblRate] DECIMAL(18, 6) NULL DEFAULT 0  
	,[intCostUOMId] INT NULL
	,[intOtherChargeEntityVendorId] INT NULL
	,[dblAmount] NUMERIC(18, 6) NULL
	,[intContractHeaderId] INT NULL
	,[intContractDetailId] INT NULL	
	,[ysnAccrue] BIT NULL
	,[ysnPrice] BIT NULL 
	,[strChargesLink] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	,[ysnAllowVoucher] BIT NULL
	,[intLoadShipmentId] INT NULL
	,[intLoadShipmentCostId] INT NULL
	,intTaxGroupId INT NULL
)

BEGIN
	IF @ysnReferenceOnly = 0
	BEGIN
		IF ISNULL(@intLoadCostId,0) != 0
		BEGIN
			INSERT INTO @OtherCharges
			(
				[intEntityVendorId] 
				,[strBillOfLadding] 
				,[strReceiptType] 
				,[intLocationId] 
				,[intShipViaId] 
				,[intShipFromId] 
				,[intCurrencyId]
				,[intCostCurrencyId]  	
				,[intChargeId]
				,[intForexRateTypeId]
				,[dblForexRate] 
				,[ysnInventoryCost] 
				,[strCostMethod] 
				,[dblRate] 
				,[intCostUOMId] 
				,[intOtherChargeEntityVendorId] 
				,[dblAmount] 
				,[intContractHeaderId]
				,[intContractDetailId] 
				,[ysnAccrue]
				,[ysnPrice]
				,[strChargesLink]
				,[ysnAllowVoucher]
				,[intLoadShipmentId]			
				,[intLoadShipmentCostId]	
				,intTaxGroupId
			)
			SELECT	
			[intEntityVendorId]					= RE.intEntityVendorId
			,[strBillOfLadding]					= RE.strBillOfLadding
			,[strReceiptType]					= RE.strReceiptType
			,[intLocationId]					= RE.intLocationId
			,[intShipViaId]						= RE.intShipViaId
			,[intShipFromId]					= RE.intShipFromId
			,[intCurrencyId]  					= RE.intCurrencyId
			,[intCostCurrencyId]  				= ISNULL(LoadCost.intCurrencyId,RE.intCurrencyId)
			,[intChargeId]						= LoadCost.intItemId
			,[intForexRateTypeId]				= RE.intForexRateTypeId
			,[dblForexRate]						= RE.dblForexRate
			,[ysnInventoryCost]					= CASE WHEN ISNULL(LoadCost.ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
			,[strCostMethod]                    = LoadCost.strCostMethod
			,[dblRate]							= CASE
													WHEN LoadCost.strCostMethod = 'Amount' THEN 0
													ELSE LoadCost.dblRate
												END
			,[intCostUOMId]						= LoadCost.intItemUOMId
			,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
			,[dblAmount]						= CASE
													WHEN LoadCost.strCostMethod = 'Amount' THEN  ROUND ((RE.dblQty / SC.dblNetUnits * LoadCost.dblRate), 2)
													ELSE 0
												END								
			,[intContractHeaderId]				= (SELECT TOP 1 intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = RE.intContractDetailId)
			,[intContractDetailId]				= RE.intContractDetailId 
			,[ysnAccrue]						= CASE WHEN ISNULL(LoadCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
			,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN LoadCost.ysnPrice ELSE 0 END
			,[strChargesLink]					= RE.strChargesLink
			,[ysnAllowVoucher]				= CASE WHEN ISNULL(LoadCost.intVendorId,0) > 0 AND ISNULL(LoadCost.intVendorId,0) <> RE.intEntityVendorId THEN 1 ELSE  RE.ysnAllowVoucher END
			,[intLoadShipmentId]			= RE.intLoadShipmentId 
			,[intLoadShipmentCostId]		= LoadCost.intLoadCostId
			,intTaxGroupId = RE.intTaxGroupId
			FROM @ReceiptStagingTable RE 
			INNER JOIN tblLGLoadDetail LoadDetail
				ON RE.intContractDetailId = LoadDetail.intPContractDetailId
			INNER JOIN tblSCTicket SC 
				ON SC.intTicketId = RE.intSourceId
			INNER JOIN tblSCTicketLoadUsed TL
				ON LoadDetail.intLoadDetailId = TL.intLoadDetailId
					AND SC.intTicketId = TL.intTicketId
			LEFT JOIN tblLGLoadCost LoadCost 
				ON LoadCost.intLoadId = LoadDetail.intLoadId
			LEFT JOIN tblICItem IC 
				ON IC.intItemId = LoadCost.intItemId
			WHERE LoadCost.dblRate != 0 
				AND ISNULL(@intFreightItemId, 0) != CASE WHEN  ISNULL(@intFreightItemId, 0) = 0 THEN 1 ELSE LoadCost.intItemId END 
				AND (LoadCost.strEntityType <> 'Customer' OR LoadCost.strEntityType IS NULL)
		END
		ELSE
		BEGIN
			INSERT INTO @OtherCharges
			(
				[intEntityVendorId] 
				,[strBillOfLadding] 
				,[strReceiptType] 
				,[intLocationId] 
				,[intShipViaId] 
				,[intShipFromId] 
				,[intCurrencyId]
				,[intCostCurrencyId]  	
				,[intChargeId]
				,[intForexRateTypeId]
				,[dblForexRate] 
				,[ysnInventoryCost] 
				,[strCostMethod] 
				,[dblRate] 
				,[intCostUOMId] 
				,[intOtherChargeEntityVendorId] 
				,[dblAmount] 
				,[intContractHeaderId]
				,[intContractDetailId] 
				,[ysnAccrue]
				,[ysnPrice]
				,[strChargesLink]
				,[ysnAllowVoucher]
				,[intLoadShipmentId]			
				,[intLoadShipmentCostId]	
				,intTaxGroupId	
			)
			SELECT	
			[intEntityVendorId]					= RE.intEntityVendorId
			,[strBillOfLadding]					= RE.strBillOfLadding
			,[strReceiptType]					= RE.strReceiptType
			,[intLocationId]					= RE.intLocationId
			,[intShipViaId]						= RE.intShipViaId
			,[intShipFromId]					= RE.intShipFromId
			,[intCurrencyId]  					= RE.intCurrencyId
			,[intCostCurrencyId]  				= ISNULL(ContractCost.intCurrencyId,RE.intCurrencyId)
			,[intChargeId]						= ContractCost.intItemId
			,[intForexRateTypeId]				= RE.intForexRateTypeId
			,[dblForexRate]						= RE.dblForexRate
			,[ysnInventoryCost]					= CASE WHEN ISNULL(ContractCost.ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
			,[strCostMethod]					= ContractCost.strCostMethod
			,[dblRate]							= CASE
													WHEN ContractCost.strCostMethod = 'Amount' THEN 0
													ELSE ContractCost.dblRate
												END
			,[intCostUOMId]						= ContractCost.intItemUOMId
			,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
			,[dblAmount]						= CASE
													WHEN ContractCost.strCostMethod = 'Amount' THEN 
													CASE
														WHEN RE.ysnIsStorage = 1 THEN 0
														WHEN RE.ysnIsStorage = 0 THEN ContractCost.dblRate
													END
													ELSE 0
												END
			,[intContractHeaderId]				= RE.intContractHeaderId
			,[intContractDetailId]				= ContractCost.intContractDetailId
			,[ysnAccrue]						= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 THEN 1 ELSE 0 END
			,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN ContractCost.ysnPrice ELSE 0 END
			,[strChargesLink]					= RE.strChargesLink
			,[ysnAllowVoucher]				= CASE WHEN ISNULL(ContractCost.intVendorId,0) > 0 AND ISNULL(ContractCost.intVendorId,0) <> RE.intEntityVendorId THEN 1 ELSE  RE.ysnAllowVoucher END
			,[intLoadShipmentId]			= RE.intLoadShipmentId 
			,[intLoadShipmentCostId]		= NULL--RE.intLoadShipmentDetailId
			,intTaxGroupId = RE.intTaxGroupId
			FROM @ReceiptStagingTable RE 
			INNER JOIN tblCTContractCost ContractCost 
				ON RE.intContractDetailId = ContractCost.intContractDetailId
			INNER JOIN tblSCTicket SC 
				ON SC.intTicketId = RE.intSourceId
			INNER JOIN tblSCTicketContractUsed TC
				ON SC.intTicketId = TC.intTicketId
					AND ContractCost.intContractDetailId = TC.intContractDetailId
			LEFT JOIN tblICItem IC 
				ON IC.intItemId = ContractCost.intItemId
			WHERE ContractCost.dblRate != 0
				AND ISNULL(@intFreightItemId, 0) != CASE WHEN  ISNULL(@intFreightItemId, 0) = 0 THEN 1 ELSE ContractCost.intItemId END 
		END
	END
	ELSE
	BEGIN
		INSERT INTO @OtherCharges
			(
				[intEntityVendorId] 
				,[strBillOfLadding] 
				,[strReceiptType] 
				,[intLocationId] 
				,[intShipViaId] 
				,[intShipFromId] 
				,[intCurrencyId]
				,[intCostCurrencyId]  	
				,[intChargeId]
				,[intForexRateTypeId]
				,[dblForexRate] 
				,[ysnInventoryCost] 
				,[strCostMethod] 
				,[dblRate] 
				,[intCostUOMId] 
				,[intOtherChargeEntityVendorId] 
				,[dblAmount] 
				,[intContractHeaderId]
				,[intContractDetailId] 
				,[ysnAccrue]
				,[ysnPrice]
				,[strChargesLink]
				,[ysnAllowVoucher]
				,[intLoadShipmentId]			
				,[intLoadShipmentCostId]	
				,intTaxGroupId
			)
			SELECT	
			[intEntityVendorId]					= RE.intEntityVendorId
			,[strBillOfLadding]					= RE.strBillOfLadding
			,[strReceiptType]					= RE.strReceiptType
			,[intLocationId]					= RE.intLocationId
			,[intShipViaId]						= RE.intShipViaId
			,[intShipFromId]					= RE.intShipFromId
			,[intCurrencyId]  					= RE.intCurrencyId
			,[intCostCurrencyId]  				= ISNULL(LoadCost.intCurrencyId,RE.intCurrencyId)
			,[intChargeId]						= LoadCost.intItemId
			,[intForexRateTypeId]				= RE.intForexRateTypeId
			,[dblForexRate]						= RE.dblForexRate
			,[ysnInventoryCost]					= CASE WHEN ISNULL(LoadCost.ysnPrice,0) = 1 THEN 0 ELSE IC.ysnInventoryCost END
			,[strCostMethod]                    = LoadCost.strCostMethod
			,[dblRate]							= CASE
													WHEN LoadCost.strCostMethod = 'Amount' THEN 0
													ELSE LoadCost.dblRate
												END
			,[intCostUOMId]						= LoadCost.intItemUOMId
			,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
			,[dblAmount]						= CASE
													WHEN LoadCost.strCostMethod = 'Amount' THEN  ROUND ((RE.dblQty / SC.dblNetUnits * LoadCost.dblRate), 2)
													ELSE 0
												END								
			,[intContractHeaderId]				= (SELECT TOP 1 intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = RE.intContractDetailId)
			,[intContractDetailId]				= RE.intContractDetailId 
			,[ysnAccrue]						= CASE WHEN ISNULL(LoadCost.intVendorId,0) > 0 AND ISNULL(LoadCost.intVendorId,0) <> RE.intEntityVendorId THEN 1 ELSE 0 END
			,[ysnPrice]							= CASE WHEN RE.ysnIsStorage = 0 THEN LoadCost.ysnPrice ELSE 0 END
			,[strChargesLink]					= RE.strChargesLink
			,[ysnAllowVoucher]				= CASE WHEN ISNULL(LoadCost.intVendorId,0) > 0 AND ISNULL(LoadCost.intVendorId,0) <> RE.intEntityVendorId THEN LoadCost.ysnAccrue ELSE  RE.ysnAllowVoucher END
			,[intLoadShipmentId]			= RE.intLoadShipmentId 
			,[intLoadShipmentCostId]		= LoadCost.intLoadCostId
			,intTaxGroupId = RE.intTaxGroupId
			FROM @ReceiptStagingTable RE 			
			INNER JOIN tblSCTicket SC 
				ON SC.intTicketId = RE.intSourceId
			INNER JOIN tblLGLoadDetail LoadDetail
				ON SC.intLoadId = LoadDetail.intLoadId				
			LEFT JOIN tblLGLoadCost LoadCost 
				ON LoadCost.intLoadId = LoadDetail.intLoadId
			LEFT JOIN tblICItem IC 
				ON IC.intItemId = LoadCost.intItemId
			WHERE LoadCost.dblRate != 0 
				AND ISNULL(@intFreightItemId, 0) != CASE WHEN  ISNULL(@intFreightItemId, 0) = 0 THEN 1 ELSE LoadCost.intItemId END 
				AND (LoadCost.strEntityType <> 'Customer' OR LoadCost.strEntityType IS NULL)

	END
	
	RETURN
END