CREATE PROCEDURE [dbo].[uspLGCreateLotNumberOnInventoryTransfer]
	@strTransactionId NVARCHAR(40) = NULL   
	,@intEntityUserSecurityId INT
	,@ysnPost BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2
		,@LotType_ManualSerial AS INT = 3

-- Create the temp table 
CREATE TABLE #GeneratedLotItems (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intDetailId INT 
	,intParentLotId INT
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

------------------------------------------------------------------------------
-- Validation 
------------------------------------------------------------------------------
BEGIN 
	DECLARE @strItemNo AS NVARCHAR(50)
	DECLARE @strUnitMeasure AS NVARCHAR(50)
	DECLARE @intItemId AS INT
	DECLARE @OpenReceiveQty AS NUMERIC(38,20)
	DECLARE @LotQty AS NUMERIC(38,20)
	DECLARE @OpenReceiveQtyInItemUOM AS NUMERIC(38,20)
	DECLARE @LotQtyInItemUOM AS NUMERIC(38,20)

	DECLARE @FormattedReceivedQty AS NVARCHAR(50)
	DECLARE @FormattedLotQty AS NVARCHAR(50)
	DECLARE @FormattedDifference AS NVARCHAR(50)

	-- Check if the unit quantities on the UOM table are valid. 
	BEGIN 
		SELECT	TOP 1 
				@strItemNo = Item.strItemNo
				,@intItemId = Item.intItemId
				,@strUnitMeasure = UOM.strUnitMeasure
		FROM	dbo.tblLGLoad [Transfer]
				INNER JOIN dbo.tblLGLoadDetail TransferItem
					ON [Transfer].intLoadId = TransferItem.intLoadId
				INNER JOIN dbo.tblICItem Item
					ON TransferItem.intItemId = Item.intItemId
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemUOM.intItemId = TransferItem.intItemId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE	ISNULL(ItemUOM.dblUnitQty, 0) <= 0
				AND [Transfer].strLoadNumber = @strTransactionId

		IF @intItemId IS NOT NULL 
		BEGIN 
			IF ISNULL(@strItemNo, '') = '' 
				SET @strItemNo = 'an item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

			-- 'Please correct the unit qty in UOM {UOM} on {Item}.'
			EXEC uspICRaiseError 80017, @strUnitMeasure, @strItemNo;
			RETURN -1; 			 
		END 
	END 
		
	-- Check if the Item Transfer quantity matches the total Quantity in the Lot
	SET @strItemNo = NULL 
	SET @intItemId = NULL 

	SELECT	TOP 1 
			@strItemNo					= Item.strItemNo
			,@intItemId					= Item.intItemId
			,@OpenReceiveQty			= TransferItem.dblQuantity
			,@LotQty					= ItemLot.TotalLotQty
			,@LotQtyInItemUOM			= ItemLot.TotalLotQtyInItemUOM
			,@OpenReceiveQtyInItemUOM	= dbo.fnCalculateQtyBetweenUOM (
											TransferItem.intItemUOMId
											,TransferItem.intItemUOMId
											,TransferItem.dblQuantity
										)
	FROM	dbo.tblLGLoad [Transfer] INNER JOIN dbo.tblLGLoadDetail TransferItem
				ON [Transfer].intLoadId = TransferItem.intLoadId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = TransferItem.intItemId
			LEFT JOIN (
				SELECT  tblLGLoadDetail.intLoadDetailId
						,TotalLotQtyInItemUOM = SUM(
							dbo.fnCalculateQtyBetweenUOM(
								ISNULL(tblLGLoadDetailLot.intItemUOMId, tblLGLoadDetail.intItemUOMId)
								,tblLGLoadDetail.intItemUOMId
								,tblLGLoadDetailLot.dblLotQuantity
							)
						)
						,TotalLotQty = SUM(ISNULL(tblLGLoadDetailLot.dblLotQuantity, 0))
				FROM	dbo.tblLGLoad 
					INNER JOIN dbo.tblLGLoadDetail
						ON tblLGLoad.intLoadId = tblLGLoadDetail.intLoadId
					INNER JOIN tblLGLoadDetailLot
						ON tblLGLoadDetail.intLoadDetailId = tblLGLoadDetailLot.intLoadDetailId
				WHERE	tblLGLoad.strLoadNumber = @strTransactionId				
				GROUP BY tblLGLoadDetail.intLoadDetailId
			) ItemLot
				ON ItemLot.intLoadDetailId = TransferItem.intLoadDetailId											
	WHERE	dbo.fnGetItemLotType(TransferItem.intItemId) <> 0 
			AND [Transfer].strLoadNumber = @strTransactionId
			AND ROUND(ItemLot.TotalLotQtyInItemUOM, 2) <>
				ROUND(dbo.fnCalculateQtyBetweenUOM (
					TransferItem.intItemUOMId
					,TransferItem.intItemUOMId
					,TransferItem.dblQuantity
				), 2)

	IF @intItemId IS NOT NULL 
	BEGIN 
		IF ISNULL(@strItemNo, '') = '' 
			SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

		-- The expected qty to receive for {Item} is {Open Receive Qty}. Lot Quantity is {Total Lot Qty}. The difference is {Calculated difference}.'
		DECLARE @difference AS NUMERIC(18, 6) = ABS(@OpenReceiveQty - @LotQtyInItemUOM);
		EXEC uspICRaiseError 80006, @strItemNo, @OpenReceiveQty, @LotQtyInItemUOM, @difference;
		RETURN -1; 
	END 
