CREATE PROCEDURE [dbo].[uspMFCreatePickListForProduction] @intWorkOrderId INT
	,@dblQtyToProduce NUMERIC(38, 20)
AS
DECLARE @intLocationId INT
DECLARE @intMinItem INT
DECLARE @intItemId INT
DECLARE @dblRequiredQty NUMERIC(38, 20)
DECLARE @dblItemRequiredQty NUMERIC(38, 20)
DECLARE @strLotTracking NVARCHAR(50)
DECLARE @intItemUOMId INT
DECLARE @intMinLot INT
DECLARE @intLotId INT
DECLARE @dblAvailableQty NUMERIC(38, 20)
DECLARE @intPickListId INT
DECLARE @intRecipeId INT
DECLARE @intOutputItemId INT
DECLARE @intManufacturingProcessId INT
DECLARE @intDayOfYear INT
DECLARE @dtmDate DATETIME = Convert(DATE, GetDate())
DECLARE @dblReservedQty NUMERIC(38, 20)
DECLARE @ysnWOStagePick BIT = 0
DECLARE @intConsumptionMethodId INT
DECLARE @strPackagingCategory NVARCHAR(50)
Declare @dblDefaultResidueQty NUMERIC(38,20)

DECLARE @tblInputItem TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intRecipeId INT
	,intRecipeItemId INT
	,intItemId INT
	,dblRequiredQty NUMERIC(38, 20)
	,ysnIsSubstitute BIT
	,ysnMinorIngredient BIT
	,intConsumptionMethodId INT
	,intConsumptionStoragelocationId INT
	,intParentItemId INT
	,dblSubstituteRatio NUMERIC(38, 20)
	,dblMaxSubstituteRatio NUMERIC(38, 20)
	,strLotTracking NVARCHAR(50)
	,intItemUOMId INT
	)
DECLARE @tblInputItemCopy AS TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intRecipeId INT
	,intRecipeItemId INT
	,intItemId INT
	,dblRequiredQty NUMERIC(38, 20)
	,ysnIsSubstitute BIT
	,ysnMinorIngredient BIT
	,intConsumptionMethodId INT
	,intConsumptionStoragelocationId INT
	,intParentItemId INT
	,dblSubstituteRatio NUMERIC(38, 20)
	,dblMaxSubstituteRatio NUMERIC(38, 20)
	,strLotTracking NVARCHAR(50)
	,intItemUOMId INT
	)
DECLARE @tblLot TABLE (
	intRowNo INT IDENTITY
	,intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38, 20)
	,intItemUOMId INT
	,intLocationId INT
	,intSubLocationId INT
	,intStorageLocationId INT
	,dblReservedQty NUMERIC(38, 20)
	,dtmDateCreated DATETIME
	)
DECLARE @tblLotCopy TABLE (
	intRowNo INT IDENTITY
	,intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38, 20)
	,intItemUOMId INT
	,intLocationId INT
	,intSubLocationId INT
	,intStorageLocationId INT
	,dblReservedQty NUMERIC(38, 20)
	,dtmDateCreated DATETIME
	)
DECLARE @tblPickedLot TABLE (
	intRowNo INT IDENTITY
	,intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38, 20)
	,intItemUOMId INT
	,intLocationId INT
	,intSubLocationId INT
	,intStorageLocationId INT
	,dblItemRequiredQty NUMERIC(38, 20)
	,dblAvailableQty NUMERIC(38, 20)
	,dblReservedQty NUMERIC(38, 20)
	)
DECLARE @tblWOStagingLocation AS TABLE (intStagingLocationId INT)

Select TOP 1 @dblDefaultResidueQty=ISNULL(dblDefaultResidueQty,0.00001) From tblMFCompanyPreference

SELECT @intLocationId = intLocationId
	,@intOutputItemId = intItemId
	,@intPickListId = ISNULL(intPickListId, 0)
FROM tblMFWorkOrder
WHERE intWorkOrderId = @intWorkOrderId

SELECT @intRecipeId = intRecipeId
	,@intManufacturingProcessId = intManufacturingProcessId
