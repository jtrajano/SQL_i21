CREATE TRIGGER trgAfterInsertUpdatetblMFWorkOrder ON tblMFWorkOrder
AFTER INSERT
	,UPDATE
AS
DECLARE @dtmCurrentDate DATETIME
	,@intDayOfYear INT
	,@strPackagingCategory NVARCHAR(50)
	,@intPackagingCategoryId INT
	,@intPMCategoryId INT
	,@intManufacturingProcessId INT
	,@intLocationId INT
	,@dblQuantity NUMERIC(18, 6)
	,@intItemId INT
	,@strMinQtyCanBeProduced NVARCHAR(50)
	,@strItemNo NVARCHAR(50)
	,@intItemUOMId INT
	,@intUnitMeasureId INT
	,@strUnitMeasure NVARCHAR(50)
	,@strAvailableQty NVARCHAR(50)
	,@strRequiredQty NVARCHAR(50)
	,@intWorkOrderId INT
	,@intStatusId INT
	,@intPrevStatusId INT
	,@intUserId INT
	,@strReferenceNo NVARCHAR(50)
	,@ysnNotifyInventoryShortOnReleaseWorkOrder BIT
	,@ysnNotifyInventoryShortOnCreateWorkOrder BIT

	DECLARE @tblSubstituteItem TABLE (
		intItemRecordId INT Identity(1, 1)
		,intItemId INT
		,intSubstituteItemId INT
		,dblSubstituteRatio NUMERIC(18, 6)
		,dblMaxSubstituteRatio NUMERIC(18, 6)
		)

SELECT @intWorkOrderId = intWorkOrderId
	,@intStatusId = intStatusId
	,@intUserId = intLastModifiedUserId
	,@strReferenceNo = CASE 
		WHEN strReferenceNo <> ''
			THEN strReferenceNo
		ELSE strWorkOrderNo
		END
FROM INSERTED

SELECT @intPrevStatusId = intStatusId
FROM Deleted

IF NOT (
		(
			@intPrevStatusId IS NULL
			AND @intStatusId = 1
			)
		OR (
			@intPrevStatusId = 1
			AND @intStatusId = 9
			)
		)
BEGIN
	RETURN
END

SELECT @ysnNotifyInventoryShortOnCreateWorkOrder = ysnNotifyInventoryShortOnCreateWorkOrder
	,@ysnNotifyInventoryShortOnReleaseWorkOrder = ysnNotifyInventoryShortOnReleaseWorkOrder
FROM tblMFCompanyPreference

IF (
		@intPrevStatusId IS NULL
		AND @intStatusId = 1
		)
	AND @ysnNotifyInventoryShortOnCreateWorkOrder = 0
BEGIN
	RETURN
END

IF (
		@intPrevStatusId = 1
		AND @intStatusId = 9
		)
	AND @ysnNotifyInventoryShortOnReleaseWorkOrder = 0
BEGIN
	RETURN
END

--SELECT @intWorkOrderId=31
SELECT @dtmCurrentDate = GetDate()

SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDate)

SELECT @intManufacturingProcessId = intManufacturingProcessId
	,@intLocationId = intLocationId
	,@intItemId = intItemId
	,@dblQuantity = dblQuantity
	,@intItemUOMId = intItemUOMId
FROM tblMFWorkOrder
WHERE intWorkOrderId = @intWorkOrderId

SELECT @intPackagingCategoryId = intAttributeId
FROM tblMFAttribute
WHERE strAttributeName = 'Packaging Category'

SELECT @strPackagingCategory = strAttributeValue
FROM tblMFManufacturingProcessAttribute
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND intAttributeId = @intPackagingCategoryId

SELECT @intPMCategoryId = intCategoryId
FROM tblICCategory
WHERE strCategoryCode = @strPackagingCategory

DECLARE @tblMFItem TABLE (
	intItemId INT
	,dblQuantity NUMERIC(38, 20)
	,intItemUOMId INT
	,dblRequiredQtyByCase NUMERIC(38, 20)
	)
DECLARE @tblMFPlannedItem TABLE (
	intItemId INT
	,dblQuantity NUMERIC(38, 20)
	,intItemUOMId INT
	)

INSERT INTO @tblMFItem (
	intItemId
	,dblQuantity
	,intItemUOMId
	,dblRequiredQtyByCase
	)
SELECT ri.intItemId
	,CASE 
		WHEN C.strCategoryCode = @strPackagingCategory
			THEN CAST(CEILING((ri.dblCalculatedQuantity * (@dblQuantity / r.dblQuantity))) AS NUMERIC(38, 2))
		ELSE (ri.dblCalculatedQuantity * (@dblQuantity / r.dblQuantity))
		END
	,ri.intItemUOMId
	,CASE 
		WHEN C.strCategoryCode = @strPackagingCategory
			THEN CAST(CEILING((ri.dblCalculatedQuantity / r.dblQuantity)) AS NUMERIC(38, 2))
		ELSE (ri.dblCalculatedQuantity / r.dblQuantity)
		END
