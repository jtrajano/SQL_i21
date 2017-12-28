
/*
	This is the stored procedure that handles the adjustment to the item cost. 
	
	It uses a cursor to iterate over the list of records found in @ItemsToAdjust, a table-valued parameter (variable). 

	Parameters: 
	@ItemsToAdjust - A user-defined table type. This is a table variable that tells this SP what items to process. 	
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@intEntityUserSecurityId - The user who is initiating the post. Must be an entity id. 

	@ysnPost - Do a post (1) or unpost (0). Default is 1. 
*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentFromOtherCharge]
	@ChargesToAdjust AS OtherChargeCostAdjustmentTableType READONLY
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
	,@ysnPost AS BIT = 1
	,@strTransactionType AS NVARCHAR(50) = 'Bill'
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

/*--------------------------------------------------
 Declarations 
--------------------------------------------------*/
BEGIN 
	-- Constants
	DECLARE @COST_METHOD_Per_Unit AS NVARCHAR(50) = 'Per Unit'
			,@COST_METHOD_Percentage AS NVARCHAR(50) = 'Percentage'
			,@COST_METHOD_Amount AS NVARCHAR(50) = 'Amount'

			,@ALLOCATE_COST_BY_Unit AS NVARCHAR(50) = 'Unit'
			,@ALLOCATE_COST_BY_Stock_Unit AS NVARCHAR(50) = 'Stock Unit'
			,@ALLOCATE_COST_BY_Weight AS NVARCHAR(50) = 'Weight'
			,@ALLOCATE_COST_BY_Cost AS NVARCHAR(50) = 'Cost'

			,@UNIT_TYPE_Weight AS NVARCHAR(50) = 'Weight'

			,@OWNERSHIP_TYPE_Own AS INT = 1
			,@OWNERSHIP_TYPE_Storage AS INT = 2
			,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
			,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

	DECLARE	-- Receipt Types
			@RECEIPT_TYPE_PurchaseContract AS NVARCHAR(50) = 'Purchase Contract'
			,@RECEIPT_TYPE_PurchaseOrder AS NVARCHAR(50) = 'Purchase Order'
			,@RECEIPT_TYPE_TransferOrder AS NVARCHAR(50) = 'Transfer Order'
			,@RECEIPT_TYPE_Direct AS NVARCHAR(50) = 'Direct'
			-- Source Types
			,@SOURCE_TYPE_None AS INT = 0
			,@SOURCE_TYPE_Scale AS INT = 1
			,@SOURCE_TYPE_InboundShipment AS INT = 2
			,@SOURCE_TYPE_Transport AS INT = 3

	DECLARE @ApprovedChargesToAdjust AS OtherChargeCostAdjustmentTableType
			,@ReturnValue AS INT 
END 

/*--------------------------------------------------
 Validation 
--------------------------------------------------*/
BEGIN 
	-- Filter the data and insert it to the @ApprovedChargesToAdjust
	INSERT INTO @ApprovedChargesToAdjust(
		intInventoryReceiptChargeId
		,dblNewValue
		,dtmDate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
	)
	SELECT  c.intInventoryReceiptChargeId
			,c.dblNewValue
			,c.dtmDate
			,c.intTransactionId
			,c.intTransactionDetailId
			,c.strTransactionId
	FROM	tblICInventoryReceiptCharge rc INNER JOIN @ChargesToAdjust c
				ON rc.intInventoryReceiptChargeId = c.intInventoryReceiptChargeId
	WHERE	rc.ysnInventoryCost = 1	

	-- Exit immediately if cost change for the other charge does not require inventory cost change. 
	IF NOT EXISTS (SELECT TOP 1 1 FROM @ApprovedChargesToAdjust)
	BEGIN 
		GOTO _Exit; 
	END 
END

