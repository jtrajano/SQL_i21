CREATE PROCEDURE dbo.uspMFGetItemRequirement @dtmStartDate DATETIME = NULL
	,@dtmEndDate DATETIME = NULL
	,@strManufacturingCellId NVARCHAR(MAX)
	,@intLocationId INT
	,@strWorkOrderId NVARCHAR(MAX) = ''
AS
BEGIN
	DECLARE @dtmCurrentDate DATETIME
	DECLARE @tblMFLot TABLE (
		intItemId INT
		,dblQty NUMERIC(18, 6)
		)
	DECLARE @tblInputItem TABLE (
		intItemId INT
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strShortName NVARCHAR(250) COLLATE Latin1_General_CI_AS
		,strDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblPlannedQty NUMERIC(18, 6)
		,intUnitMeasureId INT
		,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intConcurrencyId INT
		,intItemUOMId INT
		,strLotTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblInputItemReservation TABLE (
		intItemId INT
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strShortName NVARCHAR(250) COLLATE Latin1_General_CI_AS
		,strDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblPlannedQty NUMERIC(18, 6)
		,intUnitMeasureId INT
		,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intConcurrencyId INT
		,intItemUOMId INT
		,strLotTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblMFWorkOrder TABLE (
		intWorkOrderId INT
		,strWorkOrderNo NVARCHAR(50)
		)

	IF @strWorkOrderId = ''
	BEGIN
		INSERT INTO @tblMFWorkOrder
		EXEC dbo.uspMFGetWorkOrderByPlannedDate @dtmStartDate = @dtmStartDate
			,@dtmEndDate = @dtmEndDate
			,@strManufacturingCellId = @strManufacturingCellId
			,@intLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFWorkOrder (intWorkOrderId)
		SELECT Item
		FROM dbo.fnSplitString(@strWorkOrderId, ',')
	END

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101))

	SELECT @dtmStartDate = convert(DATETIME, Convert(CHAR, @dtmStartDate, 101))

	SELECT @dtmEndDate = convert(DATETIME, Convert(CHAR, @dtmEndDate, 101)) + 1

	IF EXISTS (
			SELECT *
			FROM tblMFSchedule
			WHERE ysnStandard = 1
			)
	BEGIN
		SELECT W.intWorkOrderId
			,W.strWorkOrderNo
			,W.strSalesOrderNo
			,W.strCustomerOrderNo
			,E.strName AS strCustomerName
			,'' AS strAdditive
			,I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,ROUND(SUM(SWD.dblPlannedQty), 0) dblPlannedQty
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,W.dtmExpectedDate
			,W.dtmEarliestDate
			,W.dtmLatestDate
			,SW.dtmPlannedStartDate
			,SW.dtmPlannedEndDate
			,SH.strShiftName
			,0 AS intConcurrencyId
		FROM dbo.tblMFSchedule S
		JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
			AND S.ysnStandard = 1
			AND S.intLocationId = @intLocationId
		JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
		JOIN @tblMFWorkOrder W1 ON W1.intWorkOrderId = SW.intWorkOrderId
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = W1.intWorkOrderId
			AND W.intStatusId <> 13
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblMFShift SH ON SH.intShiftId = SWD.intPlannedShiftId
		LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = W.intCustomerId
		WHERE (
				(
					SW.dtmPlannedStartDate >= @dtmStartDate
					AND SW.dtmPlannedEndDate <= @dtmEndDate
					)
				OR (
					@dtmStartDate BETWEEN SW.dtmPlannedStartDate
						AND SW.dtmPlannedEndDate
					OR @dtmEndDate BETWEEN SW.dtmPlannedStartDate
						AND SW.dtmPlannedEndDate
					)
				)
			AND W.intManufacturingCellId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strManufacturingCellId, ',')
				)
		GROUP BY W.intWorkOrderId
			,W.strWorkOrderNo
			,W.strSalesOrderNo
			,W.strCustomerOrderNo
			,E.strName
			,I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,W.dtmExpectedDate
			,W.dtmEarliestDate
			,W.dtmLatestDate
			,SW.dtmPlannedStartDate
			,SW.dtmPlannedEndDate
			,SH.strShiftName
		ORDER BY W.strSalesOrderNo

		INSERT INTO @tblInputItem (
			intItemId
			,strItemNo
			,strShortName
			,strDescription
			,dblPlannedQty
			,intUnitMeasureId
			,strUnitMeasure
			,intConcurrencyId
			,intItemUOMId
			,strLotTracking
			)
		SELECT DISTINCT I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,Round(SUM(SWD.dblPlannedQty * RI.dblCalculatedQuantity / R.dblQuantity), 0) AS dblPlannedQty
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,0 AS intConcurrencyId
			,RI.intItemUOMId
			,I.strLotTracking
		FROM dbo.tblMFSchedule S
		JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
			AND S.ysnStandard = 1
			AND S.intLocationId = @intLocationId
		JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
		JOIN @tblMFWorkOrder W1 ON W1.intWorkOrderId = SW.intWorkOrderId
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = W1.intWorkOrderId
			AND W.intStatusId <> 13
		JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
			AND R.intLocationId = @intLocationId
			AND R.ysnActive = 1
		JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
			AND RI.intRecipeItemTypeId = 1
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
			AND I.strType <> 'Other Charge'
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		WHERE (
				(
					SW.dtmPlannedStartDate >= @dtmStartDate
					AND SW.dtmPlannedEndDate <= @dtmEndDate
					)
				OR (
					@dtmStartDate BETWEEN SW.dtmPlannedStartDate
						AND SW.dtmPlannedEndDate
					OR @dtmEndDate BETWEEN SW.dtmPlannedStartDate
						AND SW.dtmPlannedEndDate
					)
				)
			AND W.intManufacturingCellId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strManufacturingCellId, ',')
				)
		GROUP BY I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,RI.intItemUOMId
			,I.strLotTracking
		ORDER BY I.strItemNo

		INSERT INTO @tblInputItemReservation (
			intItemId
			,strItemNo
			,strShortName
			,strDescription
			,dblPlannedQty
			,intUnitMeasureId
			,strUnitMeasure
			,intConcurrencyId
			,intItemUOMId
			,strLotTracking
			)
		SELECT DISTINCT I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,Round(SUM(SWD.dblPlannedQty * RI.dblCalculatedQuantity / R.dblQuantity), 0) AS dblPlannedQty
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,0 AS intConcurrencyId
			,RI.intItemUOMId
			,I.strLotTracking
		FROM dbo.tblMFSchedule S
		JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
			AND S.ysnStandard = 1
			AND S.intLocationId = @intLocationId
		JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
			AND W.intStatusId <> 13
		JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
			AND R.intLocationId = @intLocationId
			AND R.ysnActive = 1
		JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
			AND RI.intRecipeItemTypeId = 1
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
			AND I.strType <> 'Other Charge'
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		WHERE SW.dtmPlannedStartDate < @dtmStartDate
			AND W.intManufacturingCellId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strManufacturingCellId, ',')
				)
		GROUP BY I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,RI.intItemUOMId
			,I.strLotTracking
		ORDER BY I.strItemNo

		INSERT INTO @tblMFLot (
			intItemId
			,dblQty
			)
		SELECT I.intItemId
			,SUM(IsNULL((
						CASE 
							WHEN L.intWeightUOMId IS NULL
								THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty)
							ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, I.intItemUOMId, L.dblWeight)
							END
						), 0))
		FROM @tblInputItem I
		JOIN tblICLot L ON L.intItemId = I.intItemId
			AND I.strLotTracking <> 'No'
			AND L.intLotStatusId = 1
			AND ISNULL(L.dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate
			AND L.dblQty > 0
		GROUP BY I.intItemId

		INSERT INTO @tblMFLot (
			intItemId
			,dblQty
			)
		SELECT I.intItemId
			,SUM(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(S.intItemUOMId, I.intItemUOMId, S.dblOnHand), 0))
		FROM @tblInputItem I
		JOIN tblICItemStockUOM S ON S.intItemId = I.intItemId
			AND I.strLotTracking = 'No'
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
			AND IU.ysnStockUnit = 1
		JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
			AND S.dblOnHand > 0
			AND IL.intLocationId = @intLocationId
		GROUP BY I.intItemId

		UPDATE L
		SET dblQty = CASE 
				WHEN L.dblQty - IsNULL(R.dblPlannedQty, 0) > 0
					THEN L.dblQty - IsNULL(R.dblPlannedQty, 0)
				ELSE 0
				END
		FROM @tblMFLot L
		LEFT JOIN @tblInputItemReservation R ON L.intItemId = R.intItemId

		SELECT I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,I.dblPlannedQty
			,I.intUnitMeasureId
			,I.strUnitMeasure
			,I.intConcurrencyId
			,IsNULL(L.dblQty, 0) AS dblAvailableQty
			,CASE 
				WHEN I.dblPlannedQty - IsNULL(L.dblQty, 0) > 0
					THEN I.dblPlannedQty - IsNULL(L.dblQty, 0)
				ELSE 0
				END AS dblShortQty
		FROM @tblInputItem I
		LEFT JOIN @tblMFLot L ON L.intItemId = I.intItemId
	END
	ELSE
	BEGIN
		SELECT W.intWorkOrderId
			,W.strWorkOrderNo
			,W.strSalesOrderNo
			,W.strCustomerOrderNo
			,E.strName AS strCustomerName
			,'' AS strAdditive
			,I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,ROUND(SUM(CASE 
						WHEN (W.dblQuantity - W.dblProducedQuantity) > 0
							THEN (W.dblQuantity - W.dblProducedQuantity)
						ELSE 0
						END), 0) dblPlannedQty
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,W.dtmExpectedDate
			,W.dtmEarliestDate
			,W.dtmLatestDate
			,W.dtmPlannedDate AS dtmPlannedStartDate
			,W.dtmPlannedDate AS dtmPlannedEndDate
			,SH.strShiftName
			,0 AS intConcurrencyId
		FROM dbo.tblMFWorkOrder W
		JOIN @tblMFWorkOrder W1 ON W1.intWorkOrderId = W.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
			AND W.intStatusId <> 13
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblMFShift SH ON SH.intShiftId = W.intPlannedShiftId
		LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = W.intCustomerId
		WHERE (
				W.dtmPlannedDate >= @dtmStartDate
				AND W.dtmPlannedDate <= @dtmEndDate
				)
			AND W.intManufacturingCellId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strManufacturingCellId, ',')
				)
		GROUP BY W.intWorkOrderId
			,W.strWorkOrderNo
			,W.strSalesOrderNo
			,W.strCustomerOrderNo
			,E.strName
			,I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,W.dtmExpectedDate
			,W.dtmEarliestDate
			,W.dtmLatestDate
			,W.dtmPlannedDate
			,SH.strShiftName
		ORDER BY W.strSalesOrderNo

		INSERT INTO @tblInputItem (
			intItemId
			,strItemNo
			,strShortName
			,strDescription
			,dblPlannedQty
			,intUnitMeasureId
			,strUnitMeasure
			,intConcurrencyId
			,intItemUOMId
			,strLotTracking
			)
		SELECT DISTINCT I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,Round(SUM(CASE 
						WHEN (W.dblQuantity - W.dblProducedQuantity) > 0
							THEN (W.dblQuantity - W.dblProducedQuantity) * RI.dblCalculatedQuantity / R.dblQuantity
						ELSE 0
						END), 0) AS dblPlannedQty
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,0 AS intConcurrencyId
			,RI.intItemUOMId
			,I.strLotTracking
		FROM dbo.tblMFWorkOrder W
		JOIN @tblMFWorkOrder W1 ON W1.intWorkOrderId = W.intWorkOrderId
		JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
			AND W.intStatusId <> 13
			AND R.intLocationId = @intLocationId
			AND R.ysnActive = 1
		JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
			AND RI.intRecipeItemTypeId = 1
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
			AND I.strType <> 'Other Charge'
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		WHERE (
				W.dtmPlannedDate >= @dtmStartDate
				AND W.dtmPlannedDate <= @dtmEndDate
				)
			AND W.intManufacturingCellId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strManufacturingCellId, ',')
				)
		GROUP BY I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,RI.intItemUOMId
			,I.strLotTracking
		ORDER BY I.strItemNo

		INSERT INTO @tblInputItemReservation (
			intItemId
			,strItemNo
			,strShortName
			,strDescription
			,dblPlannedQty
			,intUnitMeasureId
			,strUnitMeasure
			,intConcurrencyId
			,intItemUOMId
			,strLotTracking
			)
		SELECT DISTINCT I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,Round(SUM(CASE 
						WHEN (W.dblQuantity - W.dblProducedQuantity) > 0
							THEN (W.dblQuantity - W.dblProducedQuantity) * RI.dblCalculatedQuantity / R.dblQuantity
						ELSE 0
						END), 0) AS dblPlannedQty
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,0 AS intConcurrencyId
			,RI.intItemUOMId
			,I.strLotTracking
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
			AND W.intStatusId <> 13
			AND R.intLocationId = @intLocationId
			AND R.ysnActive = 1
		JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
			AND RI.intRecipeItemTypeId = 1
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
			AND I.strType <> 'Other Charge'
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		WHERE W.dtmPlannedDate < @dtmStartDate
			AND W.intManufacturingCellId IN (
				SELECT Item
				FROM dbo.fnSplitString(@strManufacturingCellId, ',')
				)
		GROUP BY I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,UM.intUnitMeasureId
			,UM.strUnitMeasure
			,RI.intItemUOMId
			,I.strLotTracking
		ORDER BY I.strItemNo

		INSERT INTO @tblMFLot (
			intItemId
			,dblQty
			)
		SELECT I.intItemId
			,SUM(IsNULL((
						CASE 
							WHEN L.intWeightUOMId IS NULL
								THEN dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, I.intItemUOMId, L.dblQty)
							ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intWeightUOMId, I.intItemUOMId, L.dblWeight)
							END
						), 0))
		FROM @tblInputItem I
		JOIN tblICLot L ON L.intItemId = I.intItemId
			AND I.strLotTracking <> 'No'
			AND L.intLotStatusId = 1
			AND ISNULL(L.dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate
			AND L.dblQty > 0
		GROUP BY I.intItemId

		INSERT INTO @tblMFLot (
			intItemId
			,dblQty
			)
		SELECT I.intItemId
			,SUM(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(S.intItemUOMId, I.intItemUOMId, S.dblOnHand), 0))
		FROM @tblInputItem I
		JOIN tblICItemStockUOM S ON S.intItemId = I.intItemId
			AND I.strLotTracking = 'No'
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
			AND IU.ysnStockUnit = 1
		JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
			AND IL.intItemId = I.intItemId
			AND S.dblOnHand > 0
			AND IL.intLocationId = @intLocationId
		GROUP BY I.intItemId

		UPDATE L
		SET dblQty = CASE 
				WHEN L.dblQty - IsNULL(R.dblPlannedQty, 0) > 0
					THEN L.dblQty - IsNULL(R.dblPlannedQty, 0)
				ELSE 0
				END
		FROM @tblMFLot L
		LEFT JOIN @tblInputItemReservation R ON L.intItemId = R.intItemId

		SELECT I.intItemId
			,I.strItemNo
			,I.strShortName
			,I.strDescription
			,I.dblPlannedQty
			,I.intUnitMeasureId
			,I.strUnitMeasure
			,I.intConcurrencyId
			,IsNULL(L.dblQty, 0) AS dblAvailableQty
			,CASE 
				WHEN I.dblPlannedQty - IsNULL(L.dblQty, 0) > 0
					THEN - (I.dblPlannedQty - IsNULL(L.dblQty, 0))
				ELSE 0
				END AS dblShortQty
		FROM @tblInputItem I
		LEFT JOIN @tblMFLot L ON L.intItemId = I.intItemId
	END
END