FROM tblMFRecipe
WHERE intItemId = @intOutputItemId
	AND intLocationId = @intLocationId
	AND ysnActive = 1

SELECT @strPackagingCategory = pa.strAttributeValue
FROM tblMFManufacturingProcessAttribute pa
JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND at.strAttributeName = 'Packaging Category'

SELECT @intDayOfYear = DATEPART(dy, @dtmDate)

IF ISNULL(@intPickListId, 0) = 0
BEGIN
	INSERT INTO @tblInputItem (
		intRecipeId
		,intRecipeItemId
		,intItemId
		,dblRequiredQty
		,ysnIsSubstitute
		,ysnMinorIngredient
		,intConsumptionMethodId
		,intConsumptionStoragelocationId
		,intParentItemId
		,dblSubstituteRatio
		,dblMaxSubstituteRatio
		,strLotTracking
		,intItemUOMId
		)
	SELECT @intRecipeId
		,ri.intRecipeItemId
		,ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0 AS ysnIsSubstitute
		,ri.ysnMinorIngredient
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
		,0
		,0.0
		,0.0
		,i.strLotTracking
		,ri.intItemUOMId
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	JOIN tblICItem i ON ri.intItemId = i.intItemId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND (
			(
				ri.ysnYearValidationRequired = 1
				AND @dtmDate BETWEEN ri.dtmValidFrom
					AND ri.dtmValidTo
				)
			OR (
				ri.ysnYearValidationRequired = 0
				AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
					AND DATEPART(dy, ri.dtmValidTo)
				)
			)
		AND ri.intConsumptionMethodId IN (
			1
			,2
			,3
			)
	
	UNION
	
	SELECT @intRecipeId
		,rs.intRecipeSubstituteItemId
		,rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1 AS ysnIsSubstitute
		,0
		,1
		,0
		,ri.intItemId
		,rs.dblSubstituteRatio
		,rs.dblMaxSubstituteRatio
		,i.strLotTracking
		,ri.intItemUOMId
	FROM tblMFRecipeSubstituteItem rs
	JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
	JOIN tblMFRecipeItem ri ON rs.intRecipeItemId = ri.intRecipeItemId
	JOIN tblICItem i ON ri.intItemId = i.intItemId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
	ORDER BY ysnIsSubstitute
END
ELSE
BEGIN --Pick List is already created
	INSERT INTO @tblInputItemCopy (
		intRecipeId
		,intRecipeItemId
		,intItemId
		,dblRequiredQty
		,ysnIsSubstitute
		,ysnMinorIngredient
		,intConsumptionMethodId
		,intConsumptionStoragelocationId
		,intParentItemId
		,dblSubstituteRatio
		,dblMaxSubstituteRatio
		,strLotTracking
		,intItemUOMId
		)
	SELECT r.intRecipeId
		,ri.intRecipeItemId
		,ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0 AS ysnIsSubstitute
		,ri.ysnMinorIngredient
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
		,0
		,0.0
		,0.0
		,i.strLotTracking
		,ri.intItemUOMId
	FROM tblMFWorkOrderRecipeItem ri
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
	JOIN tblICItem i ON ri.intItemId = i.intItemId
	WHERE r.intWorkOrderId = @intWorkOrderId
		AND ri.intRecipeItemTypeId = 1
		AND ri.intConsumptionMethodId IN (
			1
			,2
			,3
			)
	
	UNION
	
	SELECT r.intRecipeId
		,rs.intRecipeSubstituteItemId
		,rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1 AS ysnIsSubstitute
		,0
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
		,ri.intItemId
		,rs.dblSubstituteRatio
		,rs.dblMaxSubstituteRatio
		,i.strLotTracking
		,ri.intItemUOMId
	FROM tblMFWorkOrderRecipeSubstituteItem rs
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
	JOIN tblMFWorkOrderRecipeItem ri ON rs.intRecipeItemId = ri.intRecipeItemId
		AND ri.intWorkOrderId = r.intWorkOrderId
	JOIN tblICItem i ON rs.intSubstituteItemId = i.intItemId
	WHERE r.intWorkOrderId = @intWorkOrderId
		AND rs.intRecipeItemTypeId = 1
	ORDER BY ysnIsSubstitute

	INSERT INTO @tblInputItem (
		intRecipeId
		,intRecipeItemId
		,intItemId
		,dblRequiredQty
		,ysnIsSubstitute
		,ysnMinorIngredient
		,intConsumptionMethodId
		,intConsumptionStoragelocationId
		,intParentItemId
		,dblSubstituteRatio
		,dblMaxSubstituteRatio
		,strLotTracking
		,intItemUOMId
		)
	SELECT ti.intRecipeId
		,ti.intRecipeItemId
		,ti.intItemId
		,ISNULL(ti.dblRequiredQty, 0) - ISNULL(t.dblQty, 0)
		,ti.ysnIsSubstitute
		,ti.ysnMinorIngredient
		,ti.intConsumptionMethodId
		,ti.intConsumptionStoragelocationId
		,ti.intParentItemId
		,ti.dblSubstituteRatio
		,ti.dblMaxSubstituteRatio
		,ti.strLotTracking
		,ti.intItemUOMId
	FROM @tblInputItemCopy ti
	LEFT JOIN (
		SELECT pld.intItemId
			,SUM(pld.dblPickQuantity) AS dblQty
		FROM tblMFPickListDetail pld
		WHERE intPickListId = @intPickListId
		GROUP BY pld.intItemId
		) t ON ti.intItemId = t.intItemId

	DELETE
	FROM @tblInputItem
	WHERE ISNULL(dblRequiredQty, 0) = 0