/*---------------------------------------------------------------
 Allocate the new cost from the charge to the items. 
---------------------------------------------------------------*/
BEGIN 
	DECLARE @itemsForCostAdjustment as ItemCostAdjustmentTableType

	-- Allocate new cost by contract. 
	BEGIN 			
		-- Allocate by 'Unit'
		INSERT INTO @itemsForCostAdjustment 
		(
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId]
				,[dtmDate] 
				,[dblNewValue]
				,[intTransactionId]
				,[intTransactionDetailId] 
				,[strTransactionId] 
				,[intTransactionTypeId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[ysnIsStorage] 
				,[strActualCostId] 
				,[intSourceTransactionId] 
				,[intSourceTransactionDetailId] 
				,[strSourceTransactionId]
				,[intOtherChargeItemId] 
		)
		SELECT
				[intItemId]						= ReceiptItem.intItemId
				,[intItemLocationId]			= il.intItemLocationId
				,[intItemUOMId]					= COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId) 
				,[dtmDate]						= approvedCharges.dtmDate
				,[dblNewValue]					= dbo.fnMultiply(
													approvedCharges.dblNewValue
													,dbo.fnDivide( 
														CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN ISNULL(ReceiptItem.dblNet, 0)
																ELSE ISNULL(ReceiptItem.dblOpenReceive, 0)
														END 
														,TotalUnitsPerContract.dblTotalUnits)
												) 		
				,[intTransactionId]				= approvedCharges.intTransactionId
				,[intTransactionDetailId]		= approvedCharges.intTransactionDetailId
				,[strTransactionId]				= approvedCharges.strTransactionId
				,[intTransactionTypeId]			= invType.intTransactionTypeId
				,[intSubLocationId]				= ReceiptItem.intSubLocationId
				,[intStorageLocationId]			= ReceiptItem.intStorageLocationId
				,[ysnIsStorage]					= 0
				,[strActualCostId]				= Receipt.strActualCostId
				,[intSourceTransactionId]		= Receipt.intInventoryReceiptId
				,[intSourceTransactionDetailId] = ReceiptItem.intInventoryReceiptItemId
				,[strSourceTransactionId]		= Receipt.strReceiptNumber
				,[intOtherChargeItemId]			= ReceiptCharge.intChargeId 
		FROM	tblICInventoryReceiptCharge ReceiptCharge INNER JOIN @ApprovedChargesToAdjust approvedCharges
					ON ReceiptCharge.intInventoryReceiptChargeId = approvedCharges.intInventoryReceiptChargeId						
				INNER JOIN tblICInventoryReceipt Receipt 
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
					AND ReceiptItem.intOrderId = ReceiptCharge.intContractId
					AND ReceiptItem.intLineNo = ReceiptCharge.intContractDetailId
				INNER JOIN tblICItemLocation il 
					ON il.intItemId = ReceiptItem.intItemId
					AND il.intLocationId = Receipt.intLocationId
				CROSS APPLY (
					SELECT	dblTotalUnits = SUM(
								CASE	WHEN ReceiptItemWithSameContract.intWeightUOMId IS NOT NULL THEN 
											ISNULL(ReceiptItemWithSameContract.dblNet, 0) 
										ELSE 
											ISNULL(ReceiptItemWithSameContract.dblOpenReceive, 0) 
								END
							)
					FROM	dbo.tblICInventoryReceiptItem ReceiptItemWithSameContract INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItemWithSameContract.intUnitMeasureId 
					WHERE	ReceiptItemWithSameContract.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND ReceiptItemWithSameContract.intOrderId = ReceiptItem.intOrderId
							AND ReceiptItemWithSameContract.intLineNo = ReceiptItem.intLineNo

				) TotalUnitsPerContract
				LEFT JOIN tblICInventoryTransactionType invType
					on invType.strName = @strTransactionType
		WHERE	ReceiptCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Unit

		-- Allocate by 'Cost'
		UNION ALL 
		SELECT
				[intItemId]						= ReceiptItem.intItemId
				,[intItemLocationId]			= il.intItemLocationId
				,[intItemUOMId]					= COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId) 
				,[dtmDate]						= approvedCharges.dtmDate
				,[dblNewValue]					= dbo.fnMultiply(
													approvedCharges.dblNewValue
													,dbo.fnDivide( 
														CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
																	dbo.fnMultiply(
																		ISNULL(ReceiptItem.dblNet, 0) 
																		,ISNULL(ReceiptItem.dblUnitCost, 0)
																	)	
																ELSE 
																	dbo.fnMultiply(
																		ISNULL(ReceiptItem.dblOpenReceive, 0) 
																		,ISNULL(ReceiptItem.dblUnitCost, 0)
																	)	
														END 
														,TotalCostPerContract.dblTotalCost)
												) 		
				,[intTransactionId]				= approvedCharges.intTransactionId
				,[intTransactionDetailId]		= approvedCharges.intTransactionDetailId
				,[strTransactionId]				= approvedCharges.strTransactionId
				,[intTransactionTypeId]			= invType.intTransactionTypeId
				,[intSubLocationId]				= ReceiptItem.intSubLocationId
				,[intStorageLocationId]			= ReceiptItem.intStorageLocationId
				,[ysnIsStorage]					= 0
				,[strActualCostId]				= Receipt.strActualCostId
				,[intSourceTransactionId]		= Receipt.intInventoryReceiptId
				,[intSourceTransactionDetailId] = ReceiptItem.intInventoryReceiptItemId
				,[strSourceTransactionId]		= Receipt.strReceiptNumber
				,[intOtherChargeItemId]			= ReceiptCharge.intChargeId
		FROM	tblICInventoryReceiptCharge ReceiptCharge INNER JOIN @ApprovedChargesToAdjust approvedCharges
					ON ReceiptCharge.intInventoryReceiptChargeId = approvedCharges.intInventoryReceiptChargeId		
				INNER JOIN tblICInventoryReceipt Receipt 
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
					AND ReceiptItem.intOrderId = ReceiptCharge.intContractId
					AND ReceiptItem.intLineNo = ReceiptCharge.intContractDetailId
				INNER JOIN tblICItemLocation il 
					ON il.intItemId = ReceiptItem.intItemId
					AND il.intLocationId = Receipt.intLocationId
				CROSS APPLY (
					SELECT	dblTotalCost = SUM(
								CASE	WHEN ReceiptItemWithSameContract.intWeightUOMId IS NOT NULL THEN 
											dbo.fnMultiply(
												ISNULL(ReceiptItemWithSameContract.dblNet, 0) 
												,ISNULL(ReceiptItemWithSameContract.dblUnitCost, 0)
											)											
										ELSE 
											dbo.fnMultiply(
												ISNULL(ReceiptItemWithSameContract.dblOpenReceive, 0) 
												,ISNULL(ReceiptItemWithSameContract.dblUnitCost, 0)
											)
								END
							)
					FROM	dbo.tblICInventoryReceiptItem ReceiptItemWithSameContract INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItemWithSameContract.intUnitMeasureId 
					WHERE	ReceiptItemWithSameContract.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND ReceiptItemWithSameContract.intOrderId = ReceiptItem.intOrderId
							AND ReceiptItemWithSameContract.intLineNo = ReceiptItem.intLineNo

				) TotalCostPerContract
				LEFT JOIN tblICInventoryTransactionType invType
					on invType.strName = @strTransactionType		
		WHERE	ReceiptCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Cost

		-- Allocate by 'Stock Qty/Stock Unit'
		UNION ALL 
		SELECT
				[intItemId]						= ReceiptItem.intItemId
				,[intItemLocationId]			= il.intItemLocationId
				,[intItemUOMId]					= COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId) 
				,[dtmDate]						= approvedCharges.dtmDate
				,[dblNewValue]					= dbo.fnMultiply(
													approvedCharges.dblNewValue
													,dbo.fnDivide( 
														CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
																	dbo.fnCalculateStockUnitQty(ReceiptItem.dblNet, GrossNetUOM.dblUnitQty) 
																ELSE 
																	dbo.fnCalculateStockUnitQty(ReceiptItem.dblOpenReceive, GrossNetUOM.dblUnitQty) 
														END
														,TotalUnitsPerContract.dblTotalUnits)
												) 		
				,[intTransactionId]				= approvedCharges.intTransactionId
				,[intTransactionDetailId]		= approvedCharges.intTransactionDetailId
				,[strTransactionId]				= approvedCharges.strTransactionId
				,[intTransactionTypeId]			= invType.intTransactionTypeId
				,[intSubLocationId]				= ReceiptItem.intSubLocationId
				,[intStorageLocationId]			= ReceiptItem.intStorageLocationId
				,[ysnIsStorage]					= 0
				,[strActualCostId]				= Receipt.strActualCostId
				,[intSourceTransactionId]		= Receipt.intInventoryReceiptId
				,[intSourceTransactionDetailId] = ReceiptItem.intInventoryReceiptItemId
				,[strSourceTransactionId]		= Receipt.strReceiptNumber
				,[intOtherChargeItemId]			= ReceiptCharge.intChargeId
		FROM	tblICInventoryReceiptCharge ReceiptCharge INNER JOIN @ApprovedChargesToAdjust approvedCharges
					ON ReceiptCharge.intInventoryReceiptChargeId = approvedCharges.intInventoryReceiptChargeId						
				INNER JOIN tblICInventoryReceipt Receipt 
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
					AND ReceiptItem.intOrderId = ReceiptCharge.intContractId
					AND ReceiptItem.intLineNo = ReceiptCharge.intContractDetailId
				INNER JOIN tblICItemLocation il 
					ON il.intItemId = ReceiptItem.intItemId
					AND il.intLocationId = Receipt.intLocationId
				CROSS APPLY (
					SELECT	dblTotalUnits = SUM(
								CASE	WHEN ReceiptItemWithSameContract.intWeightUOMId IS NOT NULL THEN 
											dbo.fnCalculateStockUnitQty(ReceiptItemWithSameContract.dblNet, GrossNetUOM2.dblUnitQty) 
										ELSE 
											dbo.fnCalculateStockUnitQty(ReceiptItemWithSameContract.dblOpenReceive, GrossNetUOM2.dblUnitQty) 
								END
							)
					FROM	dbo.tblICInventoryReceiptItem ReceiptItemWithSameContract INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItemWithSameContract.intUnitMeasureId 
							LEFT JOIN  dbo.tblICItemUOM GrossNetUOM2
								ON GrossNetUOM2.intItemUOMId = ReceiptItemWithSameContract.intWeightUOMId
					WHERE	ReceiptItemWithSameContract.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND ReceiptItemWithSameContract.intOrderId = ReceiptItem.intOrderId
							AND ReceiptItemWithSameContract.intLineNo = ReceiptItem.intLineNo

				) TotalUnitsPerContract
				LEFT JOIN dbo.tblICItemUOM GrossNetUOM
					ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
				LEFT JOIN tblICInventoryTransactionType invType
					on invType.strName = @strTransactionType
		WHERE	ReceiptCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Stock_Unit
	END 

	-- Allocate new cost for those without a contract. 
	BEGIN 		
		-- Allocate by 'Unit'
		INSERT INTO @itemsForCostAdjustment 
		(
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId]
				,[dtmDate] 
				,[dblNewValue]
				,[intTransactionId]
				,[intTransactionDetailId] 
				,[strTransactionId] 
				,[intTransactionTypeId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[ysnIsStorage] 
				,[strActualCostId] 
				,[intSourceTransactionId] 
				,[intSourceTransactionDetailId] 
				,[strSourceTransactionId] 
				,[intOtherChargeItemId]
		)
		SELECT
				[intItemId]						= ReceiptItem.intItemId
				,[intItemLocationId]			= il.intItemLocationId
				,[intItemUOMId]					= COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId) 
				,[dtmDate]						= approvedCharges.dtmDate
				,[dblNewValue]					= dbo.fnMultiply(
													approvedCharges.dblNewValue
													,dbo.fnDivide( 
														CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN ISNULL(ReceiptItem.dblNet, 0)
																ELSE ISNULL(ReceiptItem.dblOpenReceive, 0)
														END 
														,TotalUnitsPerContract.dblTotalUnits)
												) 		
				,[intTransactionId]				= approvedCharges.intTransactionId
				,[intTransactionDetailId]		= approvedCharges.intTransactionDetailId
				,[strTransactionId]				= approvedCharges.strTransactionId
				,[intTransactionTypeId]			= invType.intTransactionTypeId
				,[intSubLocationId]				= ReceiptItem.intSubLocationId
				,[intStorageLocationId]			= ReceiptItem.intStorageLocationId
				,[ysnIsStorage]					= 0
				,[strActualCostId]				= Receipt.strActualCostId
				,[intSourceTransactionId]		= Receipt.intInventoryReceiptId
				,[intSourceTransactionDetailId] = ReceiptItem.intInventoryReceiptItemId
				,[strSourceTransactionId]		= Receipt.strReceiptNumber
				,[intOtherChargeItemId]			= ReceiptCharge.intChargeId
		FROM	tblICInventoryReceiptCharge ReceiptCharge INNER JOIN @ApprovedChargesToAdjust approvedCharges
					ON ReceiptCharge.intInventoryReceiptChargeId = approvedCharges.intInventoryReceiptChargeId						
				INNER JOIN tblICInventoryReceipt Receipt 
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
					AND 1 = CASE WHEN Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract AND ReceiptItem.intOrderId IS NULL THEN 1
								 WHEN Receipt.strReceiptType <> @RECEIPT_TYPE_PurchaseContract THEN 1
								 ELSE 0
							END 	
				INNER JOIN tblICItemLocation il 
					ON il.intItemId = ReceiptItem.intItemId
					AND il.intLocationId = Receipt.intLocationId
				CROSS APPLY (
					SELECT	dblTotalUnits = SUM(
								CASE	WHEN ReceiptItemWithNoContract.intWeightUOMId IS NOT NULL THEN 
											ISNULL(ReceiptItemWithNoContract.dblNet, 0) 
										ELSE 
											ISNULL(ReceiptItemWithNoContract.dblOpenReceive, 0) 
								END
							)
					FROM	dbo.tblICInventoryReceiptItem ReceiptItemWithNoContract INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItemWithNoContract.intUnitMeasureId 
					WHERE	ReceiptItemWithNoContract.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND 1 = CASE WHEN Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract AND ReceiptItemWithNoContract.intOrderId IS NULL THEN 1
										 WHEN Receipt.strReceiptType <> @RECEIPT_TYPE_PurchaseContract THEN 1
										 ELSE 0
									END 

				) TotalUnitsPerContract
				LEFT JOIN tblICInventoryTransactionType invType
					on invType.strName = @strTransactionType
		WHERE	ReceiptCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Unit

		-- Allocate by 'Cost'
		UNION ALL 
		SELECT
				[intItemId]						= ReceiptItem.intItemId
				,[intItemLocationId]			= il.intItemLocationId
				,[intItemUOMId]					= COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId) 
				,[dtmDate]						= approvedCharges.dtmDate
				,[dblNewValue]					= dbo.fnMultiply(
													approvedCharges.dblNewValue
													,dbo.fnDivide( 
														CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
																	dbo.fnMultiply(
																		ISNULL(ReceiptItem.dblNet, 0) 
																		,ISNULL(ReceiptItem.dblUnitCost, 0)
																	)	
																ELSE 
																	dbo.fnMultiply(
																		ISNULL(ReceiptItem.dblOpenReceive, 0) 
																		,ISNULL(ReceiptItem.dblUnitCost, 0)
																	)	
														END 
														,TotalCostPerContract.dblTotalCost)
												) 		
				,[intTransactionId]				= approvedCharges.intTransactionId
				,[intTransactionDetailId]		= approvedCharges.intTransactionDetailId
				,[strTransactionId]				= approvedCharges.strTransactionId
				,[intTransactionTypeId]			= invType.intTransactionTypeId
				,[intSubLocationId]				= ReceiptItem.intSubLocationId
				,[intStorageLocationId]			= ReceiptItem.intStorageLocationId
				,[ysnIsStorage]					= 0
				,[strActualCostId]				= Receipt.strActualCostId
				,[intSourceTransactionId]		= Receipt.intInventoryReceiptId
				,[intSourceTransactionDetailId] = ReceiptItem.intInventoryReceiptItemId
				,[strSourceTransactionId]		= Receipt.strReceiptNumber
				,[intOtherChargeItemId]			= ReceiptCharge.intChargeId
		FROM	tblICInventoryReceiptCharge ReceiptCharge INNER JOIN @ApprovedChargesToAdjust approvedCharges
					ON ReceiptCharge.intInventoryReceiptChargeId = approvedCharges.intInventoryReceiptChargeId		
				INNER JOIN tblICInventoryReceipt Receipt 
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
					AND 1 = CASE WHEN Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract AND ReceiptItem.intOrderId IS NULL THEN 1
								 WHEN Receipt.strReceiptType <> @RECEIPT_TYPE_PurchaseContract THEN 1
								 ELSE 0
							END 	
				INNER JOIN tblICItemLocation il 
					ON il.intItemId = ReceiptItem.intItemId
					AND il.intLocationId = Receipt.intLocationId
				CROSS APPLY (
					SELECT	dblTotalCost = SUM(
								CASE	WHEN ReceiptItemWithNoContract.intWeightUOMId IS NOT NULL THEN 
											dbo.fnMultiply(
												ISNULL(ReceiptItemWithNoContract.dblNet, 0) 
												,ISNULL(ReceiptItemWithNoContract.dblUnitCost, 0)
											)											
										ELSE 
											dbo.fnMultiply(
												ISNULL(ReceiptItemWithNoContract.dblOpenReceive, 0) 
												,ISNULL(ReceiptItemWithNoContract.dblUnitCost, 0)
											)
								END
							)
					FROM	dbo.tblICInventoryReceiptItem ReceiptItemWithNoContract INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItemWithNoContract.intUnitMeasureId 
					WHERE	ReceiptItemWithNoContract.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND 1 = CASE WHEN Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract AND ReceiptItemWithNoContract.intOrderId IS NULL THEN 1
										 WHEN Receipt.strReceiptType <> @RECEIPT_TYPE_PurchaseContract THEN 1
										 ELSE 0
									END 

				) TotalCostPerContract
				LEFT JOIN tblICInventoryTransactionType invType
					on invType.strName = @strTransactionType		
		WHERE	ReceiptCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Cost

		-- Allocate by 'Stock Qty/Stock Unit'
		UNION ALL 
		SELECT
				[intItemId]						= ReceiptItem.intItemId
				,[intItemLocationId]			= il.intItemLocationId
				,[intItemUOMId]					= COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId) 
				,[dtmDate]						= approvedCharges.dtmDate
				,[dblNewValue]					= dbo.fnMultiply(
													approvedCharges.dblNewValue
													,dbo.fnDivide( 
														CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
																	dbo.fnCalculateStockUnitQty(ReceiptItem.dblNet, GrossNetUOM.dblUnitQty) 
																ELSE 
																	dbo.fnCalculateStockUnitQty(ReceiptItem.dblOpenReceive, GrossNetUOM.dblUnitQty) 
														END
														,TotalUnitsPerContract.dblTotalUnits)
												) 		
				,[intTransactionId]				= approvedCharges.intTransactionId
				,[intTransactionDetailId]		= approvedCharges.intTransactionDetailId
				,[strTransactionId]				= approvedCharges.strTransactionId
				,[intTransactionTypeId]			= invType.intTransactionTypeId
				,[intSubLocationId]				= ReceiptItem.intSubLocationId
				,[intStorageLocationId]			= ReceiptItem.intStorageLocationId
				,[ysnIsStorage]					= 0
				,[strActualCostId]				= Receipt.strActualCostId
				,[intSourceTransactionId]		= Receipt.intInventoryReceiptId
				,[intSourceTransactionDetailId] = ReceiptItem.intInventoryReceiptItemId
				,[strSourceTransactionId]		= Receipt.strReceiptNumber
				,[intOtherChargeItemId]			= ReceiptCharge.intChargeId
		FROM	tblICInventoryReceiptCharge ReceiptCharge INNER JOIN @ApprovedChargesToAdjust approvedCharges
					ON ReceiptCharge.intInventoryReceiptChargeId = approvedCharges.intInventoryReceiptChargeId						
				INNER JOIN tblICInventoryReceipt Receipt 
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
					AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
					AND 1 = CASE WHEN Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract AND ReceiptItem.intOrderId IS NULL THEN 1
								 WHEN Receipt.strReceiptType <> @RECEIPT_TYPE_PurchaseContract THEN 1
								 ELSE 0
							END 	
				INNER JOIN tblICItemLocation il 
					ON il.intItemId = ReceiptItem.intItemId
					AND il.intLocationId = Receipt.intLocationId
				CROSS APPLY (
					SELECT	dblTotalUnits = SUM(
								CASE	WHEN ReceiptItemWithNoContract.intWeightUOMId IS NOT NULL THEN 
											dbo.fnCalculateStockUnitQty(ReceiptItemWithNoContract.dblNet, GrossNetUOM2.dblUnitQty) 
										ELSE 
											dbo.fnCalculateStockUnitQty(ReceiptItemWithNoContract.dblOpenReceive, GrossNetUOM2.dblUnitQty) 
								END
							)
					FROM	dbo.tblICInventoryReceiptItem ReceiptItemWithNoContract INNER JOIN dbo.tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ReceiptItemWithNoContract.intUnitMeasureId 
							LEFT JOIN  dbo.tblICItemUOM GrossNetUOM2
								ON GrossNetUOM2.intItemUOMId = ReceiptItemWithNoContract.intWeightUOMId
					WHERE	ReceiptItemWithNoContract.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND 1 = CASE WHEN Receipt.strReceiptType = @RECEIPT_TYPE_PurchaseContract AND ReceiptItemWithNoContract.intOrderId IS NULL THEN 1
										 WHEN Receipt.strReceiptType <> @RECEIPT_TYPE_PurchaseContract THEN 1
										 ELSE 0
									END 

				) TotalUnitsPerContract
				LEFT JOIN dbo.tblICItemUOM GrossNetUOM
					ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
				LEFT JOIN tblICInventoryTransactionType invType
					on invType.strName = @strTransactionType
		WHERE	ReceiptCharge.strAllocateCostBy = @ALLOCATE_COST_BY_Stock_Unit
	END 
END 

IF EXISTS (SELECT TOP 1 1 FROM @itemsForCostAdjustment)
BEGIN 	
	EXEC @ReturnValue = uspICPostCostAdjustment 
			@itemsForCostAdjustment
			, @strBatchId
			, @intEntityUserSecurityId
			, @ysnPost
END 

-- Exit point
_Exit:

RETURN ISNULL(@ReturnValue, 0) 