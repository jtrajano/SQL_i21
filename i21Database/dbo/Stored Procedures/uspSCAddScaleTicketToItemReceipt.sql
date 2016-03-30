CREATE PROCEDURE [dbo].[uspSCAddScaleTicketToItemReceipt]
	 @intTicketId AS INT
	,@intUserId AS INT
	,@Items ItemCostingTableType READONLY
	,@intEntityId AS INT
	,@strReceiptType AS NVARCHAR(100)
	,@InventoryReceiptId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryReceipt AS INT = 23;
DECLARE @ReceiptNumber AS NVARCHAR(20)

DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'

DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @dblTicketFreightRate AS DECIMAL (9, 5)
DECLARE @intScaleStationId AS INT
--DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnDeductFreightFarmer AS BIT
DECLARE @strTicketNumber AS NVARCHAR(40)
DECLARE @dblTicketFees AS DECIMAL(7, 2)
DECLARE @intFeeItemId AS INT
DECLARE @checkContract AS INT
DECLARE @intLoadContractId AS INT,
		@intLoadId AS INT,
		@intLoadCostId AS INT,
		@intHaulerId AS INT;

BEGIN 
	SELECT	@intTicketUOM = UOM.intUnitMeasureId
	FROM	dbo.tblSCTicket SC	        
			JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
	WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
END

BEGIN 
	SELECT	@intTicketItemUOMId = UM.intItemUOMId, @intLoadId = SC.intLoadId
		FROM	dbo.tblICItemUOM UM	
	      JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.intUnitMeasureId = @intTicketUOM AND SC.intTicketId = @intTicketId
END

--BEGIN
--    SELECT TOP 1 @dblTicketFreightRate = ST.dblFreightRate, @intScaleStationId = ST.intScaleSetupId,
--	@ysnDeductFreightFarmer = ST.ysnFarmerPaysFreight, @strTicketNumber = ST.strTicketNumber,
--	@dblTicketFees = ST.dblTicketFees, @intFreightVendorId = ST.intFreightCarrierId
--	FROM dbo.tblSCTicket ST WHERE
--	ST.intTicketId = @intTicketId
--END

---- Get the transaction id 
--EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt, @ReceiptNumber OUTPUT 

--IF @ReceiptNumber IS NULL 
--BEGIN 
--	-- Raise the error:
--	-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
--	RAISERROR(50030, 11, 1);
--	RETURN;
--END 

DECLARE @ReceiptStagingTable AS ReceiptStagingTable,
		@OtherCharges AS ReceiptOtherChargesTableType, 
        @total as int,
		@intSurchargeItemId as int,
		@intFreightItemId as int;

IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
BEGIN 
	CREATE TABLE #tmpAddItemReceiptResult (
		intSourceId INT
		,intInventoryReceiptId INT
	)
END 


-- Insert Entries to Stagging table that needs to processed to Transport Load
INSERT into @ReceiptStagingTable(
		-- Header
		strReceiptType
		,intEntityVendorId
		,strBillOfLadding
		,intCurrencyId
		,intLocationId
		,intShipFromId
		,intShipViaId
		,intDiscountSchedule
				
		-- Detail				
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,intGrossNetUOMId
		--,intCostUOMId				
		,intContractHeaderId
		,intContractDetailId
		,dtmDate				
		,dblQty
		,dblCost				
		,dblExchangeRate
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,ysnIsStorage
		,dblFreightRate
		,dblGross
		,dblNet
		,intSourceId
		,intSourceType	
		,strSourceScreenName
)	
SELECT 
		strReceiptType				= CASE 
										WHEN LI.intTransactionDetailId IS NULL THEN 'Direct'
										WHEN LI.intTransactionDetailId IS NOT NULL THEN 'Purchase Contract'
									  END
		,intEntityVendorId			= @intEntityId
		,strBillOfLadding			= NULL
		,intCurrencyId				= SC.intCurrencyId
		,intLocationId				= SC.intProcessingLocationId
		,intShipFromId				= (select top 1 intShipFromId from tblAPVendor where intEntityVendorId = @intEntityId)
		,intShipViaId				= SC.intFreightCarrierId
		,intDiscountSchedule		= SC.intDiscountId

		--Detail
		,intItemId					= SC.intItemId
		,intItemLocationId			= SC.intProcessingLocationId
		,intItemUOMId				= LI.intItemUOMId
		,intGrossNetUOMId			= (
											SELECT	ItemUOM.intItemUOMId
											FROM	dbo.tblICItemUOM ItemUOM INNER JOIN tblSCScaleSetup SCSetup
														ON ItemUOM.intUnitMeasureId = SCSetup.intUnitMeasureId
											WHERE	SCSetup.intTicketPoolId = SC.intTicketPoolId
													AND ItemUOM.intItemId = SC.intItemId
									)

		--,intCostUOMId				= (SELECT intUnitMeasureId FROM tblSCScaleSetup WHERE intTicketPoolId = SC.intTicketPoolId)	   
		,intContractHeaderId		= CASE 
										WHEN LI.intTransactionDetailId IS NULL THEN 
											NULL
										WHEN LI.intTransactionDetailId IS NOT NULL THEN 
											(select top 1 intContractHeaderId from tblCTContractDetail where intContractDetailId = LI.intTransactionDetailId)
									  END
		
		,intContractDetailId		= LI.intTransactionDetailId
		,dtmDate					= SC.dtmTicketDateTime
		,dblQty						= LI.dblQty
		,dblCost					= LI.dblCost
		,dblExchangeRate			= 1 -- Need to check this
		,intLotId					= NULL --No LOTS from scale
		,intSubLocationId			= SC.intSubLocationId
		,intStorageLocationId		= SC.intStorageLocationId
		--,ysnIsStorage				= CASE 
		--								WHEN LI.intTransactionDetailId IS NOT NULL THEN 0 -- own
  --                                      WHEN LI.intTransactionDetailId IS NULL THEN 1 -- storage
		--							  END
		,ysnIsStorage				= LI.ysnIsStorage
		,dblFreightRate				= SC.dblFreightRate
		,dblGross					= SC.dblGrossWeight
		,dblNet						= SC.dblGrossWeight - SC.dblTareWeight
		,intSourceId				= SC.intTicketId
		,intSourceType		 		= 1 -- Source type for scale is 1 
		,strSourceScreenName		= 'Scale Ticket'
		
		--,intInventoryReceiptId		= SC.intInventoryReceiptId
		--,dblSurcharge				= 0
		--,ysnFreightInPrice		= NULL
		--,strActualCostId			= NULL
		--,intTaxGroupId			= NULL
		--,strVendorRefNo				= NULL
		--,strSourceId				= SC.intTicketId
