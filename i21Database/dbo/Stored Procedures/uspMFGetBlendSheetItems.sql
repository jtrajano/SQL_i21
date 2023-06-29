CREATE PROCEDURE [dbo].[uspMFGetBlendSheetItems] 
(
	@intItemId				 INT
  , @intLocationId			 INT
  , @dblQtyToProduce		 DECIMAL(38, 20)
  , @dtmDueDate				 DATETIME
  , @strHandAddIngredientXml NVARCHAR(MAX) = ''
  , @intWorkOrderId			INT = NULL
) 
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intRecipeId					INT
	  , @ysnRecipeItemValidityByDueDate BIT = 0
	  , @intManufacturingProcessId		INT
	  , @intDayOfYear					INT
	  , @dtmDate						DATETIME
	  , @strPackagingCategoryId			NVARCHAR(MAX)
	  , @strBlendItemLotTracking		NVARCHAR(50)
	  , @ysnRecipeHeaderValidation		BIT = 0


DECLARE @tblRequiredQty TABLE 
(
	intItemId						INT
  , dblRequiredQty					NUMERIC(38, 20)
  , ysnIsSubstitute					BIT
  , intParentItemId					INT
  , ysnHasSubstitute				BIT
  , intRecipeItemId					INT
  , intParentRecipeItemId			INT
  , strGroupName					NVARCHAR(50)
  , dblLowerToleranceQty			NUMERIC(38, 20)
  , dblUpperToleranceQty			NUMERIC(38, 20)
  , ysnMinorIngredient				BIT
  , ysnScaled						BIT
  , dblRecipeQty					NUMERIC(38, 20)
  , dblRecipeItemQty				NUMERIC(38, 20)
  , strRecipeItemUOM				NVARCHAR(50)
  , strConsumptionStorageLocation	NVARCHAR(50)
  , intConsumptionMethodId			INT
  , intConsumptionStorageLocationId INT
);

DECLARE @tblPhysicalQty TABLE 
(
	intItemId			INT
  , dblPhysicalQty		NUMERIC(38, 20)
  , dblWeightPerUnit	NUMERIC(38, 20)
);

DECLARE @tblReservedQty TABLE (
	intItemId INT
	,dblReservedQty NUMERIC(38, 20)
	);
DECLARE @tblReservedQtyInTBS TABLE (
	intItemId INT
	,dblReservedQtyInTBS NUMERIC(38, 20)
	);
DECLARE @tblConfirmedQty TABLE (
	intItemId INT
	,dblConfirmedQty NUMERIC(38, 20)
	);

/* Get Recipe Header Validation. */
SELECT @ysnRecipeHeaderValidation = ysnRecipeHeaderValidation
FROM tblMFCompanyPreference;

SELECT TOP 1 @intRecipeId = intRecipeId
	,@intManufacturingProcessId = intManufacturingProcessId
FROM tblMFRecipe
WHERE intItemId = @intItemId
	AND intLocationId = @intLocationId
	AND (
		(
			@ysnRecipeHeaderValidation = 0
			AND ysnActive = 1
			)
		OR (
			@ysnRecipeHeaderValidation = 1
			AND @dtmDueDate <= dtmValidTo
			AND @dtmDueDate >= dtmValidFrom
			)
		)
ORDER BY dtmCreated DESC;

/* Get Output Item Lot Tracking Value. */
SELECT @strBlendItemLotTracking = strLotTracking
FROM tblICItem
WHERE intItemId = @intItemId;

/* Get Recipe Item Validity By Due Date value from Manufacturing Process. */
SELECT @ysnRecipeItemValidityByDueDate = CASE 
		WHEN UPPER(ProcessAttribute.strAttributeValue) = 'TRUE'
			THEN 1
		ELSE 0
		END
FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND Attribute.strAttributeName = 'Recipe Item Validity By Due Date';