END

INSERT INTO @tblWOStagingLocation
SELECT DISTINCT oh.intStagingLocationId
FROM tblMFStageWorkOrder sw
JOIN tblMFOrderHeader oh ON sw.intOrderHeaderId = oh.intOrderHeaderId
WHERE ISNULL(oh.intStagingLocationId, 0) > 0
	AND sw.intWorkOrderId = @intWorkOrderId

IF (
		SELECT Count(1)
		FROM @tblWOStagingLocation
		) > 0
	SET @ysnWOStagePick = 1

SELECT @intMinItem = MIN(intRowNo)
FROM @tblInputItem

WHILE @intMinItem IS NOT NULL
BEGIN
	SELECT @intItemId = intItemId
		,@dblRequiredQty = dblRequiredQty
		,@dblItemRequiredQty = dblRequiredQty
		,@intItemUOMId = intItemUOMId
		,@strLotTracking = strLotTracking
		,@intConsumptionMethodId = intConsumptionMethodId
	FROM @tblInputItem
	WHERE intRowNo = @intMinItem

	IF (
			SELECT i.intCategoryId
			FROM tblICItem i
			WHERE i.intItemId = @intItemId
			) = @strPackagingCategory
	BEGIN
		SET @dblRequiredQty = CEILING(@dblRequiredQty)
		SET @dblItemRequiredQty = CEILING(@dblRequiredQty)
	END

	DELETE
	FROM @tblLot

	IF @strLotTracking = 'No'
		INSERT INTO @tblLot (
			intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblReservedQty
			)
		SELECT 0
			,sd.intItemId
			,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId, @intItemUOMId, sd.dblAvailableQty)
			,@intItemUOMId
			,sd.intLocationId
			,sd.intSubLocationId
			,sd.intStorageLocationId
			,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId, @intItemUOMId, sd.dblReservedQty)
		FROM vyuMFGetItemStockDetail sd
		WHERE sd.intItemId = @intItemId
			AND sd.dblAvailableQty >  @dblDefaultResidueQty
			AND sd.intLocationId = @intLocationId
			AND ISNULL(sd.ysnStockUnit, 0) = 1
		ORDER BY sd.intItemStockUOMId
	ELSE
		INSERT INTO @tblLot (
			intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblReservedQty
			,dtmDateCreated
			)
		SELECT L.intLotId
			,L.intItemId
			,dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty) - (
				SELECT ISNULL(SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sr.intItemUOMId, @intItemUOMId, sr.dblQty), 0)), 0)
				FROM tblICStockReservation sr
				WHERE sr.intLotId = L.intLotId
					AND ISNULL(sr.ysnPosted, 0) = 0
				) AS dblQty
			,@intItemUOMId
			,L.intLocationId
			,L.intSubLocationId
			,L.intStorageLocationId
			,(
				SELECT ISNULL(SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sr.intItemUOMId, @intItemUOMId, sr.dblQty), 0)), 0)
				FROM tblICStockReservation sr
				WHERE sr.intLotId = L.intLotId
					AND ISNULL(sr.ysnPosted, 0) = 0
				) AS dblReservedQty
			,L.dtmDateCreated
		FROM tblICLot L
		JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
		JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					AND SL.ysnAllowConsume = 1
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = IsNULL(SL.intRestrictionId,R.intRestrictionId)
					AND R.strInternalCode = 'STOCK'
		WHERE L.intItemId = @intItemId
			AND L.intLocationId = @intLocationId
			AND LS.strPrimaryStatus IN ('Active')
			AND (
				L.dtmExpiryDate IS NULL
				OR L.dtmExpiryDate >= GETDATE()
				)
			AND L.dblQty > @dblDefaultResidueQty
		ORDER BY L.dtmDateCreated

	DELETE
	FROM @tblLot
	WHERE dblQty <  @dblDefaultResidueQty

	--if WO has associated Pick Order, pick lots from Order Staging Location
	IF @ysnWOStagePick = 1
	BEGIN
		DELETE
		FROM @tblLotCopy

		INSERT INTO @tblLotCopy (
			intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblReservedQty
			,dtmDateCreated
			)
		SELECT intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblReservedQty
			,dtmDateCreated
		FROM @tblLot tl
		WHERE tl.intStorageLocationId IN (
				SELECT intStagingLocationId
				FROM @tblWOStagingLocation
				)
		ORDER BY tl.dtmDateCreated

		INSERT INTO @tblLotCopy (
			intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblReservedQty
			,dtmDateCreated
			)
		SELECT intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblReservedQty
			,dtmDateCreated
		FROM @tblLot tl
		WHERE tl.intStorageLocationId NOT IN (
				SELECT intStagingLocationId
				FROM @tblWOStagingLocation
				)
		ORDER BY tl.dtmDateCreated

		DELETE
		FROM @tblLot

		INSERT INTO @tblLot (
			intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblReservedQty
			,dtmDateCreated
			)
		SELECT intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblReservedQty
			,dtmDateCreated
		FROM @tblLotCopy
	END

	--For Bulk Items Do not consider lot
	IF @intConsumptionMethodId IN (
			2
			,3
			) --By Location/FIFO
	BEGIN
		SET @dblAvailableQty = (
				SELECT ISNULL(SUM(ISNULL(dblQty, 0)), 0)
				FROM @tblLot
				) - (
				SELECT ISNULL(SUM(ISNULL(dblQty, 0)), 0)
				FROM tblICStockReservation
				WHERE intItemId = @intItemId
					AND intLocationId = @intLocationId
					AND ISNULL(ysnPosted, 0) = 0
				)

		SELECT @dblReservedQty = ISNULL(SUM(ISNULL(dblQty, 0)), 0)
		FROM tblICStockReservation
		WHERE intItemId = @intItemId
			AND intLocationId = @intLocationId
			AND ISNULL(ysnPosted, 0) = 0

		IF @dblAvailableQty > @dblDefaultResidueQty
		BEGIN
			DELETE
			FROM @tblLotCopy

			INSERT INTO @tblLotCopy (
				intLotId
				,intItemId
				,dblQty
				,intItemUOMId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,dblReservedQty
				,dtmDateCreated
				)
			SELECT intLotId
				,intItemId
				,dblQty
				,intItemUOMId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,dblReservedQty
				,dtmDateCreated
			FROM @tblLot

			DELETE
			FROM @tblLot

			INSERT INTO @tblLot (
				intLotId
				,intItemId
				,dblQty
				,intItemUOMId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,dblReservedQty
				,dtmDateCreated
				)
			SELECT TOP 1 - 2 intLotId
				,intItemId
				,@dblAvailableQty
				,intItemUOMId
				,intLocationId
				,0 intSubLocationId
				,0 intStorageLocationId
				,@dblReservedQty
				,dtmDateCreated
			FROM @tblLotCopy
		END
	END

	SELECT @intMinLot = MIN(intRowNo)
	FROM @tblLot

	WHILE @intMinLot IS NOT NULL
	BEGIN
		SELECT @intLotId = intLotId
			,@dblAvailableQty = dblQty
			,@dblReservedQty = dblReservedQty
		FROM @tblLot
		WHERE intRowNo = @intMinLot

		IF @dblAvailableQty >= @dblRequiredQty
		BEGIN
			INSERT INTO @tblPickedLot (
				intLotId
				,intItemId
				,dblQty
				,intItemUOMId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,dblItemRequiredQty
				,dblAvailableQty
				,dblReservedQty
				)
			SELECT @intLotId
				,@intItemId
				,@dblRequiredQty
				,intItemUOMId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,@dblRequiredQty
				,@dblAvailableQty
				,@dblReservedQty
			FROM @tblLot
			WHERE intRowNo = @intMinLot

			GOTO NEXT_ITEM
		END
		ELSE
		BEGIN
			INSERT INTO @tblPickedLot (
				intLotId
				,intItemId
				,dblQty
				,intItemUOMId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,dblItemRequiredQty
				,dblAvailableQty
				,dblReservedQty
				)
			SELECT @intLotId
				,@intItemId
				,@dblAvailableQty
				,intItemUOMId
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,@dblAvailableQty
				,@dblAvailableQty
				,@dblReservedQty
			FROM @tblLot
			WHERE intRowNo = @intMinLot

			SET @dblRequiredQty = @dblRequiredQty - @dblAvailableQty
		END

		SELECT @intMinLot = MIN(intRowNo)
		FROM @tblLot
		WHERE intRowNo > @intMinLot
	END

	IF ISNULL(@dblRequiredQty, 0) > 0
		INSERT INTO @tblPickedLot (
			intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblItemRequiredQty
			,dblAvailableQty
			,dblReservedQty
			)
		SELECT 0
			,@intItemId
			,0
			,@intItemUOMId
			,@intLocationId
			,0
			,0
			,@dblRequiredQty
			,0.0
			,0.0

	NEXT_ITEM:

	SELECT @intMinItem = MIN(intRowNo)
	FROM @tblInputItem
	WHERE intRowNo > @intMinItem