END

-- Get the list of item that needs lot numbers
BEGIN 
	INSERT INTO @ItemsThatNeedLotId (
			intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,intItemLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intItemUOMId
			,dtmExpiryDate
			,dtmManufacturedDate
			,intOriginId
			,intGradeId
			,strBOLNo
			,strVessel
			,strReceiptNumber
			,strMarkings
			,strNotes
			,intEntityVendorId
			,strVendorLotNo
			,strGarden
			,intDetailId
			,intSplitFromLotId
			,intOwnershipType
			,strParentLotNumber
			,strParentLotAlias
			,strTransactionId
			,strSourceTransactionId
			,intSourceTransactionTypeId
			,strContainerNo
			,strCondition
			,[intWeightUOMId]
			,[dblWeight]
			--,[dblGrossWeight]
			--,[dblWeightPerQty]
			,[intBookId]
			,[intSubBookId]
			,[strCertificate]
			,[intProducerId]
			,[strCertificateId]
			,[strTrackingNumber]
			,[strWarehouseRefNo]
			,intContractHeaderId
			,intContractDetailId
			,ysnWeighed
			,strSealNo
			,intLotStatusId
			,[dblTare]
			,[dblTarePerQty]
			,[strWarrantNo]
			,[intWarrantStatus]
	)
	SELECT	intLotId				= TransferItemLot.intNewLotId
			,strLotNumber			= CASE WHEN ISNULL(TransferItemLot.strNewLotNumber, '') = '' THEN SourceLot.strLotNumber ELSE TransferItemLot.strNewLotNumber END 
			,strLotAlias			= SourceLot.strLotAlias
			,intItemId				= TransferItem.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intSubLocationId		= ISNULL(WH.intSubLocationId, TransferItem.intSSubLocationId)
			,intStorageLocationId	= ISNULL(WH.intStorageLocationId, TransferItem.intSStorageLocationId)
			,dblQty					= CASE WHEN @ysnPost = 0 THEN -TransferItem.dblQuantity ELSE TransferItem.dblQuantity END 
			,intItemUOMId			= TransferItem.intItemUOMId
			,dtmExpiryDate			= SourceLot.dtmExpiryDate
			,dtmManufacturedDate	= SourceLot.dtmManufacturedDate
			,intOriginId			= SourceLot.intOriginId
			,intGradeId				= SourceLot.intGradeId
			,strBOLNo				= SourceLot.strBOLNo
			,strVessel				= SourceLot.strVessel
			,strReceiptNumber		= [Transfer].strLoadNumber
			,strMarkings			= SourceLot.strMarkings
			,strNotes				= SourceLot.strNotes
			,intEntityVendorId		= SourceLot.intEntityVendorId
			,strVendorLotNo			= SourceLot.strVendorLotNo
			,strGarden				= SourceLot.strGarden
			,intDetailId			= TransferItemLot.intLoadDetailLotId
			,intSplitFromLotId		= SourceLot.intLotId
			,intOwnershipType		= 1
			,strParentLotNumber		= ParentLotSourceLot.strParentLotNumber
			,strParentLotAlias		= ParentLotSourceLot.strParentLotAlias
			,strTransactionId			= [Transfer].strLoadNumber
			,strSourceTransactionId		= SourceLot.strTransactionId
			,intSourceTransactionTypeId = SourceLot.intSourceTransactionTypeId
			,strContainerNo			= SourceLot.strContainerNo
			,strCondition			= SourceLot.strCondition
			,[intWeightUOMId] 		= TransferItem.intWeightItemUOMId
			,[dblWeight]   			= 
				CASE 
					WHEN TransferItem.intWeightItemUOMId IS NOT NULL THEN 
						CASE WHEN @ysnPost = 0 THEN -TransferItem.dblNet ELSE TransferItem.dblNet END
					ELSE 0
				END 
			--,[dblGrossWeight] 		= CASE WHEN TransferItem.intGrossNetUOMId IS NOT NULL THEN TransferItem.dblGross ELSE NULL END
			--,[dblWeightPerQty]		= CASE WHEN TransferItem.intGrossNetUOMId IS NOT NULL THEN CASE WHEN ISNULL(NULLIF(TransferItem.dblNet, 0), 0) = 0 THEN 0 ELSE TransferItem.dblQuantity / TransferItem.dblNet END ELSE NULL END
			,[intBookId]				= SourceLot.intBookId
			,[intSubBookId]				= SourceLot.intSubBookId
			,[strCertificate]			= SourceLot.strCertificate
			,[intProducerId]			= SourceLot.intProducerId
			,[strCertificateId]			= SourceLot.strCertificateId
			,[strTrackingNumber]		= SourceLot.strTrackingNumber 
			,[strWarehouseRefNo]		= CASE WHEN ISNULL(TransferItemLot.strWarehouseCargoNumber, '') = '' THEN SourceLot.strWarehouseRefNo ELSE TransferItemLot.strWarehouseCargoNumber END 
			,intContractHeaderId		= SourceLot.intContractHeaderId
			,intContractDetailId		= SourceLot.intContractDetailId
			,ysnWeighed					= SourceLot.ysnWeighed
			,strSealNo					= SourceLot.strSealNo
			,intLotStatusId				= SourceLot.intLotStatusId 
			,[dblTare]					= SourceLot.dblTare
			,[dblTarePerQty]			= SourceLot.dblTarePerQty
			,[strWarrantNo]				= SourceLot.strWarrantNo
			,[intWarrantStatus]			= SourceLot.intWarrantStatus
	FROM	dbo.tblLGLoad [Transfer] 
			INNER JOIN dbo.tblLGLoadDetail TransferItem
				ON [Transfer].intLoadId = TransferItem.intLoadId
			INNER JOIN dbo.tblLGLoadDetailLot TransferItemLot
				ON TransferItem.intLoadDetailId = TransferItemLot.intLoadDetailId
			INNER JOIN dbo.tblICItem Item
				ON TransferItem.intItemId = Item.intItemId		
			OUTER APPLY (
				SELECT TOP 1 clsl.intCompanyLocationId, lw.intSubLocationId, lw.intStorageLocationId FROM tblLGLoadWarehouse lw 
				INNER JOIN tblSMCompanyLocationSubLocation clsl ON lw.intSubLocationId = clsl.intCompanyLocationSubLocationId
				WHERE lw.intLoadId = [Transfer].intLoadId) WH
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON TransferItem.intItemId = ItemLocation.intItemId
				AND ItemLocation.intLocationId = ISNULL(WH.intCompanyLocationId, [TransferItem].intSCompanyLocationId)
			INNER JOIN tblICLot SourceLot 
				ON SourceLot.intLotId = TransferItemLot.intLotId
			LEFT JOIN dbo.tblICParentLot ParentLotSourceLot
				ON ParentLotSourceLot.intParentLotId = SourceLot.intParentLotId
	WHERE	[Transfer].strLoadNumber = @strTransactionId

END 

-- Call the common stored procedure that will create or updat the lot master table
BEGIN 
	DECLARE @intErrorFoundOnCreateUpdateLotNumber AS INT

	EXEC @intErrorFoundOnCreateUpdateLotNumber = dbo.uspICCreateUpdateLotNumber 
		@ItemsThatNeedLotId
		,@intEntityUserSecurityId

	IF @intErrorFoundOnCreateUpdateLotNumber <> 0
		RETURN @intErrorFoundOnCreateUpdateLotNumber;
END

-- Assign the generated lot id's back to the inventory Transfer item-lot table. 
BEGIN 
	UPDATE	DetailLot
	SET		intNewLotId = LotNumbers.intLotId
			,strNewLotNumber = LotNumbers.strLotNumber		
	FROM	dbo.tblLGLoadDetailLot DetailLot INNER JOIN #GeneratedLotItems LotNumbers
				ON DetailLot.intLoadDetailId = LotNumbers.intDetailId
END 

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
	DROP TABLE #GeneratedLotItems

RETURN 0; 