/* Packaging Category value from Manufacturing Process. */
SELECT @strPackagingCategoryId = ISNULL(ProcessAttribute.strAttributeValue, '')
FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND Attribute.strAttributeName = 'Packaging Category';

IF @ysnRecipeItemValidityByDueDate = 0
BEGIN
	SET @dtmDate = CONVERT(DATE, GETDATE());
END
ELSE
BEGIN
	SET @dtmDate = CONVERT(DATE, @dtmDueDate)
END

SELECT @intDayOfYear = DATEPART(DY, @dtmDate)

IF EXISTS (
		SELECT 1
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId
		)
BEGIN
	/* Inserting Data for required Qty. */
	INSERT INTO @tblRequiredQty
	SELECT RecipeItem.intItemId
		,(RecipeItem.dblCalculatedQuantity * (@dblQtyToProduce / Recipe.dblQuantity)) AS RequiredQty
		,0
		,0
		,0
		,RecipeItem.intRecipeItemId
		,0
		,RecipeItem.strItemGroupName
		,(RecipeItem.dblCalculatedLowerTolerance * (@dblQtyToProduce / Recipe.dblQuantity)) AS dblLowerToleranceQty
		,(RecipeItem.dblCalculatedUpperTolerance * (@dblQtyToProduce / Recipe.dblQuantity)) AS dblUpperToleranceQty
		,RecipeItem.ysnMinorIngredient
		,ysnScaled
		,Recipe.dblQuantity AS dblRecipeQty
		,RecipeItem.dblQuantity AS dblRecipeItemQty
		,UnitOfMeasure.strUnitMeasure AS strRecipeItemUOM
		,ISNULL(StorageLocation.strName, '') AS strConsumptionStorageLocation
		,RecipeItem.intConsumptionMethodId
		,ISNULL(RecipeItem.intStorageLocationId, 0)
	FROM tblMFWorkOrderRecipeItem AS RecipeItem
	JOIN tblMFWorkOrderRecipe AS Recipe ON Recipe.intRecipeId = RecipeItem.intRecipeId
	and Recipe.intWorkOrderId = RecipeItem.intWorkOrderId
	JOIN tblICItemUOM AS ItemUOM ON RecipeItem.intItemUOMId = ItemUOM.intItemUOMId
	JOIN tblICUnitMeasure AS UnitOfMeasure ON ItemUOM.intUnitMeasureId = UnitOfMeasure.intUnitMeasureId
	LEFT JOIN tblICStorageLocation AS StorageLocation ON RecipeItem.intStorageLocationId = StorageLocation.intStorageLocationId
	JOIN tblICItem AS Item ON RecipeItem.intItemId = Item.intItemId
		AND Item.strType <> 'Other Charge'
	WHERE Recipe.intWorkOrderId = @intWorkOrderId
		AND RecipeItem.intRecipeItemTypeId = 1
		AND (
			(
				RecipeItem.ysnYearValidationRequired = 1
				AND @dtmDate BETWEEN RecipeItem.dtmValidFrom
					AND RecipeItem.dtmValidTo
				)
			OR (
				RecipeItem.ysnYearValidationRequired = 0
				AND @intDayOfYear BETWEEN DATEPART(dy, RecipeItem.dtmValidFrom)
					AND DATEPART(dy, RecipeItem.dtmValidTo)
				)
			)
	
	UNION
	
	SELECT SubstituteItem.intSubstituteItemId AS intItemId
		,(SubstituteItem.dblQuantity * (@dblQtyToProduce / Recipe.dblQuantity)) AS RequiredQty
		,1
		,SubstituteItem.intItemId
		,0
		,SubstituteItem.intRecipeSubstituteItemId
		,SubstituteItem.intRecipeItemId
		,''
		,(SubstituteItem.dblCalculatedLowerTolerance * (@dblQtyToProduce / Recipe.dblQuantity)) AS dblLowerToleranceQty
		,(SubstituteItem.dblCalculatedUpperTolerance * (@dblQtyToProduce / Recipe.dblQuantity)) AS dblUpperToleranceQty
		,0 AS ysnMinorIngredient
		,0 AS ysnScaled
		,Recipe.dblQuantity AS dblRecipeQty
		,SubstituteItem.dblQuantity AS dblRecipeItemQty
		,UnitOfMeasure.strUnitMeasure AS strRecipeItemUOM
		,'' AS strConsumptionStorageLocation
		,0
		,0
	FROM tblMFWorkOrderRecipeSubstituteItem AS SubstituteItem
	JOIN tblMFWorkOrderRecipe AS Recipe ON Recipe.intRecipeId = SubstituteItem.intRecipeId
	AND Recipe.intWorkOrderId = SubstituteItem.intWorkOrderId
	JOIN tblICItemUOM AS ItemUOM ON SubstituteItem.intItemUOMId = ItemUOM.intItemUOMId
	JOIN tblICUnitMeasure AS UnitOfMeasure ON ItemUOM.intUnitMeasureId = UnitOfMeasure.intUnitMeasureId
	WHERE Recipe.intWorkOrderId = @intWorkOrderId
		AND SubstituteItem.intRecipeItemTypeId = 1;