FROM	@Items LI INNER JOIN dbo.tblSCTicket SC ON SC.intTicketId = LI.intTransactionId INNER JOIN dbo.tblICItemUOM ItemUOM			
			ON ItemUOM.intItemId = SC.intItemId
			AND ItemUOM.intItemUOMId = @intTicketItemUOMId
			INNER JOIN dbo.tblICUnitMeasure UOM
			ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
			LEFT JOIN dbo.tblCTContractDetail CNT
			ON CNT.intContractDetailId = LI.intTransactionDetailId
WHERE	SC.intTicketId = @intTicketId 
		AND (SC.dblNetUnits != 0 or SC.dblFreightRate != 0)

-- Get the identity value from tblICInventoryReceipt
SELECT @InventoryReceiptId = SCOPE_IDENTITY()

IF @InventoryReceiptId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
	RAISERROR(80004, 11, 1);
	RETURN;
END
SELECT @intFreightItemId = SCSetup.intFreightItemId, @intHaulerId = SCTIicket.intHaulerId FROM tblSCScaleSetup SCSetup
LEFT JOIN tblSCTicket SCTIicket
ON SCSetup.intScaleSetupId = SCTIicket.intScaleSetupId
WHERE intTicketId = @intTicketId

IF	ISNULL(@intLoadId,0) != 0 
	BEGIN
		SELECT @intLoadContractId = LGLD.intPContractDetailId, @intLoadCostId = LGCOST.intLoadCostId FROM tblLGLoad LGL
		INNER JOIN tblLGLoadDetail LGLD
		ON LGL.intLoadId = LGLD.intLoadId
		INNER JOIN tblLGLoadCost LGCOST
		ON LGCOST.intLoadId = LGCOST.intLoadId  
		WHERE LGL.intLoadId = @intLoadId

		IF ISNULL(@intFreightItemId,0) != 0 AND ISNULL(@intHaulerId,0) != 0
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
						,[intChargeId] 
						,[ysnInventoryCost] 
						,[strCostMethod] 
						,[dblRate] 
						,[intCostUOMId] 
						,[intOtherChargeEntityVendorId] 
						,[dblAmount] 
						,[strAllocateCostBy] 
						,[intContractHeaderId]
						,[intContractDetailId] 
						,[ysnAccrue]
				) 
				SELECT	[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intChargeId]						= @intFreightItemId
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= 'Per Unit'
						,[dblRate]							= RE.dblFreightRate
						,[intCostUOMId]						= (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId =  @intFreightItemId)
						,[intOtherChargeEntityVendorId]		= @intHaulerId
						,[dblAmount]						= 0
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= RE.intContractHeaderId
						,[intContractDetailId]				= RE.intContractDetailId
						,[ysnAccrue]						= CASE	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
																		1
																	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
																		0
																	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
																		1
															  END
						FROM	@ReceiptStagingTable RE
						WHERE	RE.dblFreightRate != 0 
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
								,[intChargeId] 
								,[ysnInventoryCost] 
								,[strCostMethod] 
								,[dblRate] 
								,[intCostUOMId] 
								,[intOtherChargeEntityVendorId] 
								,[dblAmount] 
								,[strAllocateCostBy] 
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
						)
						SELECT	
						[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intChargeId]						= LoadCost.intItemId
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= LoadCost.strCostMethod
						,[dblRate]							= LoadCost.dblRate
						,[intCostUOMId]						= LoadCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
						,[dblAmount]						= 0
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
						,[intContractDetailId]				= @intLoadContractId
						,[ysnAccrue]						= LoadCost.ysnAccrue
						FROM @ReceiptStagingTable RE
						LEFT JOIN tblLGLoadDetail LoadDetail
							ON (RE.intContractDetailId = LoadDetail.intPContractDetailId AND RE.intContractDetailId = @intLoadContractId)
						LEFT JOIN tblLGLoadCost LoadCost
							ON LoadCost.intLoadId = LoadDetail.intLoadId
						WHERE LoadCost.intItemId != @intFreightItemId
						AND LoadCost.dblRate != 0;
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
								,[intChargeId] 
								,[ysnInventoryCost] 
								,[strCostMethod] 
								,[dblRate] 
								,[intCostUOMId] 
								,[intOtherChargeEntityVendorId] 
								,[dblAmount] 
								,[strAllocateCostBy] 
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
						)
						SELECT	
						[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intChargeId]						= ContractCost.intItemId
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= ContractCost.strCostMethod
						,[dblRate]							= ContractCost.dblRate
						,[intCostUOMId]						= ContractCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
						,[dblAmount]						= 0
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
						,[intContractDetailId]				= ContractCost.intContractDetailId
						,[ysnAccrue]						= ContractCost.ysnAccrue
						FROM tblCTContractCost ContractCost
						LEFT JOIN @ReceiptStagingTable RE
						ON RE.intContractDetailId = ContractCost.intContractDetailId
						WHERE ContractCost.intItemId != @intFreightItemId
						AND RE.intContractDetailId = @intLoadContractId
						AND ContractCost.intItemId != @intFreightItemId
						AND ContractCost.dblRate != 0;
					END
			END
		ELSE IF ISNULL(@intFreightItemId,0) != 0
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
								,[intChargeId] 
								,[ysnInventoryCost] 
								,[strCostMethod] 
								,[dblRate] 
								,[intCostUOMId] 
								,[intOtherChargeEntityVendorId] 
								,[dblAmount] 
								,[strAllocateCostBy] 
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
						)
						SELECT	
						[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intChargeId]						= LoadCost.intItemId
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= LoadCost.strCostMethod
						,[dblRate]							= LoadCost.dblRate
						,[intCostUOMId]						= LoadCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
						,[dblAmount]						= 0
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
						,[intContractDetailId]				= @intLoadContractId
						,[ysnAccrue]						= LoadCost.ysnAccrue
						FROM tblLGLoadDetail LoadDetail
						LEFT JOIN @ReceiptStagingTable RE
							ON RE.intContractDetailId = LoadDetail.intPContractDetailId
						LEFT JOIN tblLGLoadCost LoadCost
							ON LoadCost.intLoadId = LoadDetail.intLoadId
						WHERE LoadCost.intItemId = @intFreightItemId
						AND LoadDetail.intPContractDetailId = @intLoadContractId
						AND LoadCost.dblRate != 0;

						INSERT INTO @OtherCharges
						(
								[intEntityVendorId] 
								,[strBillOfLadding] 
								,[strReceiptType] 
								,[intLocationId] 
								,[intShipViaId] 
								,[intShipFromId] 
								,[intCurrencyId]  	
								,[intChargeId] 
								,[ysnInventoryCost] 
								,[strCostMethod] 
								,[dblRate] 
								,[intCostUOMId] 
								,[intOtherChargeEntityVendorId] 
								,[dblAmount] 
								,[strAllocateCostBy] 
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
						)
						SELECT	
						[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intChargeId]						= LoadCost.intItemId
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= LoadCost.strCostMethod
						,[dblRate]							= LoadCost.dblRate
						,[intCostUOMId]						= LoadCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
						,[dblAmount]						= 0
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
						,[intContractDetailId]				= @intLoadContractId
						,[ysnAccrue]						= LoadCost.ysnAccrue
						FROM tblLGLoadDetail LoadDetail
						LEFT JOIN @ReceiptStagingTable RE
							ON RE.intContractDetailId = LoadDetail.intPContractDetailId
						LEFT JOIN tblLGLoadCost LoadCost
							ON LoadCost.intLoadId = LoadDetail.intLoadId
						WHERE LoadCost.intItemId != @intFreightItemId
						AND LoadDetail.intPContractDetailId = @intLoadContractId
						AND LoadCost.dblRate != 0;
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
							,[intChargeId] 
							,[ysnInventoryCost] 
							,[strCostMethod] 
							,[dblRate] 
							,[intCostUOMId] 
							,[intOtherChargeEntityVendorId] 
							,[dblAmount] 
							,[strAllocateCostBy] 
							,[intContractHeaderId]
							,[intContractDetailId] 
							,[ysnAccrue]
						)
						SELECT	
						[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intChargeId]						= ContractCost.intItemId
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= ContractCost.strCostMethod
						,[dblRate]							= ContractCost.dblRate
						,[intCostUOMId]						= ContractCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
						,[dblAmount]						= 0
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
						,[intContractDetailId]				= ContractCost.intContractDetailId
						,[ysnAccrue]						= ContractCost.ysnAccrue
						FROM tblCTContractCost ContractCost
						LEFT JOIN @ReceiptStagingTable RE
						ON RE.intContractDetailId = ContractCost.intContractDetailId
						WHERE ContractCost.intItemId = @intFreightItemId
						AND RE.intContractDetailId = @intLoadContractId
						AND ContractCost.dblRate != 0;

						INSERT INTO @OtherCharges
						(
								[intEntityVendorId] 
								,[strBillOfLadding] 
								,[strReceiptType] 
								,[intLocationId] 
								,[intShipViaId] 
								,[intShipFromId] 
								,[intCurrencyId]  	
								,[intChargeId] 
								,[ysnInventoryCost] 
								,[strCostMethod] 
								,[dblRate] 
								,[intCostUOMId] 
								,[intOtherChargeEntityVendorId] 
								,[dblAmount] 
								,[strAllocateCostBy] 
								,[intContractHeaderId]
								,[intContractDetailId] 
								,[ysnAccrue]
						)
						SELECT	
						[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intChargeId]						= ContractCost.intItemId
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= ContractCost.strCostMethod
						,[dblRate]							= ContractCost.dblRate
						,[intCostUOMId]						= ContractCost.intItemUOMId
						,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
						,[dblAmount]						= 0
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
						,[intContractDetailId]				= ContractCost.intContractDetailId
						,[ysnAccrue]						= ContractCost.ysnAccrue
						FROM tblCTContractCost ContractCost
						LEFT JOIN @ReceiptStagingTable RE
						ON RE.intContractDetailId = ContractCost.intContractDetailId
						WHERE ContractCost.intItemId != @intFreightItemId
						AND RE.intContractDetailId = @intLoadContractId
						AND ContractCost.dblRate != 0;
					END
			END
		ELSE
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
							,[intChargeId] 
							,[ysnInventoryCost] 
							,[strCostMethod] 
							,[dblRate] 
							,[intCostUOMId] 
							,[intOtherChargeEntityVendorId] 
							,[dblAmount] 
							,[strAllocateCostBy] 
							,[intContractHeaderId]
							,[intContractDetailId] 
							,[ysnAccrue]
					)
					SELECT	
					[intEntityVendorId]					= RE.intEntityVendorId
					,[strBillOfLadding]					= RE.strBillOfLadding
					,[strReceiptType]					= RE.strReceiptType
					,[intLocationId]					= RE.intLocationId
					,[intShipViaId]						= RE.intShipViaId
					,[intShipFromId]					= RE.intShipFromId
					,[intCurrencyId]  					= RE.intCurrencyId
					,[intChargeId]						= LoadCost.intItemId
					,[ysnInventoryCost]					= 0
					,[strCostMethod]					= LoadCost.strCostMethod
					,[dblRate]							= LoadCost.dblRate
					,[intCostUOMId]						= LoadCost.intItemUOMId
					,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
					,[dblAmount]						= 0
					,[strAllocateCostBy]				=  NULL
					,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
					,[intContractDetailId]				= @intLoadContractId
					,[ysnAccrue]						= LoadCost.ysnAccrue
					FROM tblLGLoadDetail LoadDetail
					LEFT JOIN @ReceiptStagingTable RE
						ON RE.intContractDetailId = LoadDetail.intPContractDetailId
					LEFT JOIN tblLGLoadCost LoadCost
						ON LoadCost.intLoadId = LoadDetail.intLoadId
					WHERE LoadCost.intItemId = @intFreightItemId
					AND LoadDetail.intPContractDetailId = @intLoadContractId
					AND LoadCost.dblRate != 0;

					INSERT INTO @OtherCharges
					(
							[intEntityVendorId] 
							,[strBillOfLadding] 
							,[strReceiptType] 
							,[intLocationId] 
							,[intShipViaId] 
							,[intShipFromId] 
							,[intCurrencyId]  	
							,[intChargeId] 
							,[ysnInventoryCost] 
							,[strCostMethod] 
							,[dblRate] 
							,[intCostUOMId] 
							,[intOtherChargeEntityVendorId] 
							,[dblAmount] 
							,[strAllocateCostBy] 
							,[intContractHeaderId]
							,[intContractDetailId] 
							,[ysnAccrue]
					)
					SELECT	
					[intEntityVendorId]					= RE.intEntityVendorId
					,[strBillOfLadding]					= RE.strBillOfLadding
					,[strReceiptType]					= RE.strReceiptType
					,[intLocationId]					= RE.intLocationId
					,[intShipViaId]						= RE.intShipViaId
					,[intShipFromId]					= RE.intShipFromId
					,[intCurrencyId]  					= RE.intCurrencyId
					,[intChargeId]						= LoadCost.intItemId
					,[ysnInventoryCost]					= 0
					,[strCostMethod]					= LoadCost.strCostMethod
					,[dblRate]							= LoadCost.dblRate
					,[intCostUOMId]						= LoadCost.intItemUOMId
					,[intOtherChargeEntityVendorId]		= LoadCost.intVendorId
					,[dblAmount]						= 0
					,[strAllocateCostBy]				=  NULL
					,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId)
					,[intContractDetailId]				= @intLoadContractId
					,[ysnAccrue]						= LoadCost.ysnAccrue
					FROM tblLGLoadDetail LoadDetail
					LEFT JOIN @ReceiptStagingTable RE
						ON RE.intContractDetailId = LoadDetail.intPContractDetailId
					LEFT JOIN tblLGLoadCost LoadCost
						ON LoadCost.intLoadId = LoadDetail.intLoadId
					WHERE LoadCost.intItemId != @intFreightItemId
					AND LoadDetail.intPContractDetailId = @intLoadContractId
					AND LoadCost.dblRate != 0;
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
						,[intChargeId] 
						,[ysnInventoryCost] 
						,[strCostMethod] 
						,[dblRate] 
						,[intCostUOMId] 
						,[intOtherChargeEntityVendorId] 
						,[dblAmount] 
						,[strAllocateCostBy] 
						,[intContractHeaderId]
						,[intContractDetailId] 
						,[ysnAccrue]
					)
					SELECT	
					[intEntityVendorId]					= RE.intEntityVendorId
					,[strBillOfLadding]					= RE.strBillOfLadding
					,[strReceiptType]					= RE.strReceiptType
					,[intLocationId]					= RE.intLocationId
					,[intShipViaId]						= RE.intShipViaId
					,[intShipFromId]					= RE.intShipFromId
					,[intCurrencyId]  					= RE.intCurrencyId
					,[intChargeId]						= ContractCost.intItemId
					,[ysnInventoryCost]					= 0
					,[strCostMethod]					= ContractCost.strCostMethod
					,[dblRate]							= ContractCost.dblRate
					,[intCostUOMId]						= ContractCost.intItemUOMId
					,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
					,[dblAmount]						= 0
					,[strAllocateCostBy]				=  NULL
					,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
					,[intContractDetailId]				= ContractCost.intContractDetailId
					,[ysnAccrue]						= ContractCost.ysnAccrue
					FROM tblCTContractCost ContractCost
					LEFT JOIN @ReceiptStagingTable RE
					ON RE.intContractDetailId = ContractCost.intContractDetailId
					WHERE ContractCost.intItemId = @intFreightItemId
					AND RE.intContractDetailId = @intLoadContractId
					AND ContractCost.dblRate != 0;

					INSERT INTO @OtherCharges
					(
							[intEntityVendorId] 
							,[strBillOfLadding] 
							,[strReceiptType] 
							,[intLocationId] 
							,[intShipViaId] 
							,[intShipFromId] 
							,[intCurrencyId]  	
							,[intChargeId] 
							,[ysnInventoryCost] 
							,[strCostMethod] 
							,[dblRate] 
							,[intCostUOMId] 
							,[intOtherChargeEntityVendorId] 
							,[dblAmount] 
							,[strAllocateCostBy] 
							,[intContractHeaderId]
							,[intContractDetailId] 
							,[ysnAccrue]
					)
					SELECT	
					[intEntityVendorId]					= RE.intEntityVendorId
					,[strBillOfLadding]					= RE.strBillOfLadding
					,[strReceiptType]					= RE.strReceiptType
					,[intLocationId]					= RE.intLocationId
					,[intShipViaId]						= RE.intShipViaId
					,[intShipFromId]					= RE.intShipFromId
					,[intCurrencyId]  					= RE.intCurrencyId
					,[intChargeId]						= ContractCost.intItemId
					,[ysnInventoryCost]					= 0
					,[strCostMethod]					= ContractCost.strCostMethod
					,[dblRate]							= ContractCost.dblRate
					,[intCostUOMId]						= ContractCost.intItemUOMId
					,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
					,[dblAmount]						= 0
					,[strAllocateCostBy]				=  NULL
					,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
					,[intContractDetailId]				= ContractCost.intContractDetailId
					,[ysnAccrue]						= ContractCost.ysnAccrue
					FROM tblCTContractCost ContractCost
					LEFT JOIN @ReceiptStagingTable RE
					ON RE.intContractDetailId = ContractCost.intContractDetailId
					WHERE ContractCost.intItemId != @intFreightItemId
					AND RE.intContractDetailId = @intLoadContractId
					AND ContractCost.dblRate != 0;
				END
		END
	END