FROM dbo.tblMFRecipeItem ri
JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	AND r.ysnActive = 1
	AND r.intLocationId = @intLocationId
JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
WHERE ri.intRecipeItemTypeId = 1
	AND (
		(
			ri.ysnYearValidationRequired = 1
			AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
				AND ri.dtmValidTo
			)
		OR (
			ri.ysnYearValidationRequired = 0
			AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
				AND DATEPART(dy, ri.dtmValidTo)
			)
		)
	AND ri.intConsumptionMethodId <> 4
	AND r.intItemId = @intItemId

	INSERT INTO @tblSubstituteItem (
			intItemId
			,intSubstituteItemId
			,dblSubstituteRatio
			,dblMaxSubstituteRatio
			)
		SELECT ri.intItemId
			,rs.intSubstituteItemId
			,dblSubstituteRatio
			,dblMaxSubstituteRatio
		FROM dbo.tblMFRecipe r
		JOIN dbo.tblMFRecipeItem ri ON r.intRecipeId =ri.intRecipeId
		JOIN dbo.tblMFRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
			AND r.ysnActive = 1
			AND r.intLocationId = @intLocationId
			AND r.intItemId = @intItemId
		WHERE ri.intRecipeItemTypeId = 1
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND ri.intConsumptionMethodId <> 4

DECLARE @tblMFAvlQty TABLE (
	intItemId INT
	,dblQuantity DECIMAL(38, 20)
	,intItemUOMId INT
	)

INSERT INTO @tblMFAvlQty (
	intItemId
	,dblQuantity
	,intItemUOMId
	)
SELECT I.intItemId
	,IsNULL(sum(CASE 
				WHEN L.intWeightUOMId IS NULL
					THEN L.dblQty
				ELSE L.dblWeight
				END), 0)
	,IsNULL(L.intWeightUOMId, L.intItemUOMId)
FROM @tblMFItem I
LEFT JOIN dbo.tblICLot L ON L.intItemId = I.intItemId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
	AND R.strInternalCode = 'STOCK'
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
	AND BS.strPrimaryStatus = 'Active'
JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	AND LS.strPrimaryStatus = 'Active'
	AND L.intLotStatusId = 1
	AND L.dtmExpiryDate > GetDate()
GROUP BY I.intItemId
	,IsNULL(L.intWeightUOMId, L.intItemUOMId)

	DECLARE @tblMFAvlSubQty TABLE (
	intItemId INT
	,dblQuantity DECIMAL(38, 20)
	,intItemUOMId INT
	)
	INSERT INTO @tblMFAvlSubQty (
	intItemId
	,dblQuantity
	,intItemUOMId
	)
SELECT I.intItemId
	,IsNULL(sum(CASE 
				WHEN L.intWeightUOMId IS NULL
					THEN L.dblQty
				ELSE L.dblWeight
				END), 0)
	,IsNULL(L.intWeightUOMId, L.intItemUOMId)
FROM @tblSubstituteItem I
LEFT JOIN dbo.tblICLot L ON L.intItemId = I.intSubstituteItemId
JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
	AND R.strInternalCode = 'STOCK'
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
	AND BS.strPrimaryStatus = 'Active'
JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
	AND LS.strPrimaryStatus = 'Active'
	AND L.intLotStatusId = 1
	AND L.dtmExpiryDate > GetDate()
GROUP BY I.intItemId
	,IsNULL(L.intWeightUOMId, L.intItemUOMId)

INSERT INTO @tblMFPlannedItem (
	intItemId
	,dblQuantity
	,intItemUOMId
	)
SELECT ri.intItemId
	,SUM(CASE 
			WHEN C.strCategoryCode = @strPackagingCategory
				THEN CAST(CEILING((ri.dblCalculatedQuantity * (W.dblQuantity / r.dblQuantity))) AS NUMERIC(38, 2))
			ELSE (ri.dblCalculatedQuantity * (W.dblQuantity / r.dblQuantity))
			END)
	,ri.intItemUOMId
FROM dbo.tblMFRecipeItem ri
JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	AND r.ysnActive = 1
	AND r.intLocationId = @intLocationId
JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
JOIN dbo.tblMFWorkOrder W ON W.intItemId = r.intItemId
	AND W.intStatusId IN (
		9
		,10
		)
	AND W.intWorkOrderId <> @intWorkOrderId
