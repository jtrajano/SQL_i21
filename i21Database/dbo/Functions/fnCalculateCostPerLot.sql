﻿-- This function returns the cost per lot item. 
CREATE FUNCTION [dbo].[fnCalculateCostPerLot] (	
	@intItemUOMId AS INT
	,@intWeightUOMId AS INT
	,@intLotUOMId AS INT
	,@dblCostPerItemUOMId AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	DECLARE @CostPerWeightUOM AS NUMERIC(38,20)

	DECLARE @ItemUOMUnitQty AS NUMERIC(38,20)
			,@WeightUOMUnitQty AS NUMERIC(38,20)
			,@LotUOMUnitQty AS NUMERIC(38,20)

	-- If lot UOM is null, then assume it is the Item UOM. 
	IF ISNULL(@intLotUOMId, 0) = 0 
	BEGIN 
		SET @intLotUOMId = @intItemUOMId
	END 

	SELECT	@ItemUOMUnitQty = CASE WHEN intItemUOMId = @intItemUOMId THEN dblUnitQty ELSE @ItemUOMUnitQty END 
			,@WeightUOMUnitQty = CASE WHEN intItemUOMId = @intWeightUOMId THEN dblUnitQty ELSE @WeightUOMUnitQty END 
			,@LotUOMUnitQty = CASE WHEN intItemUOMId = @intLotUOMId THEN dblUnitQty ELSE @LotUOMUnitQty END 
	FROM	dbo.tblICItemUOM ItemUOM
	WHERE	ItemUOM.intItemUOMId IN (@intItemUOMId, @intWeightUOMId, @intLotUOMId)

	IF ISNULL(@ItemUOMUnitQty, 0) = 0 OR ISNULL(@WeightUOMUnitQty, 0) = 0 OR ISNULL(@LotUOMUnitQty, 0) = 0
	BEGIN 
		RETURN NULL;
	END 

	-- Formula to get the cost per Weight UOM
	-- Let: 
	-- A = Cost per Weight UOM
	-- B = Cost per Lot UOM
	--
	-- Calculation: 
	-- A = Cost / (	(Item UOM Unit Qty) / (Weight UOM Unit Qty) )
	-- B = A / (Weight UOM Unit Qty) * (Lot UOM Unit Qty)
	RETURN (
		dbo.fnMultiply (
			dbo.fnDivide (
				dbo.fnDivide (@dblCostPerItemUOMId, dbo.fnDivide(@ItemUOMUnitQty, @WeightUOMUnitQty)) 
				,@WeightUOMUnitQty
			)
			,@LotUOMUnitQty
		) 
	)
END