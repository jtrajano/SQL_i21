CREATE PROCEDURE [dbo].uspMFReportItemPlanSummary @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strItemNo NVARCHAR(50)
		,@xmlDocumentId INT
		,@intBlendAttributeId int
		,@strBlendAttributeValue nvarchar(50)


	Select @intBlendAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Blend Category'
	
	Select @strBlendAttributeValue=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intAttributeId=@intBlendAttributeId

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

	DECLARE @intLocationId INT
		,@strSQL NVARCHAR(Max)
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

	SET @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, GetDate(), 101))
	SET @dtmCurrentDateTime = GetDate()

	--SELECT @intCategoryId = intCategoryId
	--FROM tblICCategory
	--WHERE strCategoryCode = 'Blend'
	INSERT INTO @tblMFItemPlanSummary
	SELECT DATEPART(Month, CD.dtmShiftStartTime) dtmShiftStartTime
		,DATENAME(Month, CD.dtmShiftStartTime) dtmShiftStartTime
		,II.strItemNo
		,II.strDescription
		,CL.strLocationName
		,SUM(RI.dblCalculatedQuantity * SWD.dblPlannedQty)
		,II.intItemId
		,0
		,0 dblUnPackedPounds
		,0 dblPoundsAvailable
		,0 dblTotalPoundsAvailable
		,'' strWorkInstruction
		,0
		,0
		,CL.intCompanyLocationId
		,0
		,0
		,DATEPART(YEAR, CD.dtmShiftStartTime)
	FROM dbo.tblMFSchedule S
	JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
		AND SW.intStatusId <> 13
	JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
	JOIN dbo.tblMFScheduleCalendarDetail CD ON CD.intCalendarDetailId = SWD.intCalendarDetailId
	JOIN dbo.tblMFManufacturingCell MC ON MC.intManufacturingCellId = S.intManufacturingCellId
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
	JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
		AND R.ysnActive = 1
	JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
		AND RI.intRecipeItemTypeId = 1
	JOIN dbo.tblICItem II ON II.intItemId = RI.intItemId
	JOIN dbo.tblICCategory C on C.intCategoryId =II.intCategoryId
		AND C.strCategoryCode = @strBlendAttributeValue
	WHERE S.ysnStandard = 1
		AND CD.dtmCalendarDate <= @dtmCurrentDate
	GROUP BY DATEPART(MONTH, CD.dtmShiftStartTime)
		,CD.dtmShiftStartTime
		,II.strItemNo
		,II.strDescription
		,CL.strLocationName
		,II.intItemId
		--,II.strWorkInstruction
		,CL.intCompanyLocationId
		,DATEPART(YEAR, CD.dtmShiftStartTime)
	ORDER BY II.strItemNo
		,DATEPart(YEAR, CD.dtmShiftStartTime)
		,DATEPart(MONTH, CD.dtmShiftStartTime)

	DECLARE @tblMFQtyOnHand TABLE (
		intCompanyLocationId INT
		,intItemId INT
		,dblWeight NUMERIC(38, 20)
		)

	INSERT INTO @tblMFQtyOnHand
	SELECT L.intLocationId AS intCompanyLocationId
		,I.intItemId
		,Sum(L.dblWeight) AS dblWeight
	FROM @tblMFItemPlanSummary I
	JOIN dbo.tblICLot L ON I.intItemId = L.intItemId
	JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
	WHERE L.intLotStatusId = 1
		AND ISNULL(dtmExpiryDate,@dtmCurrentDateTime) >= @dtmCurrentDateTime
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
		,Sum(W.dblQuantity) AS dblWeight
	FROM @tblMFItemPlanSummary I
	JOIN dbo.tblMFWorkOrder W ON I.intItemId = W.intItemId
		AND W.intStatusId IN (
			9
			,10
			,11
			,12
			)
	GROUP BY W.intLocationId
		,I.intItemId

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
		,strDescription NVARCHAR(50)
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
		JOIN dbo.tblICCategory C on C.intCategoryId =II.intCategoryId
		AND C.strCategoryCode = @strBlendAttributeValue
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = W.intLocationId
	
	UNION
	
	SELECT DISTINCT I.intItemId
		,I.strItemNo
		,I.strDescription
		,CL.intCompanyLocationId
		,CL.strLocationName
	FROM dbo.tblICLot L
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN dbo.tblICCategory C on C.intCategoryId =I.intCategoryId
		AND C.strCategoryCode = @strBlendAttributeValue
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
				ELSE round(isnull(S.dblAvlQtyBreakUp, 0), 2)
				END - round(isnull(dblUnPackedPounds, 0), 2)
			) [dblPoundsAvailable1]
		,round(isnull(S.dblMaxPoundsRequired, 0), 2) dblMaxPoundsRequired
		,Round(isnull(S.dblTotalPoundsAvailable, 0), 2) dblTotalPoundsAvailable
		,CASE 
			WHEN (
					round(isnull(S.dblMaxPoundsRequired, 0), 2) - CASE 
						WHEN (S.dblAvlQtyBreakUp) < 0
							THEN 0
						ELSE round(isnull(S.dblAvlQtyBreakUp, 0), 2)
						END
					) < 0
				THEN 0
			ELSE (
					round(isnull(S.dblMaxPoundsRequired, 0), 2) - CASE 
						WHEN (S.dblAvlQtyBreakUp) < 0
							THEN 0
						ELSE round(isnull(S.dblAvlQtyBreakUp, 0), 2)
						END
					)
			END [dblNetBlendKilosRequired]
		,CASE 
			WHEN (S.dblAvlQtyBreakUp) < 0
				THEN 0
			ELSE round(isnull(S.dblAvlQtyBreakUp, 0), 2)
			END dblAvlQtyBreakUp
		,round(isnull(dblUnPackedPounds, 0), 2) AS [dblUnPackedPounds1]
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
