CREATE PROCEDURE [dbo].[uspMFAutoBlendSheetQuality] @intLocationId INT
	,@intBlendRequirementId INT
	,@dblQtyToProduce NUMERIC(38, 20)
	,@strXml NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	SET NOCOUNT ON

	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @idoc INT
	DECLARE @intBlendItemId INT
	DECLARE @strBlendItemNo NVARCHAR(50)
	DECLARE @dblRequiredQty NUMERIC(38, 20)
	DECLARE @intMinRowNo INT
	DECLARE @intRecipeItemId INT
	DECLARE @intRawItemId INT
	DECLARE @intIssuedUOMTypeId INT
	DECLARE @ysnMinorIngredient BIT
	DECLARE @dblPercentageIncrease NUMERIC(38, 20) = 0
	DECLARE @intNoOfSheets INT = 1
	DECLARE @intStorageLocationId INT
	DECLARE @intRecipeId INT
	DECLARE @strBlenderName NVARCHAR(50)
	DECLARE @dblAvailableQty NUMERIC(38, 20)
	DECLARE @dblSelectedQty NUMERIC(38, 20)
	DECLARE @intEstNoOfSheets INT
	DECLARE @dblWeightPerQty NUMERIC(38, 20)
	DECLARE @intMachineId INT
	DECLARE @strSQL NVARCHAR(MAX)
	DECLARE @ysnEnableParentLot BIT = 0
	DECLARE @ysnShowAvailableLotsByStorageLocation BIT = 0
	DECLARE @intManufacturingProcessId INT
	DECLARE @ysnRecipeItemValidityByDueDate BIT = 0
	DECLARE @intDayOfYear INT
	DECLARE @dtmDate DATETIME
	DECLARE @dtmDueDate DATETIME
	DECLARE @dblOriginalRequiredQty NUMERIC(38, 20)
	DECLARE @dblPartialQuantity NUMERIC(38, 20)
	DECLARE @dblRemainingRequiredQty NUMERIC(38, 20)
	DECLARE @intPartialQuantityStorageLocationId INT
	DECLARE @intOriginalIssuedUOMTypeId INT
	DECLARE @intKitStagingLocationId INT
	DECLARE @intBlendStagingLocationId INT
	DECLARE @intMinPartialQtyLotRowNo INT
	DECLARE @dblAvailablePartialQty NUMERIC(38, 20)
	DECLARE @intConsumptionMethodId INT
	DECLARE @intConsumptionStoragelocationId INT
	DECLARE @ysnIsSubstitute BIT
	DECLARE @intPropertyCount INT
	DECLARE @intSequenceNo INT
		,@intSequenceCount INT = 1
		,@strRuleName NVARCHAR(100)
		,@strValue NVARCHAR(50)
		,@strOrderBy NVARCHAR(MAX) = ''
		,@strOrderByFinal NVARCHAR(MAX) = ''
		,@intProductTypeId INT
		,@strOrderByPreference nvarchar(MAX)=''
	DECLARE @intPropertyId INT
		,@strPropertyName NVARCHAR(100)
		,@dblMinValue NUMERIC(38, 20)
		,@dblMaxValue NUMERIC(38, 20)
		,@dblMedian NUMERIC(38, 20)
		,@strPivotSelect NVARCHAR(max)
		,@strPivotfor NVARCHAR(max)
		,@strTableColumns NVARCHAR(max)
	DECLARE @strTbl NVARCHAR(MAX)
	DECLARE @strLot NVARCHAR(MAX)
	DECLARE @strFromTB NVARCHAR(MAX)
	--DECLARE @SQL NVARCHAR(MAX)
	DECLARE @strSQLFinal NVARCHAR(MAX)
	DECLARE @strOrderBydev NVARCHAR(MAX)
	DECLARE @strOrderByFIFO NVARCHAR(MAX)
	DECLARE @strOrderByLIFO NVARCHAR(MAX)
	DECLARE @strOrderByFEFO NVARCHAR(MAX)
	DECLARE @strOrderByCost NVARCHAR(MAX)
	DECLARE @strtblnameChk NVARCHAR(50)
	--DECLARE @strPropertName NVARCHAR(50),
	--DECLARE @Count decimal(38,0)
	DECLARE @strTblName NVARCHAR(MAX)
		,@intControlPointId INT
	DECLARE @intRCount INT
		,@intSeq INT
		,@intCount INT
		,@intLotId INT
		,@strPickByStorageLocation NVARCHAR(50)
		,@intSubLocationId INT
		,@dblUpperToleranceQty NUMERIC(38, 20)
		,@dblLowerToleranceQty NUMERIC(38, 20)
		,@ysnComplianceItem BIT
		,@dblCompliancePercent NUMERIC(38, 20)
		,@dblQuantity NUMERIC(38, 20)
		,@dblIssuedQuantity NUMERIC(38, 20)
		,@intItemIssuedUOMId INT
		,@dblUnitCost NUMERIC(38, 20)
		,@dblPickedQty NUMERIC(38, 20)
		,@dblItemRequiredQty NUMERIC(38, 20)
		,@intInputItemSeq INT
		,@dblTotalPickedQty NUMERIC(38, 20)
		,@intParentLotId INT
		,@intItemId INT
		,@intItemUOMId INT
		,@dblLastCost INT
	DECLARE @tblInputItemSeq TABLE (
		intItemId INT
		,intSeq INT
		)

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblMFCompanyPreference

	IF @ysnEnableParentLot = 0
		SET @intProductTypeId = 6
	ELSE
		SET @intProductTypeId = 11

	SELECT @strBlendItemNo = i.strItemNo
		,@intBlendItemId = i.intItemId
		,@intMachineId = intMachineId
		,@intEstNoOfSheets = (
			CASE 
				WHEN ISNULL(dblEstNoOfBlendSheet, 0) = 0
					THEN 1
				ELSE CEILING(dblEstNoOfBlendSheet)
				END
			)
		,@dtmDueDate = dtmDueDate
	FROM tblMFBlendRequirement br
	JOIN tblICItem i ON br.intItemId = i.intItemId
	WHERE br.intBlendRequirementId = @intBlendRequirementId

	SET @intNoOfSheets = @intEstNoOfSheets

	SELECT @intRecipeId = intRecipeId
		,@intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFRecipe
	WHERE intItemId = @intBlendItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1

	SELECT @ysnRecipeItemValidityByDueDate = CASE 
			WHEN UPPER(pa.strAttributeValue) = 'TRUE'
				THEN 1
			ELSE 0
			END
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Recipe Item Validity By Due Date'

	IF @ysnRecipeItemValidityByDueDate = 0
		SET @dtmDate = Convert(DATE, GetDate())
	ELSE
		SET @dtmDate = Convert(DATE, @dtmDueDate)

	SELECT @intDayOfYear = DATEPART(dy, @dtmDate)

	SELECT @ysnShowAvailableLotsByStorageLocation = CASE 
			WHEN UPPER(pa.strAttributeValue) = 'TRUE'
				THEN 1
			ELSE 0
			END
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Show Available Lots By Storage Location'

	SELECT @intPartialQuantityStorageLocationId = ISNULL(pa.strAttributeValue, 0)
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Partial Quantity Storage Location'

	SELECT @intKitStagingLocationId = pa.strAttributeValue
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Kit Staging Location'

	SELECT @intBlendStagingLocationId = ISNULL(intBlendProductionStagingUnitId, 0)
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

	SELECT @strPickByStorageLocation = ISNULL(pa.strAttributeValue, '')
	FROM tblMFManufacturingProcessAttribute pa
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND pa.intAttributeId = 123

	SELECT @intIssuedUOMTypeId = ISNULL(intIssuedUOMTypeId, 0)
		,@strBlenderName = strName
		,@intSubLocationId = intSubLocationId
	FROM tblMFMachine
	WHERE intMachineId = @intMachineId

	DECLARE @tblSourceSubLocation AS TABLE (intSubLocationId INT)

	IF IsNULL(@strPickByStorageLocation, '') = 'True'
	BEGIN
		INSERT INTO @tblSourceSubLocation
		SELECT @intSubLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblSourceSubLocation
		SELECT intCompanyLocationSubLocationId
		FROM tblSMCompanyLocationSubLocation
		WHERE intCompanyLocationId = @intLocationId
	END

	IF @intIssuedUOMTypeId = 0
	BEGIN
		SET @intIssuedUOMTypeId = 1
	END

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
		,dblUpperToleranceQty NUMERIC(38, 20)
		,dblLowerToleranceQty NUMERIC(38, 20)
		,ysnComplianceItem BIT
		,dblCompliancePercent NUMERIC(38, 20)
		,dblPickedQty NUMERIC(38, 20)
		)

	IF OBJECT_ID('tempdb..#tblProductProperty') IS NOT NULL
		DROP TABLE #tblProductProperty

	CREATE TABLE #tblProductProperty (
		intRowNo INT IDENTITY(1, 1)
		,intPropertyId INT
		,strPropertyName NVARCHAR(100)
		,intProductId INT
		,dblMinValue NUMERIC(38, 20)
		,dblMaxValue NUMERIC(38, 20)
		,dblMedian NUMERIC(38, 20)
		,intSequenceNo INT
		)

	IF OBJECT_ID('tempdb..#tblBlendSheetLot') IS NOT NULL
		DROP TABLE #tblBlendSheetLot

	CREATE TABLE #tblBlendSheetLot (
		intParentLotId INT
		,intItemId INT
		,dblQuantity NUMERIC(38, 20)
		,intItemUOMId INT
		,dblIssuedQuantity NUMERIC(38, 20)
		,intItemIssuedUOMId INT
		,intRecipeItemId INT
		,intStorageLocationId INT
		,dblWeightPerQty NUMERIC(38, 20)
		,dblUnitCost NUMERIC(38, 20)
		)

	IF OBJECT_ID('tempdb..#tblBlendSheetLotFinal') IS NOT NULL
		DROP TABLE #tblBlendSheetLotFinal

	CREATE TABLE #tblBlendSheetLotFinal (
		intParentLotId INT
		,intItemId INT
		,dblQuantity NUMERIC(38, 20)
		,intItemUOMId INT
		,dblIssuedQuantity NUMERIC(38, 20)
		,intItemIssuedUOMId INT
		,intRecipeItemId INT
		,intStorageLocationId INT
		,dblWeightPerQty NUMERIC(38, 20)
		,dblUnitCost NUMERIC(38, 20)
		)

	IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL
		DROP TABLE #tblNames

	CREATE TABLE #tblNames (
		intRowNo INT IDENTITY(1, 1)
		,strtblName NVARCHAR(50)
		,intItemId INT
		,dblRequiredQty NUMERIC(38, 20)
		,dblDemandQty NUMERIC(38, 20)
		)

	--to hold not available and less qty lots
	DECLARE @tblRemainingPickedLots AS TABLE (
		intWorkOrderInputLotId INT
		,intLotId INT
		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblQuantity NUMERIC(38, 20)
		,intItemUOMId INT
		,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblIssuedQuantity NUMERIC(38, 20)
		,intItemIssuedUOMId INT
		,strIssuedUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intItemId INT
		,intRecipeItemId INT
		,dblUnitCost NUMERIC(38, 20)
		,dblDensity NUMERIC(38, 20)
		,dblRequiredQtyPerSheet NUMERIC(38, 20)
		,dblWeightPerUnit NUMERIC(38, 20)
		,dblRiskScore NUMERIC(38, 20)
		,intStorageLocationId INT
		,strStorageLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intLocationId INT
		,strSubLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strLotAlias NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,ysnParentLot BIT
		,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

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
		,dblUpperToleranceQty
		,dblLowerToleranceQty
		,ysnComplianceItem
		,dblCompliancePercent
		)
	SELECT @intRecipeId
		,ri.intRecipeItemId
		,ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.ysnMinorIngredient
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
		,0
		,(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedUpperTolerance
		,(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedLowerTolerance
		,ri.ysnComplianceItem
		,ri.dblCompliancePercent
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
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
		,ri.intRecipeItemId
		,rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1
		,0
		,1
		,0
		,ri.intItemId
		,(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedUpperTolerance
		,(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedLowerTolerance
		,ri.ysnComplianceItem
		,ri.dblCompliancePercent
	FROM tblMFRecipeSubstituteItem rs
	JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
	JOIN tblMFRecipeItem ri ON rs.intRecipeItemId = ri.intRecipeItemId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
	ORDER BY 4 DESC
		,5
		,6

	IF (
			SELECT ISNULL(COUNT(1), 0)
			FROM @tblInputItem
			) = 0
	BEGIN
		SET @strErrMsg = 'No input item(s) found for the blend item ' + @strBlendItemNo + '.'

		RAISERROR (
				@strErrMsg
				,16
				,1
				)
	END

	SELECT @intControlPointId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE pa.intManufacturingProcessId = @intManufacturingProcessId
		AND pa.intLocationId = @intLocationId
		AND at.strAttributeName = 'Control Point'

	INSERT INTO #tblProductProperty (
		intPropertyId
		,strPropertyName
		,intProductId
		,dblMinValue
		,dblMaxValue
		,dblMedian
		,intSequenceNo
		)
	SELECT DISTINCT pt.intPropertyId
		,pt.strPropertyName
		,p.intProductValueId
		,pv.dblMinValue
		,pv.dblMaxValue
		,((ISNULL(pv.dblMinValue, 0) + ISNULL(pv.dblMaxValue, 0)) / 2) AS dblMedian
		,pp.intSequenceNo
	FROM tblQMProduct p
	JOIN tblQMProductProperty pp ON pp.intProductId = p.intProductId
	JOIN tblQMProductPropertyValidityPeriod pv ON pv.intProductPropertyId = pp.intProductPropertyId
	JOIN tblQMProperty pt ON pt.intPropertyId = pp.intPropertyId
	JOIN tblQMProductControlPoint c ON c.intProductId = p.intProductId
	WHERE p.intProductValueId = @intBlendItemId
		AND p.intProductTypeId = 2
		AND pt.intDataTypeId IN (
			1
			,2
			,6
			)
		AND c.intControlPointId = @intControlPointId
		AND p.ysnActive = 1
	ORDER BY pp.intSequenceNo

	SELECT @intPropertyCount = COUNT(1)
	FROM #tblProductProperty

	IF @intPropertyCount = 0
		RAISERROR (
				'Please configure Quality and Formula for the output item.'
				,16
				,1
				)

	SET @strPivotSelect = 'intParentLotId,intItemId,SUM(dblDeviation),MAX(dblQuantity),Max(dtmCreateDate),Max(dtmExpiryDate),Max(dblUnitCost),intPreference'
	SET @strTableColumns = 'intParentLotId INT,intItemId INT,dblDeviation numeric(38,20),dblQuantity numeric(38,20),dtmCreateDate datetime,dtmExpiryDate datetime,dblUnitCost numeric(38,20),intPreference int'
	SET @strPivotfor = ''

	DECLARE @intMinPropertyId INT

	SELECT @intMinPropertyId = MIN(intPropertyId)
	FROM #tblProductProperty

	WHILE @intMinPropertyId IS NOT NULL
	BEGIN
		SELECT @intPropertyId = intPropertyId
			,@strPropertyName = strPropertyName
			,@dblMinValue = dblMinValue
			,@dblMaxValue = dblMaxValue
			,@dblMedian = dblMedian
		FROM #tblProductProperty
		WHERE intPropertyId = @intMinPropertyId

		IF LEN(@strPivotSelect) > 0
			SET @strPivotSelect = @strPivotSelect + ', '
		SET @strPivotSelect = @strPivotSelect + 'SUM(ISNULL([' + str(@intPropertyId) + '],0)) AS [' + @strPropertyName + ']'

		IF LEN(@strPivotfor) > 0
			SET @strPivotfor = @strPivotfor + ', '
		SET @strPivotfor = @strPivotfor + '[' + str(@intPropertyId) + ']'

		IF LEN(@strTableColumns) > 0
			SET @strTableColumns = @strTableColumns + ', '
		SET @strTableColumns = @strTableColumns + '[' + @strPropertyName + '] Numeric(38,20)'

		SELECT @intMinPropertyId = MIN(intPropertyId)
		FROM #tblProductProperty
		WHERE intPropertyId > @intMinPropertyId
	END
	
	UPDATE @tblInputItem
	SET dblPickedQty = dblRequiredQty

	WHILE @intNoOfSheets > 0 --No Of Sheets Loop
	BEGIN
		--Clean Up Code for existing tblItem global temp tables
		IF (
				SELECT COUNT(1)
				FROM tempdb.sys.objects
				WHERE name LIKE '##tblItem%'
				) > 0
		BEGIN
			INSERT INTO #tblNames (strtblName)
			SELECT name
			FROM tempdb.sys.objects
			WHERE name LIKE '##tblItem%'

			SET @intSeq = 1

			SELECT @intRCount = MAX(intRowNo)
			FROM #tblNames

			WHILE @intSeq <= @intRCount
			BEGIN
				SELECT @strTbl = 'IF OBJECT_ID(''tempdb..' + strtblName + ''') IS NOT NULL DROP TABLE ' + strtblName
				FROM #tblNames
				WHERE intRowNo = @intSeq

				EXEC (@strTbl)

				SET @intSeq = @intSeq + 1
			END

			DELETE
			FROM #tblNames

			SET @intSeq = 0
			SET @intRCount = 0
		END
		SET @strSQL = ''

		DELETE
		FROM #tblNames

		SELECT @intMinRowNo = MIN(intRowNo)
		FROM @tblInputItem

		WHILE @intMinRowNo IS NOT NULL --Item Loop
		BEGIN
			SELECT @intRecipeItemId = NULL
				,@intRawItemId = NULL
				,@dblRequiredQty = NULL
				,@ysnMinorIngredient = NULL
				,@intConsumptionMethodId = NULL
				,@intConsumptionStoragelocationId = NULL
				,@ysnIsSubstitute = NULL
				,@dblUpperToleranceQty = NULL
				,@dblLowerToleranceQty = NULL
				,@ysnComplianceItem = NULL
				,@dblCompliancePercent = NULL

			SELECT @intRecipeItemId = intRecipeItemId
				,@intRawItemId = intItemId
				,@dblRequiredQty = (dblRequiredQty / @intEstNoOfSheets)
				,@ysnMinorIngredient = ysnMinorIngredient
				,@intConsumptionMethodId = intConsumptionMethodId
				,@intConsumptionStoragelocationId = intConsumptionStoragelocationId
				,@ysnIsSubstitute = ISNULL(ysnIsSubstitute, 0)
				,@dblUpperToleranceQty = dblUpperToleranceQty
				,@dblLowerToleranceQty = dblLowerToleranceQty
				,@ysnComplianceItem = ysnComplianceItem
				,@dblCompliancePercent = dblCompliancePercent
			FROM @tblInputItem
			WHERE intRowNo = @intMinRowNo

			IF @ysnIsSubstitute = 0
			BEGIN
				SELECT @strTbl = 'CREATE TABLE ##tblItem' + RTRIM(LTRIM(convert(VARCHAR, @intRawItemId))) + '( ' + @strTableColumns

				IF RIGHT(@strTbl, 1) = ','
					SET @strTbl = LEFT(@strTbl, LEN(@strTbl) - 1)
				SET @strTbl = @strTbl + ') '

				EXEC (@strTbl)

				DECLARE @strInputTables NVARCHAR(max)

				SET @strInputTables = RTRIM(LTRIM('##tblItem' + convert(VARCHAR, @intRawItemId)))

				INSERT INTO #tblNames
				VALUES (
					@strInputTables
					,@intRawItemId
					,@dblRequiredQty
					,@dblQtyToProduce
					)
			END
			ELSE
			BEGIN
				SELECT @strInputTables = strtblName
				FROM #tblNames
				WHERE intItemId = (
						SELECT intItemId
						FROM @tblInputItem
						WHERE intRecipeItemId = @intRecipeItemId
							AND ysnIsSubstitute = 0
						)
			END

			IF OBJECT_ID('tempdb..#tblLot') IS NOT NULL
				DROP TABLE #tblLot

			CREATE TABLE #tblLot (
				intLotId INT
				,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intItemId INT
				,dblQty NUMERIC(38, 20)
				,intLocationId INT
				,intSubLocationId INT
				,intStorageLocationId INT
				,dtmCreateDate DATETIME
				,dtmExpiryDate DATETIME
				,dblUnitCost NUMERIC(38, 20)
				,dblWeightPerQty NUMERIC(38, 20)
				,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intParentLotId INT
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				,intPreference INT
				)

			IF OBJECT_ID('tempdb..#tblParentLot') IS NOT NULL
				DROP TABLE #tblParentLot

			CREATE TABLE #tblParentLot (
				intParentLotId INT
				,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intItemId INT
				,dblQty NUMERIC(38, 20)
				,intLocationId INT
				,intSubLocationId INT
				,intStorageLocationId INT
				,dtmCreateDate DATETIME
				,dtmExpiryDate DATETIME
				,dblUnitCost NUMERIC(38, 20)
				,dblWeightPerQty NUMERIC(38, 20)
				,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				,intPreference INT
				)

			--Get the Lots
			INSERT INTO #tblLot (
				intLotId
				,strLotNumber
				,intItemId
				,dblQty
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,dtmCreateDate
				,dtmExpiryDate
				,dblUnitCost
				,dblWeightPerQty
				,strCreatedBy
				,intParentLotId
				,intItemUOMId
				,intItemIssuedUOMId
				,intPreference
				)
			SELECT L.intLotId
				,L.strLotNumber
				,L.intItemId
				,L.dblWeight
				,L.intLocationId
				,L.intSubLocationId
				,L.intStorageLocationId
				,L.dtmDateCreated
				,L.dtmExpiryDate
				,L.dblLastCost
				,L.dblWeightPerQty
				,US.strUserName
				,L.intParentLotId
				,L.intWeightUOMId
				,L.intItemUOMId
				,(Case When SubLoc.intSubLocationId is not null then 1 else 2 End ) AS  intPreference
			FROM tblICLot L
			LEFT JOIN tblSMUserSecurity US ON L.intCreatedEntityId = US.[intEntityId]
			JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
			LEFT JOIN @tblSourceSubLocation SubLoc ON SubLoc.intSubLocationId = L.intSubLocationId
			WHERE L.intItemId = @intRawItemId
				AND L.intLocationId = @intLocationId
				AND LS.strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
				AND (
					L.dtmExpiryDate IS NULL
					OR L.dtmExpiryDate >= GETDATE()
					)
				AND L.dblWeight > 0
				AND L.intStorageLocationId NOT IN (
					ISNULL(@intKitStagingLocationId, 0)
					,ISNULL(@intBlendStagingLocationId, 0)
					) --Exclude Kit Staging,Blend Staging,Partial Qty Storage Locations

			--,@intPartialQuantityStorageLocationId
			--Get Either Parent Lot OR Child Lot Based on Setting
			IF @ysnEnableParentLot = 0
			BEGIN
				INSERT INTO #tblParentLot (
					intParentLotId
					,strParentLotNumber
					,intItemId
					,dblQty
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,dtmCreateDate
					,dtmExpiryDate
					,dblUnitCost
					,dblWeightPerQty
					,strCreatedBy
					,intItemUOMId
					,intItemIssuedUOMId
					)
				SELECT TL.intLotId
					,TL.strLotNumber
					,TL.intItemId
					,TL.dblQty
					,TL.intLocationId
					,TL.intSubLocationId
					,TL.intStorageLocationId
					,TL.dtmCreateDate
					,TL.dtmExpiryDate
					,TL.dblUnitCost
					,TL.dblWeightPerQty
					,TL.strCreatedBy
					,TL.intItemUOMId
					,TL.intItemIssuedUOMId
				FROM #tblLot TL
			END
			ELSE
			BEGIN
				IF @ysnShowAvailableLotsByStorageLocation = 1
				BEGIN
					INSERT INTO #tblParentLot (
						intParentLotId
						,strParentLotNumber
						,intItemId
						,dblQty
						,intLocationId
						,intSubLocationId
						,intStorageLocationId
						,dtmCreateDate
						,dtmExpiryDate
						,dblUnitCost
						,dblWeightPerQty
						,strCreatedBy
						,intItemUOMId
						,intItemIssuedUOMId
						,intPreference
						)
					SELECT TL.intParentLotId
						,PL.strParentLotNumber
						,TL.intItemId
						,SUM(TL.dblQty) AS dblQty
						,TL.intLocationId
						,TL.intSubLocationId
						,TL.intStorageLocationId
						,TL.dtmCreateDate
						,MAX(TL.dtmExpiryDate) AS dtmExpiryDate
						,TL.dblUnitCost
						,TL.dblWeightPerQty
						,TL.strCreatedBy
						,TL.intItemUOMId
						,TL.intItemIssuedUOMId
						,TL.intPreference
					FROM #tblLot TL
					JOIN tblICParentLot PL ON TL.intParentLotId = PL.intParentLotId
					GROUP BY TL.intParentLotId
						,PL.strParentLotNumber
						,TL.intItemId
						,TL.intLocationId
						,TL.intSubLocationId
						,TL.intStorageLocationId
						,TL.dtmCreateDate
						,TL.dblUnitCost
						,TL.dblWeightPerQty
						,TL.strCreatedBy
						,TL.intItemUOMId
						,TL.intItemIssuedUOMId
						,TL.intPreference
				END
				ELSE
				BEGIN
					INSERT INTO #tblParentLot (
						intParentLotId
						,strParentLotNumber
						,intItemId
						,dblQty
						,intLocationId
						,intSubLocationId
						,intStorageLocationId
						,dtmCreateDate
						,dtmExpiryDate
						,dblUnitCost
						,dblWeightPerQty
						,strCreatedBy
						,intItemUOMId
						,intItemIssuedUOMId
						)
					SELECT TL.intParentLotId
						,PL.strParentLotNumber
						,TL.intItemId
						,SUM(TL.dblQty) AS dblQty
						,TL.intLocationId
						,NULL AS intSubLocationId
						,NULL AS intStorageLocationId
						,TL.dtmCreateDate
						,MAX(TL.dtmExpiryDate) AS dtmExpiryDate
						,TL.dblUnitCost
						,TL.dblWeightPerQty
						,TL.strCreatedBy
						,TL.intItemUOMId
						,TL.intItemIssuedUOMId
					FROM #tblLot TL
					JOIN tblICParentLot PL ON TL.intParentLotId = PL.intParentLotId
					GROUP BY TL.intParentLotId
						,PL.strParentLotNumber
						,TL.intItemId
						,TL.intLocationId
						,TL.dtmCreateDate
						,TL.dblUnitCost
						,TL.dblWeightPerQty
						,TL.strCreatedBy
						,TL.intItemUOMId
						,TL.intItemIssuedUOMId
				END
			END

			SET @strSQL = 'INSERT INTO ' + @strInputTables + ' SELECT ' + @strPivotSelect + 'FROM (
						SELECT * From ( 
						SELECT DISTINCT pl.intParentLotId
							,pl.intItemId
							,ABS(ISNULL(r.strPropertyValue, 0) - ISNULL(p.dblMedian, 0)) AS dblDeviation
							,isnull(p.strPropertyName, '''') AS strPropertyName
							,r.intPropertyId
							,(
								pl.dblQty - (
									ISNULL(('

			IF @ysnEnableParentLot = 0
				SET @strSQL = @strSQL + ' 
											SELECT sum(dblQty)
											FROM tblICStockReservation
											WHERE intLotId = pl.intParentLotId AND ISNULL(ysnPosted,0)=0
											), 0) + (
										SELECT isnull(sum(dblQuantity), 0)
										FROM #tblBlendSheetLot
										WHERE intParentLotId = pl.intParentLotId '

			IF @ysnEnableParentLot = 1
			BEGIN
				IF @ysnShowAvailableLotsByStorageLocation = 1
					SET @strSQL = @strSQL + ' 
							SELECT sum(dblQty)
							FROM tblICStockReservation
							WHERE intParentLotId = pl.intParentLotId
							AND intStorageLocationId = pl.intStorageLocationId AND ISNULL(ysnPosted,0)=0
							), 0) + (
						SELECT isnull(sum(dblQuantity), 0)
						FROM #tblBlendSheetLot
						WHERE intParentLotId = pl.intParentLotId '
				ELSE
					SET @strSQL = @strSQL + ' 
								SELECT sum(dblQty)
								FROM tblICStockReservation
								WHERE intParentLotId = pl.intParentLotId AND ISNULL(ysnPosted,0)=0
								), 0) + (
							SELECT isnull(sum(dblQuantity), 0)
							FROM #tblBlendSheetLot
							WHERE intParentLotId = pl.intParentLotId '
			END

			SET @strSQL = @strSQL + ' ) )
								) AS dblQuantity
							,pl.dtmCreateDate
							,pl.dtmExpiryDate
							,pl.dblUnitCost
							,CONVERT(NUMERIC(38,20), ISNULL(r.strPropertyValue, 0)) AS dblPropertyValue
							,p.dblMedian
							,p.dblMaxValue
							,p.dblMinValue
							,IsNULL(pl.intPreference,1) AS intPreference
						FROM #tblProductProperty p
						INNER JOIN tblQMTestResult AS r ON p.intPropertyId=r.intPropertyId
							AND ISNUMERIC(r.strPropertyValue) = 1
						INNER JOIN #tblParentLot pl ON r.intProductValueId=pl.intParentLotId
							AND r.intProductTypeId = ' + CONVERT(VARCHAR, @intProductTypeId) + '
							AND (pl.dtmExpiryDate IS NULL OR pl.dtmExpiryDate >= getdate())
							AND r.intSampleId = (
								SELECT MAX(intSampleId)
								FROM tblQMTestResult
								WHERE intProductValueId = pl.intParentLotId
									AND intProductTypeId = ' + CONVERT(VARCHAR, @intProductTypeId) + '
								)
						WHERE pl.intItemId = ' + CONVERT(VARCHAR, @intRawItemId) + 
				'
							AND pl.dblQty > 0
							AND pl.intLocationId = ' + CONVERT(VARCHAR, @intLocationId) + '
							) t Where ABS(ISNULL(
										t.dblPropertyValue
										, 0) - ISNULL(t.dblMedian, 0)) <= (ISNULL(t.dblMaxValue, 0) - ISNULL(t.dblMinValue, 0))
						) P
					PIVOT(Sum(dblPropertyValue) FOR intPropertyId IN (' + @strPivotfor + ')) AS pvt
					GROUP BY intParentLotId
						,intItemId
						,dtmCreateDate
						,dtmExpiryDate
						,dblUnitCost
						,dblQuantity
						,intPreference
					HAVING dblQuantity > 0'

			EXEC sp_executesql @strSQL

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblInputItem
			WHERE intRowNo > @intMinRowNo
		END

		SET @strSQLFinal = ''
		SET @strOrderBydev = ''
		SET @strOrderByFIFO = ''
		SET @strOrderByLIFO = ''
		SET @strOrderByFEFO = ''
		SET @strOrderByCost = ''
		SET @strtblnameChk = ''
		SELECT @strOrderByPreference=''
		--DECLARE @strPropertName NVARCHAR(50),
		--DECLARE @Count decimal(38,0)
		SET @strTblName = ''

		DECLARE @intMinProductProperty INT

		SELECT @intMinProductProperty = MIN(intRowNo)
		FROM #tblProductProperty

		WHILE @intMinProductProperty IS NOT NULL
		BEGIN
			SELECT @strPropertyName = strPropertyName
				,@dblMedian = dblMedian
				,@intSequenceNo = intSequenceNo
			FROM #tblProductProperty
			WHERE intRowNo = @intMinProductProperty

			SET @strPropertyName = '[' + @strPropertyName + ']'
			SET @strSQL = ''
			SET @strLot = ''
			SET @strFromTB = ''

			DECLARE @intMinTableName INT

			SELECT @intMinTableName = MIN(intRowNo)
			FROM #tblNames

			WHILE @intMinTableName IS NOT NULL
			BEGIN
				SELECT @intCount = intRowNo
					,@strTblName = strtblName
					,@intRawItemId = intItemId
					,@dblRequiredQty = dblRequiredQty
					,@dblQtyToProduce = dblDemandQty
				FROM #tblNames
				WHERE intRowNo = @intMinTableName

				SET @strSQL = @strSQL + '(' + @strTblName + '.' + @strPropertyName + '* ' + LTRIM(str(@dblRequiredQty)) + ')' + '+'

				DECLARE @aliasName NVARCHAR(max)

				SET @aliasName = '[' + 'Lot' + convert(NVARCHAR, @intRawItemId) + ']'
				SET @strLot = @strLot + @strTblName + '.' + 'intParentLotId as ' + @aliasName + ',' + @strTblName + '.' + 'intItemId as ' + @strTblName + ',' + @strTblName + '.' + 'dblQuantity as ' + @strTblName + 'Qty' + ',' + @strTblName + '.' + 'dtmCreateDate as ' + @strTblName + 'CDate ' + ',' + @strTblName + '.' + 'dtmExpiryDate as ' + @strTblName + 'EDate'+ ',' + @strTblName + '.' + 'intPreference as ' + @strTblName + 'Preference' + ',' + @strTblName + '.' + 'dblUnitCost as ' + @strTblName + 'Clb' + ','
				SET @strFromTB = @strFromTB + @strTblName + ','

				IF CHARINDEX(@strTblName, @strOrderByCost) = 0
					SET @strOrderByCost = @strOrderByCost + @strTblName + 'Clb ASC, '

				IF CHARINDEX(@strTblName, @strOrderByFIFO) = 0
					SET @strOrderByFIFO = @strOrderByFIFO + @strTblName + 'CDate ASC, '

				IF CHARINDEX(@strTblName, @strOrderByLIFO) = 0
					SET @strOrderByLIFO = @strOrderByLIFO + @strTblName + 'CDate DESC, '

				IF CHARINDEX(@strTblName, @strOrderByFEFO) = 0
					SET @strOrderByFEFO = @strOrderByFEFO + + @strTblName + 'EDate ASC, '

				IF CHARINDEX(@strTblName, @strOrderByPreference) = 0
					SELECT @strOrderByPreference = @strOrderByPreference + @strTblName + 'Preference ASC, '

				SELECT @intMinTableName = MIN(intRowNo)
				FROM #tblNames
				WHERE intRowNo > @intMinTableName
			END

			IF RIGHT(@strSQL, 1) = '+'
				SET @strSQL = LEFT(@strSQL, LEN(@strSQL) - 1)
			SET @strSQLFinal = @strSQLFinal + '(' + @strSQL + ')' + '/' + LTRIM(CONVERT(NVARCHAR, @dblQtyToProduce)) + ' AS ' + @strPropertyName + ' ,' + + 'ABS(((' + @strSQL + ')' + '/' + LTRIM(CONVERT(NVARCHAR, @dblQtyToProduce)) + ') -' + LTRIM(CONVERT(NVARCHAR, @dblMedian)) + ') AS ' + LEFT(@strPropertyName, LEN(@strPropertyName) - 1) + 'dblDeviation]' + ','

			IF CHARINDEX(@strTblName, @strOrderBydev) = 0
				SET @strOrderBydev = @strOrderBydev + LEFT(@strPropertyName, LEN(@strPropertyName) - 1) + 'dblDeviation] ASC' + ','

			SELECT @intMinProductProperty = MIN(intRowNo)
			FROM #tblProductProperty
			WHERE intRowNo > @intMinProductProperty
		END

		--Get the Rules
		SELECT @intSequenceNo = MAX(intSequenceNo) + 1
		FROM tblMFBlendRequirementRule
		WHERE intBlendRequirementId = @intBlendRequirementId

		WHILE (@intSequenceCount < @intSequenceNo)
		BEGIN
			SELECT @strRuleName = b.strName
				,@strValue = a.strValue
			FROM tblMFBlendRequirementRule a
			JOIN tblMFBlendSheetRule b ON a.intBlendSheetRuleId = b.intBlendSheetRuleId
			WHERE intBlendRequirementId = @intBlendRequirementId
				AND a.intSequenceNo = @intSequenceCount

			IF @strRuleName = 'Pick Order'
			BEGIN
				IF @strValue = 'FIFO'
					SET @strOrderBy = @strOrderByFIFO
				ELSE IF @strValue = 'LIFO'
					SET @strOrderBy = @strOrderByLIFO
				ELSE IF @strValue = 'FEFO'
					SET @strOrderBy = @strOrderByFEFO
			END

			IF @strRuleName = 'Is Cost Applicable?'
			BEGIN
				IF @strValue = 'Yes'
					SET @strOrderBy = @strOrderByCost
			END

			IF @strRuleName = 'Is Quality Data Applicable?'
			BEGIN
				IF @strValue = 'Yes'
					SET @strOrderBy = @strOrderBydev
			END

			SET @strOrderByFinal = @strOrderByFinal + @strOrderBy
			SET @strOrderBy = ''
			SET @intSequenceCount = @intSequenceCount + 1
		END

		IF LEN(@strOrderByFinal) > 0
			AND RIGHT(@strOrderByFinal, 1) = ','
			SET @strOrderByFinal = LEFT(@strOrderByFinal, LEN(@strOrderByFinal) - 1)

		IF RIGHT(@strFromTB, 1) = ','
			SET @strFromTB = ' INTO ##tblResult FROM ' + LEFT(@strFromTB, LEN(@strFromTB) - 1) + ' Order By '+@strOrderByPreference + @strOrderByFinal

		IF RIGHT(@strSQLFinal, 1) = ','
			SET @strSQLFinal = LEFT(@strSQLFinal, LEN(@strSQLFinal) - 1)

		IF OBJECT_ID('tempdb..##tblResult') IS NOT NULL
			DROP TABLE ##tblResult

		EXEC ('Select Top 100 ' + @strLot + @strSQLFinal + @strFromTB)

		--TO CHECK
		IF NOT EXISTS (
				SELECT *
				FROM ##tblResult
				)
		BEGIN
			RAISERROR (
					'There are no lots for one or more ingredient item(s) to process further.'
					,16
					,1
					)

			RETURN
		END

		--Minor Ingredient
		DECLARE @dblQuantityTaken NUMERIC(38, 20)
		DECLARE @ysnPercResetRequired BIT = 0
		DECLARE @sRequiredQty NUMERIC(38, 20)

		SELECT @intMinRowNo = MIN(intRowNo)
		FROM @tblInputItem

		WHILE @intMinRowNo IS NOT NULL
		BEGIN
			SELECT @intRecipeItemId = NULL
				,@intRawItemId = NULL
				,@dblRequiredQty = NULL
				,@ysnMinorIngredient = NULL
				,@intConsumptionMethodId = NULL
				,@intConsumptionStoragelocationId = NULL
				,@ysnIsSubstitute = NULL
				,@dblUpperToleranceQty = NULL
				,@dblLowerToleranceQty = NULL

			SELECT @intRecipeItemId = intRecipeItemId
				,@intRawItemId = intItemId
				,@dblRequiredQty = (dblRequiredQty / @intEstNoOfSheets)
				,@ysnMinorIngredient = ysnMinorIngredient
				,@intConsumptionMethodId = intConsumptionMethodId
				,@intConsumptionStoragelocationId = intConsumptionStoragelocationId
				,@ysnIsSubstitute = ysnIsSubstitute
				,@dblUpperToleranceQty = dblUpperToleranceQty
				,@dblLowerToleranceQty = dblLowerToleranceQty
			FROM @tblInputItem
			WHERE intRowNo = @intMinRowNo

			UPDATE @tblInputItem
			SET dblPickedQty = 0
			WHERE intItemId = @intRawItemId

			IF @ysnMinorIngredient = 1
			BEGIN
				IF @ysnPercResetRequired = 0
				BEGIN
					SELECT @sRequiredQty = SUM(dblRequiredQty) / @intEstNoOfSheets
					FROM @tblInputItem
					WHERE ysnMinorIngredient = 0

					SELECT @dblQuantityTaken = Sum(dblQuantity)
					FROM #tblBlendSheetLot

					IF @dblQuantityTaken > @sRequiredQty
					BEGIN
						SELECT @ysnPercResetRequired = 1

						SET @dblPercentageIncrease = (@dblQuantityTaken - @sRequiredQty) / @sRequiredQty * 100
					END
				END

				SET @dblRequiredQty = (@dblRequiredQty + (@dblRequiredQty * ISNULL(@dblPercentageIncrease, 0) / 100))
			END

			SET @dblAvailableQty = 0

			--Substitute
			DECLARE @dblQty NUMERIC(38, 20)
			DECLARE @dblInputReqQty NUMERIC(38, 20)
			DECLARE @dblRemainingQty NUMERIC(38, 20)
			DECLARE @intInputItemId INT

			IF @ysnIsSubstitute = 1
			BEGIN
				SELECT @intInputItemId = intItemId
					,@dblInputReqQty = dblRequiredQty / @intNoOfSheets
				FROM @tblInputItem
				WHERE intRecipeItemId = @intRecipeItemId
					AND ysnIsSubstitute = 0

				IF EXISTS (
						SELECT *
						FROM #tblBlendSheetLot
						WHERE intItemId = @intInputItemId
						)
				BEGIN
					SELECT @dblQty = SUM(dblQuantity)
					FROM #tblBlendSheetLot
					WHERE intItemId = @intInputItemId

					SET @dblRemainingQty = @dblInputReqQty - @dblQty
					SET @dblRequiredQty = @dblRemainingQty
				END
				ELSE
				BEGIN
					SELECT @intInputItemId = intItemId
						,@dblInputReqQty = dblRequiredQty / @intNoOfSheets
					FROM @tblInputItem
					WHERE intRecipeItemId = @intRecipeItemId
						AND ysnIsSubstitute = 0

					SET @dblRequiredQty = @dblInputReqQty
				END
			END
			ELSE
			BEGIN
				SELECT @intInputItemId = @intRawItemId
			END

			IF OBJECT_ID('tempdb..##tblBestLot') IS NOT NULL
				DROP TABLE ##tblBestLot

			IF OBJECT_ID('tempdb..##tblBestResultFinal') IS NOT NULL
				DROP TABLE ##tblBestResultFinal

			SELECT TOP 1 *
			INTO ##tblBestResultFinal
			FROM ##tblResult

			DECLARE @strSQL1 NVARCHAR(MAX)

			SET @strSQL1 = 'SELECT TOP 1 Lot' + ltrim(@intInputItemId) + ' as intLotId, ##tblItem' + ltrim(@intInputItemId) + ' as intItemId,' + '##tblItem' + ltrim(@intInputItemId) + 'Qty as dblAvailableQty' + ' INTO ##tblBestLot FROM ##tblResult WHERE  ##tblItem' + ltrim(@intInputItemId) + ' = ' + ltrim(str(@intRawItemId))

			EXEC (@strSQL1)

			SELECT @intLotId = intLotId
				,@dblAvailableQty = dblAvailableQty
			FROM ##tblBestLot

			IF @ysnEnableParentLot = 0
				SELECT @dblWeightPerQty = CASE 
						WHEN ISNULL(dblWeightPerQty, 0) = 0
							THEN 1
						ELSE dblWeightPerQty
						END
				FROM tblICLot
				WHERE intLotId = @intLotId
			ELSE
				SELECT TOP 1 @dblWeightPerQty = CASE 
						WHEN ISNULL(dblWeightPerQty, 0) = 0
							THEN 1
						ELSE dblWeightPerQty
						END
				FROM tblICLot
				WHERE intParentLotId = @intLotId
					AND dblWeight > 0

			IF @intIssuedUOMTypeId = 2 --'BAG' 
				SET @dblAvailableQty = @dblAvailableQty - (@dblAvailableQty % @dblWeightPerQty)

			--IF @intIssuedUOMTypeId = 3 --Weight and Pack 
			--BEGIN
			--	SET @dblAvailableQty = @dblAvailableQty - (@dblAvailableQty % @dblWeightPerQty)
			--END
			IF @dblAvailableQty > 0
			BEGIN
				IF (@dblAvailableQty >= @dblRequiredQty)
					SET @dblSelectedQty = @dblRequiredQty
				ELSE
					SET @dblSelectedQty = @dblAvailableQty

				IF @ysnEnableParentLot = 0
					INSERT INTO #tblBlendSheetLot (
						intParentLotId
						,intItemId
						,dblQuantity
						,intItemUOMId
						,dblIssuedQuantity
						,intItemIssuedUOMId
						,intRecipeItemId
						,intStorageLocationId
						,dblWeightPerQty
						,dblUnitCost
						)
					SELECT L.intLotId
						,L.intItemId
						,CASE 
							WHEN @intIssuedUOMTypeId = 2
								THEN (
										(
											CASE 
												WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
													THEN 1
												ELSE Floor(@dblSelectedQty / L.dblWeightPerQty)
												END
											) * L.dblWeightPerQty
										)
							ELSE @dblSelectedQty --To Review ROUND(@dblSelectedQty,3) 
							END AS dblQuantity
						,L.intWeightUOMId AS intItemUOMId
						,CASE 
							WHEN @intIssuedUOMTypeId = 2
								THEN (
										CASE 
											WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
												THEN 1
											ELSE Convert(NUMERIC(38, 20), Floor(@dblSelectedQty / L.dblWeightPerQty))
											END
										)
							ELSE @dblSelectedQty --To Review ROUND(@dblSelectedQty,3) 
							END AS dblIssuedQuantity
						,CASE 
							WHEN @intIssuedUOMTypeId in (2,3)
								THEN L.intItemUOMId
							ELSE L.intWeightUOMId
							END AS intItemIssuedUOMId
						,@intRecipeItemId AS intRecipeItemId
						,L.intStorageLocationId AS intStorageLocationId
						,L.dblWeightPerQty
						,L.dblLastCost
					FROM tblICLot L
					WHERE L.intLotId = @intLotId
						AND L.dblWeight > 0
				ELSE
					SELECT @intParentLotId = NULL
						,@intItemId = NULL
						,@dblQuantity = NULL
						,@intItemUOMId = NULL
						,@dblIssuedQuantity = NULL
						,@intItemIssuedUOMId = NULL
						,@intStorageLocationId = NULL
						,@dblWeightPerQty = NULL
						,@dblLastCost = NULL

				SELECT TOP 1 @intParentLotId = L.intParentLotId
					,@intItemId = L.intItemId
					,@dblQuantity = CASE 
						WHEN @intIssuedUOMTypeId = 2
							THEN (
									(
										CASE 
											WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
												THEN 1
											ELSE Floor(@dblSelectedQty / L.dblWeightPerQty)
											END
										) * L.dblWeightPerQty
									)
						ELSE @dblSelectedQty -- To Review ROUND(@dblSelectedQty,3) 
						END
					,@intItemUOMId = L.intWeightUOMId
					,@dblIssuedQuantity = CASE 
						WHEN @intIssuedUOMTypeId = 2
							THEN (
									CASE 
										WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
											THEN 1
										ELSE Convert(NUMERIC(38, 20), Floor(@dblSelectedQty / L.dblWeightPerQty))
										END
									)
						ELSE @dblSelectedQty --To Review ROUND(@dblSelectedQty,3) 
						END
					,@intItemIssuedUOMId = CASE 
						WHEN @intIssuedUOMTypeId in (2,3)
							THEN L.intItemUOMId
						ELSE L.intWeightUOMId
						END
					,@intStorageLocationId = CASE 
						WHEN @ysnShowAvailableLotsByStorageLocation = 1
							THEN L.intStorageLocationId
						ELSE 0
						END
					,@dblWeightPerQty = L.dblWeightPerQty
					,@dblLastCost = L.dblLastCost
				FROM tblICLot L
				WHERE L.intParentLotId = @intLotId
					AND L.dblWeight -IsNULL((Select SUM(SR.dblQty) from tblICStockReservation SR Where SR.intLotId =L.intLotId),0)> 0

				IF @intIssuedUOMTypeId = 3
				BEGIN
					SELECT @dblQuantity = NULL
						,@dblIssuedQuantity = NULL

					SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(@dblRequiredQty / @dblWeightPerQty, 0) * @dblWeightPerQty)
						,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(@dblRequiredQty / @dblWeightPerQty, 0))

					IF @dblQuantity = 0
					BEGIN
						SELECT @dblQuantity = NULL
							,@dblIssuedQuantity = NULL
							,@intItemIssuedUOMId = NULL

						SELECT @dblQuantity = @dblRequiredQty
							,@dblIssuedQuantity = @dblRequiredQty
							,@intItemIssuedUOMId = @intItemUOMId

						UPDATE @tblInputItem
						SET dblPickedQty = dblPickedQty + @dblQuantity
						WHERE intItemId = @intRawItemId
					END
					ELSE
					BEGIN
						UPDATE @tblInputItem
						SET dblPickedQty = dblPickedQty + @dblQuantity
						WHERE intItemId = @intRawItemId

						SELECT @dblPickedQty = NULL

						SELECT @dblPickedQty = dblPickedQty
						FROM @tblInputItem
						WHERE intItemId = @intRawItemId

						IF (
								@dblPickedQty BETWEEN @dblLowerToleranceQty
									AND @dblUpperToleranceQty
								)
							AND @dblLowerToleranceQty > 0
							AND @dblUpperToleranceQty > 0
						BEGIN
							DELETE
							FROM @tblInputItemSeq

							INSERT INTO @tblInputItemSeq (
								intItemId
								,intSeq
								)
							SELECT intItemId
								,row_number() OVER (
									ORDER BY dblPickedQty DESC
									)
							FROM @tblInputItem

							SELECT @intInputItemSeq = NULL

							SELECT @intInputItemSeq = intSeq
							FROM @tblInputItemSeq
							WHERE intItemId = @intRawItemId

							IF @intMinRowNo = @intInputItemSeq
							BEGIN
								SELECT @dblTotalPickedQty = NULL

								SELECT @dblTotalPickedQty = Sum(dblPickedQty)
								FROM @tblInputItem

								IF @ysnComplianceItem = 1
									AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
								BEGIN
									SELECT @dblQuantity = NULL
										,@dblIssuedQuantity = NULL
										,@intItemIssuedUOMId = NULL

									SELECT @dblQuantity = @dblRequiredQty
										,@dblIssuedQuantity = @dblRequiredQty
										,@intItemIssuedUOMId = @intItemUOMId
								END
							END
							ELSE
							BEGIN
								SELECT @dblQuantity = NULL
									,@dblIssuedQuantity = NULL
									,@intItemIssuedUOMId = NULL

								SELECT @dblQuantity = @dblRequiredQty
									,@dblIssuedQuantity = @dblRequiredQty
									,@intItemIssuedUOMId = @intItemUOMId
							END
						END
						ELSE
						BEGIN
							SELECT @dblQuantity = NULL
								,@dblIssuedQuantity = NULL
								,@intItemIssuedUOMId = NULL

							SELECT @dblQuantity = @dblRequiredQty
								,@dblIssuedQuantity = @dblRequiredQty
								,@intItemIssuedUOMId = @intItemUOMId
						END
					END
				END

				INSERT INTO #tblBlendSheetLot (
					intParentLotId
					,intItemId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intRecipeItemId
					,intStorageLocationId
					,dblWeightPerQty
					,dblUnitCost
					)
				SELECT @intParentLotId
					,@intItemId
					,@dblQuantity
					,@intItemUOMId
					,@dblIssuedQuantity
					,@intItemIssuedUOMId
					,@intRecipeItemId
					,@intStorageLocationId
					,@dblWeightPerQty
					,@dblLastCost

				IF (@dblAvailableQty >= @dblRequiredQty)
				BEGIN
					SET @dblRequiredQty = 0

					GOTO LOOP_END
				END
				ELSE
					SET @dblRequiredQty = @dblRequiredQty - @dblAvailableQty
			END

			--Search for next best lot
			IF OBJECT_ID('tempdb..##tblNextBestLot') IS NOT NULL
				DROP TABLE ##tblNextBestLot

			DECLARE @strJoinClause NVARCHAR(max) = ''

			SELECT @strJoinClause = ISNULL(@strJoinClause, '') + ' and  a.' + a.name + ' = ' + ' b.' + a.name
			FROM sys.columns AS a
			JOIN sys.objects AS b ON a.object_id = b.object_id
			WHERE b.name = '##tblResult'
				AND a.name LIKE 'Lot%'
				AND a.name <> 'Lot' + CONVERT(VARCHAR, @intInputItemId)

			DECLARE @strSQL2 NVARCHAR(MAX)

			SET @strSQL2 = 'SELECT a.Lot' + ltrim(@intInputItemId) + ' as intLotId, a.##tblItem' + ltrim(@intInputItemId) + ' as intItemId,' + 'a.##tblItem' + ltrim(@intInputItemId) + 'Qty as dblAvailableQty' + ' INTO ##tblNextBestLot FROM ##tblResult a,##tblBestResultFinal b' + + ' WHERE a.##tblItem' + ltrim(@intInputItemId) + ' = ' + ltrim(str(@intRawItemId)) + ' AND a.Lot' + ltrim(@intInputItemId) + '<>''' + ltrim(@intLotId) + '''' + @strJoinClause

			EXEC (@strSQL2)

			--Get the Lots
			INSERT INTO #tblLot (
				intLotId
				,strLotNumber
				,intItemId
				,dblQty
				,intLocationId
				,intSubLocationId
				,intStorageLocationId
				,dtmCreateDate
				,dtmExpiryDate
				,dblUnitCost
				,dblWeightPerQty
				,strCreatedBy
				,intParentLotId
				,intItemUOMId
				,intItemIssuedUOMId
				)
			SELECT L.intLotId
				,L.strLotNumber
				,L.intItemId
				,L.dblWeight
				,L.intLocationId
				,L.intSubLocationId
				,L.intStorageLocationId
				,L.dtmDateCreated
				,L.dtmExpiryDate
				,L.dblLastCost
				,L.dblWeightPerQty
				,US.strUserName
				,L.intParentLotId
				,L.intWeightUOMId
				,L.intItemUOMId
			FROM tblICLot L
			LEFT JOIN tblSMUserSecurity US ON L.intCreatedEntityId = US.[intEntityId]
			JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
			JOIN @tblSourceSubLocation SubLoc ON SubLoc.intSubLocationId = L.intSubLocationId
			WHERE L.intItemId = @intRawItemId
				AND L.intLocationId = @intLocationId
				AND LS.strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
				AND (
					L.dtmExpiryDate IS NULL
					OR L.dtmExpiryDate >= GETDATE()
					)
				AND L.dblWeight > 0
				AND L.intStorageLocationId NOT IN (
					ISNULL(@intKitStagingLocationId, 0)
					,ISNULL(@intBlendStagingLocationId, 0)
					) --Exclude Kit Staging,Blend Staging,Partial Qty Storage Locations

			--,@intPartialQuantityStorageLocationId
			DECLARE @intMinBestPick INT

			SELECT @intMinBestPick = MIN(intLotId)
			FROM ##tblNextBestLot

			WHILE EXISTS (
					SELECT 1
					FROM ##tblNextBestLot
					)
			BEGIN
				SELECT @intLotId = intLotId
					,@intRawItemId = intItemId
					,@dblAvailableQty = dblAvailableQty
				FROM ##tblNextBestLot
				WHERE intLotId = @intMinBestPick

				IF @ysnEnableParentLot = 0
					SELECT @dblWeightPerQty = CASE 
							WHEN ISNULL(dblWeightPerQty, 0) = 0
								THEN 1
							ELSE dblWeightPerQty
							END
					FROM tblICLot
					WHERE intLotId = @intLotId
				ELSE
					SELECT TOP 1 @dblWeightPerQty = CASE 
							WHEN ISNULL(dblWeightPerQty, 0) = 0
								THEN 1
							ELSE dblWeightPerQty
							END
					FROM tblICLot
					WHERE intParentLotId = @intLotId
						AND dblWeight > 0

				IF @intIssuedUOMTypeId = 2 --'BAG' 
					SET @dblAvailableQty = @dblAvailableQty - (@dblAvailableQty % @dblWeightPerQty)

				IF @dblAvailableQty > 0
				BEGIN
					IF (@dblAvailableQty >= @dblRequiredQty)
						SET @dblSelectedQty = @dblRequiredQty
					ELSE
						SET @dblSelectedQty = @dblAvailableQty

					IF @ysnEnableParentLot = 0
						INSERT INTO #tblBlendSheetLot (
							intParentLotId
							,intItemId
							,dblQuantity
							,intItemUOMId
							,dblIssuedQuantity
							,intItemIssuedUOMId
							,intRecipeItemId
							,intStorageLocationId
							,dblWeightPerQty
							,dblUnitCost
							)
						SELECT L.intLotId
							,L.intItemId
							,CASE 
								WHEN @intIssuedUOMTypeId = 2
									THEN (
											(
												CASE 
													WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
														THEN 1
													ELSE Floor(@dblSelectedQty / L.dblWeightPerQty)
													END
												) * L.dblWeightPerQty
											)
								ELSE @dblSelectedQty --To Review ROUND(@dblSelectedQty,3) 
								END AS dblQuantity
							,L.intWeightUOMId AS intItemUOMId
							,CASE 
								WHEN @intIssuedUOMTypeId = 2
									THEN (
											CASE 
												WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
													THEN 1
												ELSE Convert(NUMERIC(38, 20), Floor(@dblSelectedQty / L.dblWeightPerQty))
												END
											)
								ELSE @dblSelectedQty --To Review ROUND(@dblSelectedQty,3) 
								END AS dblIssuedQuantity
							,CASE 
								WHEN @intIssuedUOMTypeId = 2
									THEN L.intItemUOMId
								ELSE L.intWeightUOMId
								END AS intItemIssuedUOMId
							,@intRecipeItemId AS intRecipeItemId
							,L.intStorageLocationId AS intStorageLocationId
							,L.dblWeightPerQty
							,L.dblLastCost
						FROM tblICLot L
						WHERE L.intLotId = @intLotId
							AND L.dblWeight > 0
					ELSE
						SELECT @intParentLotId = NULL
							,@intItemId = NULL
							,@dblQuantity = NULL
							,@intItemUOMId = NULL
							,@dblIssuedQuantity = NULL
							,@intItemIssuedUOMId = NULL
							,@intStorageLocationId = NULL
							,@dblWeightPerQty = NULL
							,@dblLastCost = NULL

					SELECT @intParentLotId = intParentLotId
						,@intItemId = intItemId
						,@dblQuantity = CASE 
							WHEN @intIssuedUOMTypeId = 2
								THEN (
										(
											CASE 
												WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
													THEN 1
												ELSE Floor(@dblSelectedQty / L.dblWeightPerQty)
												END
											) * L.dblWeightPerQty
										)
							ELSE @dblSelectedQty -- To Review ROUND(@dblSelectedQty,3) 
							END
						,@intItemUOMId = L.intWeightUOMId
						,@dblIssuedQuantity = CASE 
							WHEN @intIssuedUOMTypeId = 2
								THEN (
										CASE 
											WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
												THEN 1
											ELSE Convert(NUMERIC(38, 20), Floor(@dblSelectedQty / L.dblWeightPerQty))
											END
										)
							ELSE @dblSelectedQty --To Review ROUND(@dblSelectedQty,3) 
							END
						,@intItemIssuedUOMId = CASE 
							WHEN @intIssuedUOMTypeId = 2
								THEN L.intItemUOMId
							ELSE L.intWeightUOMId
							END
						,@intStorageLocationId = CASE 
							WHEN @ysnShowAvailableLotsByStorageLocation = 1
								THEN L.intStorageLocationId
							ELSE 0
							END
						,@dblWeightPerQty = dblWeightPerQty
						,@dblLastCost = dblLastCost
					FROM tblICLot L
					WHERE L.intParentLotId = @intLotId
						AND L.dblWeight > 0

					IF @intIssuedUOMTypeId = 3
					BEGIN
						SELECT @dblQuantity = NULL
							,@dblIssuedQuantity = NULL

						SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(@dblRequiredQty / @dblWeightPerQty, 0) * @dblWeightPerQty)
							,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(@dblRequiredQty / @dblWeightPerQty, 0))

						IF @dblQuantity = 0
						BEGIN
							SELECT @dblQuantity = @dblRequiredQty
								,@dblIssuedQuantity = NULL
								,@intItemIssuedUOMId = NULL

							SELECT @dblQuantity = @dblRequiredQty
								,@dblIssuedQuantity = @dblRequiredQty
								,@intItemIssuedUOMId = @intItemUOMId

							UPDATE @tblInputItem
							SET dblPickedQty = dblPickedQty + @dblQuantity
							WHERE intItemId = @intRawItemId
						END
						ELSE
						BEGIN
							UPDATE @tblInputItem
							SET dblPickedQty = dblPickedQty + @dblQuantity
							WHERE intItemId = @intRawItemId

							SELECT @dblPickedQty = NULL

							SELECT @dblPickedQty = dblPickedQty
							FROM @tblInputItem
							WHERE intItemId = @intRawItemId

							IF (
									@dblPickedQty BETWEEN @dblLowerToleranceQty
										AND @dblUpperToleranceQty
									)
								AND @dblLowerToleranceQty > 0
								AND @dblUpperToleranceQty > 0
							BEGIN
								DELETE
								FROM @tblInputItemSeq

								INSERT INTO @tblInputItemSeq (
									intItemId
									,intSeq
									)
								SELECT intItemId
									,row_number() OVER (
										ORDER BY dblPickedQty DESC
										)
								FROM @tblInputItem

								SELECT @intInputItemSeq = NULL

								SELECT @intInputItemSeq = intSeq
								FROM @tblInputItemSeq
								WHERE intItemId = @intRawItemId

								IF @intMinRowNo = @intInputItemSeq
								BEGIN
									SELECT @dblTotalPickedQty = NULL

									SELECT @dblTotalPickedQty = Sum(dblPickedQty)
									FROM @tblInputItem

									IF @ysnComplianceItem = 1
										AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
									BEGIN
										SELECT @dblQuantity = NULL
											,@dblIssuedQuantity = NULL
											,@intItemIssuedUOMId = NULL

										SELECT @dblQuantity = @dblRequiredQty
											,@dblIssuedQuantity = @dblRequiredQty
											,@intItemIssuedUOMId = @intItemUOMId
									END
								END
								ELSE
								BEGIN
									SELECT @dblQuantity = NULL
										,@dblIssuedQuantity = NULL
										,@intItemIssuedUOMId = NULL

									SELECT @dblQuantity = @dblRequiredQty
										,@dblIssuedQuantity = @dblRequiredQty
										,@intItemIssuedUOMId = @intItemUOMId
								END
							END
							ELSE
							BEGIN
								SELECT @dblQuantity = NULL
									,@dblIssuedQuantity = NULL
									,@intItemIssuedUOMId = NULL

								SELECT @dblQuantity = @dblRequiredQty
									,@dblIssuedQuantity = @dblRequiredQty
									,@intItemIssuedUOMId = @intItemUOMId
							END
						END
					END

					INSERT INTO #tblBlendSheetLot (
						intParentLotId
						,intItemId
						,dblQuantity
						,intItemUOMId
						,dblIssuedQuantity
						,intItemIssuedUOMId
						,intRecipeItemId
						,intStorageLocationId
						,dblWeightPerQty
						,dblUnitCost
						)
					SELECT @intParentLotId
						,@intItemId
						,@dblQuantity
						,@intItemUOMId
						,@dblIssuedQuantity
						,@intItemIssuedUOMId
						,@intRecipeItemId
						,@intStorageLocationId
						,@dblWeightPerQty
						,@dblLastCost

					IF (@dblAvailableQty >= @dblRequiredQty)
					BEGIN
						SET @dblRequiredQty = 0

						GOTO LOOP_END
					END
					ELSE
						SET @dblRequiredQty = @dblRequiredQty - @dblAvailableQty
				END

				SELECT @intLotId = intLotId
					,@intRawItemId = intItemId
					,@dblAvailableQty = dblAvailableQty
				FROM ##tblNextBestLot
				WHERE intLotId > @intMinBestPick
			END

			LOOP_END:

			--End Search for next best lot
			IF OBJECT_ID('tempdb..##tblBestResultFinal') IS NOT NULL
				DROP TABLE ##tblBestResultFinal

			IF OBJECT_ID('tempdb..##tblBestLot') IS NOT NULL
				DROP TABLE ##tblBestLot

			IF OBJECT_ID('tempdb..##tblNextBestLot') IS NOT NULL
				DROP TABLE ##tblNextBestLot

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblInputItem
			WHERE intRowNo > @intMinRowNo
		END --While Loop End For Per Recipe Item

		IF OBJECT_ID('tempdb..##tblResult') IS NOT NULL
			DROP TABLE ##tblResult

		SET @intPropertyCount = 0

		SELECT @intPropertyCount = COUNT(*)
		FROM #tblNames

		IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL
			AND @intPropertyCount > 0
		BEGIN
			SET @intSeq = 1

			SELECT @intRCount = MAX(intRowNo)
			FROM #tblNames

			WHILE @intSeq <= @intRCount
			BEGIN
				SELECT @strTbl = 'IF OBJECT_ID(''tempdb..' + strtblName + ''') IS NOT NULL DROP TABLE ' + strtblName
				FROM #tblNames
				WHERE intRowNo = @intSeq

				EXEC (@strTbl)

				SET @intSeq = @intSeq + 1
			END
		END

		SET @strLot = ''
		SET @strSQLFinal = ''
		SET @strFromTB = ''
		SET @intNoOfSheets = @intNoOfSheets - 1
	END -- While Loop End For Per Sheet

	--Final table after summing the Qty for all individual blend sheet
	INSERT INTO #tblBlendSheetLotFinal (
		intParentLotId
		,intItemId
		,dblQuantity
		,intItemUOMId
		,dblIssuedQuantity
		,intItemIssuedUOMId
		,intRecipeItemId
		,intStorageLocationId
		,dblWeightPerQty
		,dblUnitCost
		)
	SELECT intParentLotId
		,intItemId
		,SUM(dblQuantity) AS dblQuantity
		,intItemUOMId
		,SUM(dblIssuedQuantity) AS dblIssuedQuantity
		,intItemIssuedUOMId
		,intRecipeItemId
		,intStorageLocationId
		,AVG(dblWeightPerQty)
		,Max(dblUnitCost)
	FROM #tblBlendSheetLot
	GROUP BY intParentLotId
		,intItemId
		,intItemUOMId
		,intItemIssuedUOMId
		,intRecipeItemId
		,intStorageLocationId

	--Return Date
	IF @ysnEnableParentLot = 0
		SELECT L.intLotId AS intWorkOrderInputLotId
			,L.intLotId AS intLotId
			,L.strLotNumber
			,I.strItemNo
			,I.strDescription
			,BS.dblQuantity
			,BS.intItemUOMId
			,UM1.strUnitMeasure AS strUOM
			,BS.dblIssuedQuantity
			,BS.intItemIssuedUOMId
			,UM2.strUnitMeasure AS strIssuedUOM
			,BS.intItemId
			,BS.intRecipeItemId
			,L.dblLastCost AS dblUnitCost
			,CONVERT(DECIMAL(24, 2), (
					SELECT TOP 1 (
							CASE 
								WHEN ISNULL(TR.strPropertyValue, 0) = ''
									THEN 0.0
								ELSE isnull(CONVERT(DECIMAL(24, 2), TR.strPropertyValue), 0.0)
								END
							)
					FROM tblQMTestResult TR
					INNER JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
						AND ISNUMERIC(TR.strPropertyValue) = 1
						AND P.strPropertyName = 'Density'
					WHERE TR.intProductTypeId = 11
						AND TR.intProductValueId = PL.intParentLotId
					ORDER BY TR.intSampleId DESC
					)) AS dblDensity
			,(BS.dblQuantity / @intEstNoOfSheets) AS dblRequiredQtyPerSheet
			,L.dblWeightPerQty AS dblWeightPerUnit
			,ISNULL(I.dblRiskScore, 0) AS dblRiskScore
			,BS.intStorageLocationId
			,SL.strName AS strStorageLocationName
			,CL.strLocationName
			,@intLocationId AS intLocationId
			,CSL.strSubLocationName
			,L.strLotAlias
			,CAST(0 AS BIT) ysnParentLot
			,'Added' AS strRowState
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICLot L ON BS.intParentLotId = L.intLotId
			AND L.dblWeight > 0
		INNER JOIN tblICItem I ON I.intItemId = L.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId = UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.intItemIssuedUOMId
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId = UM2.intUnitMeasureId
		INNER JOIN tblICStorageLocation SL ON SL.intStorageLocationId = BS.intStorageLocationId
		INNER JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
		WHERE BS.dblQuantity > 0
		
		UNION
		
		SELECT *
		FROM @tblRemainingPickedLots
	ELSE IF @ysnShowAvailableLotsByStorageLocation = 1
		SELECT PL.intParentLotId AS intWorkOrderInputLotId
			,PL.intParentLotId AS intLotId
			,PL.strParentLotNumber AS strLotNumber
			,I.strItemNo
			,I.strDescription
			,BS.dblQuantity
			,BS.intItemUOMId
			,UM1.strUnitMeasure AS strUOM
			,BS.dblIssuedQuantity
			,BS.intItemIssuedUOMId
			,UM2.strUnitMeasure AS strIssuedUOM
			,BS.intItemId
			,BS.intRecipeItemId
			,BS.dblUnitCost AS dblUnitCost -- Review
			,CONVERT(DECIMAL(24, 2), (
					SELECT TOP 1 (
							CASE 
								WHEN ISNULL(TR.strPropertyValue, 0) = ''
									THEN 0.0
								ELSE isnull(CONVERT(DECIMAL(24, 2), TR.strPropertyValue), 0.0)
								END
							)
					FROM tblQMTestResult TR
					INNER JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
						AND ISNUMERIC(TR.strPropertyValue) = 1
						AND P.strPropertyName = 'Density'
					WHERE TR.intProductTypeId = 11
						AND TR.intProductValueId = PL.intParentLotId
					ORDER BY TR.intSampleId DESC
					)) AS dblDensity
			,(BS.dblQuantity / @intEstNoOfSheets) AS dblRequiredQtyPerSheet
			,BS.dblWeightPerQty AS dblWeightPerUnit
			,ISNULL(I.dblRiskScore, 0) AS dblRiskScore
			,BS.intStorageLocationId
			,SL.strName AS strStorageLocationName
			,CL.strLocationName
			,@intLocationId AS intLocationId
			,CSL.strSubLocationName
			,CAST(1 AS BIT) ysnParentLot
			,'Added' AS strRowState
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICParentLot PL ON BS.intParentLotId = PL.intParentLotId --AND PL.dblWeight > 0
		INNER JOIN tblICItem I ON I.intItemId = PL.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId = UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.intItemIssuedUOMId
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId = UM2.intUnitMeasureId
		INNER JOIN tblICStorageLocation SL ON SL.intStorageLocationId = BS.intStorageLocationId
		INNER JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
		WHERE BS.dblQuantity > 0
	ELSE
		SELECT PL.intParentLotId AS intWorkOrderInputLotId
			,PL.intParentLotId AS intLotId
			,PL.strParentLotNumber AS strLotNumber
			,I.strItemNo
			,I.strDescription
			,BS.dblQuantity
			,BS.intItemUOMId
			,UM1.strUnitMeasure AS strUOM
			,BS.dblIssuedQuantity
			,BS.intItemIssuedUOMId
			,UM2.strUnitMeasure AS strIssuedUOM
			,BS.intItemId
			,BS.intRecipeItemId
			,BS.dblUnitCost AS dblUnitCost -- Review
			,CONVERT(DECIMAL(24, 2), (
					SELECT TOP 1 (
							CASE 
								WHEN ISNULL(TR.strPropertyValue, 0) = ''
									THEN 0.0
								ELSE isnull(CONVERT(DECIMAL(24, 2), TR.strPropertyValue), 0.0)
								END
							)
					FROM tblQMTestResult TR
					INNER JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
						AND ISNUMERIC(TR.strPropertyValue) = 1
						AND P.strPropertyName = 'Density'
					WHERE TR.intProductTypeId = 11
						AND TR.intProductValueId = PL.intParentLotId
					ORDER BY TR.intSampleId DESC
					)) AS dblDensity
			,(BS.dblQuantity / @intEstNoOfSheets) AS dblRequiredQtyPerSheet
			,BS.dblWeightPerQty AS dblWeightPerUnit
			,ISNULL(I.dblRiskScore, 0) AS dblRiskScore
			,BS.intStorageLocationId
			,CL.strLocationName
			,@intLocationId AS intLocationId
			,CAST(1 AS BIT) ysnParentLot
			,'Added' AS strRowState
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICParentLot PL ON BS.intParentLotId = PL.intParentLotId --AND PL.dblWeight > 0
		INNER JOIN tblICItem I ON I.intItemId = PL.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId = UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.intItemIssuedUOMId
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId = UM2.intUnitMeasureId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = @intLocationId
		WHERE BS.dblQuantity > 0

	--Clean Up Code
	IF OBJECT_ID('tempdb..#tblBlendSheetLot') IS NOT NULL
		DROP TABLE #tblBlendSheetLot

	IF OBJECT_ID('tempdb..##tblResult') IS NOT NULL
		DROP TABLE ##tblResult

	SET @intPropertyCount = 0

	SELECT @intPropertyCount = COUNT(*)
	FROM #tblNames

	IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL
		AND @intPropertyCount > 0
	BEGIN
		SET @intSeq = 1

		SELECT @intRCount = MAX(intRowNo)
		FROM #tblNames

		WHILE @intSeq <= @intRCount
		BEGIN
			SELECT @strTbl = 'IF OBJECT_ID(''tempdb..' + strtblName + ''') IS NOT NULL DROP TABLE ' + strtblName
			FROM #tblNames
			WHERE intRowNo = @intSeq

			EXEC (@strTbl)

			SET @intSeq = @intSeq + 1
		END
	END

	IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL
		DROP TABLE #tblNames
END TRY

BEGIN CATCH
	--Clean Up Code
	IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL
		AND @intPropertyCount > 0
	BEGIN
		SET @intSeq = 1

		SELECT @intRCount = MAX(intRowNo)
		FROM #tblNames

		WHILE @intSeq <= @intRCount
		BEGIN
			SELECT @strTbl = 'IF OBJECT_ID(''tempdb..' + strtblName + ''') IS NOT NULL DROP TABLE ' + strtblName
			FROM #tblNames
			WHERE intRowNo = @intSeq

			EXEC (@strTbl)

			SET @intSeq = @intSeq + 1
		END
	END

	IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL
		DROP TABLE #tblNames

	IF OBJECT_ID('tempdb..##tblResult') IS NOT NULL
		DROP TABLE ##tblResult

	IF OBJECT_ID('tempdb..##tblBestLot') IS NOT NULL
		DROP TABLE ##tblBestLot

	IF OBJECT_ID('tempdb..#tblBlendSheetLot') IS NOT NULL
		DROP TABLE #tblBlendSheetLot

	SET @strErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