END
ELSE
BEGIN
	/* Inserting Data for required Qty. */
	INSERT INTO @tblRequiredQty
	SELECT RecipeItem.intItemId
		,(RecipeItem.dblCalculatedQuantity * (@dblQtyToProduce / Recipe.dblQuantity)) AS RequiredQty
		,0
		,0
		,0
		,RecipeItem.intRecipeItemId
		,0
		,RecipeItem.strItemGroupName
		,(RecipeItem.dblCalculatedLowerTolerance * (@dblQtyToProduce / Recipe.dblQuantity)) AS dblLowerToleranceQty
		,(RecipeItem.dblCalculatedUpperTolerance * (@dblQtyToProduce / Recipe.dblQuantity)) AS dblUpperToleranceQty
		,RecipeItem.ysnMinorIngredient
		,ysnScaled
		,Recipe.dblQuantity AS dblRecipeQty
		,RecipeItem.dblQuantity AS dblRecipeItemQty
		,UnitOfMeasure.strUnitMeasure AS strRecipeItemUOM
		,ISNULL(StorageLocation.strName, '') AS strConsumptionStorageLocation
		,RecipeItem.intConsumptionMethodId
		,ISNULL(RecipeItem.intStorageLocationId, 0)
	FROM tblMFRecipeItem AS RecipeItem
	JOIN tblMFRecipe AS Recipe ON Recipe.intRecipeId = RecipeItem.intRecipeId
	JOIN tblICItemUOM AS ItemUOM ON RecipeItem.intItemUOMId = ItemUOM.intItemUOMId
	JOIN tblICUnitMeasure AS UnitOfMeasure ON ItemUOM.intUnitMeasureId = UnitOfMeasure.intUnitMeasureId
	LEFT JOIN tblICStorageLocation AS StorageLocation ON RecipeItem.intStorageLocationId = StorageLocation.intStorageLocationId
	JOIN tblICItem AS Item ON RecipeItem.intItemId = Item.intItemId
		AND Item.strType <> 'Other Charge'
	WHERE Recipe.intRecipeId = @intRecipeId
		AND RecipeItem.intRecipeItemTypeId = 1
		AND (
			(
				RecipeItem.ysnYearValidationRequired = 1
				AND @dtmDate BETWEEN RecipeItem.dtmValidFrom
					AND RecipeItem.dtmValidTo
				)
			OR (
				RecipeItem.ysnYearValidationRequired = 0
				AND @intDayOfYear BETWEEN DATEPART(dy, RecipeItem.dtmValidFrom)
					AND DATEPART(dy, RecipeItem.dtmValidTo)
				)
			)
	
	UNION
	
	SELECT SubstituteItem.intSubstituteItemId AS intItemId
		,(SubstituteItem.dblQuantity * (@dblQtyToProduce / Recipe.dblQuantity)) AS RequiredQty
		,1
		,SubstituteItem.intItemId
		,0
		,SubstituteItem.intRecipeSubstituteItemId
		,SubstituteItem.intRecipeItemId
		,''
		,(SubstituteItem.dblCalculatedLowerTolerance * (@dblQtyToProduce / Recipe.dblQuantity)) AS dblLowerToleranceQty
		,(SubstituteItem.dblCalculatedUpperTolerance * (@dblQtyToProduce / Recipe.dblQuantity)) AS dblUpperToleranceQty
		,0 AS ysnMinorIngredient
		,0 AS ysnScaled
		,Recipe.dblQuantity AS dblRecipeQty
		,SubstituteItem.dblQuantity AS dblRecipeItemQty
		,UnitOfMeasure.strUnitMeasure AS strRecipeItemUOM
		,'' AS strConsumptionStorageLocation
		,0
		,0
	FROM tblMFRecipeSubstituteItem AS SubstituteItem
	JOIN tblMFRecipe AS Recipe ON Recipe.intRecipeId = SubstituteItem.intRecipeId
	JOIN tblICItemUOM AS ItemUOM ON SubstituteItem.intItemUOMId = ItemUOM.intItemUOMId
	JOIN tblICUnitMeasure AS UnitOfMeasure ON ItemUOM.intUnitMeasureId = UnitOfMeasure.intUnitMeasureId
	WHERE Recipe.intRecipeId = @intRecipeId
		AND SubstituteItem.intRecipeItemTypeId = 1;
