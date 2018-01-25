CREATE PROCEDURE uspMFGetProductionReport @intDay INT = 1
AS
DECLARE @dtmProductionDate DATETIME

IF @dtmProductionDate IS NULL
BEGIN
	SELECT @dtmProductionDate = convert(DATETIME, Convert(CHAR, GetDATE(), 101)) - @intDay
END
ELSE
BEGIN
	SELECT @dtmProductionDate = convert(DATETIME, Convert(CHAR, @dtmProductionDate, 101))
END

IF @intDay = - 1
BEGIN
	SELECT [Production Date]
		,[Item]
		,[Description]
		,[Work Order #]
		,[Job #]
		,[Production Lot]
		,[Pallet No]
		,[Quantity]
		,[Quantity UOM]
		,[Weight]
		,[Weight UOM]
		,[Line]
	FROM vyuMFGetProduction
	ORDER BY dtmPlannedDate
		,intWorkOrderId

	SELECT [Dump Date]
		,[Product]
		,[Product Description]
		,[Production Lot]
		,Line
		,[Work Order #]
		,[Job #]
		,[WSI Item]
		,[WSI Item Description]
		,dblRequiredQty
		,[Pallet Id]
		,[Lot #]
		,[Quantity]
		,[Quantity UOM]
		,[Weight]
		,[Weight UOM]
	FROM vyuMFGetRMUsage
	ORDER BY dtmPlannedDate
		,intWorkOrderId

	SELECT [Dump Date]
		,[Product]
		,[Product Description]
		,[Production Lot]
		,Line
		,[Work Order #]
		,[Job #]
		,[WSI Item]
		,[WSI Item Description]
		,[Lot #]
		,Quantity
		,[Quantity UOM]
		,[Weight]
		,[Weight UOM]
	FROM vyuMFGetRMUsageByLot
	ORDER BY dtmPlannedDate
		,intWorkOrderId

	SELECT [Dump Date]
		,[Product]
		,[Product Description]
		,[Production Lot]
		,Line
		,[Work Order #]
		,[Job #]
		,[WSI Item]
		,[WSI Item Description]
		,dblRequiredQty
		,[Total Consumed Quantity]
		,[Used in Packaging]
		,[UOM]
		,[Damaged]
	FROM vyuMFGetPMUsage
	ORDER BY dtmPlannedDate
		,intWorkOrderId

	SELECT [Production Date]
		,Item
		,[Description]
		,[Work Order #]
		,[Job #]
		,[Production Lot]
		,[Good produced Pouches]
		,[Total Pouches passed through counter]
		,[Underweight Pouches]
		,[Overweight Pouches]
		,[Total sweeps (lb)]
	FROM vyuMFGetOverAndUnderWeight
	ORDER BY dtmPlannedDate
		,intWorkOrderId
END
ELSE
BEGIN
	SELECT [Production Date]
		,[Item]
		,[Description]
		,[Work Order #]
		,[Job #]
		,[Production Lot]
		,[Pallet No]
		,[Quantity]
		,[Quantity UOM]
		,[Weight]
		,[Weight UOM]
		,[Line]
	FROM vyuMFGetProduction
	WHERE [Production Date] = @dtmProductionDate
	ORDER BY dtmPlannedDate
		,intWorkOrderId

	SELECT [Dump Date]
		,[Product]
		,[Product Description]
		,[Production Lot]
		,Line
		,[Work Order #]
		,[Job #]
		,[WSI Item]
		,[WSI Item Description]
		,dblRequiredQty
		,[Pallet Id]
		,[Lot #]
		,[Quantity]
		,[Quantity UOM]
		,[Weight]
		,[Weight UOM]
	FROM vyuMFGetRMUsage
	WHERE [Dump Date] = @dtmProductionDate
	ORDER BY dtmPlannedDate
		,intWorkOrderId

	SELECT [Dump Date]
		,[Product]
		,[Product Description]
		,[Production Lot]
		,Line
		,[Work Order #]
		,[Job #]
		,[WSI Item]
		,[WSI Item Description]
		,[Lot #]
		,Quantity
		,[Quantity UOM]
		,[Weight]
		,[Weight UOM]
	FROM vyuMFGetRMUsageByLot
	WHERE [Dump Date] = @dtmProductionDate
	ORDER BY dtmPlannedDate
		,intWorkOrderId

	SELECT [Dump Date]
		,[Product]
		,[Product Description]
		,[Production Lot]
		,Line
		,[Work Order #]
		,[Job #]
		,[WSI Item]
		,[WSI Item Description]
		,dblRequiredQty
		,[Total Consumed Quantity]
		,[Used in Packaging]
		,[UOM]
		,[Damaged]
	FROM vyuMFGetPMUsage
	WHERE [Dump Date] = @dtmProductionDate
	ORDER BY dtmPlannedDate
		,intWorkOrderId

	SELECT [Production Date]
		,Item
		,[Description]
		,[Work Order #]
		,[Job #]
		,[Production Lot]
		,[Good produced Pouches]
		,[Total Pouches passed through counter]
		,[Underweight Pouches]
		,[Overweight Pouches]
		,[Total sweeps (lb)]
	FROM vyuMFGetOverAndUnderWeight
	WHERE [Production Date] = @dtmProductionDate
	ORDER BY dtmPlannedDate
		,intWorkOrderId
END
