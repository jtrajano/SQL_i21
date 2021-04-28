﻿CREATE PROCEDURE [dbo].uspMFReportItemPlanSummary @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strItemNo NVARCHAR(50)
		,@xmlDocumentId INT
		,@strBlendAttributeValue NVARCHAR(MAX)
		,@strProcessName NVARCHAR(50)
		,@intManufacturingProcessId INT
		,@intCompanyLocationId INT
		,@strCompanyLocationName NVARCHAR(50)
		,@intLocationId INT

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
			[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @strItemNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strItemNo'

	IF @strItemNo = ''
		OR @strItemNo IS NULL
	BEGIN
		SELECT @strItemNo = '%'
	END

	SELECT @strProcessName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strProcessName'

	SELECT @strCompanyLocationName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strLocationName'

	IF @strCompanyLocationName IS NULL
		SELECT @strCompanyLocationName = ''

	IF IsNULL(@strProcessName, '') <> ''
	BEGIN
		SELECT @strBlendAttributeValue = ''

		SELECT @intLocationId = intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE strLocationName = @strCompanyLocationName

		SELECT @strBlendAttributeValue = @strBlendAttributeValue + strAttributeValue + ','
		FROM tblMFManufacturingProcessAttribute
		WHERE intAttributeId = 78 --Category for Ingredient Demand Report
			AND intLocationId = CASE 
				WHEN @intLocationId IS NOT NULL
					THEN @intLocationId
				ELSE intLocationId
				END
			AND intManufacturingProcessId IN (
				SELECT intManufacturingProcessId
				FROM tblMFManufacturingProcess
				WHERE strProcessName = @strProcessName
				)

		IF len(@strBlendAttributeValue) > 0
		BEGIN
			SELECT @strBlendAttributeValue = Left(@strBlendAttributeValue, len(@strBlendAttributeValue) - 1)
		END

		IF @strBlendAttributeValue IS NULL
			OR @strBlendAttributeValue = ''
		BEGIN
			SELECT @strBlendAttributeValue = ''

			SELECT @strBlendAttributeValue = @strBlendAttributeValue + strCategoryCode + ','
			FROM tblICCategory
		END
	END
	ELSE
	BEGIN
		SELECT @strBlendAttributeValue = ''

		SELECT @strBlendAttributeValue = @strBlendAttributeValue + strCategoryCode + ','
		FROM tblICCategory
	END

	DECLARE @strSQL NVARCHAR(Max)
		,@dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intRecordId INT
		,@dblRunningTotal DECIMAL(24, 10)
		,@dblMaxPoundsRequired DECIMAL(24, 10)
		,@intItemId NUMERIC(18, 0)
		,@intPrevItemId NUMERIC(18, 0)
		,@dblUnPackedPounds NUMERIC(24, 10)
		,@dblAvailablePounds NUMERIC(24, 10)
		,@intNextMonth INT
	DECLARE @tblMFMonth TABLE (
		intMonthId INT
		,strMonthName NVARCHAR(50)
		,intYearName INT
		)
	DECLARE @tblMFItemPlan TABLE (
		intMonthId INT
		,strStartingMonth NVARCHAR(50)
		,strItemNo NVARCHAR(50)
		,strDescription NVARCHAR(100)
		,strCompanyLocationName NVARCHAR(50)
		,dblMaxPoundsRequired NUMERIC(38, 20)
		,intItemId INT
		,dblSafetyStockPounds NUMERIC(38, 20)
		,dblUnPackedPounds NUMERIC(38, 20)
		,dblPoundsAvailable NUMERIC(38, 20)
		,dblTotalPoundsAvailable NUMERIC(38, 20)
		,strComments NVARCHAR(250)
		,dblRunningTotal NUMERIC(38, 20)
		,dblAvlQtyBreakUp NUMERIC(38, 20)
		,intCompanyLocationId INT
		,dblUnpackedBreakUp NUMERIC(38, 20)
		,dblAvlBreakup NUMERIC(38, 20)
		,strStartingYear NVARCHAR(50)
		)
	DECLARE @tblMFItemPlanSummary TABLE (
		intRecordId INT IDENTITY(1, 1)
		,intMonthId INT
		,strStartingMonth NVARCHAR(50)
		,strItemNo NVARCHAR(50)
		,strDescription NVARCHAR(100)
		,strCompanyLocationName NVARCHAR(50)
		,dblMaxPoundsRequired NUMERIC(38, 20)
		,intItemId INT
		,dblSafetyStockPounds NUMERIC(38, 20)
		,dblUnPackedPounds NUMERIC(38, 20)
		,dblPoundsAvailable NUMERIC(38, 20)
		,dblTotalPoundsAvailable NUMERIC(38, 20)
		,strComments NVARCHAR(250)
		,dblRunningTotal NUMERIC(38, 20)
		,dblAvlQtyBreakUp NUMERIC(38, 20)
		,intCompanyLocationId INT
		,dblUnpackedBreakUp NUMERIC(38, 20)
		,dblAvlBreakup NUMERIC(38, 20)
		,strStartingYear NVARCHAR(50)
		)

	SET @dtmCurrentDateTime = GetDate()

	SELECT @intCompanyLocationId = MIN(intCompanyLocationId)
	FROM dbo.tblSMCompanyLocation
	WHERE strLocationName = CASE 
			WHEN LTRIM(RTRIM(@strCompanyLocationName)) = ''
				THEN strLocationName
			ELSE @strCompanyLocationName
			END
	AND ysnLocationActive=1

	SET @dtmCurrentDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intCompanyLocationId)

	WHILE @intCompanyLocationId > 0
	BEGIN
		IF EXISTS (
				SELECT *
				FROM tblMFSchedule
				WHERE ysnStandard = 1
				)
		BEGIN
			INSERT INTO @tblMFItemPlan
			SELECT DATEPART(Month, CD.dtmShiftStartTime) intMonthId
				,DATENAME(Month, CD.dtmShiftStartTime) dtmShiftStartTime
				,II.strItemNo
				,II.strDescription
				,CL.strLocationName
				,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(RI.intItemUOMId, IU.intItemUOMId, (RI.dblCalculatedQuantity * SWD.dblPlannedQty))) dblMaxPoundsRequired
				,II.intItemId
				,0 dblSafetyStockPounds
				,0 dblUnPackedPounds
				,0 dblPoundsAvailable
				,0 dblTotalPoundsAvailable
				,'' strWorkInstruction
				,0 dblRunningTotal
				,0 dblAvlQtyBreakUp
				,CL.intCompanyLocationId
				,0 dblUnpackedBreakUp
				,0 dblAvlBreakup
				,DATEPART(YEAR, CD.dtmShiftStartTime) strStartingYear
			FROM dbo.tblMFSchedule S
			JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
				AND SW.intStatusId <> 13
			JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
			JOIN dbo.tblMFScheduleCalendarDetail CD ON CD.intCalendarDetailId = SWD.intCalendarDetailId
			JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = S.intManufacturingCellId
			JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
			JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
			JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
				AND R.intLocationId = W.intLocationId
				AND R.ysnActive = 1
			JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				AND RI.intRecipeItemTypeId = 1
			JOIN dbo.tblICItem II ON II.intItemId = RI.intItemId
			JOIN dbo.tblICCategory C ON C.intCategoryId = II.intCategoryId
				AND C.strCategoryCode IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strBlendAttributeValue, ',')
					)
			JOIN tblICItemUOM IU ON IU.intItemId = II.intItemId
				AND IU.ysnStockUnit = 1
				AND S.intLocationId = @intCompanyLocationId
			WHERE S.ysnStandard = 1
				AND CD.dtmCalendarDate >= @dtmCurrentDate
			GROUP BY DATEPART(MONTH, CD.dtmShiftStartTime)
				,CD.dtmShiftStartTime
				,II.strItemNo
				,II.strDescription
				,CL.strLocationName
				,II.intItemId
				--,II.strWorkInstruction
				,CL.intCompanyLocationId
				,DATEPART(YEAR, CD.dtmShiftStartTime)
			ORDER BY strItemNo
				,strStartingYear
				,intMonthId
		END
		ELSE
		BEGIN
			INSERT INTO @tblMFItemPlan
			SELECT DATEPART(Month, W.dtmPlannedDate) intMonthId
				,DATENAME(Month, W.dtmPlannedDate) dtmShiftStartTime
				,II.strItemNo
				,II.strDescription
				,CL.strLocationName
				,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(RI.intItemUOMId, IU.intItemUOMId, (RI.dblCalculatedQuantity * dbo.fnMFConvertQuantityToTargetItemUOM(W.intItemUOMId, R.intItemUOMId, (W.dblQuantity - W.dblProducedQuantity))  / R.dblQuantity))) dblMaxPoundsRequired
				,II.intItemId
				,0 dblSafetyStockPounds
				,0 dblUnPackedPounds
				,0 dblPoundsAvailable
				,0 dblTotalPoundsAvailable
				,'' strWorkInstruction
				,0 dblRunningTotal
				,0 dblAvlQtyBreakUp
				,CL.intCompanyLocationId
				,0 dblUnpackedBreakUp
				,0 dblAvlBreakup
				,DATEPART(YEAR, W.dtmPlannedDate) strStartingYear
			FROM dbo.tblMFManufacturingCell MC
			JOIN dbo.tblMFWorkOrder W ON MC.intManufacturingCellId = W.intManufacturingCellId
			JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
			JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
				AND R.intLocationId = W.intLocationId
				AND R.ysnActive = 1
			JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
				AND RI.intRecipeItemTypeId = 1
			JOIN dbo.tblICItem II ON II.intItemId = RI.intItemId
			JOIN dbo.tblICCategory C ON C.intCategoryId = II.intCategoryId
				AND C.strCategoryCode IN (
					SELECT Item Collate Latin1_General_CI_AS
					FROM [dbo].[fnSplitString](@strBlendAttributeValue, ',')
					)
			JOIN tblICItemUOM IU ON IU.intItemId = II.intItemId
				AND IU.ysnStockUnit = 1
			WHERE W.dtmPlannedDate >= @dtmCurrentDate
				AND W.dblQuantity - W.dblProducedQuantity > 0
				AND W.intLocationId = @intCompanyLocationId
			GROUP BY DATEPART(MONTH, W.dtmPlannedDate)
				,W.dtmPlannedDate
				,II.strItemNo
				,II.strDescription
				,CL.strLocationName
				,II.intItemId
				--,II.strWorkInstruction
				,CL.intCompanyLocationId
				,DATEPART(YEAR, W.dtmPlannedDate)
			ORDER BY strItemNo
				,strStartingYear
				,intMonthId

			INSERT INTO @tblMFItemPlan
			SELECT DATEPART(Month, InvS.dtmShipDate) intMonthId
				,DATENAME(Month, InvS.dtmShipDate) dtmShiftStartTime
				,I.strItemNo
				,I.strDescription
				,CL.strLocationName
				,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(InvI.intItemUOMId, IU.intItemUOMId, InvI.dblQuantity)) dblMaxPoundsRequired
				,I.intItemId
				,0 dblSafetyStockPounds
				,0 dblUnPackedPounds
				,0 dblPoundsAvailable
				,0 dblTotalPoundsAvailable
				,'' strWorkInstruction
				,0 dblRunningTotal
				,0 dblAvlQtyBreakUp
				,CL.intCompanyLocationId
				,0 dblUnpackedBreakUp
				,0 dblAvlBreakup
				,DATEPART(YEAR, InvS.dtmShipDate) strStartingYear
			FROM tblICInventoryShipment InvS
			JOIN tblICInventoryShipmentItem InvI ON InvI.intInventoryShipmentId = InvS.intInventoryShipmentId
			JOIN dbo.tblICItem I ON I.intItemId = InvI.intItemId
			JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = InvS.intShipFromLocationId
			JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND IU.ysnStockUnit = 1
			WHERE InvS.ysnPosted = 0
				AND I.strManufactureType = 'Raw Material'
				AND InvS.dtmShipDate >= @dtmCurrentDate
				AND InvS.intShipFromLocationId = @intCompanyLocationId
			GROUP BY DATEPART(Month, InvS.dtmShipDate)
				,DATENAME(Month, InvS.dtmShipDate)
				,I.strItemNo
				,I.strDescription
				,CL.strLocationName
				,I.intItemId
				,CL.intCompanyLocationId
				,DATEPART(YEAR, InvS.dtmShipDate)
		END

		SELECT @intCompanyLocationId = MIN(intCompanyLocationId)
		FROM dbo.tblSMCompanyLocation
		WHERE intCompanyLocationId > @intCompanyLocationId
			AND strLocationName = CASE 
				WHEN LTRIM(RTRIM(@strCompanyLocationName)) = ''
					THEN strLocationName
				ELSE @strCompanyLocationName
				END
		AND ysnLocationActive=1
	END

	INSERT INTO @tblMFItemPlanSummary
	SELECT intMonthId
		,strStartingMonth
		,strItemNo
		,strDescription
		,strCompanyLocationName
		,SUM(dblMaxPoundsRequired)
		,intItemId
		,dblSafetyStockPounds
		,dblUnPackedPounds
		,dblPoundsAvailable
		,dblTotalPoundsAvailable
		,strComments
		,dblRunningTotal
		,dblAvlQtyBreakUp
		,intCompanyLocationId
		,dblUnpackedBreakUp
		,dblAvlBreakup
		,strStartingYear
	FROM @tblMFItemPlan
	GROUP BY intMonthId
		,strStartingMonth
		,strItemNo
		,strDescription
		,strCompanyLocationName
		,intItemId
		,dblSafetyStockPounds
		,dblUnPackedPounds
		,dblPoundsAvailable
		,dblTotalPoundsAvailable
		,strComments
		,dblRunningTotal
		,dblAvlQtyBreakUp
		,intCompanyLocationId
		,dblUnpackedBreakUp
		,dblAvlBreakup
		,strStartingYear

	DECLARE @tblMFQtyOnHand TABLE (
		intCompanyLocationId INT
		,intItemId INT
		,dblWeight NUMERIC(38, 20)
		)

	INSERT INTO @tblMFQtyOnHand
	SELECT L.intLocationId AS intCompanyLocationId
		,I.intItemId
		,Sum(dbo.fnMFConvertQuantityToTargetItemUOM(IsNULL(L.intWeightUOMId, L.intItemUOMId), IU.intItemUOMId, (
					CASE 
						WHEN L.intWeightUOMId IS NOT NULL
							THEN L.dblWeight
						ELSE L.dblQty
						END
					))) AS dblWeight
	FROM @tblMFItemPlanSummary I
	JOIN dbo.tblICLot L ON I.intItemId = L.intItemId
	JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
	JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
	JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
		AND BS.strPrimaryStatus = 'Active'
	JOIN tblICItemUOM IU ON IU.intItemId = L.intItemId
		AND IU.ysnStockUnit = 1
	WHERE L.intLotStatusId = 1
		AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
		AND CSL.strSubLocationName <> 'Intrasit'
	GROUP BY L.intLocationId
		,I.intItemId

	UPDATE I
	SET dblUnPackedPounds = Q.dblWeight
	FROM @tblMFItemPlanSummary I
	JOIN @tblMFQtyOnHand Q ON Q.intItemId = I.intItemId
		AND I.intCompanyLocationId = Q.intCompanyLocationId

	DECLARE @tblMFQtyInProduction TABLE (
		intCompanyLocationId INT
		,intItemId INT
		,dblWeight NUMERIC(38, 20)
		)

	INSERT INTO @tblMFQtyInProduction
	SELECT W.intLocationId AS intCompanyLocationId
		,I.intItemId
		,Sum(dbo.fnMFConvertQuantityToTargetItemUOM(W.intItemUOMId, IU.intItemUOMId, W.dblQuantity)) AS dblWeight
	FROM @tblMFItemPlanSummary I
	JOIN dbo.tblMFWorkOrder W ON I.intItemId = W.intItemId
		AND W.intStatusId IN (
			9
			,10
			,11
			,12
			)
	JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	GROUP BY W.intLocationId
		,I.intItemId

	INSERT INTO @tblMFQtyInProduction
	SELECT R.intLocationId
		,RI.intItemId
		,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(IsNULL(RI.intWeightUOMId, RI.intUnitMeasureId), IU.intItemUOMId, (
					CASE 
						WHEN RI.intWeightUOMId IS NULL
							THEN RI.dblOpenReceive
						ELSE RI.dblNet
						END
					)))
	FROM dbo.tblICInventoryReceiptItem RI
	JOIN dbo.tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	JOIN tblICItemUOM IU ON IU.intItemId = RI.intItemId
		AND IU.ysnStockUnit = 1
	WHERE R.ysnPosted = 0
	GROUP BY R.intLocationId
		,RI.intItemId

	UPDATE I
	SET dblPoundsAvailable = Q.dblWeight
	FROM @tblMFItemPlanSummary I
	JOIN @tblMFQtyInProduction Q ON Q.intItemId = I.intItemId
		AND I.intCompanyLocationId = Q.intCompanyLocationId

	UPDATE @tblMFItemPlanSummary
	SET dblTotalPoundsAvailable = dblUnPackedPounds + dblPoundsAvailable
		,dblUnpackedBreakUp = dblUnPackedPounds
		,dblAvlBreakup = dblPoundsAvailable

	SELECT @intNextMonth = 0

	WHILE (
			SELECT COUNT(*)
			FROM @tblMFMonth
			) < 9
	BEGIN
		INSERT INTO @tblMFMonth
		SELECT DATEPart(Month, Dateadd(mm, @intNextMonth, @dtmCurrentDateTime - 93))
			,DATENAME(Month, Dateadd(mm, @intNextMonth, @dtmCurrentDateTime - 93))
			,DATEPart(YEAR, Dateadd(mm, @intNextMonth, @dtmCurrentDateTime - 93))

		SELECT @intNextMonth = @intNextMonth + 1
	END

	SELECT @dblRunningTotal = 0
		,@intPrevItemId = 0

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFItemPlanSummary

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @dblMaxPoundsRequired = dblMaxPoundsRequired
			,@intItemId = intItemId
		FROM @tblMFItemPlanSummary
		WHERE intRecordId = @intRecordId

		IF @intItemId <> @intPrevItemId
		BEGIN
			SELECT @dblUnPackedPounds = dblUnPackedPounds
				,@dblAvailablePounds = dblPoundsAvailable
			FROM @tblMFItemPlanSummary
			WHERE intRecordId = @intRecordId

			SELECT @dblRunningTotal = 0
		END

		UPDATE @tblMFItemPlanSummary
		SET dblAvlQtyBreakUp = dblTotalPoundsAvailable - @dblRunningTotal
		WHERE intRecordId = @intRecordId

		DECLARE @dblcRunningTotal DECIMAL(24, 10)

		SELECT @dblcRunningTotal = @dblRunningTotal

		IF @dblUnPackedPounds > 0
		BEGIN
			UPDATE @tblMFItemPlanSummary
			SET dblUnpackedBreakUp = @dblUnPackedPounds - (
					CASE 
						WHEN @dblUnPackedPounds - @dblcRunningTotal > 0
							THEN @dblcRunningTotal
						ELSE @dblUnPackedPounds
						END
					)
			WHERE intRecordId = @intRecordId

			IF @dblUnPackedPounds - @dblcRunningTotal > 0
			BEGIN
				SELECT @dblUnPackedPounds = @dblUnPackedPounds - @dblcRunningTotal

				SELECT @dblcRunningTotal = 0
			END
			ELSE
			BEGIN
				SELECT @dblcRunningTotal = @dblcRunningTotal - @dblUnPackedPounds

				SELECT @dblUnPackedPounds = 0
			END
		END

		IF @dblAvailablePounds > 0
			AND @dblcRunningTotal > 0
		BEGIN
			UPDATE @tblMFItemPlanSummary
			SET dblAvlBreakup = @dblAvailablePounds - (
					CASE 
						WHEN @dblAvailablePounds - @dblcRunningTotal > 0
							THEN @dblcRunningTotal
						ELSE @dblAvailablePounds
						END
					)
			WHERE intRecordId = @intRecordId

			IF @dblAvailablePounds - @dblcRunningTotal > 0
			BEGIN
				SELECT @dblAvailablePounds = @dblAvailablePounds - @dblcRunningTotal
			END
			ELSE
			BEGIN
				SELECT @dblAvailablePounds = @dblAvailablePounds - @dblUnPackedPounds
			END
		END

		SELECT @dblRunningTotal = @dblRunningTotal + @dblMaxPoundsRequired

		SELECT @intPrevItemId = @intItemId

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFItemPlanSummary
		WHERE intRecordId > @intRecordId
	END

	DECLARE @tblMFFinalItemPlanSummary TABLE (
		intItemId INT
		,strItemNo NVARCHAR(50)
		,strDescription NVARCHAR(100)
		,intCompanyLocationId INT
		,strLocationName NVARCHAR(50)
		)

	INSERT INTO @tblMFFinalItemPlanSummary
	SELECT DISTINCT II.intItemId
		,II.strItemNo
		,II.strDescription
		,CL.intCompanyLocationId
		,CL.strLocationName
	FROM tblMFWorkOrder W
	JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
		AND R.intLocationId = W.intLocationId
		AND R.ysnActive = 1
	JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
		AND RI.intRecipeItemTypeId = 1
	JOIN dbo.tblICItem II ON II.intItemId = RI.intItemId
	JOIN dbo.tblICCategory C ON C.intCategoryId = II.intCategoryId
		AND C.strCategoryCode IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@strBlendAttributeValue, ',')
			)
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
	
	UNION
	
	SELECT DISTINCT I.intItemId
		,I.strItemNo
		,I.strDescription
		,CL.intCompanyLocationId
		,CL.strLocationName
	FROM dbo.tblICLot L
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
		AND C.strCategoryCode IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@strBlendAttributeValue, ',')
			)
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = L.intLocationId
	WHERE L.dblWeight > 0

	SELECT M.*
		,S.intRecordId
		,FS.strItemNo
		,FS.strItemNo + ' - ' + FS.strDescription AS strItemDesc
		,FS.strLocationName
		,(
			CASE 
				WHEN (S.dblAvlQtyBreakUp) < 0
					THEN 0
				ELSE round(isnull(S.dblAvlQtyBreakUp, 0), 6)
				END - round(isnull(dblUnPackedPounds, 0), 6)
			) [dblPoundsAvailable1]
		,round(isnull(S.dblMaxPoundsRequired, 0), 6) dblMaxPoundsRequired
		,Round(isnull(S.dblTotalPoundsAvailable, 0), 6) dblTotalPoundsAvailable
		,CASE 
			WHEN (
					round(isnull(S.dblMaxPoundsRequired, 0), 6) - CASE 
						WHEN (S.dblAvlQtyBreakUp) < 0
							THEN 0
						ELSE round(isnull(S.dblAvlQtyBreakUp, 0), 6)
						END
					) < 0
				THEN 0
			ELSE (
					round(isnull(S.dblMaxPoundsRequired, 0), 6) - CASE 
						WHEN (S.dblAvlQtyBreakUp) < 0
							THEN 0
						ELSE round(isnull(S.dblAvlQtyBreakUp, 0), 6)
						END
					)
			END [dblNetBlendKilosRequired]
		,CASE 
			WHEN (S.dblAvlQtyBreakUp) < 0
				THEN 0
			ELSE round(isnull(S.dblAvlQtyBreakUp, 0), 6)
			END dblAvlQtyBreakUp
		,round(isnull(dblUnPackedPounds, 0), 6) AS [dblUnPackedPounds1]
		,S.strComments
		,dblAvlBreakup [dblPoundsAvailable]
		,dblUnpackedBreakUp [dblUnPackedPounds]
	FROM @tblMFFinalItemPlanSummary FS
	CROSS JOIN @tblMFMonth M
	JOIN tblICItem I ON FS.intItemId = I.intItemId
		AND FS.strItemNo LIKE @strItemNo + '%'
	JOIN @tblMFItemPlanSummary S ON M.intMonthId = S.intMonthId
		AND I.intItemId = S.intItemId
		AND FS.intCompanyLocationId = S.intCompanyLocationId
		AND S.intItemId = FS.intItemId
	ORDER BY FS.strItemNo
		,FS.intCompanyLocationId
		,M.intYearName
		,M.intMonthId
END