END

SELECT p.intItemId
	,i.strItemNo
	,i.strDescription
	,p.intLotId
	,l.strLotNumber
	,p.intStorageLocationId
	,sl.strName AS strStorageLocationName
	,p.dblQty AS dblPickQuantity
	,p.intItemUOMId AS intPickUOMId
	,um.strUnitMeasure AS strPickUOM
	,pl.intParentLotId
	,pl.strParentLotNumber
	,p.intSubLocationId
	,sbl.strSubLocationName
	,p.intLocationId
	,i.strLotTracking
	,p.dblItemRequiredQty AS dblQuantity
	,p.intItemUOMId
	,um.strUnitMeasure AS strUOM
	,p.dblItemRequiredQty AS dblIssuedQuantity
	,p.intItemUOMId AS intItemIssuedUOMId
	,um.strUnitMeasure AS strIssuedUOM
	,p.dblAvailableQty
	,p.dblReservedQty
	,l.dblWeightPerQty AS dblWeightPerUnit
FROM @tblPickedLot p
JOIN tblICItem i ON p.intItemId = i.intItemId
LEFT JOIN tblICLot l ON p.intLotId = l.intLotId
LEFT JOIN tblICParentLot pl ON l.intParentLotId = pl.intParentLotId
LEFT JOIN tblICStorageLocation sl ON p.intStorageLocationId = sl.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation sbl ON p.intSubLocationId = sbl.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation cl ON p.intLocationId = cl.intCompanyLocationId
JOIN tblICItemUOM iu ON p.intItemUOMId = iu.intItemUOMId
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
