CREATE PROCEDURE uspLGRecalculatedWarehouseServiceCharges
	@intLoadWarehouseId INT,
	@intEntityUserSecurityId INT

AS 
BEGIN TRY
	DECLARE @intLoadId INT
	DECLARE @intMinWSRecordId INT
	DECLARE @intCalculateQtyBy INT
	DECLARE @intWarehouseServiceId INT
	DECLARE @intReceiptUOMId INT
	DECLARE @intWarehouserServiceItemUOMId INT
	DECLARE @intWarehouseRateMatrixHeaderId INT
	DECLARE @intWarehouseRateMatrixDetailId INT

	DECLARE @strCalculateBy NVARCHAR(100)
	DECLARE @strErrorMessage NVARCHAR(MAX)

	DECLARE @dblReceiptNetWeight NUMERIC(18,6)
	DECLARE @dblReceiptGrossWeight NUMERIC(18,6)
	DECLARE @dblWarehouserServiceUnitRate NUMERIC(18,6)

	DECLARE @tblRateMatrixCalculateBy TABLE (
		 intCalculateById INT
		,strCalculateBy NVARCHAR(100))

	DECLARE @tblWarehouseServices TABLE (
		 intWSRecordId INT IDENTITY(1, 1)
		,intLoadWarehouseId INT
		,intLoadId INT
		,intLoadWarehouseServicesId INT
		,intWarehouseRateMatrixHeaderId INT
		,intWarehouseRateMatrixDetailId INT
		,intItemUOMId INT
		,dblUnitRate NUMERIC(18,6))
 
 	INSERT INTO @tblRateMatrixCalculateBy
	SELECT 1, 'By Shipped Net Wt'
	UNION
	SELECT 2, 'By Shipped Gross Wt'
	UNION
	SELECT 3, 'By Received Net Wt'
	UNION
	SELECT 4, 'By Received Gross Wt'
	UNION
	SELECT 5, 'By Delivered Net Wt'
	UNION
	SELECT 6, 'By Delivered Gross Wt'
	UNION
	SELECT 7, 'By Quantity'
	UNION
	SELECT 8, 'Manual Entry'

	INSERT INTO @tblWarehouseServices
	SELECT LW.intLoadWarehouseId,
		   LW.intLoadId,
		   LWS.intLoadWarehouseServicesId,
		   LW.intWarehouseRateMatrixHeaderId,
		   LWS.intWarehouseRateMatrixDetailId,
		   LWS.intItemUOMId,
		   LWS.dblUnitRate
	FROM tblLGLoadWarehouse LW
	JOIN tblLGLoadWarehouseServices LWS ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId
	WHERE LW.intLoadWarehouseId = @intLoadWarehouseId
	
	SELECT @intLoadId = intLoadId,
		   @intWarehouseRateMatrixHeaderId = intWarehouseRateMatrixHeaderId
	FROM tblLGLoadWarehouse
	WHERE intLoadWarehouseId = @intLoadWarehouseId

	SELECT @dblReceiptGrossWeight = ISNULL(SUM(IRIL.dblGrossWeight),0), 
		   @dblReceiptNetWeight = ISNULL(SUM(IRI.dblNet),0),
		   @intReceiptUOMId = MAX(IRI.intWeightUOMId)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblICInventoryReceiptItem IRI ON IRI.intSourceId = LD.intLoadDetailId
	JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	WHERE L.intLoadId = @intLoadId
		AND IR.intSourceType = 2

	SELECT @intMinWSRecordId = MIN(intWSRecordId) 
	FROM @tblWarehouseServices

	WHILE ISNULL(@intMinWSRecordId,0) > 0
	BEGIN
		SET @intWarehouseRateMatrixDetailId = NULL
		SET @intCalculateQtyBy = NULL
		SET @strCalculateBy = NULL
		SET @intWarehouserServiceItemUOMId = NULL
		SET @dblWarehouserServiceUnitRate = NULL
		SET @intWarehouseServiceId = NULL

		SELECT @intWarehouseRateMatrixDetailId = intWarehouseRateMatrixDetailId,
			   @dblWarehouserServiceUnitRate = dblUnitRate,
			   @intWarehouserServiceItemUOMId = intItemUOMId,
			   @intWarehouseServiceId = intLoadWarehouseServicesId
		FROM @tblWarehouseServices WHERE intWSRecordId = @intMinWSRecordId
		
		SELECT @intCalculateQtyBy = intCalculateQty
		FROM tblLGWarehouseRateMatrixDetail
		WHERE intWarehouseRateMatrixDetailId = @intWarehouseRateMatrixDetailId

		SELECT @strCalculateBy = strCalculateBy
		FROM @tblRateMatrixCalculateBy
		WHERE intCalculateById = @intCalculateQtyBy

		IF (@strCalculateBy = 'By Shipped Net Wt')
		BEGIN
			UPDATE tblLGLoadWarehouseServices
			SET dblQuantity = dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptNetWeight)
				,dblCalculatedAmount = (dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptNetWeight)) * dblUnitRate
				,dblActualAmount = (dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptNetWeight)) * dblUnitRate
			WHERE intLoadWarehouseServicesId = @intWarehouseServiceId
		END
		ELSE IF (@strCalculateBy = 'By Shipped Gross Wt')
		BEGIN
			UPDATE tblLGLoadWarehouseServices
			SET dblQuantity = dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptGrossWeight)
				,dblCalculatedAmount = (dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptGrossWeight)) * dblUnitRate
				,dblActualAmount = (dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptGrossWeight)) * dblUnitRate
			WHERE intLoadWarehouseServicesId = @intWarehouseServiceId
		END
		ELSE IF (@strCalculateBy = 'By Received Net Wt')
		BEGIN
			UPDATE tblLGLoadWarehouseServices
			SET dblQuantity = dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptNetWeight)
				,dblCalculatedAmount = (dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptNetWeight)) * dblUnitRate
				,dblActualAmount = (dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptNetWeight)) * dblUnitRate
			WHERE intLoadWarehouseServicesId = @intWarehouseServiceId
		END
		ELSE IF (@strCalculateBy = 'By Received Gross Wt')
		BEGIN
			UPDATE tblLGLoadWarehouseServices
			SET dblQuantity = dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptGrossWeight)
				,dblCalculatedAmount = (dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptGrossWeight)) * dblUnitRate
				,dblActualAmount = (dbo.[fnCTConvertQtyToTargetItemUOM](@intReceiptUOMId, intItemUOMId, @dblReceiptGrossWeight)) * dblUnitRate
			WHERE intLoadWarehouseServicesId = @intWarehouseServiceId
		END
		
		SELECT @intMinWSRecordId = MIN(intWSRecordId)
		FROM @tblWarehouseServices
		WHERE intWSRecordId > @intMinWSRecordId
	END
	
END TRY

BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE();

	RAISERROR (@strErrorMessage,16,1)
END CATCH