END

UPDATE RequiredQty
SET RequiredQty.ysnHasSubstitute = 1
FROM @tblRequiredQty AS RequiredQty
JOIN @tblRequiredQty AS RequiredQty_1 ON RequiredQty.intItemId = RequiredQty_1.intParentItemId

/* For Pack Items take the ceil of Req Qty. */
UPDATE RequiredQty
SET RequiredQty.dblRequiredQty = CEILING(RequiredQty.dblRequiredQty)
FROM @tblRequiredQty AS RequiredQty
JOIN tblICItem AS Item ON RequiredQty.intItemId = Item.intItemId
JOIN (
	SELECT value
	FROM dbo.fnCommaSeparatedValueToTable(@strPackagingCategoryId)
	) AS PackageCategory ON Item.intCategoryId = PackageCategory.value;

/* Hand Add Ingredient. */
IF ISNULL(@strHandAddIngredientXml, '') <> ''
BEGIN
	DECLARE @tblHandAddIngredient AS TABLE (
		intRecipeItemId INT
		,dblQuantity NUMERIC(38, 20)
		);
	DECLARE @idoc INT
		,@dblHandAddIngredientQty NUMERIC(38, 20)
		,@dblRemainingHandAddQty NUMERIC(38, 20)
		,@dblTotalHandAddReqQty NUMERIC(38, 20)
		,@dblRecipeQtyWOHandAdd NUMERIC(38, 20)
		,@dblSumOfConsumeQty NUMERIC(38, 20)
		,@dblQtyDiff NUMERIC(38, 20)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strHandAddIngredientXml;

	INSERT INTO @tblHandAddIngredient (
		intRecipeItemId
		,dblQuantity
		)
	SELECT intRecipeItemId
		,dblQuantity
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intRecipeItemId INT
			,dblQuantity NUMERIC(38, 20)
			);

	SELECT @dblHandAddIngredientQty = SUM(dblQuantity)
	FROM @tblHandAddIngredient;

	SELECT @dblTotalHandAddReqQty = SUM(RequiredQty.dblRequiredQty)
	FROM @tblRequiredQty AS RequiredQty
	JOIN tblICItem AS Item ON RequiredQty.intItemId = Item.intItemId
	WHERE ISNULL(Item.ysnHandAddIngredient, 0) = 1;

	SELECT @dblRecipeQtyWOHandAdd = SUM(RequiredQty.dblRecipeItemQty)
	FROM @tblRequiredQty AS RequiredQty
	JOIN tblICItem AS Item ON RequiredQty.intItemId = Item.intItemId
	WHERE ISNULL(Item.ysnHandAddIngredient, 0) = 0;

	IF @dblHandAddIngredientQty <= @dblTotalHandAddReqQty
	BEGIN
		SET @dblRemainingHandAddQty = @dblTotalHandAddReqQty - @dblHandAddIngredientQty;
	END
	ELSE
	BEGIN
		SET @dblRemainingHandAddQty = @dblHandAddIngredientQty;
	END

	/* Add the variance to required quantity. */
	UPDATE RequiredQty
	SET RequiredQty.dblRequiredQty = RequiredQty.dblRequiredQty + (dblRecipeItemQty / @dblRecipeQtyWOHandAdd * @dblRemainingHandAddQty)
	FROM @tblRequiredQty AS RequiredQty
	JOIN tblICItem AS Item ON RequiredQty.intItemId = Item.intItemId
	WHERE ISNULL(Item.ysnHandAddIngredient, 0) = 0;

	/* Leave the hand add quantity unchanged. */
	UPDATE RequiredQty
	SET RequiredQty.dblRequiredQty = HandAddIngredient.dblQuantity
	FROM @tblRequiredQty AS RequiredQty
	JOIN @tblHandAddIngredient AS HandAddIngredient ON RequiredQty.intRecipeItemId = HandAddIngredient.intRecipeItemId
	JOIN tblICItem AS Item ON RequiredQty.intItemId = Item.intItemId
	WHERE ISNULL(Item.ysnHandAddIngredient, 0) = 1;

	/* Adjust the quantity difference between Quantity to Produce and Sum of Consume Qty. */
	SELECT @dblSumOfConsumeQty = SUM(dblRequiredQty)
	FROM @tblRequiredQty;

	SET @dblQtyDiff = @dblQtyToProduce - @dblSumOfConsumeQty;

	IF @dblQtyDiff <> 0
	BEGIN
		UPDATE RequiredQty
		SET RequiredQty.dblRequiredQty = RequiredQty.dblRequiredQty + @dblQtyDiff
		FROM (
			SELECT TOP 1 RequiredQty.*
			FROM @tblRequiredQty AS RequiredQty
			JOIN tblICItem AS Item ON RequiredQty.intItemId = Item.intItemId
			WHERE ISNULL(Item.ysnHandAddIngredient, 0) = 0
			ORDER BY dblRequiredQty DESC
			) AS RequiredQty;
	END