ELSE
	BEGIN
		IF ISNULL(@intFreightItemId,0) != 0 AND ISNULL(@intHaulerId,0) != 0
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
						,[intChargeId] 
						,[ysnInventoryCost] 
						,[strCostMethod] 
						,[dblRate] 
						,[intCostUOMId] 
						,[intOtherChargeEntityVendorId] 
						,[dblAmount] 
						,[strAllocateCostBy] 
						,[intContractHeaderId]
						,[intContractDetailId] 
						,[ysnAccrue]
				) 
				SELECT	[intEntityVendorId]					= RE.intEntityVendorId
						,[strBillOfLadding]					= RE.strBillOfLadding
						,[strReceiptType]					= RE.strReceiptType
						,[intLocationId]					= RE.intLocationId
						,[intShipViaId]						= RE.intShipViaId
						,[intShipFromId]					= RE.intShipFromId
						,[intCurrencyId]  					= RE.intCurrencyId
						,[intChargeId]						= @intFreightItemId
						,[ysnInventoryCost]					= 0
						,[strCostMethod]					= 'Per Unit'
						,[dblRate]							= RE.dblFreightRate
						,[intCostUOMId]						= (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId =  @intFreightItemId)
						,[intOtherChargeEntityVendorId]		= @intHaulerId
						,[dblAmount]						= 0
						,[strAllocateCostBy]				=  NULL
						,[intContractHeaderId]				= RE.intContractHeaderId
						,[intContractDetailId]				= RE.intContractDetailId
						,[ysnAccrue]						= CASE	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
																		1
																	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
																		0
																	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
																		1
															END
						FROM	@ReceiptStagingTable RE
						WHERE	RE.dblFreightRate != 0 
			END
		ELSE IF ISNULL(@intFreightItemId,0) != 0
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
						,[intChargeId] 
						,[ysnInventoryCost] 
						,[strCostMethod] 
						,[dblRate] 
						,[intCostUOMId] 
						,[intOtherChargeEntityVendorId] 
						,[dblAmount] 
						,[strAllocateCostBy] 
						,[intContractHeaderId]
						,[intContractDetailId] 
						,[ysnAccrue]
				)
				SELECT	
				[intEntityVendorId]					= RE.intEntityVendorId
				,[strBillOfLadding]					= RE.strBillOfLadding
				,[strReceiptType]					= RE.strReceiptType
				,[intLocationId]					= RE.intLocationId
				,[intShipViaId]						= RE.intShipViaId
				,[intShipFromId]					= RE.intShipFromId
				,[intCurrencyId]  					= RE.intCurrencyId
				,[intChargeId]						= ContractCost.intItemId
				,[ysnInventoryCost]					= 0
				,[strCostMethod]					= ContractCost.strCostMethod
				,[dblRate]							= ContractCost.dblRate
				,[intCostUOMId]						= ContractCost.intItemUOMId
				,[intOtherChargeEntityVendorId]		= CASE 
														WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
															RE.intEntityVendorId
														WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
															NULL
														WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
															RE.intShipViaId
													  END
				,[dblAmount]						= 0
				,[strAllocateCostBy]				=  NULL
				,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
				,[intContractDetailId]				= ContractCost.intContractDetailId
				,[ysnAccrue]						= ContractCost.ysnAccrue
				FROM tblCTContractCost ContractCost
				LEFT JOIN @ReceiptStagingTable RE
				ON RE.intContractDetailId = ContractCost.intContractDetailId
				WHERE ContractCost.intItemId = @intFreightItemId
				AND RE.intContractDetailId IS NOT NULL
				AND ContractCost.dblRate != 0;
			END
		INSERT INTO @OtherCharges
		(
				[intEntityVendorId] 
				,[strBillOfLadding] 
				,[strReceiptType] 
				,[intLocationId] 
				,[intShipViaId] 
				,[intShipFromId] 
				,[intCurrencyId]  	
				,[intChargeId] 
				,[ysnInventoryCost] 
				,[strCostMethod] 
				,[dblRate] 
				,[intCostUOMId] 
				,[intOtherChargeEntityVendorId] 
				,[dblAmount] 
				,[strAllocateCostBy] 
				,[intContractHeaderId]
				,[intContractDetailId] 
				,[ysnAccrue]
		)
		SELECT	
		[intEntityVendorId]					= RE.intEntityVendorId
		,[strBillOfLadding]					= RE.strBillOfLadding
		,[strReceiptType]					= RE.strReceiptType
		,[intLocationId]					= RE.intLocationId
		,[intShipViaId]						= RE.intShipViaId
		,[intShipFromId]					= RE.intShipFromId
		,[intCurrencyId]  					= RE.intCurrencyId
		,[intChargeId]						= ContractCost.intItemId
		,[ysnInventoryCost]					= 0
		,[strCostMethod]					= ContractCost.strCostMethod
		,[dblRate]							= ContractCost.dblRate
		,[intCostUOMId]						= ContractCost.intItemUOMId
		,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
		,[dblAmount]						= 0
		,[strAllocateCostBy]				=  NULL
		,[intContractHeaderId]				= (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ContractCost.intContractDetailId)
		,[intContractDetailId]				= ContractCost.intContractDetailId
		,[ysnAccrue]						= ContractCost.ysnAccrue
		FROM tblCTContractCost ContractCost
		LEFT JOIN @ReceiptStagingTable RE
		ON RE.intContractDetailId = ContractCost.intContractDetailId
		WHERE ContractCost.intItemId != @intFreightItemId
		AND RE.intContractDetailId IS NOT NULL
		AND ContractCost.dblRate != 0;
	END

