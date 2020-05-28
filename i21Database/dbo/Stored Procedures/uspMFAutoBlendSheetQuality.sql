CREATE PROCEDURE [dbo].[uspMFAutoBlendSheetQuality]
	 @intLocationId INT
	,@intBlendRequirementId INT
	,@dblQtyToProduce NUMERIC(38,20)
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
	DECLARE @idoc int 
	DECLARE @intBlendItemId INT
	DECLARE @strBlendItemNo NVARCHAR(50)
	DECLARE @dblRequiredQty NUMERIC(38,20)
	DECLARE @intMinRowNo INT
	DECLARE @intRecipeItemId INT
	DECLARE @intRawItemId INT
	DECLARE @intIssuedUOMTypeId INT
	DECLARE @ysnMinorIngredient BIT
	DECLARE @dblPercentageIncrease NUMERIC(38,20) = 0
	DECLARE @intNoOfSheets INT = 1
	DECLARE @intStorageLocationId INT
	DECLARE @intRecipeId INT
	DECLARE @strBlenderName NVARCHAR(50)
	DECLARE @dblAvailableQty NUMERIC(38,20)
	DECLARE @dblSelectedQty NUMERIC(38,20)
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
	DECLARE @dblOriginalRequiredQty NUMERIC(38,20)
	DECLARE @dblPartialQuantity NUMERIC(38,20)
	DECLARE @dblRemainingRequiredQty NUMERIC(38,20)
	DECLARE @intPartialQuantityStorageLocationId INT
	DECLARE @intOriginalIssuedUOMTypeId INT
	DECLARE @intKitStagingLocationId INT
	DECLARE @intBlendStagingLocationId INT
	DECLARE @intMinPartialQtyLotRowNo INT
	DECLARE @dblAvailablePartialQty NUMERIC(38,20)
	DECLARE @intConsumptionMethodId INT
	DECLARE @intConsumptionStoragelocationId INT
	DECLARE @ysnIsSubstitute bit
	DECLARE @intPropertyCount INT
	DECLARE @intSequenceNo INT
		,@intSequenceCount INT = 1
		,@strRuleName NVARCHAR(100)
		,@strValue NVARCHAR(50)
		,@strOrderBy NVARCHAR(MAX) = ''
		,@strOrderByFinal NVARCHAR(MAX) = ''
		,@intProductTypeId INT

	Declare @intPropertyId INT
			,@strPropertyName NVARCHAR(100)
			,@dblMinValue NUMERIC(38,20)
			,@dblMaxValue NUMERIC(38,20)
			,@dblMedian NUMERIC(38,20)
			,@strPivotSelect nvarchar(max)
			,@strPivotfor nvarchar(max)
			,@strTableColumns nvarchar(max)

	DECLARE @strTbl NVARCHAR(MAX)
	DECLARE @strLot NVARCHAR(MAX)
	DECLARE @strFromTB NVARCHAR(MAX)
	--DECLARE @SQL NVARCHAR(MAX)
	DECLARE @strSQLFinal NVARCHAR(MAX)
	DECLARE @strOrderBydev nvarchar(MAX)
	DECLARE @strOrderByFIFO nvarchar(MAX)
	DECLARE @strOrderByLIFO nvarchar(MAX)
	DECLARE @strOrderByFEFO nvarchar(MAX)
	DECLARE @strOrderByCost nvarchar(MAX)
	DECLARE @strtblnameChk nvarchar(50)
	--DECLARE @strPropertName NVARCHAR(50),
    --DECLARE @Count decimal(38,0)
    DECLARE @strTblName nvarchar(MAX)
			,@intControlPointId int

	DECLARE @intRCount int ,
            @intSeq int,
			@intCount int,
			@intLotId int

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblMFCompanyPreference

	If @ysnEnableParentLot=0 
		Set @intProductTypeId=6
	Else
		Set @intProductTypeId=11

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

	SELECT @intIssuedUOMTypeId = ISNULL(intIssuedUOMTypeId, 0)
		,@strBlenderName = strName
	FROM tblMFMachine
	WHERE intMachineId = @intMachineId

	IF @intIssuedUOMTypeId = 0
	BEGIN
		--SET @strErrMsg='Please configure Issued UOM Type for machine ''' + @strBlenderName + '''.'
		--RAISERROR(@strErrMsg,16,1)
		SET @intIssuedUOMTypeId = 1
	END

	DECLARE @tblInputItem TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intRecipeId INT
		,intRecipeItemId INT
		,intItemId INT
		,dblRequiredQty NUMERIC(38,20)
		,ysnIsSubstitute BIT
		,ysnMinorIngredient BIT
		,intConsumptionMethodId INT
		,intConsumptionStoragelocationId INT
		,intParentItemId int
		)

	IF OBJECT_ID('tempdb..#tblProductProperty') IS NOT NULL
		DROP TABLE #tblProductProperty

    CREATE TABLE #tblProductProperty       
    ( 
		intRowNo		INT IDENTITY(1,1),
		intPropertyId	INT,
		strPropertyName NVARCHAR(100),  
		intProductId	INT,
		dblMinValue     NUMERIC(38,20), 
		dblMaxValue     NUMERIC(38,20), 
		dblMedian       NUMERIC(38,20), 
		intSequenceNo   INT
    )

	IF OBJECT_ID('tempdb..#tblBlendSheetLot') IS NOT NULL
		DROP TABLE #tblBlendSheetLot

	CREATE TABLE #tblBlendSheetLot (
		intParentLotId INT
		,intItemId INT
		,dblQuantity NUMERIC(38,20)
		,intItemUOMId INT
		,dblIssuedQuantity NUMERIC(38,20)
		,intItemIssuedUOMId INT
		,intRecipeItemId INT
		,intStorageLocationId INT
		,dblWeightPerQty NUMERIC(38, 20)
		)

	IF OBJECT_ID('tempdb..#tblBlendSheetLotFinal') IS NOT NULL
		DROP TABLE #tblBlendSheetLotFinal

	CREATE TABLE #tblBlendSheetLotFinal (
		intParentLotId INT
		,intItemId INT
		,dblQuantity NUMERIC(38,20)
		,intItemUOMId INT
		,dblIssuedQuantity NUMERIC(38,20)
		,intItemIssuedUOMId INT
		,intRecipeItemId INT
		,intStorageLocationId INT
		,dblWeightPerQty NUMERIC(38, 20)
		)

		IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL  
        DROP TABLE #tblNames  

        Create table #tblNames
        (                       
            intRowNo INT IDENTITY(1,1),
            strtblName nvarchar(50),
            intItemId int,
            dblRequiredQty numeric(38,20),
            dblDemandQty numeric(38,20)                                    
        )

    --to hold not available and less qty lots
	Declare @tblRemainingPickedLots AS table
	( 
		intWorkOrderInputLotId int,
		intLotId int,
		strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
		strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS,
		strDescription nvarchar(200) COLLATE Latin1_General_CI_AS,
		dblQuantity numeric(38,20),
		intItemUOMId int,
		strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
		dblIssuedQuantity numeric(38,20),
		intItemIssuedUOMId int,
		strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
		intItemId int,
		intRecipeItemId int,
		dblUnitCost numeric(38,20),
		dblDensity numeric(38,20),
		dblRequiredQtyPerSheet numeric(38,20),
		dblWeightPerUnit numeric(38,20),
		dblRiskScore numeric(38,20),
		intStorageLocationId int,
		strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
		strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
		intLocationId int,
		strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
		strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS,
		ysnParentLot bit,
		strRowState nvarchar(50) COLLATE Latin1_General_CI_AS
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
			AND ri.intConsumptionMethodId IN (1,2,3)

		UNION
	
		SELECT @intRecipeId
			,rs.intRecipeSubstituteItemId
			,rs.intSubstituteItemId AS intItemId
			,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
			,1
			,0
			,1
			,0
			,ri.intItemId
		FROM tblMFRecipeSubstituteItem rs
		JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
		JOIN tblMFRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
		WHERE r.intRecipeId = @intRecipeId
			AND rs.intRecipeItemTypeId = 1
		ORDER BY ysnMinorIngredient

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

		INSERT INTO #tblProductProperty(intPropertyId,strPropertyName,intProductId,dblMinValue,dblMaxValue,dblMedian,intSequenceNo)
		SELECT DISTINCT pt.intPropertyId,pt.strPropertyName,p.intProductValueId,pv.dblMinValue,pv.dblMaxValue,
		((ISNULL(pv.dblMinValue,0)+ISNULL(pv.dblMaxValue,0))/2) as dblMedian,pp.intSequenceNo
		From tblQMProduct p  
		JOIN tblQMProductProperty pp ON pp.intProductId=p.intProductId
		JOIN tblQMProductPropertyValidityPeriod pv ON pv.intProductPropertyId=pp.intProductPropertyId
		JOIN tblQMProperty pt ON pt.intPropertyId=pp.intPropertyId
		JOIN tblQMProductControlPoint c on c.intProductId=p.intProductId
		WHERE p.intProductValueId=@intBlendItemId
		AND p.intProductTypeId=2 AND pt.intDataTypeId in (1,2,6)
		AND c.intControlPointId=@intControlPointId
		AND p.ysnActive = 1
		ORDER BY pp.intSequenceNo

		Select @intPropertyCount = COUNT(1) From #tblProductProperty

		if @intPropertyCount=0
			RAISERROR('Please configure Quality and Formula for the output item.',16,1)

	  SET @strPivotSelect = 'intParentLotId,intItemId,SUM(dblDeviation),MAX(dblQuantity),Max(dtmCreateDate),Max(dtmExpiryDate),Max(dblUnitCost)'
	  SET @strTableColumns = 'intParentLotId INT,intItemId INT,dblDeviation numeric(38,20),dblQuantity numeric(38,20),dtmCreateDate datetime,dtmExpiryDate datetime,dblUnitCost numeric(38,20)'
	  SET @strPivotfor = ''

      Declare @intMinPropertyId INT
      Select  @intMinPropertyId=MIN(intPropertyId) from #tblProductProperty
      WHILE @intMinPropertyId is not null
      BEGIN
		  Select @intPropertyId=intPropertyId,@strPropertyName=strPropertyName,@dblMinValue=dblMinValue,@dblMaxValue=dblMaxValue,@dblMedian=dblMedian 
		  from #tblProductProperty Where intPropertyId=@intMinPropertyId 	

		  if LEN(@strPivotSelect ) > 0 
		  SET @strPivotSelect = @strPivotSelect  + ', '

		  Set @strPivotSelect = @strPivotSelect  + 'SUM(ISNULL([' + str(@intPropertyId) + '],0)) AS [' + @strPropertyName + ']' 

		  if LEN(@strPivotfor) > 0 
		  SET @strPivotfor = @strPivotfor + ', '

		  Set @strPivotfor = @strPivotfor + '[' + str(@intPropertyId) + ']'

		  if LEN(@strTableColumns) > 0 
		  SET @strTableColumns = @strTableColumns + ', '

		  Set @strTableColumns = @strTableColumns + '[' + @strPropertyName +'] Numeric(38,20)'

		  Select  @intMinPropertyId=MIN(intPropertyId) from #tblProductProperty Where intPropertyId>@intMinPropertyId
      END

	--Clean Up Code for existing tblItem global temp tables
	IF (Select COUNT(1) From tempdb.sys.objects Where name like '##tblItem%')>0
	BEGIN
		INSERT INTO #tblNames(strtblName)
		Select name From tempdb.sys.objects Where name like '##tblItem%'

		SET @intSeq=1
		SELECT @intRCount=MAX(intRowNo) FROM #tblNames
		WHILE @intSeq<=@intRCount
		BEGIN
			SELECT @strTbl='IF OBJECT_ID(''tempdb..'+ strtblName +''') IS NOT NULL DROP TABLE '+ strtblName FROM #tblNames WHERE intRowNo=@intSeq
			EXEC(@strTbl)
			Set @intSeq=@intSeq +1
		END
		DELETE FROM #tblNames
		SET @intSeq=0
		SET @intRCount=0
	END

	WHILE @intNoOfSheets > 0 --No Of Sheets Loop
	BEGIN
		SET @strSQL = ''
		Delete from #tblNames

		SELECT @intMinRowNo=MIN(intRowNo) FROM @tblInputItem
        WHILE @intMinRowNo IS NOT NULL --Item Loop
        BEGIN
			SELECT @intRecipeItemId = intRecipeItemId
				,@intRawItemId = intItemId
				,@dblRequiredQty = (dblRequiredQty / @intEstNoOfSheets)
				,@ysnMinorIngredient = ysnMinorIngredient
				,@intConsumptionMethodId = intConsumptionMethodId
				,@intConsumptionStoragelocationId = intConsumptionStoragelocationId
				,@ysnIsSubstitute=ISNULL(ysnIsSubstitute,0)
			FROM @tblInputItem
			WHERE intRowNo = @intMinRowNo
          
            IF @ysnIsSubstitute = 0  
			BEGIN
				SELECT @strTbl='CREATE TABLE ##tblItem'+RTRIM(LTRIM(convert(varchar,@intRawItemId)))+'( '+ @strTableColumns

				IF RIGHT(@strTbl,1)=','
					SET @strTbl=LEFT(@strTbl, LEN(@strTbl) - 1)
				SET @strTbl=@strTbl+') '
				EXEC(@strTbl)
            
				DECLARE @strInputTables nvarchar(max)
				SET @strInputTables=RTRIM(LTRIM('##tblItem'+convert(varchar,@intRawItemId)))
				INSERT INTO #tblNames VALUES(@strInputTables,@intRawItemId,@dblRequiredQty,@dblQtyToProduce)
			END
			ELSE
			BEGIN
				SELECT @strInputTables=strtblName FROM #tblNames WHERE intItemId=
				(SELECT intItemId FROM @tblInputItem WHERE intRecipeItemId=@intRecipeItemId AND ysnIsSubstitute=0)
			END
					
			IF OBJECT_ID('tempdb..#tblLot') IS NOT NULL
				DROP TABLE #tblLot

			CREATE TABLE #tblLot (
				intLotId INT
				,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intItemId INT
				,dblQty NUMERIC(38,20)
				,intLocationId INT
				,intSubLocationId INT
				,intStorageLocationId INT
				,dtmCreateDate DATETIME
				,dtmExpiryDate DATETIME
				,dblUnitCost NUMERIC(38,20)
				,dblWeightPerQty NUMERIC(38, 20)
				,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intParentLotId INT
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				)

			IF OBJECT_ID('tempdb..#tblParentLot') IS NOT NULL
				DROP TABLE #tblParentLot

			CREATE TABLE #tblParentLot (
				intParentLotId INT
				,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intItemId INT
				,dblQty NUMERIC(38,20)
				,intLocationId INT
				,intSubLocationId INT
				,intStorageLocationId INT
				,dtmCreateDate DATETIME
				,dtmExpiryDate DATETIME
				,dblUnitCost NUMERIC(38,20)
				,dblWeightPerQty NUMERIC(38, 20)
				,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intItemUOMId INT
				,intItemIssuedUOMId INT
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
			WHERE L.intItemId = @intRawItemId
				AND L.intLocationId = @intLocationId
				AND LS.strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
				AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
				AND L.dblWeight > 0
				AND L.intStorageLocationId NOT IN (
					ISNULL(@intKitStagingLocationId,0)
					,ISNULL(@intBlendStagingLocationId,0)
					--,@intPartialQuantityStorageLocationId
					) --Exclude Kit Staging,Blend Staging,Partial Qty Storage Locations

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

				SET @strSQL ='INSERT INTO '+ @strInputTables + 
				' SELECT ' + @strPivotSelect + 
					'FROM (
						SELECT * From ( 
						SELECT DISTINCT pl.intParentLotId
							,pl.intItemId
							,ABS(ISNULL(r.strPropertyValue, 0) - ISNULL(p.dblMedian, 0)) AS dblDeviation
							,isnull(p.strPropertyName, '''') AS strPropertyName
							,r.intPropertyId
							,(
								pl.dblQty - (
									ISNULL(('

				If @ysnEnableParentLot=0
					SET @strSQL = @strSQL + ' 
											SELECT sum(dblQty)
											FROM tblICStockReservation
											WHERE intLotId = pl.intParentLotId AND ISNULL(ysnPosted,0)=0
											), 0) + (
										SELECT isnull(sum(dblQuantity), 0)
										FROM #tblBlendSheetLot
										WHERE intParentLotId = pl.intParentLotId '

				If @ysnEnableParentLot=1
				Begin
				If @ysnShowAvailableLotsByStorageLocation=1
					SET @strSQL = @strSQL + ' 
							SELECT sum(dblQty)
							FROM tblICStockReservation
							WHERE intParentLotId = pl.intParentLotId
							AND intStorageLocationId = pl.intStorageLocationId AND ISNULL(ysnPosted,0)=0
							), 0) + (
						SELECT isnull(sum(dblQuantity), 0)
						FROM #tblBlendSheetLot
						WHERE intParentLotId = pl.intParentLotId '
				Else
						SET @strSQL = @strSQL + ' 
								SELECT sum(dblQty)
								FROM tblICStockReservation
								WHERE intParentLotId = pl.intParentLotId AND ISNULL(ysnPosted,0)=0
								), 0) + (
							SELECT isnull(sum(dblQuantity), 0)
							FROM #tblBlendSheetLot
							WHERE intParentLotId = pl.intParentLotId '
				End

				SET @strSQL = @strSQL + ' ) )
								) AS dblQuantity
							,pl.dtmCreateDate
							,pl.dtmExpiryDate
							,pl.dblUnitCost
							,CONVERT(NUMERIC(38,20), ISNULL(r.strPropertyValue, 0)) AS dblPropertyValue
							,p.dblMedian
							,p.dblMaxValue
							,p.dblMinValue
						FROM #tblProductProperty p
						INNER JOIN tblQMTestResult AS r ON p.intPropertyId=r.intPropertyId
							AND ISNUMERIC(r.strPropertyValue) = 1
						INNER JOIN #tblParentLot pl ON r.intProductValueId=pl.intParentLotId
							AND r.intProductTypeId = ' + CONVERT(varchar,@intProductTypeId) + '
							AND (pl.dtmExpiryDate IS NULL OR pl.dtmExpiryDate >= getdate())
							AND r.intSampleId = (
								SELECT MAX(intSampleId)
								FROM tblQMTestResult
								WHERE intProductValueId = pl.intParentLotId
									AND intProductTypeId = ' + CONVERT(varchar,@intProductTypeId) + '
								)
						WHERE pl.intItemId = '+ CONVERT(varchar,@intRawItemId) + '
							AND pl.dblQty > 0
							AND pl.intLocationId = '+ CONVERT(varchar,@intLocationId) +'
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
					HAVING dblQuantity > 0'

				exec sp_executesql @strSQL
				  
                SELECT @intMinRowNo=MIN(intRowNo) FROM @tblInputItem WHERE intRowNo>@intMinRowNo
        END

	SET @strSQLFinal =''
	SET @strOrderBydev =''
	SET @strOrderByFIFO =''
	SET @strOrderByLIFO =''
	SET @strOrderByFEFO =''
	SET @strOrderByCost =''
	SET @strtblnameChk =''
	--DECLARE @strPropertName NVARCHAR(50),
    --DECLARE @Count decimal(38,0)
    SET @strTblName =''

	 Declare @intMinProductProperty INT
	 Select @intMinProductProperty=MIN(intRowNo) From #tblProductProperty
     
	 WHILE @intMinProductProperty is not null
      BEGIN
		Select @strPropertyName=strPropertyName,@dblMedian=dblMedian,@intSequenceNo=intSequenceNo From #tblProductProperty Where intRowNo=@intMinProductProperty

		SET @strPropertyName= '['+ @strPropertyName + ']' 
		SET @strSQL=''
		SET @strLot=''
		SET @strFromTB=''
  
		Declare @intMinTableName INT
		Select @intMinTableName=MIN(intRowNo) From #tblNames

            WHILE @intMinTableName is not null
            BEGIN                
				Select @intCount=intRowNo,@strTblName=strtblName,@intRawItemId=intItemId,@dblRequiredQty=dblRequiredQty,@dblQtyToProduce=dblDemandQty 
				from #tblNames Where intRowNo=@intMinTableName
				                     
				SET @strSQL = @strSQL + '('+ @strTblName +'.'+ @strPropertyName+'* ' + LTRIM(str(@dblRequiredQty)) + ')' + '+' 
                                                      
				declare @aliasName nvarchar(max)
				set @aliasName='['+'Lot'+ convert(nvarchar,@intRawItemId) + ']'

				SET @strLot=@strLot + @strTblName +'.'+ 'intParentLotId as '+ @aliasName +','+ @strTblName +'.'+ 'intItemId as ' +@strTblName +','+ @strTblName +'.'
				+ 'dblQuantity as ' +@strTblName + 'Qty'+',' + @strTblName +'.'+ 'dtmCreateDate as ' + @strTblName + 'CDate ' + ','  + @strTblName +'.'+ 'dtmExpiryDate as ' 
				+ @strTblName + 'EDate' + ',' + @strTblName +'.'+ 'dblUnitCost as ' + @strTblName + 'Clb' + ','
				SET @strFromTB=@strFromTB + @strTblName + ','
			 
				if CHARINDEX(@strTblName,@strOrderByCost) = 0
				SET @strOrderByCost = @strOrderByCost + @strTblName + 'Clb ASC, ' 

				if CHARINDEX(@strTblName,@strOrderByFIFO) = 0
				SET @strOrderByFIFO =@strOrderByFIFO + @strTblName + 'CDate ASC, '

				if CHARINDEX(@strTblName,@strOrderByLIFO) = 0
				SET @strOrderByLIFO =@strOrderByLIFO + @strTblName + 'CDate DESC, ' 

				if CHARINDEX(@strTblName,@strOrderByFEFO) = 0
				SET @strOrderByFEFO=@strOrderByFEFO+ + @strTblName + 'EDate ASC, '
								
				Select @intMinTableName=MIN(intRowNo) From #tblNames Where intRowNo>@intMinTableName
			END 
               		
        IF RIGHT(@strSQL,1)='+'
        SET @strSQL=LEFT(@strSQL, LEN(@strSQL) - 1)
            
        SET @strSQLFinal = @strSQLFinal + '(' + @strSQL + ')' + '/' + LTRIM(CONVERT(NVARCHAR,@dblQtyToProduce)) +' AS ' + @strPropertyName  +' ,' + + 'ABS(((' + @strSQL + ')' + '/' + 
		LTRIM(CONVERT(NVARCHAR,@dblQtyToProduce))+') -' + LTRIM(CONVERT(NVARCHAR,@dblMedian)) +') AS ' + LEFT(@strPropertyName, LEN(@strPropertyName) - 1)   +'dblDeviation]'+','
		if CHARINDEX(@strTblName,@strOrderBydev) = 0                
		SET @strOrderBydev= @strOrderBydev + LEFT(@strPropertyName, LEN(@strPropertyName) - 1)   +'dblDeviation] ASC'+','

		Select @intMinProductProperty=MIN(intRowNo) From #tblProductProperty Where intRowNo>@intMinProductProperty
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
		SET @strOrderByFinal = LEFT(@strOrderByFinal, LEN(@strOrderByFinal) - 1)

      IF RIGHT(@strFromTB,1)=','
      SET @strFromTB=' INTO ##tblResult FROM '+LEFT(@strFromTB, LEN(@strFromTB) - 1) + ' Order By ' + @strOrderByFinal

	  IF RIGHT(@strSQLFinal,1)=','
      SET @strSQLFinal=LEFT(@strSQLFinal, LEN(@strSQLFinal) - 1)

	  IF OBJECT_ID('tempdb..##tblResult') IS NOT NULL  
      DROP TABLE ##tblResult  

      exec('Select Top 100 '  + @strLot + @strSQLFinal + @strFromTB )

	  --TO CHECK
     IF NOT EXISTS(SELECT * from ##tblResult)
	 Begin    
		Raiserror('There are no lots for one or more ingredient item(s) to process further.',16,1)
		Return
	 End

		--Minor Ingredient
		DECLARE @dblQuantityTaken NUMERIC(38,20)
		DECLARE @ysnPercResetRequired BIT = 0
		DECLARE @sRequiredQty NUMERIC(38,20)

		SELECT @intMinRowNo = MIN(intRowNo)
		FROM @tblInputItem

		WHILE @intMinRowNo IS NOT NULL
		BEGIN
			SELECT @intRecipeItemId = intRecipeItemId
				,@intRawItemId = intItemId
				,@dblRequiredQty = (dblRequiredQty / @intEstNoOfSheets)
				,@ysnMinorIngredient = ysnMinorIngredient
				,@intConsumptionMethodId = intConsumptionMethodId
				,@intConsumptionStoragelocationId = intConsumptionStoragelocationId
				,@ysnIsSubstitute=ysnIsSubstitute
			FROM @tblInputItem
			WHERE intRowNo = @intMinRowNo

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

            SET @dblAvailableQty =0

			--Substitute
			DECLARE @dblQty numeric(38,20)
			DECLARE @dblInputReqQty numeric(38,20)
			DECLARE @dblRemainingQty numeric(38,20)
			DECLARE @intInputItemId int

			IF @ysnIsSubstitute=1
			BEGIN
				SELECT @intInputItemId=intItemId,@dblInputReqQty=dblRequiredQty/@intNoOfSheets FROM @tblInputItem WHERE intRecipeItemId=@intRecipeItemId AND ysnIsSubstitute=0
				IF EXISTS(SELECT * FROM #tblBlendSheetLot WHERE intItemId=@intInputItemId)	
				BEGIN
					SELECT @dblQty=SUM(dblQuantity) FROM #tblBlendSheetLot WHERE intItemId=@intInputItemId
					SET @dblRemainingQty= @dblInputReqQty-@dblQty			
					SET @dblRequiredQty = @dblRemainingQty 
				END
				ELSE
				BEGIN
					SELECT @intInputItemId=intItemId,@dblInputReqQty=dblRequiredQty/@intNoOfSheets FROM @tblInputItem WHERE intRecipeItemId=@intRecipeItemId AND ysnIsSubstitute=0
					SET @dblRequiredQty =@dblInputReqQty 
				END
					  		 				
			END
			ELSE
			BEGIN
				SELECT @intInputItemId=@intRawItemId
			END 

			IF OBJECT_ID('tempdb..##tblBestLot') IS NOT NULL  
            DROP TABLE ##tblBestLot  

			IF OBJECT_ID('tempdb..##tblBestResultFinal') IS NOT NULL  
			DROP TABLE ##tblBestResultFinal  

			Select Top 1 * into ##tblBestResultFinal from ##tblResult

			DECLARE @strSQL1 NVARCHAR(MAX)
            SET @strSQL1='SELECT TOP 1 Lot'+ ltrim(@intInputItemId) +' as intLotId, ##tblItem' +ltrim(@intInputItemId) +' as intItemId,'+
			'##tblItem'+ltrim(@intInputItemId)+'Qty as dblAvailableQty' 
			+ ' INTO ##tblBestLot FROM ##tblResult WHERE  ##tblItem'+ltrim(@intInputItemId) +' = '+ltrim(str(@intRawItemId)) 

			EXEC(@strSQL1)
                  
			SELECT @intLotId=intLotId,@dblAvailableQty=dblAvailableQty FROM ##tblBestLot   

			If @ysnEnableParentLot=0
				Select @dblWeightPerQty=CASE WHEN ISNULL(dblWeightPerQty,0)=0 THEN 1 ELSE dblWeightPerQty END From tblICLot Where intLotId=@intLotId
			Else
				Select TOP 1 @dblWeightPerQty=CASE WHEN ISNULL(dblWeightPerQty,0)=0 THEN 1 ELSE dblWeightPerQty END From tblICLot Where intParentLotId=@intLotId AND dblWeight>0

			IF @intIssuedUOMTypeId = 2 --'BAG' 
				SET @dblAvailableQty = @dblAvailableQty - (@dblAvailableQty % @dblWeightPerQty)

			IF @dblAvailableQty > 0 
			BEGIN
	
				IF(@dblAvailableQty>=@dblRequiredQty) 
					SET @dblSelectedQty=@dblRequiredQty
				ELSE
					SET @dblSelectedQty=@dblAvailableQty

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
											ELSE Convert(numeric(38,20),Floor(@dblSelectedQty / L.dblWeightPerQty))
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
					FROM tblICLot L
					WHERE L.intLotId = @intLotId
						AND L.dblWeight > 0
				ELSE
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
						)
					SELECT TOP 1 L.intParentLotId
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
							ELSE @dblSelectedQty -- To Review ROUND(@dblSelectedQty,3) 
							END AS dblQuantity
						,L.intWeightUOMId AS intItemUOMId
						,CASE 
							WHEN @intIssuedUOMTypeId = 2
								THEN (
										CASE 
											WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
												THEN 1
											ELSE Convert(numeric(38,20),Floor(@dblSelectedQty / L.dblWeightPerQty))
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
						,CASE 
							WHEN @ysnShowAvailableLotsByStorageLocation = 1
								THEN L.intStorageLocationId
							ELSE 0
							END AS intStorageLocationId
						,L.dblWeightPerQty
					FROM tblICLot L
					WHERE L.intParentLotId = @intLotId AND L.dblWeight > 0

				IF(@dblAvailableQty>=@dblRequiredQty) 
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

			DECLARE @strJoinClause nvarchar(max) =''
			SELECT @strJoinClause=ISNULL(@strJoinClause,'') +' and  a.'+ a.name +' = ' +' b.'+a.name 
			FROM sys.columns AS a 
			JOIN sys.objects AS b ON a.object_id=b.object_id 
			WHERE b.name='##tblResult' 
			AND a.name LIKE 'Lot%'
			AND a.name <> 'Lot' + CONVERT(varchar,@intInputItemId)

			DECLARE @strSQL2 NVARCHAR(MAX)
			SET @strSQL2='SELECT a.Lot'+ltrim(@intInputItemId) +', a.##tblItem' +ltrim(@intInputItemId) +','
			+'a.##tblItem'+ltrim(@intInputItemId)+'Qty ' + ' INTO ##tblNextBestLot FROM ##tblResult a,##tblBestResultFinal b'++' WHERE a.##tblItem'+ltrim(@intInputItemId) +' = '
			+ltrim(str(@intRawItemId))+' AND a.Lot'+ltrim(@intInputItemId)+'<>'''+ltrim(@intLotId) +''''+ @strJoinClause

			EXEC(@strSQL2)

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
			WHERE L.intItemId = @intRawItemId
				AND L.intLocationId = @intLocationId
				AND LS.strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
				AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
				AND L.dblWeight > 0
				AND L.intStorageLocationId NOT IN (
					ISNULL(@intKitStagingLocationId,0)
					,ISNULL(@intBlendStagingLocationId,0)
					--,@intPartialQuantityStorageLocationId
					) --Exclude Kit Staging,Blend Staging,Partial Qty Storage Locations

			DECLARE @intMinBestPick INT
			SELECT @intMinBestPick=MIN(intLotId) FROM ##tblNextBestLot                        

			WHILE EXISTS (SELECT 1 FROM ##tblNextBestLot)                        
			BEGIN
				Select @intLotId=intLotId,@intRawItemId=intItemId,@dblAvailableQty=dblAvailableQty From ##tblNextBestLot Where intLotId=@intMinBestPick

				If @ysnEnableParentLot=0
					Select @dblWeightPerQty=CASE WHEN ISNULL(dblWeightPerQty,0)=0 THEN 1 ELSE dblWeightPerQty END From tblICLot Where intLotId=@intLotId
				Else
					Select TOP 1 @dblWeightPerQty=CASE WHEN ISNULL(dblWeightPerQty,0)=0 THEN 1 ELSE dblWeightPerQty END From tblICLot Where intParentLotId=@intLotId AND dblWeight>0

				IF @intIssuedUOMTypeId = 2 --'BAG' 
					SET @dblAvailableQty = @dblAvailableQty - (@dblAvailableQty % @dblWeightPerQty)

				IF @dblAvailableQty > 0 
				BEGIN
	
					IF(@dblAvailableQty>=@dblRequiredQty) 
						SET @dblSelectedQty=@dblRequiredQty
					ELSE
						SET @dblSelectedQty=@dblAvailableQty

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
												ELSE Convert(numeric(38,20),Floor(@dblSelectedQty / L.dblWeightPerQty))
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
						FROM tblICLot L
						WHERE L.intLotId = @intLotId
							AND L.dblWeight > 0
					ELSE
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
							)
						SELECT TOP 1 L.intParentLotId
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
								ELSE @dblSelectedQty -- To Review ROUND(@dblSelectedQty,3) 
								END AS dblQuantity
							,L.intWeightUOMId AS intItemUOMId
							,CASE 
								WHEN @intIssuedUOMTypeId = 2
									THEN (
											CASE 
												WHEN Floor(@dblSelectedQty / L.dblWeightPerQty) = 0
													THEN 1
												ELSE Convert(numeric(38,20),Floor(@dblSelectedQty / L.dblWeightPerQty))
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
							,CASE 
								WHEN @ysnShowAvailableLotsByStorageLocation = 1
									THEN L.intStorageLocationId
								ELSE 0
								END AS intStorageLocationId
							,L.dblWeightPerQty
						FROM tblICLot L
						WHERE L.intParentLotId = @intLotId AND L.dblWeight > 0

					IF(@dblAvailableQty>=@dblRequiredQty) 
						BEGIN
							SET @dblRequiredQty = 0
							GOTO LOOP_END
						END
					ELSE
						SET @dblRequiredQty = @dblRequiredQty - @dblAvailableQty

				END
                  
				Select @intLotId=intLotId,@intRawItemId=intItemId,@dblAvailableQty=dblAvailableQty From ##tblNextBestLot Where intLotId>@intMinBestPick  
			END
			LOOP_END:	
			--End Search for next best lot

			IF OBJECT_ID('tempdb..##tblBestResultFinal') IS NOT NULL  
			Drop table ##tblBestResultFinal

			IF OBJECT_ID('tempdb..##tblBestLot') IS NOT NULL 
			Drop table ##tblBestLot

			IF OBJECT_ID('tempdb..##tblNextBestLot') IS NOT NULL 
			DROP table ##tblNextBestLot

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblInputItem
			WHERE intRowNo > @intMinRowNo
		END --While Loop End For Per Recipe Item

		IF OBJECT_ID('tempdb..##tblResult') IS NOT NULL  
		DROP TABLE ##tblResult  
	  
		SET @intPropertyCount=0
		SELECT @intPropertyCount=COUNT(*) FROM #tblNames

		IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL AND  @intPropertyCount > 0
		BEGIN
			SET @intSeq=1
			SELECT @intRCount=MAX(intRowNo) FROM #tblNames
			WHILE @intSeq<=@intRCount
			BEGIN
				SELECT @strTbl='IF OBJECT_ID(''tempdb..'+ strtblName +''') IS NOT NULL DROP TABLE '+ strtblName FROM #tblNames WHERE intRowNo=@intSeq
				EXEC(@strTbl)
				Set @intSeq=@intSeq +1
			END
		END 
				  
	  Set @strLot=''
	  Set @strSQLFinal =''
	  Set @strFromTB=''

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
			--,(
			--	SELECT TOP 1 (CAST(PropertyValue AS NUMERIC(38,20))) AS PropertyValue
			--	FROM dbo.QM_TestResult AS TR
			--	INNER JOIN dbo.QM_Property AS P ON P.PropertyKey = TR.PropertyKey
			--	WHERE ProductObjectKey = PL.MainLotKey
			--		AND TR.ProductTypeKey = 16
			--		AND P.PropertyName IN (
			--			SELECT V.SettingValue
			--			FROM dbo.iMake_AppSettingValue AS V
			--			INNER JOIN dbo.iMake_AppSetting AS S ON V.SettingKey = S.SettingKey
			--				AND S.SettingName = '' Average Density ''
			--			)
			--		AND PropertyValue IS NOT NULL
			--		AND PropertyValue <> ''''
			--		AND isnumeric(tr.PropertyValue) = 1
			--	ORDER BY TR.LastUpdateOn DESC
			--	) AS 'Density' --To Review
			,CAST(0 AS DECIMAL) AS dblDensity
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
		Select * From @tblRemainingPickedLots
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
			,0.0 AS dblUnitCost -- Review
			--,(
			--	SELECT TOP 1 (CAST(PropertyValue AS NUMERIC(38,20))) AS PropertyValue
			--	FROM dbo.QM_TestResult AS TR
			--	INNER JOIN dbo.QM_Property AS P ON P.PropertyKey = TR.PropertyKey
			--	WHERE ProductObjectKey = PL.MainLotKey
			--		AND TR.ProductTypeKey = 16
			--		AND P.PropertyName IN (
			--			SELECT V.SettingValue
			--			FROM dbo.iMake_AppSettingValue AS V
			--			INNER JOIN dbo.iMake_AppSetting AS S ON V.SettingKey = S.SettingKey
			--				AND S.SettingName = '' Average Density ''
			--			)
			--		AND PropertyValue IS NOT NULL
			--		AND PropertyValue <> ''''
			--		AND isnumeric(tr.PropertyValue) = 1
			--	ORDER BY TR.LastUpdateOn DESC
			--	) AS 'Density' --To Review
			,CAST(0 AS DECIMAL) AS dblDensity
			,(BS.dblQuantity / @intEstNoOfSheets) AS dblRequiredQtyPerSheet
			,BS.dblWeightPerQty AS dblWeightPerUnit
			,ISNULL(I.dblRiskScore, 0) AS dblRiskScore
			,BS.intStorageLocationId
			,SL.strName AS strStorageLocationName
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
		INNER JOIN tblICStorageLocation SL ON SL.intStorageLocationId = BS.intStorageLocationId
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
			,0.0 AS dblUnitCost -- Review
			--,(
			--	SELECT TOP 1 (CAST(PropertyValue AS NUMERIC(38,20))) AS PropertyValue
			--	FROM dbo.QM_TestResult AS TR
			--	INNER JOIN dbo.QM_Property AS P ON P.PropertyKey = TR.PropertyKey
			--	WHERE ProductObjectKey = PL.MainLotKey
			--		AND TR.ProductTypeKey = 16
			--		AND P.PropertyName IN (
			--			SELECT V.SettingValue
			--			FROM dbo.iMake_AppSettingValue AS V
			--			INNER JOIN dbo.iMake_AppSetting AS S ON V.SettingKey = S.SettingKey
			--				AND S.SettingName = '' Average Density ''
			--			)
			--		AND PropertyValue IS NOT NULL
			--		AND PropertyValue <> ''''
			--		AND isnumeric(tr.PropertyValue) = 1
			--	ORDER BY TR.LastUpdateOn DESC
			--	) AS 'Density' --To Review
			,CAST(0 AS DECIMAL) AS dblDensity
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
                
	SET @intPropertyCount=0
	SELECT @intPropertyCount=COUNT(*) FROM #tblNames

	IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL AND  @intPropertyCount > 0
	BEGIN
		SET @intSeq=1
		SELECT @intRCount=MAX(intRowNo) FROM #tblNames
		WHILE @intSeq<=@intRCount
		BEGIN
			SELECT @strTbl='IF OBJECT_ID(''tempdb..'+ strtblName +''') IS NOT NULL DROP TABLE '+ strtblName FROM #tblNames WHERE intRowNo=@intSeq
			EXEC(@strTbl)
			Set @intSeq=@intSeq +1
		END
	END 

	IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL  
	DROP TABLE #tblNames  

END TRY

BEGIN CATCH
	--Clean Up Code
	IF OBJECT_ID('tempdb..#tblNames') IS NOT NULL AND  @intPropertyCount > 0
	BEGIN
		SET @intSeq=1
		SELECT @intRCount=MAX(intRowNo) FROM #tblNames
		WHILE @intSeq<=@intRCount
		BEGIN
			SELECT @strTbl='IF OBJECT_ID(''tempdb..'+ strtblName +''') IS NOT NULL DROP TABLE '+ strtblName FROM #tblNames WHERE intRowNo=@intSeq
			EXEC(@strTbl)
			Set @intSeq=@intSeq +1
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
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