END

/* End of Hand Add Ingredient. */
/* Create Physical Quantity. */
INSERT INTO @tblPhysicalQty
SELECT RecipeItem.intItemId
	,SUM(CASE 
			WHEN ISNULL(Lot.dblWeight, 0) > 0
				THEN Lot.dblWeight
			ELSE dbo.fnMFConvertQuantityToTargetItemUOM(Lot.intItemUOMId, RecipeItem.intItemUOMId, Lot.dblQty)
			END) AS dblPhysicalQty
	,CASE 
		WHEN ISNULL(MAX(Lot.dblWeightPerQty), 1) = 0
			THEN 1
		ELSE ISNULL(MAX(Lot.dblWeightPerQty), 1)
		END AS dblWeightPerUnit
FROM tblICLot AS Lot
JOIN tblMFRecipeItem AS RecipeItem ON RecipeItem.intItemId = Lot.intItemId
JOIN tblICItem AS Item ON RecipeItem.intItemId = Item.intItemId
	AND Item.strType <> 'Other Charge'
WHERE RecipeItem.intRecipeId = @intRecipeId
	AND Lot.intLocationId = @intLocationId
GROUP BY RecipeItem.intItemId;

/* Create Physical Quantity for Substitute. */
INSERT INTO @tblPhysicalQty
SELECT SubstituteItem.intSubstituteItemId
	,SUM(CASE 
			WHEN ISNULL(Lot.dblWeight, 0) > 0
				THEN Lot.dblWeight
			ELSE dbo.fnMFConvertQuantityToTargetItemUOM(Lot.intItemUOMId, SubstituteItem.intItemUOMId, Lot.dblQty)
			END) AS dblPhysicalQty
	,CASE 
		WHEN ISNULL(MAX(Lot.dblWeightPerQty), 1) = 0
			THEN 1
		ELSE ISNULL(MAX(Lot.dblWeightPerQty), 1)
		END AS dblWeightPerUnit