--SELECT TOP 1 @intFreightItemId = intItemForFreightId FROM tblTRCompanyPreference
--SELECT TOP 1 @intSurchargeItemId = intItemId FROM vyuICGetOtherCharges WHERE intOnCostTypeId = @intFreightItemId

--Fuel Freight
--INSERT INTO @OtherCharges
--(
--		[intEntityVendorId] 
--		,[strBillOfLadding] 
--		,[strReceiptType] 
--		,[intLocationId] 
--		,[intShipViaId] 
--		,[intShipFromId] 
--		,[intCurrencyId]  	
--		,[intChargeId] 
--		,[ysnInventoryCost] 
--		,[strCostMethod] 
--		,[dblRate] 
--		,[intCostUOMId] 
--		,[intOtherChargeEntityVendorId] 
--		,[dblAmount] 
--		,[strAllocateCostBy] 
--		,[intContractHeaderId]
--		,[intContractDetailId] 
--		,[ysnAccrue]
--) 
--SELECT	[intEntityVendorId]					= RE.intEntityVendorId
--		,[strBillOfLadding]					= RE.strBillOfLadding
--		,[strReceiptType]					= RE.strReceiptType
--		,[intLocationId]					= RE.intLocationId
--		,[intShipViaId]						= RE.intShipViaId
--		,[intShipFromId]					= RE.intShipFromId
--		,[intCurrencyId]  					= RE.intCurrencyId
--		,[intChargeId]						= @intFreightItemId
--		,[ysnInventoryCost]					= 0
--		,[strCostMethod]					= 'Per Unit'
--		,[dblRate]							= RE.dblFreightRate
--		,[intCostUOMId]						= (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId =  @intFreightItemId)
--		,[intOtherChargeEntityVendorId]		= CASE	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
--														RE.intEntityVendorId
--													WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
--														NULL
--													WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
--														RE.intShipViaId
--											END
--		,[dblAmount]						= 0
--		,[strAllocateCostBy]				=  NULL
--		,[intContractHeaderId]				= RE.intContractHeaderId
--		,[intContractDetailId]				= RE.intContractDetailId
--		,[ysnAccrue]						= CASE	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
--														1
--													WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
--														0
--													WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
--														1
--											END
--FROM	@ReceiptStagingTable RE 
--WHERE	RE.dblFreightRate != 0 

