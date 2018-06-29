CREATE PROCEDURE [dbo].[uspSCAddDeliverySheetToItemReceipt]
	@intDeliverySheetId AS INT
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

DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @dblTicketFreightRate AS DECIMAL (9, 5)
DECLARE @dblTicketGross AS DECIMAL (38, 20)
DECLARE @dblTicketTare AS DECIMAL (38, 20)
DECLARE @intScaleStationId AS INT
--DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnDeductFreightFarmer AS BIT
		,@ysnDeductFeesCusVen AS BIT;
DECLARE @strTicketNumber AS NVARCHAR(40)
DECLARE @dblTicketFees AS DECIMAL(7, 2)
DECLARE @checkContract AS INT
DECLARE @intHaulerId AS INT,
		@ysnAccrue AS BIT,
		@ysnPrice AS BIT,
		@intFutureMarketId AS INT,
		@batchId AS NVARCHAR(40),
		@ticketBatchId AS NVARCHAR(40),
		@splitDistribution AS NVARCHAR(40);
		
BEGIN 
	SELECT	@intTicketItemUOMId = UM.intItemUOMId
	FROM	dbo.tblICItemUOM UM	JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.ysnStockUnit = 1 AND SC.intTicketId = @intDeliverySheetId
END

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
		,strVendorRefNo
		,intForexRateTypeId
		,dblForexRate
				
		-- Detail				
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,intGrossNetUOMId
		,intCostUOMId				
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
		,intSourceId
		,intSourceType	
		,strSourceScreenName
		,strChargesLink
		,dblGross
		,dblNet
		,intFreightTermId
)	
SELECT 
		strReceiptType				= CASE 
										WHEN LI.strSourceTransactionId = 'SPT' THEN 'Purchase Contract'
										WHEN LI.strSourceTransactionId = 'CNT' THEN 'Purchase Contract'
										WHEN LI.strSourceTransactionId = 'LOD' THEN 'Purchase Contract'
										WHEN @strReceiptType = 'Delayed Price' THEN 'Purchase Contract' 
										ELSE 'Direct'
									  END
		,intEntityVendorId			= @intEntityId
		,strBillOfLadding			= NULL
		,intCurrencyId				= CASE
										WHEN ISNULL(CNT.intContractDetailId,0) = 0 THEN SCD.intCurrencyId 
										WHEN ISNULL(CNT.intContractDetailId,0) > 0 THEN CNT.intCurrencyId
									END
		,intLocationId				= SCD.intCompanyLocationId
		,intShipFromId				= CASE 
										WHEN ISNULL((SELECT TOP 1 intShipFromId from tblAPVendor where intEntityId = @intEntityId), 0) > 0
										THEN (SELECT TOP 1 intShipFromId from tblAPVendor where intEntityId = @intEntityId)
										ELSE (SELECT top 1 intEntityLocationId from tblEMEntityLocation where intEntityId = @intEntityId AND ysnDefaultLocation = 1)
									END
		,intShipViaId				= NULL
		,intDiscountSchedule		= SCD.intDiscountId
		,strVendorRefNo				= 'DS-' + SCD.strDeliverySheetNumber
		,intForexRateTypeId			= NULL
		,dblForexRate				= NULL
		--Detail
		,intItemId					= SCD.intItemId
		,intItemLocationId			= SCD.intCompanyLocationId
		,intItemUOMId				= LI.intItemUOMId
		,intGrossNetUOMId			= NULL
		,intCostUOMId				= CASE
										WHEN ISNULL(CNT.intPriceItemUOMId,0) = 0 THEN LI.intItemUOMId 
										WHEN ISNULL(CNT.intPriceItemUOMId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(CNT.intItemId, CNT.intPriceItemUOMId)
									END
		,intContractHeaderId		= CASE 
										WHEN LI.intTransactionDetailId IS NULL THEN NULL
										WHEN LI.intTransactionDetailId IS NOT NULL THEN CNT.intContractHeaderId
									  END
		,intContractDetailId		= LI.intTransactionDetailId
		,dtmDate					= LI.dtmDate
		,dblQty						= LI.dblQty
		,dblCost					= CASE
										WHEN CNT.intPricingTypeId = 2 THEN 
										(
											SELECT ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(UOM.intItemUOMId,futureUOM.intItemUOMId,dblSettlementPrice + ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(futureUOM.intItemUOMId,CNT.intBasisUOMId,LI.dblCost),0)),0) 
											FROM dbo.fnRKGetFutureAndBasisPrice (1,IC.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),2,CNT.intFutureMarketId,CNT.intFutureMonthId,NULL,NULL,0 ,SCD.intItemId,SCD.intCurrencyId)
											LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId AND futureUOM.intItemId = LI.intItemId
										)
										ELSE LI.dblCost
									END
		,dblExchangeRate			= 1 -- Need to check this
		,intLotId					= NULL --No LOTS from scale
		,intSubLocationId			= NULL -- no requirements yet for sublocation DS
		,intStorageLocationId		= NULL -- no requirements yet for sublocation DS
		,ysnIsStorage				= LI.ysnIsStorage
		,dblFreightRate				= NULL -- no requirements yet for sublocation DS
		,intSourceId				= LI.intTransactionId
		,intSourceType		 		= 5 -- Source type for Delivery Sheet is 5 
		,strSourceScreenName		= 'Delivery Sheet'
		,strChargesLink				= 'CL-'+ CAST (LI.intId AS nvarchar(MAX)) 
		,dblGross					= (LI.dblQty / SCD.dblNet) * SCD.dblGross
		,dblNet						= LI.dblQty
		,intFreightTermId			= CNT.intFreightTermId
