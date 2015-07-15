CREATE PROCEDURE [dbo].[uspMFGetBlendSheetItems]
	@intItemId int,
	@intLocationId int,
	@dblQtyToProduce decimal(18,6)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables
BEGIN 
	DECLARE @WorkOrderStatus_New AS INT = 1
			,@WorkOrderStatus_Not_Released AS INT = 2
			,@WorkOrderStatus_Open AS INT = 3
			,@WorkOrderStatus_Frozen AS INT = 4
			,@WorkOrderStatus_Hold AS INT = 5
			,@WorkOrderStatus_Pre_Kitted AS INT = 6
			,@WorkOrderStatus_Kitted AS INT = 7
			,@WorkOrderStatus_Kit_Transferred AS INT = 8
			,@WorkOrderStatus_Released AS INT = 9
			,@WorkOrderStatus_Started AS INT = 10
			,@WorkOrderStatus_Paused AS INT = 11
			,@WorkOrderStatus_Staged AS INT = 12
			,@WorkOrderStatus_Completed AS INT = 13
END

-- Get the receipt id based on the selected item and company location 
BEGIN 
	DECLARE @intRecipeId AS INT 
	SELECT	@intRecipeId = intRecipeId 
	FROM	tblMFRecipe 
	WHERE	intItemId = @intItemId 
			AND intLocationId = @intLocationId 
			AND ysnActive = 1
END

-- Get the ingredients of the recipe
BEGIN 
	DECLARE @tblRequiredQty TABLE
	(
		intItemId INT,
		dblRequiredQty NUMERIC(18,6),
		ysnIsSubstitute BIT,
		intParentItemId INT,
		ysnHasSubstitute BIT,
		intRecipeItemId INT,
		intParentRecipeItemId INT,
		strGroupName NVARCHAR(50)
	)

	INSERT INTO @tblRequiredQty
	SELECT	ri.intItemId
			,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) RequiredQty
			,0
			,0
			,0
			,ri.intRecipeItemId
			,0
			,ri.strItemGroupName
	FROM	tblMFRecipeItem ri JOIN tblMFRecipe r
				ON r.intRecipeId = ri.intRecipeId 
	WHERE	r.intRecipeId = @intRecipeId 
			AND ri.intRecipeItemTypeId = 1
	UNION
	SELECT	rs.intSubstituteItemId AS intItemId
			,(rs.dblQuantity * (@dblQtyToProduce/r.dblQuantity)) RequiredQty
			,1
			,rs.intItemId
			,0
			,rs.intRecipeSubstituteItemId
			,rs.intRecipeItemId
			,''
	FROM	tblMFRecipeSubstituteItem rs JOIN tblMFRecipe r 
				ON r.intRecipeId = rs.intRecipeId 
	WHERE	r.intRecipeId = @intRecipeId 
			AND rs.intRecipeItemTypeId = 1

	-- Flag an ingredient if it has a substitute. 
	UPDATE	a 
	SET		a.ysnHasSubstitute = 1 
	FROM	@tblRequiredQty a JOIN @tblRequiredQty b 
				ON a.intItemId = b.intParentItemId
END

-- Get the physical quantities of the ingredients
BEGIN 
	DECLARE @tblPhysicalQty TABLE
	(
		intItemId int,
		dblPhysicalQty numeric(18,6)
	)
	
	-- Get the physical quantities of the main ingredients
	INSERT INTO @tblPhysicalQty
	SELECT	ri.intItemId
			,SUM(l.dblWeight) AS dblPhysicalQty 
	FROM	tblICLot l JOIN tblMFRecipeItem ri 
				ON ri.intItemId = l.intItemId 
	WHERE	ri.intRecipeId = @intRecipeId 
			AND l.intLocationId=@intLocationId
	GROUP BY ri.intItemId

	-- Get the physical quantities of the substitute ingredients
	INSERT INTO @tblPhysicalQty
	SELECT	rs.intSubstituteItemId
			,SUM(l.dblWeight) AS dblPhysicalQty 
	FROM	tblICLot l JOIN tblMFRecipeSubstituteItem rs 
				ON rs.intSubstituteItemId = l.intItemId 
	WHERE	rs.intRecipeId = @intRecipeId 
			AND l.intLocationId=@intLocationId
	GROUP BY rs.intSubstituteItemId

END

-- Reserve the ingredients
BEGIN 
	DECLARE @tblReservedQty table
	(
		intItemId int,
		dblReservedQty numeric(18,6)
	)

	-- Reserve the main ingredients
	INSERT INTO @tblReservedQty
	SELECT	ri.intItemId
			,SUM(cl.dblQuantity) AS dblReservedQty 
	FROM	tblMFWorkOrderConsumedLot cl JOIN tblMFWorkOrder w 
				ON cl.intWorkOrderId = w.intWorkOrderId
			JOIN tblICLot l 
				ON l.intLotId = cl.intLotId
			JOIN tblMFRecipeItem ri 
				ON ri.intItemId = l.intItemId 
	WHERE	ri.intRecipeId = @intRecipeId 
			AND w.intStatusId <> @WorkOrderStatus_Completed
	GROUP BY ri.intItemId

	-- Reserve the Substitute ingredients
	INSERT INTO @tblReservedQty
	SELECT	rs.intSubstituteItemId
			,SUM(cl.dblQuantity) AS dblReservedQty 
	FROM	tblMFWorkOrderConsumedLot cl JOIN tblMFWorkOrder w 
				ON cl.intWorkOrderId = w.intWorkOrderId
			JOIN tblICLot l 
				ON l.intLotId = cl.intLotId
			JOIN tblMFRecipeSubstituteItem rs 
				ON rs.intItemId = l.intItemId 
	WHERE	rs.intRecipeId = @intRecipeId 
			AND w.intStatusId <> @WorkOrderStatus_Completed
	GROUP BY rs.intSubstituteItemId
END

-- Return the blend sheet items as a query. 
BEGIN
	SELECT	i.intItemId
			,i.strItemNo
			,i.strDescription
			,a.dblRequiredQty
			,ISNULL(b.dblPhysicalQty,0) AS dblPhysicalQty
			,ISNULL(c.dblReservedQty,0) AS dblReservedQty
			,ISNULL((ISNULL(b.dblPhysicalQty,0) - ISNULL(c.dblReservedQty,0)),0) AS dblAvailableQty
			,0.0 AS dblSelectedQty
			,0.0 AS dblAvailableUnit
			,a.ysnIsSubstitute
			,a.intParentItemId
			,a.ysnHasSubstitute
			,a.intRecipeItemId
			,a.intParentRecipeItemId
			,a.strGroupName
	FROM	@tblRequiredQty a LEFT JOIN @tblPhysicalQty b 
				ON a.intItemId = b.intItemId
			LEFT JOIN @tblReservedQty c 
				ON a.intItemId = c.intItemId
			JOIN tblICItem i 
				ON a.intItemId=i.intItemId
END