JOIN @tblMFItem PI1 ON PI1.intItemId = ri.intItemId
WHERE ri.intRecipeItemTypeId = 1
	AND (
		(
			ri.ysnYearValidationRequired = 1
			AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
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
		)
GROUP BY ri.intItemId
	,ri.intItemUOMId

DECLARE @tblMFFinalAvlQty TABLE (
	intItemId INT
	,dblQuantity DECIMAL(38, 20)
	,intItemUOMId INT
	)

INSERT INTO @tblMFFinalAvlQty (
	intItemId
	,dblQuantity
	,intItemUOMId
	)
SELECT Q.intItemId
	,CASE 
		WHEN Q.dblQuantity - IsNULL(PI1.dblQuantity, 0) > 0
			THEN Q.dblQuantity - IsNULL(PI1.dblQuantity, 0)
		ELSE 0
		END
	,Q.intItemUOMId
FROM @tblMFAvlQty Q
LEFT JOIN @tblMFPlannedItem PI1 ON PI1.intItemId = Q.intItemId

IF EXISTS (
		SELECT *
		FROM @tblMFItem I
		LEFT JOIN @tblMFFinalAvlQty Inv ON Inv.intItemId = I.intItemId
		WHERE I.dblQuantity - IsNull(Inv.dblQuantity, 0) > 0
		)
BEGIN
	SELECT @intItemId = I.intItemId
		,@strMinQtyCanBeProduced = Convert(DECIMAL(38, 2), Min(IsNull(Inv.dblQuantity, 0) / dblRequiredQtyByCase))
		,@strRequiredQty = Convert(DECIMAL(38, 2), MIn(I.dblQuantity))
		,@strAvailableQty = Convert(DECIMAL(38, 2), MIn(IsNull(Inv.dblQuantity, 0)))
	FROM @tblMFItem I
	LEFT JOIN @tblMFFinalAvlQty Inv ON Inv.intItemId = I.intItemId
	WHERE I.dblQuantity - IsNull(Inv.dblQuantity, 0) > 0
	GROUP BY I.intItemId
		,I.intItemUOMId

	BEGIN TRY
		DECLARE @tableHTML VARCHAR(MAX)
			,@Result INT
			,@subject NVARCHAR(400)
			,@strEmail NVARCHAR(MAX)
			,@strName NVARCHAR(50)

		IF @intPrevStatusId IS NULL
			AND @intStatusId = 1
		BEGIN
			SET @subject = 'Alert: Inventory shortage for Work Order ' + @strReferenceNo
			SET @tableHTML = N'<head><style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style></head><body><FONT COLOR="#4682B4"> ' + ' Inventory shortage for Work Order ' + @strReferenceNo + '</FONT>'
			SET @tableHTML = @tableHTML + N'<table border="1">' + N'<tr bgcolor="#F0E68C" style="text-align:center;"><FONT COLOR="#4682B4"><th>Item</th><th>Item Desc</th><th>Available Qty</th>' + N'<th>Required Qty</th><th>UOM</th></tr>'

			SELECT @tableHTML = @tableHTML + (
					CASE 
						WHEN I.dblQuantity - IsNull(Inv.dblQuantity, 0) > 0
							THEN '<tr bgcolor="#ffb3b3"><td>'
						ELSE '<tr><td>'
						END
					) + I1.strItemNo + '</td><td>' + I1.strDescription + '</td><td style="text-align:right;">' + Ltrim(Convert(DECIMAL(38, 2), IsNull(Inv.dblQuantity, 0))) + '</td><td style="text-align:right;">' + Ltrim(Convert(DECIMAL(38, 2), I.dblQuantity)) + '</td><td>' + U.strUnitMeasure + '</td></tr>'
			FROM @tblMFItem I
			JOIN tblICItem I1 ON I1.intItemId = I.intItemId
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = I.intItemUOMId
			JOIN tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
			LEFT JOIN @tblMFFinalAvlQty Inv ON Inv.intItemId = I.intItemId

			SET @tableHTML = @tableHTML + N'</table>';
			SET @tableHTML = @tableHTML + '<br></br><FONT COLOR="#4682B4">This is an automatic e-mail generated by i21 system.</FONT>'

			SELECT @strName = strName
			FROM tblEMEntity
			WHERE intEntityId = @intUserId

			SELECT @strEmail = IsNULL(strEmail, '')
			FROM tblEMEntity
			WHERE strName = @strName
				AND strEmail <> ''

			IF @strEmail <> ''
			BEGIN
				EXEC @Result = msdb.dbo.sp_send_dbmail @recipients = @strEmail
					,@copy_recipients = NULL
					,@subject = @subject
					,@body = @tableHTML
					,@importance = 'High'
					,@body_format = 'HTML'
			END
		END
	END TRY

	BEGIN CATCH
	END CATCH

	IF @intPrevStatusId = 1
		AND @intStatusId = 9
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM tblICItem
		WHERE intItemId = @intItemId

		SELECT @intUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intItemUOMId

		SELECT @strUnitMeasure = strUnitMeasure
		FROM tblICUnitMeasure
		WHERE intUnitMeasureId = @intUnitMeasureId

		SELECT @strMinQtyCanBeProduced = @strMinQtyCanBeProduced + ' ' + @strUnitMeasure

		RAISERROR (
				'Available qty for item %s is %s which is less than the required qty %s. %s can be produced with the available inputs. Please change the work order quantity and try again.'
				,11
				,1
				,@strItemNo
				,@strAvailableQty
				,@strRequiredQty
				,@strMinQtyCanBeProduced
				)

		RETURN
	END
END