FROM	@Items LI 
		INNER JOIN tblSCDeliverySheet SCD ON SCD.intDeliverySheetId = LI.intTransactionId
		INNER JOIN tblICItem IC ON IC.intItemId = SCD.intItemId
		INNER JOIN tblICItemUOM UOM ON UOM.intItemId = IC.intItemId AND UOM.ysnStockUnit = 1
		LEFT JOIN (
			SELECT CTD.intContractHeaderId
			,CTD.intContractDetailId
			,CTD.intItemId
			,CTD.intItemUOMId
			,CTD.intFutureMarketId
			,CTD.intFutureMonthId
			,CTD.intRateTypeId 
			,CTD.intPriceItemUOMId
			,CTD.ysnUseFXPrice
			,CTD.intCurrencyExchangeRateId 
			,CTD.dblRate 
			,CTD.intFXPriceUOMId 
			,CTD.intInvoiceCurrencyId 
			,CTD.intCurrencyId
			,CTD.intAdjItemUOMId
			,CTD.intPricingTypeId
			,CTD.intBasisUOMId
			,CTD.dtmEndDate
			,CTD.intFreightTermId
			,AD.dblSeqPrice
			,CU.intCent
			,CU.ysnSubCurrency
			FROM tblCTContractDetail CTD 
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CTD.intCurrencyId
			CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CTD.intContractDetailId) AD
		) CNT ON CNT.intContractDetailId = LI.intTransactionDetailId
WHERE	SCD.intDeliverySheetId = @intDeliverySheetId

-- Get the identity value from tblICInventoryReceipt
SELECT @InventoryReceiptId = SCOPE_IDENTITY()

IF @InventoryReceiptId IS NULL 
BEGIN 
	-- Raise the error:
	-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
	EXEC uspICRaiseError 80004; 
	RETURN;
END

SELECT DISTINCT @intFreightItemId = SCSetup.intFreightItemId, @intHaulerId = SCTicket.intHaulerId
	, @ysnDeductFreightFarmer = SCTicket.ysnFarmerPaysFreight 
	, @ysnDeductFeesCusVen = SCTicket.ysnCusVenPaysFees