FROM tblICLot AS Lot
JOIN tblMFRecipeSubstituteItem AS SubstituteItem ON SubstituteItem.intSubstituteItemId = Lot.intItemId
WHERE SubstituteItem.intRecipeId = @intRecipeId
	AND Lot.intLocationId = @intLocationId
GROUP BY SubstituteItem.intSubstituteItemId;

/* Create Reserved Quantity. */
INSERT INTO @tblReservedQty
SELECT RecipeItem.intItemId
	,SUM(StockReservation.dblQty) AS dblReservedQty
FROM tblICStockReservation AS StockReservation
JOIN tblMFRecipeItem AS RecipeItem ON RecipeItem.intItemId = StockReservation.intItemId
JOIN tblICItem AS Item ON RecipeItem.intItemId = Item.intItemId
	AND Item.strType <> 'Other Charge'
WHERE RecipeItem.intRecipeId = @intRecipeId
	AND RecipeItem.intRecipeItemTypeId = 1
	AND ISNULL(StockReservation.ysnPosted, 0) = 0
GROUP BY RecipeItem.intItemId;

/* Create Reserved Quantity for Trial Blend Sheet. */
INSERT INTO @tblReservedQtyInTBS
SELECT RecipeItem.intItemId
	,SUM(LotInventory.dblReservedQtyInTBS) AS dblReservedQty
FROM tblICLot AS Lot
JOIN tblMFLotInventory AS LotInventory ON LotInventory.intLotId = Lot.intLotId
JOIN tblMFRecipeItem AS RecipeItem ON RecipeItem.intItemId = Lot.intItemId
WHERE RecipeItem.intRecipeId = @intRecipeId
	AND RecipeItem.intRecipeItemTypeId = 1
GROUP BY RecipeItem.intItemId;

/* Create Reserved Quantity for Substitute. */
INSERT INTO @tblReservedQty
SELECT SubstituteItem.intSubstituteItemId
	,SUM(StockReservation.dblQty) AS dblReservedQty
FROM tblICStockReservation AS StockReservation
JOIN tblMFRecipeSubstituteItem AS SubstituteItem ON SubstituteItem.intSubstituteItemId = StockReservation.intItemId
WHERE SubstituteItem.intRecipeId = @intRecipeId
	AND ISNULL(StockReservation.ysnPosted, 0) = 0
GROUP BY SubstituteItem.intSubstituteItemId;

/* Create Confirmed Quantity. */
INSERT INTO @tblConfirmedQty (
	intItemId
	,dblConfirmedQty
	)
SELECT intItemId
	,SUM(dblQuantity)
FROM tblMFWorkOrderConsumedLot
WHERE intWorkOrderId = @intWorkOrderId
	AND ISNULL(ysnStaged, 0) = 1
GROUP BY intItemId;