----Fuel Surcharge
--UNION ALL 
--SELECT	[intEntityVendorId]					= RE.intEntityVendorId
--		,[strBillOfLadding]					= RE.strBillOfLadding
--		,[strReceiptType]					= RE.strReceiptType
--		,[intLocationId]					= RE.intLocationId
--		,[intShipViaId]						= RE.intShipViaId
--		,[intShipFromId]					= RE.intShipFromId
--		,[intCurrencyId]  					= RE.intCurrencyId
--		,[intChargeId]						= @intSurchargeItemId
--		,[ysnInventoryCost]					= NULL
--		,[strCostMethod]					= 'Percentage'
--		,[dblRate]							= RE.dblSurcharge
--		,[intCostUOMId]						= (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId =  @intSurchargeItemId)
--		,[intOtherChargeEntityVendorId]		= CASE	WHEN (SELECT strFreightBilledBy FROM tblSMShipVia SM WHERE SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
--														RE.intEntityVendorId
--													WHEN (SELECT strFreightBilledBy FROM tblSMShipVia SM WHERE SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
--														NULL
--													WHEN (SELECT strFreightBilledBy FROM tblSMShipVia SM WHERE SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
--														RE.intShipViaId
--											END
--		,[dblAmount]						= 0
--		,[strAllocateCostBy]				= NULL
--		,[intContractHeaderId]				= RE.intContractHeaderId
--		,[intContractDetailId]				= RE.intContractDetailId
--		,[ysnAccrue]						= CASE	WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor' THEN 
--														1
--													WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal' THEN 
--														0
--													WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other' THEN 
--														1
--											END
--FROM	@ReceiptStagingTable RE 
--WHERE	RE.dblSurcharge != 0 

-- No Records to process so exit
SELECT @checkContract = COUNT(intContractDetailId) FROM @ReceiptStagingTable WHERE intContractDetailId != 0;
IF(@checkContract > 0)
	UPDATE @ReceiptStagingTable SET strReceiptType = 'Purchase Contract'

SELECT @total = COUNT(*) FROM @ReceiptStagingTable;
IF (@total = 0)
	RETURN;

EXEC dbo.uspICAddItemReceipt 
		@ReceiptStagingTable
		,@OtherCharges
		,@intEntityId;

-- Update the Inventory Receipt Key to the Transaction Table
UPDATE	SC
SET		SC.intInventoryReceiptId = addResult.intInventoryReceiptId
FROM	dbo.tblSCTicket SC INNER JOIN #tmpAddItemReceiptResult addResult
			ON SC.intTicketId = addResult.intSourceId

_PostOrUnPost:
-- Post the Inventory Receipts                                            
DECLARE @ReceiptId INT
		--,@intEntityId INT
		,@strTransactionId NVARCHAR(50);

WHILE EXISTS (SELECT TOP 1 1 FROM #tmpAddItemReceiptResult) 
BEGIN

	SELECT TOP 1 
			@ReceiptId = intInventoryReceiptId  
	FROM	#tmpAddItemReceiptResult 
  
	SET @InventoryReceiptId = @ReceiptId
	-- Post the Inventory Receipt that was created
	--SELECT	@strTransactionId = strReceiptNumber 
	--FROM	tblICInventoryReceipt 
	--WHERE	intInventoryReceiptId = @ReceiptId

	--SELECT	TOP 1 @intEntityId = [intEntityUserSecurityId] 
	--FROM	dbo.tblSMUserSecurity 
	--WHERE	[intEntityUserSecurityId] = @intEntityId
	--BEGIN
	--EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intEntityId;			
	--END
		
	DELETE	FROM #tmpAddItemReceiptResult 
	WHERE	intInventoryReceiptId = @ReceiptId
END;

BEGIN
	INSERT INTO [dbo].[tblQMTicketDiscount]
       ([intConcurrencyId]
       ,[strDiscountCode]
       ,[strDiscountCodeDescription]
       ,[dblGradeReading]
       ,[strCalcMethod]
       ,[strShrinkWhat]
       ,[dblShrinkPercent]
       ,[dblDiscountAmount]
       ,[dblDiscountDue]
       ,[dblDiscountPaid]
       ,[ysnGraderAutoEntry]
       ,[intDiscountScheduleCodeId]
       ,[dtmDiscountPaidDate]
       ,[intTicketId]
       ,[intTicketFileId]
       ,[strSourceType])
	SELECT	DISTINCT [intConcurrencyId]= 1
       ,[strDiscountCode] = SD.[strDiscountCode]
       ,[strDiscountCodeDescription]= SD.[strDiscountCodeDescription]
       ,[dblGradeReading]= SD.[dblGradeReading]
       ,[strCalcMethod]= SD.[strCalcMethod]
       ,[strShrinkWhat]= 
		CASE 
			 WHEN SD.[strShrinkWhat]='N' THEN 'Net Weight' 
			 WHEN SD.[strShrinkWhat]='W' THEN 'Wet Weight' 
			 WHEN SD.[strShrinkWhat]='G' THEN 'Gross Weight' 
		END
       ,[dblShrinkPercent]= SD.[dblShrinkPercent]
       ,[dblDiscountAmount]= SD.[dblDiscountAmount]
       ,[dblDiscountDue]= SD.[dblDiscountDue]
       ,[dblDiscountPaid]= SD.[dblDiscountPaid]
       ,[ysnGraderAutoEntry]= SD.[ysnGraderAutoEntry]
       ,[intDiscountScheduleCodeId]= SD.[intDiscountScheduleCodeId]
       ,[dtmDiscountPaidDate]= SD.[dtmDiscountPaidDate]
       ,[intTicketId]= NULL
       ,[intTicketFileId]= ISH.intInventoryReceiptItemId
       ,[strSourceType]= 'Inventory Receipt'
	FROM	dbo.tblICInventoryReceiptItem ISH join dbo.[tblQMTicketDiscount] SD
	ON ISH.intSourceId = SD.intTicketId AND SD.strSourceType = 'Scale' AND
	SD.intTicketFileId = @intTicketId WHERE	ISH.intSourceId = @intTicketId AND ISH.intInventoryReceiptId = @InventoryReceiptId
END

DECLARE @intLoopReceiptItemId INT;
DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT  IRI.intInventoryReceiptItemId
FROM tblICInventoryReceiptItem IRI WHERE 
IRI.intInventoryReceiptId = @InventoryReceiptId AND dbo.fnGetItemLotType(IRI.intItemId) IN (@LotType_Manual, @LotType_Serial);

OPEN intListCursor;

-- Initial fetch attempt
FETCH NEXT FROM intListCursor INTO @intLoopReceiptItemId;

WHILE @@FETCH_STATUS = 0
BEGIN
   -- Here we do some kind of action that requires us to 
   -- process the table variable row-by-row. This example simply
   -- uses a PRINT statement as that action (not a very good
   -- example).
   IF	ISNULL(@intLoopReceiptItemId,0) != 0
   BEGIN
   INSERT INTO [dbo].[tblICInventoryReceiptItemLot]
           ([intInventoryReceiptItemId]
           ,[intLotId]
           ,[strLotNumber]
           ,[strLotAlias]
           ,[intSubLocationId]
           ,[intStorageLocationId]
           ,[intItemUnitMeasureId]
           ,[dblQuantity]
           ,[dblGrossWeight]
           ,[dblTareWeight]
           ,[dblCost]
           ,[intUnitPallet]
           ,[dblStatedGrossPerUnit]
           ,[dblStatedTarePerUnit]
           ,[strContainerNo]
           ,[intEntityVendorId]
           ,[strGarden]
           ,[strMarkings]
           ,[intOriginId]
           ,[intSeasonCropYear]
           ,[strVendorLotId]
           ,[dtmManufacturedDate]
           ,[strRemarks]
           ,[strCondition]
           ,[dtmCertified]
           ,[dtmExpiryDate]
           ,[intSort]
           ,[intConcurrencyId])
     SELECT
            [intInventoryReceiptItemId] = @intLoopReceiptItemId
           ,[intLotId] = NULL
           ,[strLotNumber]  = @strTicketNumber 
           ,[strLotAlias] = RCT.intSourceId 
           ,[intSubLocationId] = RCT.intSubLocationId
           ,[intStorageLocationId] = RCT.intStorageLocationId
           ,[intItemUnitMeasureId] = RCT.intUnitMeasureId
           ,[dblQuantity] = RCT.dblReceived
           ,[dblGrossWeight] = RCT.dblGross
           ,[dblTareWeight] = RCT.dblGross - RCT.dblNet
           ,[dblCost] = RCT.dblUnitCost
           ,[intUnitPallet] = NULL
           ,[dblStatedGrossPerUnit] = NULL
           ,[dblStatedTarePerUnit] = NULL
           ,[strContainerNo] = NULL
           ,[intEntityVendorId] = NULL
           ,[strGarden] = NULL
           ,[strMarkings] = NULL 
           ,[intOriginId] = NULL
           ,[intSeasonCropYear] = NULL
           ,[strVendorLotId] = NULL
           ,[dtmManufacturedDate] = NULL
           ,[strRemarks] = NULL
           ,[strCondition] = NULL
           ,[dtmCertified] = NULL
           ,[dtmExpiryDate] = NULL
           ,[intSort] = NULL
           ,[intConcurrencyId] = 1
		   FROM	dbo.tblICInventoryReceiptItem RCT WHERE RCT.intInventoryReceiptItemId = @intLoopReceiptItemId
   END

   -- Attempt to fetch next row from cursor
   FETCH NEXT FROM intListCursor INTO @intLoopReceiptItemId;
END;

CLOSE intListCursor;
DEALLOCATE intListCursor;