FROM tblSCScaleSetup SCSetup LEFT JOIN tblSCTicket SCTicket ON SCSetup.intScaleSetupId = SCTicket.intScaleSetupId 
WHERE SCTicket.intDeliverySheetId = @intDeliverySheetId

		--FOR DISCOUNT CHARGES
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
		)
		SELECT	
		[intEntityVendorId]					= RE.intEntityVendorId
		,[strBillOfLadding]					= RE.strBillOfLadding
		,[strReceiptType]					= RE.strReceiptType
		,[intLocationId]					= RE.intLocationId
		,[intShipViaId]						= RE.intShipViaId
		,[intShipFromId]					= RE.intShipFromId
		,[intCurrencyId]  					= RE.intCurrencyId
		,[intCostCurrencyId]  				= RE.intCurrencyId
		,[intChargeId]						= IC.intItemId
		,[intForexRateTypeId]				= RE.intForexRateTypeId
		,[dblForexRate]						= RE.dblForexRate
		,[ysnInventoryCost]					= IC.ysnInventoryCost
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 
												CASE 
													WHEN QM.dblDiscountAmount < 0 THEN 
													CASE
														WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, 1) * -1)
														ELSE (QM.dblDiscountAmount * -1)
													END 
													WHEN QM.dblDiscountAmount > 0 THEN 
													CASE
														WHEN @splitDistribution = 'SPL' THEN dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, 1)
														ELSE QM.dblDiscountAmount
													END
												END
												WHEN IC.strCostMethod = 'Amount' THEN 0
											END
		,[intCostUOMId]						= CASE
												WHEN ISNULL(UM.intUnitMeasureId,0) = 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, @intTicketItemUOMId)
												WHEN ISNULL(UM.intUnitMeasureId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, UM.intItemUOMId)
											END
		,[intOtherChargeEntityVendorId]		= RE.intEntityVendorId
		,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN 
												CASE 
													WHEN RE.ysnIsStorage = 1 THEN 0
													WHEN RE.ysnIsStorage = 0 THEN
													CASE
														WHEN QM.dblDiscountAmount < 0 THEN 
														CASE
															WHEN SCD.intSplitId > 0 THEN (dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, 1) * -1)
															ELSE (dbo.fnSCCalculateDiscount(RE.intSourceId,QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId) * -1)
														END 
														WHEN QM.dblDiscountAmount > 0 THEN 
														CASE
															WHEN SCD.intSplitId > 0 THEN dbo.fnSCCalculateDiscountSplit(RE.intSourceId, RE.intEntityVendorId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId, 1)
															ELSE dbo.fnSCCalculateDiscount(RE.intSourceId, QM.intTicketDiscountId, RE.dblQty, GR.intUnitMeasureId)
														END 
													END
												END
											END
		,[intContractHeaderId]				= RE.intContractHeaderId
		,[intContractDetailId]				= RE.intContractDetailId
		,[ysnAccrue]						= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 1
												WHEN QM.dblDiscountAmount > 0 THEN 0
											END
		,[ysnPrice]							= CASE
												WHEN QM.dblDiscountAmount < 0 THEN 0
												WHEN QM.dblDiscountAmount > 0 THEN 1
											END
		,[strChargesLink]					= RE.strChargesLink
		FROM @ReceiptStagingTable RE
		LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = RE.intSourceId AND QM.strSourceType = 'Delivery Sheet'
		LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
		LEFT JOIN tblICItem IC ON IC.intItemId = GR.intItemId
		LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
		LEFT JOIN tblSCDeliverySheet SCD ON SCD.intDeliverySheetId = RE.intSourceId
		WHERE RE.intSourceId = @intDeliverySheetId AND QM.dblDiscountAmount != 0 AND RE.ysnIsStorage = 0

		--FOR FEE CHARGES
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
		)
		SELECT	
		[intEntityVendorId]					= RE.intEntityVendorId
		,[strBillOfLadding]					= RE.strBillOfLadding
		,[strReceiptType]					= RE.strReceiptType
		,[intLocationId]					= RE.intLocationId
		,[intShipViaId]						= RE.intShipViaId
		,[intShipFromId]					= RE.intShipFromId
		,[intCurrencyId]  					= RE.intCurrencyId
		,[intCostCurrencyId]  				= RE.intCurrencyId
		,[intChargeId]						= IC.intItemId
		,[intForexRateTypeId]				= RE.intForexRateTypeId
		,[dblForexRate]						= RE.dblForexRate
		,[ysnInventoryCost]					= 0
		,[strCostMethod]					= IC.strCostMethod
		,[dblRate]							= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN SC.dblTicketFees
												WHEN IC.strCostMethod = 'Amount' THEN 0
											END
		,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(SCSetup.intDefaultFeeItemId, @intTicketItemUOMId)
		,[intOtherChargeEntityVendorId]		= RE.intEntityVendorId
		,[dblAmount]						= CASE
												WHEN IC.strCostMethod = 'Per Unit' THEN 0
												WHEN IC.strCostMethod = 'Amount' THEN 
												CASE
													WHEN RE.ysnIsStorage = 1 THEN 0
													WHEN RE.ysnIsStorage = 0 THEN (RE.dblQty / SCD.dblNet * SC.dblTicketFees)
												END
											END
		,[intContractHeaderId]				= RE.intContractHeaderId
		,[intContractDetailId]				= RE.intContractDetailId
		,[ysnAccrue]						= CASE 
												WHEN @ysnDeductFeesCusVen = 1 THEN 0
                                                WHEN @ysnDeductFeesCusVen = 0 THEN 1
											END
		,[ysnPrice]							= @ysnDeductFeesCusVen
		,[strChargesLink]					= RE.strChargesLink
		FROM @ReceiptStagingTable RE
		INNER JOIN tblSCDeliverySheet SCD ON SCD.intDeliverySheetId = RE.intSourceId
		OUTER APPLY(
			SELECT SUM(dblTicketFees) AS dblTicketFees,intScaleSetupId FROM tblSCTicket WHERE intDeliverySheetId = RE.intSourceId GROUP BY intScaleSetupId
		) SC
		INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
		INNER JOIN tblICItem IC ON IC.intItemId = SCSetup.intDefaultFeeItemId
		WHERE RE.intSourceId = @intDeliverySheetId AND SC.dblTicketFees > 0