/* RETURNED DATA. */
SELECT Item.intItemId
	 , Item.strItemNo
	 , Item.strDescription
	 , RequiredQty.dblRequiredQty
	 , ISNULL(PhysicalQty.dblPhysicalQty, 0) AS dblPhysicalQty
	 , ISNULL(ReservedQty.dblReservedQty, 0) AS dblReservedQty
	 , ISNULL((ISNULL(PhysicalQty.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - ISNULL(ReservedQtyInTBS.dblReservedQtyInTBS, 0)), 0) AS dblAvailableQty
	 , 0.0 AS dblSelectedQty
	 , ISNULL(ROUND((ISNULL((ISNULL(PhysicalQty.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - ISNULL(ReservedQtyInTBS.dblReservedQtyInTBS, 0)), 0)) / CASE WHEN ISNULL(PhysicalQty.dblWeightPerUnit, 1) = 0 THEN 1
																																										  ELSE ISNULL(PhysicalQty.dblWeightPerUnit, 1)
																																									 END, 0), 0.0) AS dblAvailableUnit
	 , RequiredQty.ysnIsSubstitute
	 , RequiredQty.intParentItemId
	 , RequiredQty.ysnHasSubstitute
	 , RequiredQty.intRecipeItemId
	 , RequiredQty.intParentRecipeItemId
	 , RequiredQty.strGroupName
	 , RequiredQty.dblLowerToleranceQty
	 , RequiredQty.dblUpperToleranceQty
	 , RequiredQty.ysnMinorIngredient
	 , RequiredQty.ysnScaled
	 , RequiredQty.dblRecipeQty
	 , RequiredQty.dblRecipeItemQty
	 , RequiredQty.strRecipeItemUOM
	 , RequiredQty.strConsumptionStorageLocation
	 , RequiredQty.intConsumptionMethodId
	 , ISNULL(Item.ysnHandAddIngredient, 0) AS ysnHandAddIngredient
	 , @intRecipeId AS intRecipeId
	 , RequiredQty.intConsumptionStorageLocationId
	 , @intManufacturingProcessId AS intManufacturingProcessId
	 , @strBlendItemLotTracking AS strBlendItemLotTracking
	 , ISNULL(ConfirmedQty.dblConfirmedQty, 0) AS dblConfirmedQty
	 , RequiredQty.dblRequiredQty AS dblOrgRequiredQty
	 , ISNULL(ReservedQtyInTBS.dblReservedQtyInTBS, 0) AS dblReservedQtyInTBS
	 , CAST(ROUND(ISNULL(ISNULL((ISNULL(PhysicalQty.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - ISNULL
		(ReservedQtyInTBS.dblReservedQtyInTBS, 0)) / CASE WHEN ISNULL(PhysicalQty.dblWeightPerUnit, 1) = 0 THEN 1
		 
                        ELSE ISNULL(PhysicalQty.dblWeightPerUnit, 1)
                    END, 0), 0.0) * (1.0 / (Item.intLayerPerPallet * Item.intUnitPerLayer)), 2)AS NUMERIC(18, 0)) AS dblNoOfPallet
	 , MT.strDescription AS strProductType
	 , B.strBrandCode
	 , Item.intUnitPerLayer
	 , Item.intLayerPerPallet
	 , Item.strShortName
FROM @tblRequiredQty AS RequiredQty
JOIN tblICItem AS Item ON RequiredQty.intItemId = Item.intItemId
LEFT JOIN @tblPhysicalQty AS PhysicalQty ON RequiredQty.intItemId = PhysicalQty.intItemId
LEFT JOIN @tblReservedQty AS ReservedQty ON RequiredQty.intItemId = ReservedQty.intItemId
LEFT JOIN @tblConfirmedQty AS ConfirmedQty ON ConfirmedQty.intItemId = Item.intItemId
LEFT JOIN @tblReservedQtyInTBS AS ReservedQtyInTBS ON RequiredQty.intItemId = ReservedQtyInTBS.intItemId
LEFT JOIN tblICCommodityAttribute MT ON MT.intCommodityAttributeId = Item.intProductTypeId
LEFT JOIN tblICBrand B ON B.intBrandId = Item.intBrandId;