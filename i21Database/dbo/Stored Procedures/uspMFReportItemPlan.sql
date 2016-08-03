﻿CREATE PROCEDURE uspMFReportItemPlan @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT
		,@intNoOfDays INT
		,@strNoOfDays NVARCHAR(50)
		,@strShowOpenWorkOrder NVARCHAR(50)
		,@strShowFrozenWorkOrder NVARCHAR(50)
		,@strShowPausedWorkOrder NVARCHAR(50)
		,@strShowReleasedWorkOrder NVARCHAR(50)
		,@strShowStartedWorkOrder NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strCompanyLocationName NVARCHAR(50)
		,@strItemGroupName NVARCHAR(50)
		,@strShowStorage NVARCHAR(50)
		,@intBlendAttributeId INT
		,@strBlendAttributeValue NVARCHAR(MAX)
		,@dtmCurrentDateTime DATETIME

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @intBlendAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Category for Ingredient Demand Report'

	SELECT @strBlendAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intAttributeId = @intBlendAttributeId

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

	SELECT @strNoOfDays = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'NoOfDays'

	IF @strNoOfDays = ''
		OR @strNoOfDays IS NULL
	BEGIN
		SELECT @strNoOfDays = '20'
	END

	SELECT @intNoOfDays = @strNoOfDays

	SELECT @strShowOpenWorkOrder = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ShowOpenWorkOrder'

	IF @strShowOpenWorkOrder = ''
		OR @strShowOpenWorkOrder IS NULL
	BEGIN
		SELECT @strShowOpenWorkOrder = 'Yes'
	END

	SELECT @strShowFrozenWorkOrder = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ShowFrozenWorkOrder'

	IF @strShowFrozenWorkOrder = ''
		OR @strShowFrozenWorkOrder IS NULL
	BEGIN
		SELECT @strShowFrozenWorkOrder = 'Yes'
	END

	SELECT @strShowPausedWorkOrder = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ShowPausedWorkOrder'

	IF @strShowPausedWorkOrder = ''
		OR @strShowPausedWorkOrder IS NULL
	BEGIN
		SELECT @strShowPausedWorkOrder = 'Yes'
	END

	SELECT @strShowReleasedWorkOrder = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ShowReleasedWorkOrder'

	IF @strShowReleasedWorkOrder = ''
		OR @strShowReleasedWorkOrder IS NULL
	BEGIN
		SELECT @strShowReleasedWorkOrder = 'Yes'
	END

	SELECT @strShowStartedWorkOrder = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ShowStartedWorkOrder'

	IF @strShowStartedWorkOrder = ''
		OR @strShowStartedWorkOrder IS NULL
	BEGIN
		SELECT @strShowStartedWorkOrder = 'Yes'
	END

	SELECT @strItemNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'Blend'

	IF @strItemNo = ''
		OR @strItemNo IS NULL
	BEGIN
		SELECT @strItemNo = '%'
	END

	SELECT @strCompanyLocationName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'Location'

	IF @strCompanyLocationName IS NULL
		SELECT @strCompanyLocationName = ''

	SELECT @strItemGroupName = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ItemGroupName'

	IF @strItemGroupName IS NULL
		SELECT @strItemGroupName = ''

	SELECT @strShowStorage = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ShowStorage'

	IF @strShowStorage IS NULL
	BEGIN
		SELECT @strShowStorage = ''
	END

	DECLARE @strShowShrtgWithAvlblUnblendedTea NVARCHAR(50)
		,@strShowShrtgWithUnvlblUnblendedTea NVARCHAR(50)
		,@intNoOfDays1 INT
		,@strSQL NVARCHAR(MAX)
		,@intOpenStatusId INT
		,@intFrozenStatusId INT
		,@intPausedStatusId INT
		,@intReleaseStatusId INT
		,@intStartedStatusId INT
		,@intCompanyLocationId NUMERIC(18, 0)
		,@dtmCurrentDate AS DATETIME
		--,@intCategoryId INT
		,@dtmCalendarDate DATETIME
	DECLARE @tblMFWIPItem TABLE (
		--strItemType NVARCHAR(50) collate Latin1_General_CI_AS
		strCellName NVARCHAR(50) collate Latin1_General_CI_AS
		,intWorkOrderId INT
		,strWorkOrderNo NVARCHAR(50) collate Latin1_General_CI_AS
		,dtmPlannedDateTime DATETIME
		,intItemId INT
		,strItemNo NVARCHAR(50) collate Latin1_General_CI_AS
		,strDescription NVARCHAR(100) collate Latin1_General_CI_AS
		,intCompanyLocationId INT
		,strCompanyLocationName NVARCHAR(50) collate Latin1_General_CI_AS
		,dblItemRequired NUMERIC(38, 20)
		,strOwner NVARCHAR(50) collate Latin1_General_CI_AS
		,dtmPlannedDate DATETIME
		,strComments NVARCHAR(MAX) collate Latin1_General_CI_AS
		,strQtyType NVARCHAR(50) collate Latin1_General_CI_AS
		,dblQuantity NUMERIC(38, 20)
		,intDisplayOrder INT
		)
	DECLARE @tblMFWIPItem_Initial TABLE (
		--strItemType NVARCHAR(50) collate Latin1_General_CI_AS
		strCellName NVARCHAR(50) collate Latin1_General_CI_AS
		,intWorkOrderId INT
		,strWorkOrderNo NVARCHAR(50) collate Latin1_General_CI_AS
		,dtmPlannedDateTime DATETIME
		,intItemId INT
		,strItemNo NVARCHAR(50) collate Latin1_General_CI_AS
		,strDescription NVARCHAR(100) collate Latin1_General_CI_AS
		,intCompanyLocationId INT
		,strCompanyLocationName NVARCHAR(50) collate Latin1_General_CI_AS
		,dblItemRequired NUMERIC(38, 20)
		,strOwner NVARCHAR(50) collate Latin1_General_CI_AS
		,dtmPlannedDate DATETIME
		,strComments NVARCHAR(MAX) collate Latin1_General_CI_AS
		,strQtyType NVARCHAR(50) collate Latin1_General_CI_AS
		,dblQuantity NUMERIC(38, 20)
		,intDisplayOrder INT
		)
	DECLARE @tblICItem TABLE (
		intItemId INT
		,strItemNo NVARCHAR(50) collate Latin1_General_CI_AS
		,strDescription NVARCHAR(100) collate Latin1_General_CI_AS
		)

	SELECT @strShowShrtgWithAvlblUnblendedTea = 'No'
		,@strShowShrtgWithUnvlblUnblendedTea = 'No'

	IF @strShowStorage = 'With Available Unblended Tea'
	BEGIN
		SELECT @strShowShrtgWithAvlblUnblendedTea = 'Yes'
	END

	IF @strShowStorage = 'Without available Unblended Tea'
	BEGIN
		SELECT @strShowShrtgWithUnvlblUnblendedTea = 'Yes'
	END

	SELECT @intNoOfDays1 = @intNoOfDays

	SELECT @intOpenStatusId = 0

	SELECT @intFrozenStatusId = 0

	SELECT @intPausedStatusId = 0

	SELECT @intReleaseStatusId = 0

	SELECT @intStartedStatusId = 0

	IF @strShowOpenWorkOrder = 'Yes'
	BEGIN
		SELECT @intOpenStatusId = 3
	END

	IF @strShowFrozenWorkOrder = 'Yes'
	BEGIN
		SELECT @intFrozenStatusId = 4
	END

	IF @strShowPausedWorkOrder = 'Yes'
	BEGIN
		SELECT @intPausedStatusId = 11
	END

	IF @strShowReleasedWorkOrder = 'Yes'
	BEGIN
		SELECT @intReleaseStatusId = 9
	END

	IF @strShowStartedWorkOrder = 'Yes'
	BEGIN
		SELECT @intStartedStatusId = 10
	END

	--SELECT @intCategoryId = intCategoryId
	--FROM tblICCategory
	--WHERE strCategoryCode = 'Blend'
	IF @strItemNo <> ''
		AND @strItemGroupName <> ''
	BEGIN
		INSERT INTO @tblICItem (
			intItemId
			,strItemNo
			,strDescription
			)
		SELECT I.intItemId
			,I.strItemNo
			,I.strDescription
		FROM tblICItem I
		JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
		WHERE C.strCategoryCode IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strBlendAttributeValue, ',')
				)
			AND strItemNo LIKE @strItemNo + '%'
			--AND strItemGroupName LIKE @strItemGroupName + '%'
	END
	ELSE IF @strItemNo = ''
		AND @strItemGroupName <> ''
	BEGIN
		INSERT INTO @tblICItem (
			intItemId
			,strItemNo
			,strDescription
			)
		SELECT I.intItemId
			,I.strItemNo
			,I.strDescription
		FROM tblICItem I
		JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
		WHERE C.strCategoryCode IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strBlendAttributeValue, ',')
				)
			--AND strItemGroupName LIKE @strItemGroupName + '%'
	END
	ELSE IF @strItemNo <> ''
		AND @strItemGroupName = ''
	BEGIN
		INSERT INTO @tblICItem (
			intItemId
			,strItemNo
			,strDescription
			)
		SELECT I.intItemId
			,I.strItemNo
			,I.strDescription
		FROM tblICItem I
		JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
		WHERE C.strCategoryCode IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strBlendAttributeValue, ',')
				)
			AND strItemNo LIKE @strItemNo + '%'
	END
	ELSE
	BEGIN
		INSERT INTO @tblICItem (
			intItemId
			,strItemNo
			,strDescription
			)
		SELECT I.intItemId
			,I.strItemNo
			,I.strDescription
		FROM tblICItem I
		JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
		WHERE C.strCategoryCode IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strBlendAttributeValue, ',')
				)
	END

	SET @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, GetDate(), 101))

	SELECT @intCompanyLocationId = MIN(intCompanyLocationId)
	FROM dbo.tblSMCompanyLocation
	WHERE strLocationName = CASE 
			WHEN LTRIM(RTRIM(@strCompanyLocationName)) = ''
				THEN strLocationName
			ELSE @strCompanyLocationName
			END

	WHILE @intCompanyLocationId > 0
	BEGIN
		SELECT DISTINCT TOP (@intNoOfDays1) @dtmCalendarDate = CD.dtmCalendarDate
		FROM dbo.tblMFSchedule S
		JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
			AND SW.intStatusId <> 13
		JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
		JOIN dbo.tblMFScheduleCalendarDetail CD ON CD.intCalendarDetailId = SWD.intCalendarDetailId
		WHERE S.intLocationId = @intCompanyLocationId
			AND S.ysnStandard = 1
			AND CD.dtmCalendarDate >= @dtmCurrentDate
		ORDER BY CD.dtmCalendarDate

		INSERT INTO @tblMFWIPItem (
			--strItemType
			strCellName
			,intWorkOrderId
			,strWorkOrderNo
			,dtmPlannedDateTime
			,intItemId
			,strItemNo
			,strDescription
			,intCompanyLocationId
			,strCompanyLocationName
			,dblItemRequired
			,strOwner
			,dtmPlannedDate
			,strComments
			,strQtyType
			,intDisplayOrder
			)
		SELECT --'Blend'
			MC.strCellName
			,W.intWorkOrderId
			,W.strWorkOrderNo
			,NULL
			,I.intItemId
			,I.strItemNo
			,I.strDescription
			,CL.intCompanyLocationId
			,CL.strLocationName
			,SUM(RI.dblCalculatedQuantity * SWD.dblPlannedQty)
			,'' AS strName
			,CD.dtmCalendarDate
			,'' strWorkInstruction
			,'Demand#'
			,0
		FROM dbo.tblMFSchedule S
		JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
			AND SW.intStatusId <> 13
		JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
		JOIN dbo.tblMFScheduleCalendarDetail CD ON CD.intCalendarDetailId = SWD.intCalendarDetailId
		JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = S.intManufacturingCellId
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
		JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
			AND R.ysnActive = 1
		JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
			AND RI.intRecipeItemTypeId = 1
		JOIN dbo.tblICItem II ON II.intItemId = RI.intItemId
		JOIN dbo.tblICCategory C ON C.intCategoryId = II.intCategoryId
			AND C.strCategoryCode IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strBlendAttributeValue, ',')
				)
		JOIN @tblICItem I ON I.intItemId = II.intItemId
		--JOIN dbo.tblEMEntity E ON E.intEntityId = I.intOwnerId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
		WHERE S.intLocationId = @intCompanyLocationId
			AND S.ysnStandard = 1
			AND CD.dtmCalendarDate <= @dtmCalendarDate
			AND SW.intStatusId IN (
				@intOpenStatusId
				,@intFrozenStatusId
				,@intPausedStatusId
				,@intReleaseStatusId
				,@intStartedStatusId
				)
		GROUP BY MC.strCellName
			,W.intWorkOrderId
			,W.strWorkOrderNo
			,I.intItemId
			,I.strItemNo
			,I.strDescription
			,CL.intCompanyLocationId
			,CL.strLocationName
			,CD.dtmCalendarDate
		ORDER BY I.strItemNo
			,CD.dtmCalendarDate
			,W.strWorkOrderNo

		SELECT @intCompanyLocationId = MIN(intCompanyLocationId)
		FROM dbo.tblSMCompanyLocation
		WHERE intCompanyLocationId > @intCompanyLocationId
			AND strLocationName = CASE 
				WHEN LTRIM(RTRIM(@strCompanyLocationName)) = ''
					THEN strLocationName
				ELSE @strCompanyLocationName
				END
	END

	INSERT INTO @tblMFWIPItem_Initial
	SELECT *
	FROM @tblMFWIPItem

	DECLARE @tblMFWIPRequiredDate TABLE (dtmPlannedDate DATETIME)

	INSERT INTO @tblMFWIPRequiredDate
	SELECT DISTINCT dtmPlannedDate
	FROM @tblMFWIPItem

	DECLARE @tblMFRequiredItem TABLE (
		intItemId INT
		,strItemNo NVARCHAR(50) collate Latin1_General_CI_AS
		,strDescription NVARCHAR(100) collate Latin1_General_CI_AS
		,intCompanyLocationId INT
		,strCompanyLocationName NVARCHAR(50) collate Latin1_General_CI_AS
		,strOwner NVARCHAR(50) collate Latin1_General_CI_AS
		,strComments NVARCHAR(MAX) collate Latin1_General_CI_AS
		)

	INSERT INTO @tblMFRequiredItem (
		intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,strOwner
		,strComments
		)
	SELECT DISTINCT intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,strOwner
		,strComments
	FROM @tblMFWIPItem

	DECLARE @tblMFRequiredItemByLocation TABLE (
		intItemId INT
		,strItemNo NVARCHAR(50) collate Latin1_General_CI_AS
		,strDescription NVARCHAR(100) collate Latin1_General_CI_AS
		,strOwner NVARCHAR(50) collate Latin1_General_CI_AS
		,strComments NVARCHAR(MAX) collate Latin1_General_CI_AS
		,dtmPlannedDate DATETIME
		,intCompanyLocationId INT
		,strCompanyLocationName NVARCHAR(50) collate Latin1_General_CI_AS
		,dblQOH NUMERIC(38, 20)
		,dblQtyInProduction NUMERIC(38, 20)
		,dblDemandQty NUMERIC(38, 20)
		,dbltDemandQty NUMERIC(38, 20)
		)

	INSERT INTO @tblMFRequiredItemByLocation
	SELECT RI.intItemId
		,strItemNo
		,strDescription
		,strOwner
		,strComments
		,dtmPlannedDate
		,CL.intCompanyLocationId
		,RI.strCompanyLocationName
		,CAST(NULL AS NUMERIC(38, 20)) dblQOH
		,CAST(NULL AS NUMERIC(38, 20)) dblQtyInProduction
		,CAST(NULL AS NUMERIC(38, 20)) dblDemandQty
		,CAST(NULL AS NUMERIC(38, 20)) dbltDemandQty
	FROM @tblMFRequiredItem RI
		,@tblMFWIPRequiredDate RD
		,tblSMCompanyLocation CL
	WHERE RI.strCompanyLocationName = CL.strLocationName
		AND CL.strLocationName = CASE 
			WHEN LTRIM(RTRIM(@strCompanyLocationName)) = ''
				THEN strLocationName
			ELSE @strCompanyLocationName
			END
	ORDER BY 1
		,2
		,3

	DECLARE @tblMFQtyOnHand TABLE (
		intCompanyLocationId INT
		,intItemId INT
		,dblWeight NUMERIC(38, 20)
		)

	INSERT INTO @tblMFQtyOnHand
	SELECT L.intLocationId AS intCompanyLocationId
		,I.intItemId
		,SUM(CASE 
				WHEN L.intWeightUOMId IS NULL
					THEN L.dblQty
				ELSE L.dblWeight
				END) AS dblWeight
	FROM @tblICItem I
	JOIN dbo.tblICLot L ON I.intItemId = L.intItemId
	JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
	WHERE L.intLotStatusId = 1
		AND ISNULL(dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
		AND CSL.strSubLocationName <> 'Intrasit'
	GROUP BY L.intLocationId
		,I.intItemId

	UPDATE @tblMFRequiredItemByLocation
	SET dblQOH = Q.dblWeight
	FROM @tblMFRequiredItemByLocation I
	JOIN @tblMFQtyOnHand Q ON Q.intItemId = I.intItemId
		AND I.intCompanyLocationId = Q.intCompanyLocationId

	--IF OBJECT_ID('tempdb..##QOH') IS NOT NULL
	--	DROP TABLE ##QOH
	--SELECT DISTINCT ks.ItemID blend
	--	,ks.Factory factoryname
	--	,KS.QOH
	--INTO ##QOH
	--FROM dbo.KS_viRely_BlendUnPackedPounds KS
	--INSERT INTO ##QOH
	--SELECT DISTINCT blend
	--	,ProductionWarehouse
	--	,0
	--FROM ##TotalBlend
	--WHERE blend NOT IN (
	--		SELECT blend
	--		FROM ##BlendDateFactory
	--		WHERE qoh IS NOT NULL
	--		GROUP BY blend
	--		)
	--UPDATE tb
	--SET tb.QOH = 0
	--FROM ##BlendDateFactory tb
	--JOIN ##TotalBlend tb1 ON tb1.Blend = tb.blend
	--	AND tb1.ProductionWarehouse = tb.factoryname
	--	AND tb.Wostartdate = tb1.wostartdate
	--	AND tb1.blend NOT IN (
	--		SELECT blend
	--		FROM ##BlendDateFactory
	--		WHERE qoh IS NOT NULL
	--		GROUP BY blend
	--		)
	DECLARE @tblMFQtyInProduction TABLE (
		intCompanyLocationId INT
		,intItemId INT
		,dblWeight NUMERIC(38, 20)
		)

	INSERT INTO @tblMFQtyInProduction
	SELECT W.intLocationId AS intCompanyLocationId
		,I.intItemId
		,Sum(W.dblQuantity) AS dblWeight
	FROM @tblICItem I
	JOIN dbo.tblMFWorkOrder W ON I.intItemId = W.intItemId
		AND W.intStatusId IN (
			9
			,10
			,11
			,12
			)
	GROUP BY W.intLocationId
		,I.intItemId

	UPDATE @tblMFRequiredItemByLocation
	SET dblQtyInProduction = Q.dblWeight
	FROM @tblMFRequiredItemByLocation I
	JOIN @tblMFQtyInProduction Q ON Q.intItemId = I.intItemId
		AND I.intCompanyLocationId = Q.intCompanyLocationId

	UPDATE @tblMFRequiredItemByLocation
	SET dblDemandQty = ISNULL((
				SELECT SUM(W.dblItemRequired)
				FROM @tblMFWIPItem W
				WHERE W.intItemId = RI.intItemId
					AND W.intCompanyLocationId = RI.intCompanyLocationId
					AND W.dtmPlannedDate <= RI.dtmPlannedDate
				), 0)
	FROM @tblMFRequiredItemByLocation RI

	UPDATE @tblMFRequiredItemByLocation
	SET dbltDemandQty = ISNULL((
				SELECT SUM(W.dblItemRequired)
				FROM @tblMFWIPItem W
				WHERE W.intItemId = RI.intItemId
					AND W.intCompanyLocationId = RI.intCompanyLocationId
					AND W.dtmPlannedDate = RI.dtmPlannedDate
				), 0)
	FROM @tblMFRequiredItemByLocation RI

	INSERT INTO @tblMFWIPItem (
		strCellName
		--,strItemType
		,strWorkOrderNo
		,dtmPlannedDateTime
		,intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,dblItemRequired
		,strOwner
		,dtmPlannedDate
		,strComments
		,strQtyType
		,intDisplayOrder
		)
	SELECT ''
		--,strItemType
		,'Demand Total'
		,NULL
		,intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,SUM(dblItemRequired)
		,strOwner
		,dtmPlannedDate
		,strComments
		,'Total'
		,1
	FROM @tblMFWIPItem
	GROUP BY strCellName
		,intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,strOwner
		,dtmPlannedDate
		,strComments
	ORDER BY 1;

	INSERT INTO @tblMFWIPItem (
		strCellName
		--,strItemType
		,strWorkOrderNo
		,dtmPlannedDateTime
		,intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,dblItemRequired
		,strOwner
		,dtmPlannedDate
		,strComments
		,strQtyType
		,dblQuantity
		,intDisplayOrder
		)
	SELECT ''
		--,strItemType
		,'Inventory - Blended'
		,NULL
		,RI.intItemId
		,strItemNo
		,strDescription
		,RI.intCompanyLocationId
		,RI.strCompanyLocationName
		,dblQOH - dblDemandQty
		,strOwner
		,dtmPlannedDate
		,strComments
		,'Inventory'
		,dblQOH
		,2
	FROM @tblMFRequiredItemByLocation RI
	JOIN @tblMFQtyOnHand Q ON Q.intItemId = RI.intItemId
		AND Q.intCompanyLocationId = RI.intCompanyLocationId
	WHERE Q.dblWeight >= 0

	--WITH CTE AS (
	--		SELECT ROW_NUMBER() OVER (
	--				PARTITION BY strItemNo
	--				,dtmPlannedDate
	--				,strCompanyLocationName ORDER BY strItemNo DESC
	--				) AS intRowNumber
	--			,'Blend'
	--			,'' ProductionLine
	--			,'Inventory - Blended' strWorkOrderNo
	--			,NULL dtmPlannedStartDate
	--			,RI.intItemId
	--			,RI.strItemNo
	--			,RI.strDescription
	--			,RI.intCompanyLocationId
	--			,RI.strCompanyLocationName 
	--			,Q.dblWeight - dblDemandQty dblItemRequired
	--			,'' strOwner
	--			,RI.dtmPlannedDate
	--			,RI.strComments
	--			,'Inventory' strQtyType
	--			,Q.dblWeight AS dblQuantity
	--			,2 intDisplayOrder
	--		FROM @tblMFRequiredItemByLocation RI
	--		JOIN @tblMFWIPItem_Initial WI ON WI.intItemId = RI.intItemId
	--			AND RI.intCompanyLocationId = WI.intCompanyLocationId
	--		JOIN @tblMFQtyOnHand Q ON Q.intItemId = RI.intItemId
	--			AND RI.intCompanyLocationId = Q.intCompanyLocationId
	--		WHERE RI.dblQOH IS NULL
	--			AND Q.dblWeight > 0
	--		)
	--INSERT INTO @tblMFWIPItem (
	--	strCellName
	--	,strItemType
	--	,strWorkOrderNo
	--	,dtmPlannedDate
	--	,intItemId
	--	,strItemNo
	--	,strDescription
	--	,intCompanyLocationId
	--	,strCompanyLocationName
	--	,dblItemRequired
	--	,strOwner
	--	,dtmPlannedDate
	--	,strComments
	--	,strQtyType
	--	,dblQuantity
	--	,intDisplayOrder
	--	)
	--SELECT strCellName
	--	,ProductionLine
	--	,strWorkOrderNo
	--	,NULL
	--	,intItemId
	--	,strItemNo
	--	,strDescription
	--	,intCompanyLocationId
	--	,strCompanyLocationName
	--	,dblItemRequired
	--	,strOwner
	--	,dtmPlannedDate
	--	,strComments
	--	,strQtyType
	--	,dblQuantity
	--	,intDisplayOrder
	--FROM CTE
	--WHERE intRowNumber = 1
	INSERT INTO @tblMFWIPItem (
		strCellName
		--,strItemType
		,strWorkOrderNo
		,intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,dblItemRequired
		,strOwner
		,dtmPlannedDate
		,strComments
		,strQtyType
		,dblQuantity
		,intDisplayOrder
		)
	SELECT ''
		--,'Blend'
		,'Inventory - Blended'
		,DT.intItemId
		,strItemNo
		,strDescription
		,DT.intCompanyLocationId
		,strCompanyLocationName
		,NULL
		,strOwner
		,dtmPlannedDate
		,strComments
		,'Inventory'
		,dblQOH
		,2
	FROM (
		SELECT intItemId
			,intCompanyLocationId
		FROM @tblMFQtyOnHand
		WHERE intItemId IN (
				SELECT intItemId
				FROM @tblMFRequiredItem
				)
		
		EXCEPT
		
		SELECT intItemId
			,intCompanyLocationId
		FROM @tblMFRequiredItem
		) DT
	JOIN @tblMFQtyOnHand Q ON Q.intItemId = DT.intItemId
		AND Q.intCompanyLocationId = DT.intCompanyLocationId
	JOIN @tblMFRequiredItemByLocation RI ON RI.intItemId = DT.intItemId;;

	INSERT INTO @tblMFWIPItem (
		strCellName
		--,strItemType
		,strWorkOrderNo
		,dtmPlannedDateTime
		,intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,dblItemRequired
		,strOwner
		,dtmPlannedDate
		,strComments
		,strQtyType
		,dblQuantity
		,intDisplayOrder
		)
	SELECT ''
		--,strItemType
		,'Inventory - Unblended'
		,NULL
		,RI.intItemId
		,strItemNo
		,strDescription
		,RI.intCompanyLocationId
		,RI.strCompanyLocationName
		,CASE 
			WHEN dblQOH - dblDemandQty < 0
				AND dbltDemandQty > 0
				THEN dblQtyInProduction + dblQOH - dblDemandQty
			ELSE NULL
			END
		,strOwner
		,dtmPlannedDate
		,strComments
		,'Inventory'
		,dblQtyInProduction
		,3
	FROM @tblMFRequiredItemByLocation RI
	JOIN @tblMFQtyInProduction Q ON Q.intItemId = RI.intItemId
		AND Q.intCompanyLocationId = RI.intCompanyLocationId
	WHERE Q.dblWeight >= 0

	INSERT INTO @tblMFWIPItem (
		strCellName
		--,strItemType
		,strWorkOrderNo
		,dtmPlannedDateTime
		,intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,dblItemRequired
		,strOwner
		,dtmPlannedDate
		,strComments
		,strQtyType
		,dblQuantity
		,intDisplayOrder
		)
	SELECT ''
		--,strItemType
		,'Inventory - Unblended'
		,NULL
		,RI.intItemId
		,strItemNo
		,strDescription
		,RI.intCompanyLocationId
		,strCompanyLocationName
		,CASE 
			WHEN dblQOH - dblDemandQty < 0
				AND dbltDemandQty > 0
				THEN dblQtyInProduction + dblQOH - dblDemandQty
			ELSE NULL
			END
		,strOwner
		,dtmPlannedDate
		,strComments
		,'Inventory'
		,dblQtyInProduction
		,3
	FROM @tblMFRequiredItemByLocation RI
	JOIN @tblMFQtyInProduction Q ON Q.intItemId = RI.intItemId
		AND Q.intCompanyLocationId = RI.intCompanyLocationId
	WHERE Q.dblWeight IS NULL

	INSERT INTO @tblMFWIPItem (
		strCellName
		--,strItemType
		--,intWorkOrderId 
		,strWorkOrderNo
		--,dtmPlannedDate
		,intItemId
		,strItemNo
		,strDescription
		,intCompanyLocationId
		,strCompanyLocationName
		,dblItemRequired
		,strOwner
		,dtmPlannedDate
		,strComments
		,strQtyType
		,dblQuantity
		,intDisplayOrder
		)
	SELECT ''
		--,'Blend'
		,'Inventory - Unblended'
		,RI.intItemId
		,strItemNo
		,strDescription
		,RI.intCompanyLocationId
		,strCompanyLocationName
		,NULL
		,strOwner
		,dtmPlannedDate
		,strComments
		,'Inventory'
		,dblQtyInProduction
		,3
	FROM (
		SELECT intItemId
			,Q.intCompanyLocationId
		FROM @tblMFQtyInProduction Q
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = Q.intCompanyLocationId
		WHERE intItemId IN (
				SELECT intItemId
				FROM @tblMFRequiredItem
				)
		
		EXCEPT
		
		SELECT intItemId
			,intCompanyLocationId
		FROM @tblMFRequiredItem
		) dt
	JOIN @tblMFQtyInProduction Q ON Q.intItemId = dt.intItemId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = Q.intCompanyLocationId
	JOIN @tblMFRequiredItemByLocation RI ON RI.intItemId = dt.intItemId

	DECLARE @tblMFFinalWIPItem TABLE (
		strCellName NVARCHAR(50) collate Latin1_General_CI_AS
		,strItemNo NVARCHAR(150) collate Latin1_General_CI_AS
		,intWorkOrderId INT
		,strWorkOrderNo NVARCHAR(50) collate Latin1_General_CI_AS
		,dtmPlannedDateTime DATETIME
		,intCompanyLocationId INT
		,strCompanyLocationName NVARCHAR(50) collate Latin1_General_CI_AS
		,dblItemRequired NUMERIC(38, 20)
		,strOwner NVARCHAR(50) collate Latin1_General_CI_AS
		,dtmPlannedDate DATETIME
		,strComments NVARCHAR(MAX) collate Latin1_General_CI_AS
		,intNoOfDays NVARCHAR(MAX) collate Latin1_General_CI_AS
		,dblQuantity NUMERIC(38, 20)
		,intDays INT
		,strQtyType NVARCHAR(50) collate Latin1_General_CI_AS
		,intDisplayOrder INT
		,intRowNumber INT
		)

	INSERT INTO @tblMFFinalWIPItem
	SELECT strCellName
		,strItemNo + ' - ' + strDescription AS strItemNo
		--,strItemType
		,intWorkOrderId
		,strWorkOrderNo
		,dtmPlannedDateTime
		,intCompanyLocationId
		,strCompanyLocationName
		,ROUND(dblItemRequired, 1) AS dblItemRequired
		,strOwner
		,dtmPlannedDate
		,strComments
		,'Ingredient demand for ' + CONVERT(NVARCHAR, @intNoOfDays) + ' rolling days' AS intNoOfDays
		,dblQuantity
		,@intNoOfDays AS intDays
		,strQtyType
		,intDisplayOrder
		,ROW_NUMBER() OVER (
			PARTITION BY strItemNo
			,strCompanyLocationName ORDER BY strItemNo
				,strCompanyLocationName
				,intDisplayOrder
				,dtmPlannedDate
			) AS intRowNumber
	FROM @tblMFWIPItem
	WHERE strCompanyLocationName = CASE 
			WHEN @strCompanyLocationName = ''
				THEN strCompanyLocationName
			ELSE @strCompanyLocationName
			END

	UPDATE @tblMFFinalWIPItem
	SET intRowNumber = NULL
		--,strItemType = CASE 
		--	WHEN strItemType = ''
		--		THEN LEFT(strWorkOrderNo, 6)
		--	ELSE strItemType
		--	END
		,dblQuantity = CASE 
			WHEN dblQuantity IS NULL
				THEN - 1
			ELSE dblQuantity
			END
	WHERE strWorkOrderNo LIKE 'Inventory -%'
		OR strWorkOrderNo LIKE 'Demand Total%'

	UPDATE @tblMFFinalWIPItem
	SET dtmPlannedDateTime = SW.dtmPlannedStartDate
	FROM @tblMFFinalWIPItem WI
	JOIN tblMFWorkOrder W ON W.intWorkOrderId = WI.intWorkOrderId
	JOIN tblMFScheduleWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
	WHERE intDisplayOrder = 0

	UPDATE @tblMFFinalWIPItem
	SET dtmPlannedDateTime = '1900-01-01'
		,strCellName = '1900-01-01'
	WHERE intDisplayOrder = 1

	UPDATE @tblMFFinalWIPItem
	SET dtmPlannedDateTime = '1901-01-02'
		,strCellName = '1901-01-02'
	WHERE intDisplayOrder IN (
			2
			,3
			)

	IF @strShowShrtgWithAvlblUnblendedTea = 'Yes'
	BEGIN
		SELECT a.strCellName
			,a.strItemNo
			,'Blend' AS strItemType
			,a.intRowNumber
			,a.strWorkOrderNo
			,convert(VARCHAR(10), a.dtmPlannedDateTime, 120) + N' ' + CONVERT(NVARCHAR, a.dtmPlannedDateTime, 8) AS dtmPlannedDateTime
			,a.strCompanyLocationName
			,a.dblItemRequired
			,a.strOwner
			,convert(VARCHAR(10), a.dtmPlannedDate, 120) AS dtmPlannedDate
			,a.strComments
			,a.intNoOfDays
			,a.dblQuantity
			,a.intDays
			,a.strQtyType
			,a.intDisplayOrder
		FROM @tblMFFinalWIPItem a
		WHERE a.strCompanyLocationName <> 'WD'
			AND a.strItemNo IN (
				SELECT b.strItemNo
				FROM @tblMFFinalWIPItem b
				WHERE b.strWorkOrderNo = 'Inventory - Blended'
					AND b.dblItemRequired < 0
					AND b.strItemNo IN (
						SELECT c.strItemNo
						FROM @tblMFFinalWIPItem c
						WHERE c.strWorkOrderNo = 'Inventory - Unblended'
							AND c.dblItemRequired > 0
							AND c.dtmPlannedDate IN (
								SELECT Max(d.dtmPlannedDate)
								FROM @tblMFFinalWIPItem d
								WHERE d.intDisplayOrder = 0
									AND d.strItemNo = a.strItemNo
								)
						)
				)
	END
	ELSE IF @strShowShrtgWithUnvlblUnblendedTea = 'Yes'
	BEGIN
		SELECT a.strCellName
			,a.strItemNo
			,'Blend' AS strItemType
			,a.intRowNumber
			,a.strWorkOrderNo
			,convert(VARCHAR(10), a.dtmPlannedDateTime, 120) + N' ' + CONVERT(NVARCHAR, a.dtmPlannedDateTime, 8) AS dtmPlannedDateTime
			,a.strCompanyLocationName
			,a.dblItemRequired
			,a.strOwner
			,convert(VARCHAR(10), a.dtmPlannedDate, 120) AS dtmPlannedDate
			,a.strComments
			,a.intNoOfDays
			,a.dblQuantity
			,a.intDays
			,a.strQtyType
			,a.intDisplayOrder
		FROM @tblMFFinalWIPItem a
		WHERE a.strCompanyLocationName <> 'WD'
			AND (
				a.strItemNo IN (
					SELECT b.strItemNo
					FROM @tblMFFinalWIPItem b
					WHERE b.strWorkOrderNo = 'Inventory - Unblended'
						AND b.dblItemRequired < 0
					)
				OR (
					NOT EXISTS (
						SELECT c.strItemNo
						FROM @tblMFFinalWIPItem c
						WHERE c.strWorkOrderNo = 'Inventory - Unblended'
							AND c.strItemNo = a.strItemNo
						)
					AND EXISTS (
						SELECT d.strItemNo
						FROM @tblMFFinalWIPItem d
						WHERE d.strWorkOrderNo = 'Inventory - blended'
							AND d.dblItemRequired < 0
							AND d.strItemNo = a.strItemNo
						)
					)
				)
	END
	ELSE
	BEGIN
		SELECT a.strCellName
			,a.strItemNo
			,'Blend' AS strItemType
			,a.intRowNumber
			,a.strWorkOrderNo
			,convert(VARCHAR(10), a.dtmPlannedDateTime, 120) + N' ' + CONVERT(NVARCHAR, a.dtmPlannedDateTime, 8) AS dtmPlannedDateTime
			,a.strCompanyLocationName
			,a.dblItemRequired
			,a.strOwner
			,convert(VARCHAR(10), a.dtmPlannedDate, 120) AS dtmPlannedDate
			,a.strComments
			,a.intNoOfDays
			,a.dblQuantity
			,a.intDays
			,a.strQtyType
			,a.intDisplayOrder
		FROM @tblMFFinalWIPItem a
		WHERE a.strCompanyLocationName <> 'WD'
		ORDER BY strItemNo
			,strCompanyLocationName
			,dtmPlannedDateTime
	END
END