IF  @ysnDeductFreightFarmer = 0 AND ISNULL(@intHaulerId,0) != 0
	BEGIN
		SET @ysnAccrue = 1
	END
ELSE IF @ysnDeductFreightFarmer = 1 AND ISNULL(@intHaulerId,0) != 0
	BEGIN
		SET @ysnAccrue = 1
		SET @ysnPrice = 1
	END
ELSE IF @ysnDeductFreightFarmer = 1 AND ISNULL(@intHaulerId,0) = 0
	BEGIN
		SET @ysnPrice = 1
	END

IF @ysnDeductFreightFarmer = 0 AND ISNULL(@intHaulerId,0) = 0
	BEGIN
		SET @ysnAccrue = 0
		SET @ysnPrice = 0
	END
IF ISNULL(@intFreightItemId,0) = 0
	SET @intFreightItemId = 0

	BEGIN
		IF ISNULL(@intFreightItemId,0) != 0
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
			)
			SELECT	
			[intEntityVendorId]					= RE.intEntityVendorId
			,[strBillOfLadding]					= RE.strBillOfLadding
			,[strReceiptType]					= RE.strReceiptType
			,[intLocationId]					= RE.intLocationId
			,[intShipViaId]						= RE.intShipViaId
			,[intShipFromId]					= RE.intShipFromId
			,[intCurrencyId]  					= RE.intCurrencyId
			,[intCostCurrencyId]				= RE.intCurrencyId
			,[intChargeId]						= ContractCost.intItemId
			,[intForexRateTypeId]				= RE.intForexRateTypeId
			,[dblForexRate]						= RE.dblForexRate
			,[ysnInventoryCost]					= IC.ysnInventoryCost
			,[strCostMethod]					= IC.strCostMethod
			,[dblRate]							= CASE
													WHEN IC.strCostMethod = 'Amount' THEN 0
													ELSE ContractCost.dblRate
												END
			,[intCostUOMId]						= dbo.fnGetMatchingItemUOMId(@intFreightItemId, ContractCost.intItemUOMId)
			,[intOtherChargeEntityVendorId]		= ContractCost.intVendorId
			,[dblAmount]						= CASE
													WHEN IC.strCostMethod = 'Amount' THEN 
													CASE
														WHEN RE.ysnIsStorage = 1 THEN 0
														WHEN RE.ysnIsStorage = 0 THEN ROUND (ContractCost.dblRate  * dbo.fnCalculateQtyBetweenUOM(ContractCost.intItemUOMId, dbo.fnGetMatchingItemUOMId(RE.intItemId, ContractCost.intItemUOMId), SC.dblGrossUnits), 2)
													END
													ELSE 0
												END
			,[intContractHeaderId]				= RE.intContractHeaderId
			,[intContractDetailId]				= RE.intContractDetailId
			,[ysnAccrue]						= ContractCost.ysnAccrue
			,[ysnPrice]							= ContractCost.ysnPrice
			,[strChargesLink]					= RE.strChargesLink
			FROM tblCTContractCost ContractCost
			LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
			OUTER APPLY(
				SELECT DISTINCT SUM(dblGrossUnits) AS dblGrossUnits,intScaleSetupId FROM tblSCTicket WHERE intDeliverySheetId = RE.intSourceId GROUP BY intScaleSetupId
			) SC
			LEFT JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
			LEFT JOIN tblICItem IC ON IC.intItemId = SCS.intFreightItemId
			WHERE ContractCost.intItemId = @intFreightItemId AND RE.intContractDetailId IS NOT NULL AND ContractCost.dblRate != 0
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
			)
			SELECT	
			[intEntityVendorId]					= RE.intEntityVendorId
			,[strBillOfLadding]					= RE.strBillOfLadding
			,[strReceiptType]					= RE.strReceiptType
			,[intLocationId]					= RE.intLocationId
			,[intShipViaId]						= RE.intShipViaId
			,[intShipFromId]					= RE.intShipFromId
			,[intCurrencyId]  					= RE.intCurrencyId
			,[intCostCurrencyId]				= RE.intCurrencyId
			,[intChargeId]						= ContractCost.intItemId
			,[intForexRateTypeId]				= RE.intForexRateTypeId
			,[dblForexRate]						= RE.dblForexRate
			,[ysnInventoryCost]					= IC.ysnInventoryCost
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
			,[intContractDetailId]				= RE.intContractDetailId
			,[ysnAccrue]						= ContractCost.ysnAccrue
			,[ysnPrice]							= ContractCost.ysnPrice
			,[strChargesLink]					= RE.strChargesLink
			FROM tblCTContractCost ContractCost
			LEFT JOIN @ReceiptStagingTable RE ON RE.intContractDetailId = ContractCost.intContractDetailId
			LEFT JOIN tblICItem IC ON IC.intItemId = ContractCost.intItemId
			WHERE ContractCost.intItemId != @intFreightItemId AND RE.intContractDetailId IS NOT NULL AND ContractCost.dblRate != 0
	END

SELECT @checkContract = COUNT(intId) FROM @ReceiptStagingTable WHERE strReceiptType = 'Purchase Contract';
IF(@checkContract > 0)
	UPDATE @ReceiptStagingTable SET strReceiptType = 'Purchase Contract'

SELECT @total = COUNT(*) FROM @ReceiptStagingTable;
IF (@total = 0)
	RETURN;

EXEC dbo.uspICAddItemReceipt 
		@ReceiptStagingTable
		,@OtherCharges
		,@intUserId;

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

	UPDATE SH  
	SET SH.[intInventoryReceiptId] = @InventoryReceiptId
	FROM tblGRStorageHistory SH
	JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=SH.intCustomerStorageId
	JOIN tblICInventoryReceipt IR ON IR.intEntityVendorId=CS.intEntityId 
	WHERE SH.[strType] = 'From Delivery Sheet' AND IR.intInventoryReceiptId=@InventoryReceiptId 
	AND ISNULL(SH.intInventoryReceiptId,0) = 0
		
	DELETE	FROM #tmpAddItemReceiptResult 
	WHERE	intInventoryReceiptId = @ReceiptId
END

BEGIN
	INSERT INTO [dbo].[tblQMTicketDiscount]
       ([intConcurrencyId]     
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
       ,[strSourceType]
	   ,[intSort]
	   ,[strDiscountChargeType])
	SELECT	DISTINCT [intConcurrencyId]= 1   
       ,[dblGradeReading]= SD.[dblGradeReading]
       ,[strCalcMethod]= SD.[strCalcMethod]
       ,[strShrinkWhat]= SD.[strShrinkWhat]		
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
	   ,[intSort]=SD.[intSort]
	   ,[strDiscountChargeType]=SD.[strDiscountChargeType]
	FROM	dbo.tblICInventoryReceiptItem ISH join dbo.[tblQMTicketDiscount] SD
	ON ISH.intSourceId = SD.intTicketId AND SD.strSourceType = 'Delivery Sheet' AND
	SD.intTicketFileId = @intDeliverySheetId WHERE	ISH.intSourceId = @intDeliverySheetId AND ISH.intInventoryReceiptId = @InventoryReceiptId
END

DECLARE @intLoopReceiptItemId INT;
DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT  IRI.intInventoryReceiptItemId
FROM tblICInventoryReceiptItem IRI WHERE 
IRI.intInventoryReceiptId = @InventoryReceiptId AND dbo.fnGetItemLotType(IRI.intItemId) <> 0;

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
           ,[dtmExpiryDate] = DATEADD(YEAR, 2, ICIR.dtmReceiptDate)
           ,[intSort] = NULL
           ,[intConcurrencyId] = 1
		   FROM	dbo.tblICInventoryReceiptItem RCT INNER JOIN dbo.tblICInventoryReceipt ICIR ON RCT.intInventoryReceiptId = ICIR.intInventoryReceiptId
		   WHERE RCT.intInventoryReceiptItemId = @intLoopReceiptItemId
   END

   -- Attempt to fetch next row from cursor
   FETCH NEXT FROM intListCursor INTO @intLoopReceiptItemId;
END;

CLOSE intListCursor;
DEALLOCATE intListCursor;