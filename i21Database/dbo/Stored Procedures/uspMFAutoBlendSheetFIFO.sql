CREATE PROCEDURE [dbo].[uspMFAutoBlendSheetFIFO] @intLocationId INT
	,@intBlendRequirementId INT
	,@dblQtyToProduce NUMERIC(38,20)
	,@strXml NVARCHAR(MAX) = NULL
	,@ysnFromPickList bit = 0
	,@strExcludedLotXml NVARCHAR(MAX) = NULL
	,@strWorkOrderIds nvarchar(max) = NULL
	,@intItemId int = null
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	SET NOCOUNT ON

	DECLARE @intBlendItemId INT
	DECLARE @strBlendItemNo NVARCHAR(50)
	DECLARE @dblRequiredQty NUMERIC(38,20)
	DECLARE @intMinRowNo INT
	DECLARE @intRecipeItemId INT
	DECLARE @intRawItemId INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intIssuedUOMTypeId INT
	DECLARE @ysnMinorIngredient BIT
	DECLARE @dblPercentageIncrease NUMERIC(38,20) = 0
	DECLARE @intNoOfSheets INT = 1
	DECLARE @intStorageLocationId INT
	DECLARE @intRecipeId INT
	DECLARE @strBlenderName NVARCHAR(50)
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @dblAvailableQty NUMERIC(38,20)
	DECLARE @intEstNoOfSheets INT
	DECLARE @dblWeightPerQty NUMERIC(38, 20)
	DECLARE @intMachineId INT
	DECLARE @strSQL NVARCHAR(MAX)
	DECLARE @ysnEnableParentLot BIT = 0
	DECLARE @ysnShowAvailableLotsByStorageLocation BIT = 0
	DECLARE @intManufacturingProcessId INT
	DECLARE @intParentLotId INT
	DECLARE @ysnRecipeItemValidityByDueDate BIT = 0
	DECLARE @intDayOfYear INT
	DECLARE @dtmDate DATETIME
	DECLARE @dtmDueDate DATETIME
	DECLARE @dblOriginalRequiredQty NUMERIC(38,20)
	DECLARE @dblPartialQuantity NUMERIC(38,20)
	DECLARE @dblRemainingRequiredQty NUMERIC(38,20)
	DECLARE @intPartialQuantitySubLocationId INT
	DECLARE @intOriginalIssuedUOMTypeId INT
	DECLARE @intKitStagingLocationId INT
	DECLARE @intBlendStagingLocationId INT
	DECLARE @intMinPartialQtyLotRowNo INT
	DECLARE @dblAvailablePartialQty NUMERIC(38,20)
	DECLARE @idoc int 
	DECLARE @idoc1 int 
	DECLARE @intConsumptionMethodId INT
	DECLARE @intConsumptionStoragelocationId INT
	DECLARE @ysnIsSubstitute bit
	DECLARE @intWorkOrderId INT
	DECLARE @dblBulkItemAvailableQty NUMERIC(38,20)
	DECLARE @dblRecipeQty NUMERIC(38,20)
	DECLARE @strLotTracking NVARCHAR(50)
	DECLARE @intItemUOMId INT
	Declare @index int
	Declare @id int
	Declare @ysnWOStagePick bit=0
	Declare @ysnIncludeKitStagingLocation bit=0

	DECLARE @intSequenceNo INT
		,@intSequenceCount INT = 1
		,@strRuleName NVARCHAR(100)
		,@strValue NVARCHAR(50)
		,@strOrderBy NVARCHAR(100) = ''
		,@strOrderByFinal NVARCHAR(100) = ''

	If @ysnFromPickList=0
		SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
		FROM tblMFCompanyPreference

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

	If ISNULL(@intBlendRequirementId,0)=0
	Begin
		Select @intBlendItemId=intItemId,@strBlendItemNo=strItemNo
		From tblICItem Where intItemId=@intItemId

		Set @intEstNoOfSheets=1
		Set @intNoOfSheets=1
		Set @dtmDueDate=GETDATE()
	End

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

	SELECT @intPartialQuantitySubLocationId = ISNULL(pa.strAttributeValue, 0)
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Partial Quantity Sub Location'

	SELECT @intKitStagingLocationId = pa.strAttributeValue
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Kit Staging Location'

	SELECT @ysnIncludeKitStagingLocation = CASE 
			WHEN UPPER(pa.strAttributeValue) = 'TRUE'
				THEN 1
			ELSE 0
			END
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Include Kit Staging Location In Pick List'

	If ISNULL(@ysnIncludeKitStagingLocation,0)=1 
		Set @intKitStagingLocationId=0

	SELECT @intBlendStagingLocationId = ISNULL(intBlendProductionStagingUnitId, 0)
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

	SELECT @intIssuedUOMTypeId = ISNULL(intIssuedUOMTypeId, 0)
		,@strBlenderName = strName
	FROM tblMFMachine
	WHERE intMachineId = @intMachineId

	IF ISNULL(@intIssuedUOMTypeId,0) = 0
	BEGIN
		--SET @strErrMsg='Please configure Issued UOM Type for machine ''' + @strBlenderName + '''.'
		--RAISERROR(@strErrMsg,16,1)
		SET @intIssuedUOMTypeId = 1
	END

	SET @intOriginalIssuedUOMTypeId = @intIssuedUOMTypeId

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
		,dblSubstituteRatio NUMERIC(38,20)
		,dblMaxSubstituteRatio NUMERIC(38,20)
		,strLotTracking NVARCHAR(50)
		,intItemUOMId int
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
		intSubLocationId int,
		strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS,
		ysnParentLot bit,
		strRowState nvarchar(50) COLLATE Latin1_General_CI_AS
	)

	DECLARE @tblPickedItem TABLE(
		 intRowNo INT IDENTITY
		,intItemStockUOMId INT
		,intItemId INT
		,dblQty NUMERIC(38,20)
		,intItemUOMId INT
		,intLocationId INT
		,intSubLocationId INT
		,intStorageLocationId INT
	)

	Declare @tblLotStatus AS Table
	(
		strStatusName nvarchar(50) COLLATE Latin1_General_CI_AS
	)

	Insert Into @tblLotStatus(strStatusName) Values('Active')

	If @ysnFromPickList=0
		Insert Into @tblLotStatus(strStatusName) Values('Quarantine')

	DECLARE @tblExcludedLot TABLE (
		 intItemId INT 
		,intLotId INT
	)

	Declare @tblWorkOrder AS table
	(
		intWorkOrderId int
	)

	Declare @tblWOStagingLocation AS table
	(
		intStagingLocationId int
	)

	--Get the Comma Separated Work Order Ids into a table
	If ISNULL(@strWorkOrderIds,'')<>''
	Begin
		SET @index = CharIndex(',',@strWorkOrderIds)
		WHILE @index > 0
		BEGIN
				SET @id = SUBSTRING(@strWorkOrderIds,1,@index-1)
				SET @strWorkOrderIds = SUBSTRING(@strWorkOrderIds,@index+1,LEN(@strWorkOrderIds)-@index)

				INSERT INTO @tblWorkOrder values (@id)
				SET @index = CharIndex(',',@strWorkOrderIds)
		END
		SET @id=@strWorkOrderIds
		INSERT INTO @tblWorkOrder values (@id)
	End

	If (Select Count(1) From @tblWorkOrder)=0
		Select TOP 1 @intWorkOrderId=intWorkOrderId From tblMFWorkOrder Where intBlendRequirementId=@intBlendRequirementId AND ISNULL(intSalesOrderLineItemId,0)>0
	Else
		Begin
			Select TOP 1 @intWorkOrderId=intWorkOrderId From @tblWorkOrder

			INSERT INTO @tblWOStagingLocation
			Select DISTINCT oh.intStagingLocationId From tblMFStageWorkOrder sw Join @tblWorkOrder w on sw.intWorkOrderId=w.intWorkOrderId
			Join tblMFOrderHeader oh on sw.intOrderHeaderId=oh.intOrderHeaderId Where ISNULL(oh.intStagingLocationId,0)>0

			If (Select Count(1) From @tblWOStagingLocation)>0 
				Set @ysnWOStagePick=1
		End

	--Get Recipe Input Items
	--@strXml (if it has value)- Used For Picking Specific Recipe Items with qty full or remaining qty
	--Called From uspMFGetPickListDetails
	If ISNULL(@strXml,'')=''
	Begin
		If Exists (Select 1 From tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId)
		Begin
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
			JOIN tblICItem i on ri.intItemId=i.intItemId
			WHERE r.intWorkOrderId=@intWorkOrderId
				AND ri.intRecipeItemTypeId = 1 AND ri.intConsumptionMethodId IN (1,2,3)
	
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
			JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId AND ri.intWorkOrderId=r.intWorkOrderId
			JOIN tblICItem i on rs.intSubstituteItemId=i.intItemId
			WHERE r.intWorkOrderId = @intWorkOrderId
				AND rs.intRecipeItemTypeId = 1
			ORDER BY ysnIsSubstitute, ysnMinorIngredient

				Select @dblRecipeQty=dblQuantity From tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId
		End
		Else
		Begin
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
			JOIN tblICItem i on ri.intItemId=i.intItemId
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
			JOIN tblMFRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
			JOIN tblICItem i on ri.intItemId=i.intItemId
			WHERE r.intRecipeId = @intRecipeId
				AND rs.intRecipeItemTypeId = 1
			ORDER BY ysnIsSubstitute,ysnMinorIngredient

			Select @dblRecipeQty=dblQuantity From tblMFRecipe Where intRecipeId=@intRecipeId
		End

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
		End
	Else
	Begin
		Set @intNoOfSheets=1
		EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml 
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
			)
		 Select intRecipeId,intRecipeItemId,intItemId,dblRequiredQty,ysnIsSubstitute,0,intConsumptionMethodId,intConsumptionStoragelocationId,intParentItemId,1,100
		 FROM OPENXML(@idoc, 'root/item', 2)  
		 WITH ( 
			intRecipeId int, 
			intRecipeItemId int,
			intItemId int,
			dblRequiredQty numeric(38,20),
			ysnIsSubstitute bit,
			intConsumptionMethodId int,
			intConsumptionStoragelocationId int,
			intParentItemId int
			) ORDER BY ysnIsSubstitute
		IF @idoc <> 0 EXEC sp_xml_removedocument @idoc

		--update substitute ratio
		If ISNULL(@intWorkOrderId,0)>0
			Update ti Set ti.dblSubstituteRatio=rs.dblSubstituteRatio,ti.dblMaxSubstituteRatio=rs.dblMaxSubstituteRatio 
			From @tblInputItem ti Join tblMFWorkOrderRecipeSubstituteItem rs on ti.intItemId=rs.intSubstituteItemId AND ti.intParentItemId=rs.intItemId
			Where rs.intWorkOrderId=@intWorkOrderId AND ti.ysnIsSubstitute=1
		Else
		If ISNULL(@intRecipeId,0)>0
			Update ti Set ti.dblSubstituteRatio=rs.dblSubstituteRatio,ti.dblMaxSubstituteRatio=rs.dblMaxSubstituteRatio 
			From @tblInputItem ti Join tblMFRecipeSubstituteItem rs on ti.intItemId=rs.intSubstituteItemId AND ti.intParentItemId=rs.intItemId
			Where rs.intRecipeId=@intRecipeId AND ti.ysnIsSubstitute=1			
	End

	--Get the Excluded Lots From Pick List/Add Lot
	If LTRIM(RTRIM(ISNULL(@strExcludedLotXml,''))) <> ''
	Begin
		EXEC sp_xml_preparedocument @idoc1 OUTPUT, @strExcludedLotXml

			INSERT INTO @tblExcludedLot (
			intItemId
			,intLotId
			)
		 Select intItemId,intLotId
		 FROM OPENXML(@idoc1, 'root/lot', 2)  
		 WITH ( 
			intItemId int, 
			intLotId int
			)

		IF @idoc1 <> 0 EXEC sp_xml_removedocument @idoc1
	End

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
				SET @strOrderBy = 'PL.dtmCreateDate ASC,'
			ELSE IF @strValue = 'LIFO'
				SET @strOrderBy = 'PL.dtmCreateDate DESC,'
			ELSE IF @strValue = 'FEFO'
				SET @strOrderBy = 'PL.dtmExpiryDate ASC,'
		END

		IF @strRuleName = 'Is Cost Applicable?'
		BEGIN
			IF @strValue = 'Yes'
				SET @strOrderBy = 'PL.dblUnitCost ASC,'
		END

		SET @strOrderByFinal = @strOrderByFinal + @strOrderBy
		SET @strOrderBy = ''
		SET @intSequenceCount = @intSequenceCount + 1
	END

	IF LEN(@strOrderByFinal) > 0
		SET @strOrderByFinal = LEFT(@strOrderByFinal, LEN(@strOrderByFinal) - 1)

	IF ISNULL(@strOrderByFinal,'')=''
		SET @strOrderByFinal='PL.dtmCreateDate ASC'

	WHILE @intNoOfSheets > 0
	BEGIN
		SET @strSQL = ''

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
				,@strLotTracking=strLotTracking
				,@intItemUOMId=intItemUOMId
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

			SET @dblOriginalRequiredQty = @dblRequiredQty

			if @intConsumptionMethodId in (2,3)
				Set @intIssuedUOMTypeId=1

			IF OBJECT_ID('tempdb..#tblLot') IS NOT NULL
				DROP TABLE #tblLot

			CREATE TABLE #tblLot (
				 intRowNo INT IDENTITY
				,intLotId INT
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

			IF OBJECT_ID('tempdb..#tblAvailableInputLot') IS NOT NULL
				DROP TABLE #tblAvailableInputLot

			CREATE TABLE #tblAvailableInputLot (
				intParentLotId INT
				,--NVARCHAR(50) COLLATE Latin1_General_CI_AS, --Review
				intItemId INT
				,dblAvailableQty NUMERIC(38,20)
				,intStorageLocationId INT
				,dblWeightPerQty NUMERIC(38, 20)
				,dtmCreateDate DATETIME
				,dtmExpiryDate DATETIME
				,dblUnitCost NUMERIC(38,20)
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				)

			IF OBJECT_ID('tempdb..#tblInputLot') IS NOT NULL
				DROP TABLE #tblInputLot

			CREATE TABLE #tblInputLot (
				intParentLotId INT
				,--NVARCHAR(50) COLLATE Latin1_General_CI_AS, --Review
				intItemId INT
				,dblAvailableQty NUMERIC(38,20)
				,intStorageLocationId INT
				,dblWeightPerQty NUMERIC(38, 20)
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				)

			IF OBJECT_ID('tempdb..#tblInputLotHandAdd') IS NOT NULL
				DROP TABLE #tblInputLotHandAdd

			CREATE TABLE #tblInputLotHandAdd (
				intParentLotId INT
				,--NVARCHAR(50) COLLATE Latin1_General_CI_AS, --Review
				intItemId INT
				,dblAvailableQty NUMERIC(38,20)
				,intStorageLocationId INT
				,dblWeightPerQty NUMERIC(38, 20)
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				)

			IF OBJECT_ID('tempdb..#tblPartialQtyLot') IS NOT NULL
				DROP TABLE #tblPartialQtyLot

			CREATE TABLE #tblPartialQtyLot (
				intRowNo INT IDENTITY(1, 1)
				,intLotId INT
				,intItemId INT
				,dblAvailableQty NUMERIC(38,20)
				,intStorageLocationId INT
				,dblWeightPerQty NUMERIC(38, 20)
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				)

			--Non Lot Tracked
			If @strLotTracking='No'
			Begin
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
					Select sd.intItemStockUOMId,'',sd.intItemId,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,@intItemUOMId,sd.dblAvailableQty),
					sd.intLocationId,sd.intSubLocationId,sd.intStorageLocationId,NULL,NULL,0,sd.dblUnitQty,'',0,@intItemUOMId AS intItemUOMId,@intItemUOMId AS intItemUOMId 
					From vyuMFGetItemStockDetail sd 
					Where sd.intItemId=@intRawItemId AND sd.dblAvailableQty > .01 AND sd.intLocationId=@intLocationId 
					AND ISNULL(sd.intStorageLocationId,0) NOT IN (@intKitStagingLocationId,@intBlendStagingLocationId)
					AND ISNULL(sd.ysnStockUnit,0)=1 ORDER BY sd.intItemStockUOMId

					Declare @intMinItem INT
					Select @intMinItem=MIN(intRowNo) From #tblLot
					While @intMinItem is not null
					Begin
						Select @dblAvailableQty=dblQty From #tblLot Where intRowNo=@intMinItem

						If @dblAvailableQty >= @dblRequiredQty 
						Begin
							INSERT INTO @tblPickedItem(intItemStockUOMId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId)
							Select intLotId,@intRawItemId,@dblRequiredQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId From #tblLot Where intRowNo=@intMinItem

							GOTO NEXT_ITEM
						End
						Else
						Begin
							INSERT INTO @tblPickedItem(intItemStockUOMId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId)
							Select intLotId,@intRawItemId,@dblAvailableQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId From #tblLot Where intRowNo=@intMinItem

							Set @dblRequiredQty = @dblRequiredQty - @dblAvailableQty
						End

						Select @intMinItem = MIN(intRowNo) From #tblLot Where intRowNo>@intMinItem
					End

					If ISNULL(@dblRequiredQty,0)>0
						INSERT INTO @tblPickedItem(intItemStockUOMId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId)
						Select -1,@intRawItemId,0,@intItemUOMId,@intLocationId,null,null

					GOTO NEXT_ITEM
			End

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
			JOIN tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
			WHERE L.intItemId = @intRawItemId
				AND L.intLocationId = @intLocationId
				AND LS.strPrimaryStatus IN (
					Select strStatusName From @tblLotStatus
					)
				AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
				AND L.dblWeight >= .01
				AND L.intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					--,@intPartialQuantitySubLocationId
					) --Exclude Kit Staging,Blend Staging,Partial Qty Storage Locations
				AND ISNULL(SL.ysnAllowConsume,0)=1
				AND L.intLotId NOT IN (Select intLotId From @tblExcludedLot Where intItemId=@intRawItemId)

			--Get Either Parent Lot OR Child Lot Based on Setting
			IF @ysnEnableParentLot = 0
			BEGIN
				--Pick Only Lots From Storage Location if recipe is by location
				If @intConsumptionMethodId = 2 
					Delete From #tblLot Where ISNULL(intStorageLocationId,0) <> ISNULL(@intConsumptionStoragelocationId,0)

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

			LotLoop:

			--Hand Add
			DELETE
			FROM #tblAvailableInputLot

			DELETE
			FROM #tblInputLot

			--Calculate Available Qty for each Lot
			--Available Qty = Physical Qty - (Resrved Qty + Sum of Qty Added to Previous Blend Sheet in cuttent Session)
			IF @ysnEnableParentLot = 1
				AND @ysnShowAvailableLotsByStorageLocation = 1
			BEGIN
				INSERT INTO #tblAvailableInputLot (
					intParentLotId
					,intItemId
					,dblAvailableQty
					,intStorageLocationId
					,dblWeightPerQty
					,dtmCreateDate
					,dtmExpiryDate
					,dblUnitCost
					,intItemUOMId
					,intItemIssuedUOMId
					)
				SELECT PL.intParentLotId
					,PL.intItemId
					,(
						PL.dblQty - (
							(
								SELECT ISNULL(SUM(SR.dblQty), 0)
								FROM tblICStockReservation SR
								WHERE SR.intParentLotId = PL.intParentLotId --Review when Parent Lot Reservation Done
									AND SR.intStorageLocationId = PL.intStorageLocationId AND ISNULL(SR.ysnPosted,0)=0
								) + (
								SELECT ISNULL(SUM(BS.dblQuantity), 0)
								FROM #tblBlendSheetLot BS
								WHERE BS.intParentLotId = PL.intParentLotId
								)
							)
						) AS dblAvailableQty
					,PL.intStorageLocationId
					,PL.dblWeightPerQty
					,PL.dtmCreateDate
					,PL.dtmExpiryDate
					,PL.dblUnitCost
					,PL.intItemUOMId
					,PL.intItemIssuedUOMId
				FROM #tblParentLot AS PL
				WHERE PL.intItemId = @intRawItemId
			END

			IF @ysnEnableParentLot = 1
			BEGIN
				INSERT INTO #tblAvailableInputLot (
					intParentLotId
					,intItemId
					,dblAvailableQty
					,intStorageLocationId
					,dblWeightPerQty
					,dtmCreateDate
					,dtmExpiryDate
					,dblUnitCost
					,intItemUOMId
					,intItemIssuedUOMId
					)
				SELECT PL.intParentLotId
					,PL.intItemId
					,(
						PL.dblQty - (
							(
								SELECT ISNULL(SUM(SR.dblQty), 0)
								FROM tblICStockReservation SR
								WHERE SR.intParentLotId = PL.intParentLotId AND ISNULL(SR.ysnPosted,0)=0
								) + (
								SELECT ISNULL(SUM(BS.dblQuantity), 0)
								FROM #tblBlendSheetLot BS
								WHERE BS.intParentLotId = PL.intParentLotId
								)
							)
						) AS dblAvailableQty
					,PL.intStorageLocationId
					,PL.dblWeightPerQty
					,PL.dtmCreateDate
					,PL.dtmExpiryDate
					,PL.dblUnitCost
					,PL.intItemUOMId
					,PL.intItemIssuedUOMId
				FROM #tblParentLot AS PL
				WHERE PL.intItemId = @intRawItemId
			END

			IF @ysnEnableParentLot = 0
			BEGIN
				INSERT INTO #tblAvailableInputLot (
					intParentLotId
					,intItemId
					,dblAvailableQty
					,intStorageLocationId
					,dblWeightPerQty
					,dtmCreateDate
					,dtmExpiryDate
					,dblUnitCost
					,intItemUOMId
					,intItemIssuedUOMId
					)
				SELECT PL.intParentLotId
					,PL.intItemId
					,(
						PL.dblQty - (
							(
								SELECT ISNULL(SUM(SR.dblQty), 0)
								FROM tblICStockReservation SR
								WHERE SR.intLotId = PL.intParentLotId AND ISNULL(SR.ysnPosted,0)=0
								) + (
								SELECT ISNULL(SUM(BS.dblQuantity), 0)
								FROM #tblBlendSheetLot BS
								WHERE BS.intParentLotId = PL.intParentLotId
								)
							)
						) AS dblAvailableQty
					,PL.intStorageLocationId
					,PL.dblWeightPerQty
					,PL.dtmCreateDate
					,PL.dtmExpiryDate
					,PL.dblUnitCost
					,PL.intItemUOMId
					,PL.intItemIssuedUOMId
				FROM #tblParentLot AS PL
				WHERE PL.intItemId = @intRawItemId
			END

			--Apply Business Rules
			If ISNULL(@ysnWOStagePick,0)=0
			Begin
				SET @strSQL = 'INSERT INTO #tblInputLot(intParentLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId) 
									   SELECT PL.intParentLotId,PL.intItemId,PL.dblAvailableQty,PL.intStorageLocationId,PL.dblWeightPerQty,PL.intItemUOMId,PL.intItemIssuedUOMId 
									   FROM #tblAvailableInputLot PL WHERE PL.dblAvailableQty >= .01 ORDER BY ' + @strOrderByFinal

				EXEC (@strSQL)
			End
			Else
			Begin
				INSERT INTO #tblInputLot(intParentLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId) 
				SELECT PL.intParentLotId,PL.intItemId,PL.dblAvailableQty,PL.intStorageLocationId,PL.dblWeightPerQty,PL.intItemUOMId,PL.intItemIssuedUOMId
				FROM #tblAvailableInputLot PL WHERE PL.dblAvailableQty >= .01 AND PL.intStorageLocationId IN (Select intStagingLocationId From @tblWOStagingLocation)
				Order By PL.dtmCreateDate

				INSERT INTO #tblInputLot(intParentLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId) 
				SELECT PL.intParentLotId,PL.intItemId,PL.dblAvailableQty,PL.intStorageLocationId,PL.dblWeightPerQty,PL.intItemUOMId,PL.intItemIssuedUOMId
				FROM #tblAvailableInputLot PL WHERE PL.dblAvailableQty >= .01 AND PL.intStorageLocationId NOT IN (Select intStagingLocationId From @tblWOStagingLocation)
				Order By PL.dtmCreateDate
			End

			--For Bulk Items Do not consider lot
			If @intConsumptionMethodId IN (2, 3) --By Location/FIFO
			Begin
				SET @dblBulkItemAvailableQty = (Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot L 
				Join tblICLotStatus LS ON L.intLotStatusId=LS.intLotStatusId
				Join tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
				WHERE L.intItemId = @intRawItemId
				AND L.intLocationId = @intLocationId
				AND LS.strPrimaryStatus IN (
					Select strStatusName From @tblLotStatus
					)
				AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
				AND L.dblWeight >= .01
				AND L.intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					) --Exclude Kit Staging,Blend Staging
				AND ISNULL(SL.ysnAllowConsume,0)=1
				AND L.intLotId NOT IN (Select intLotId From @tblExcludedLot Where intItemId=@intRawItemId))
				- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=@intRawItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0
				AND intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					) --Exclude Kit Staging,Blend Staging				
				)
				- (SELECT ISNULL(SUM(BS.dblQuantity), 0) FROM #tblBlendSheetLot BS WHERE BS.intItemId = @intRawItemId)
				
				Delete From #tblInputLot

				If @dblBulkItemAvailableQty > 0
					INSERT INTO #tblInputLot(intParentLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId)
					Select TOP 1 intLotId,intItemId,@dblBulkItemAvailableQty,intStorageLocationId,1,intWeightUOMId,intWeightUOMId 
					From tblICLot Where intItemId=@intRawItemId AND dblWeight >= .01 AND ISNULL(intStorageLocationId,0) > 0 AND intLocationId=@intLocationId
			End

			--Full Bag Pick
			If ISNULL(@intPartialQuantitySubLocationId,0)>0 AND @intOriginalIssuedUOMTypeId=@intIssuedUOMTypeId
				DELETE FROM #tblInputLot WHERE intStorageLocationId IN 
				(Select intStorageLocationId From tblICStorageLocation Where intSubLocationId = ISNULL(@intPartialQuantitySubLocationId,0))

			--Hand Add Pick
			--Pick From Hand Add, remaining pick from Full Bag 
			--#tblInputLotHandAdd table used for ordering of hand add and full bag add location lots
			If ISNULL(@intPartialQuantitySubLocationId,0)>0 AND @intOriginalIssuedUOMTypeId<>@intIssuedUOMTypeId
			Begin
				DELETE FROM #tblInputLotHandAdd

				INSERT INTO #tblInputLotHandAdd
				Select * From #tblInputLot

				DELETE FROM #tblInputLot

				INSERT INTO #tblInputLot
				Select * From #tblInputLotHandAdd Where intStorageLocationId IN 
					(Select intStorageLocationId From tblICStorageLocation Where intSubLocationId = ISNULL(@intPartialQuantitySubLocationId,0))
				
				INSERT INTO #tblInputLot
				Select * From #tblInputLotHandAdd Where intStorageLocationId NOT IN 
					(Select intStorageLocationId From tblICStorageLocation Where intSubLocationId = ISNULL(@intPartialQuantitySubLocationId,0))
			End

			If (Select COUNT(1) From #tblInputLot)=0
				GOTO NOLOT

			DECLARE Cursor_FetchItem CURSOR LOCAL FAST_FORWARD
			FOR
			SELECT intParentLotId
				,intItemId
				,dblAvailableQty
				,intStorageLocationId
				,dblWeightPerQty
			FROM #tblInputLot

			OPEN Cursor_FetchItem

			FETCH NEXT
			FROM Cursor_FetchItem
			INTO @intParentLotId
				,@intRawItemId
				,@dblAvailableQty
				,@intStorageLocationId
				,@dblWeightPerQty

			WHILE (@@FETCH_STATUS <> - 1)
			BEGIN
				IF @dblRequiredQty < @dblWeightPerQty AND ISNULL(@intPartialQuantitySubLocationId, 0) > 0 AND @intIssuedUOMTypeId = 2
					--SELECT @intIssuedUOMTypeId = 1
					GOTO LOOP_END

				IF @intIssuedUOMTypeId = 2 --'BAG' 
					SET @dblAvailableQty = @dblAvailableQty - (@dblAvailableQty % @dblWeightPerQty)

				IF @dblAvailableQty > 0
				BEGIN
					IF (@dblAvailableQty >= @dblRequiredQty)
					BEGIN
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
										THEN Convert(numeric(38,20),(
												(
													CASE 
														WHEN Floor(@dblRequiredQty / L.dblWeightPerQty) = 0
															THEN 1
														ELSE Floor(@dblRequiredQty / L.dblWeightPerQty)
														END
													) * L.dblWeightPerQty
												))
									ELSE @dblRequiredQty --To Review ROUND(@dblRequiredQty,3) 
									END AS dblQuantity
								,L.intWeightUOMId AS intItemUOMId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN Convert(numeric(38,20),(
												CASE 
													WHEN Floor(@dblRequiredQty / L.dblWeightPerQty) = 0
														THEN 1
													ELSE Convert(numeric(38,20),Floor(@dblRequiredQty / L.dblWeightPerQty))
													END
												))
									ELSE @dblRequiredQty --To Review ROUND(@dblRequiredQty,3) 
									END AS dblIssuedQuantity
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN L.intItemUOMId
									ELSE L.intWeightUOMId
									END AS intItemIssuedUOMId
								,@intRecipeItemId AS intRecipeItemId
								,@intStorageLocationId AS intStorageLocationId
								,L.dblWeightPerQty
							FROM tblICLot L
							WHERE L.intLotId = @intParentLotId
								AND L.dblWeight >= .01
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
							SELECT L.intParentLotId
								,L.intItemId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN Convert(numeric(38,20),(
												(
													CASE 
														WHEN Floor(@dblRequiredQty / L.dblWeightPerQty) = 0
															THEN 1
														ELSE Floor(@dblRequiredQty / L.dblWeightPerQty)
														END
													) * L.dblWeightPerQty
												))
									ELSE @dblRequiredQty -- To Review ROUND(@dblRequiredQty,3) 
									END AS dblQuantity
								,L.intItemUOMId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN Convert(numeric(38,20),(
												CASE 
													WHEN Floor(@dblRequiredQty / L.dblWeightPerQty) = 0
														THEN 1
													ELSE Convert(numeric(38,20),Floor(@dblRequiredQty / L.dblWeightPerQty))
													END
												))
									ELSE @dblRequiredQty --To Review ROUND(@dblRequiredQty,3) 
									END AS dblIssuedQuantity
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN L.intItemIssuedUOMId
									ELSE L.intItemUOMId
									END AS intItemIssuedUOMId
								,@intRecipeItemId AS intRecipeItemId
								,CASE 
									WHEN @ysnShowAvailableLotsByStorageLocation = 1
										THEN @intStorageLocationId
									ELSE 0
									END AS intStorageLocationId
								,L.dblWeightPerQty
							FROM #tblParentLot L
							WHERE L.intParentLotId = @intParentLotId --AND L.dblWeight > 0

						If ISNULL(@intPartialQuantitySubLocationId, 0) > 0 AND @intIssuedUOMTypeId=2
						Begin
							SET @dblRequiredQty=@dblRequiredQty - Floor(@dblRequiredQty / @dblWeightPerQty) * @dblWeightPerQty
							If @dblRequiredQty = 0 
								GOTO LOOP_END;
						End
						Else
						Begin
							SET @dblRequiredQty = 0

							GOTO LOOP_END;
						End
					END
					ELSE
					BEGIN
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
										THEN Convert(numeric(38,20),(
												(
													CASE 
														WHEN Floor(@dblAvailableQty / L.dblWeightPerQty) = 0
															THEN 1
														ELSE Floor(@dblAvailableQty / L.dblWeightPerQty)
														END
													) * L.dblWeightPerQty
												))
									ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
									END AS dblQuantity
								,L.intWeightUOMId AS intItemUOMId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN Convert(numeric(38,20),(
												CASE 
													WHEN Floor(@dblAvailableQty / L.dblWeightPerQty) = 0
														THEN 1
													ELSE Convert(numeric(38,20),Floor(@dblAvailableQty / L.dblWeightPerQty))
													END
												))
									ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
									END AS dblIssuedQuantity
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN L.intItemUOMId
									ELSE L.intWeightUOMId
									END AS intItemIssuedUOMId
								,@intRecipeItemId AS intRecipeItemId
								,@intStorageLocationId AS intStorageLocationId
								,L.dblWeightPerQty
							FROM tblICLot L
							WHERE L.intLotId = @intParentLotId
								AND L.dblWeight >= .01
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
							SELECT L.intParentLotId
								,L.intItemId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN Convert(numeric(38,20),(
												(
													CASE 
														WHEN Floor(@dblAvailableQty / L.dblWeightPerQty) = 0
															THEN 1
														ELSE Floor(@dblAvailableQty / L.dblWeightPerQty)
														END
													) * L.dblWeightPerQty
												))
									ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
									END AS dblQuantity
								,L.intItemUOMId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN Convert(numeric(38,20),(
												CASE 
													WHEN Floor(@dblAvailableQty / L.dblWeightPerQty) = 0
														THEN 1
													ELSE Convert(numeric(38,20),Floor(@dblAvailableQty / L.dblWeightPerQty))
													END
												))
									ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
									END AS dblIssuedQuantity
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN L.intItemIssuedUOMId
									ELSE L.intItemUOMId
									END AS intItemIssuedUOMId
								,@intRecipeItemId AS intRecipeItemId
								,CASE 
									WHEN @ysnShowAvailableLotsByStorageLocation = 1
										THEN @intStorageLocationId
									ELSE 0
									END AS intStorageLocationId
								,L.dblWeightPerQty
							FROM #tblParentLot L
							WHERE L.intParentLotId = @intParentLotId --AND L.dblWeight > 0

						SET @dblRequiredQty = @dblRequiredQty - @dblAvailableQty

					END
				END --AvailaQty>0 End

				SET @intStorageLocationId = NULL

				FETCH NEXT
				FROM Cursor_FetchItem
				INTO @intParentLotId
					,@intRawItemId
					,@dblAvailableQty
					,@intStorageLocationId
					,@dblWeightPerQty
			END --Cursor End For Pick Lots

			LOOP_END:

			CLOSE Cursor_FetchItem

			DEALLOCATE Cursor_FetchItem

			IF (@dblRequiredQty > 0)
			BEGIN
				SET @intIssuedUOMTypeId = 1

				GOTO LotLoop
			END

			NOLOT:

			--Pick Substitute 
			IF @ysnIsSubstitute=0
			BEGIN
				SELECT @dblRemainingRequiredQty=@dblOriginalRequiredQty - ISNULL(SUM(ISNULL(dblQuantity,0)),0) From #tblBlendSheetLot Where intItemId=@intRawItemId
				IF @dblRemainingRequiredQty > 0
				Begin
					--if main item qty not there then remaining qty pick from substitute if exists
					If Exists(Select 1 From @tblInputItem Where intParentItemId=@intRawItemId And ysnIsSubstitute=1)
						Begin
							If ISNULL(@dblRecipeQty,0)=0 SET @dblRecipeQty=1
							Update @tblInputItem Set dblRequiredQty=@dblRemainingRequiredQty * (dblSubstituteRatio*dblMaxSubstituteRatio/100) Where intParentItemId=@intRawItemId And ysnIsSubstitute=1
							Delete From @tblInputItem Where intItemId=@intRawItemId And ysnIsSubstitute=0 --Remove the main Item
						End
					Else --substitute does not exists then show 0 for main item
					Begin
						If ISNULL(@intPartialQuantitySubLocationId, 0) > 0
							INSERT INTO @tblRemainingPickedLots(intWorkOrderInputLotId,	intLotId,	strLotNumber,	strItemNo,	strDescription,	dblQuantity,	
							intItemUOMId,	strUOM,	dblIssuedQuantity,	intItemIssuedUOMId,	strIssuedUOM,	intItemId,	intRecipeItemId,	
							dblUnitCost,	dblDensity,	dblRequiredQtyPerSheet,	dblWeightPerUnit,	dblRiskScore,	intStorageLocationId,	
							strStorageLocationName,	strLocationName,	intLocationId,	strSubLocationName,intSubLocationId,	strLotAlias,	ysnParentLot,	strRowState)
							Select TOP 1 0,0,'',i.strItemNo,i.strDescription,@dblRemainingRequiredQty,l.intWeightUOMId,um.strUnitMeasure,@dblRemainingRequiredQty, l.intWeightUOMId,um.strUnitMeasure,--l.intItemUOMId,um1.strUnitMeasure, 
							@intRawItemId,0,0.0,0.0,0.0,l.dblWeightPerQty,0.0,0,'','',@intLocationId,'',0,'',0,'Added'
							From tblICLot l Join tblICItem i on l.intItemId=i.intItemId 
							Join tblICItemUOM iu on l.intWeightUOMId=iu.intItemUOMId
							Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
							Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
							Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
							Where i.intItemId=@intRawItemId ORDER BY l.intLotId DESC

							--If No Lots found for Item
						If (Select COUNT(1) FROM @tblRemainingPickedLots)=0 AND (Select COUNT(1) From tblICLot Where intItemId=@intRawItemId)=0
							INSERT INTO @tblRemainingPickedLots(intWorkOrderInputLotId,	intLotId,	strLotNumber,	strItemNo,	strDescription,	dblQuantity,	
							intItemUOMId,	strUOM,	dblIssuedQuantity,	intItemIssuedUOMId,	strIssuedUOM,	intItemId,	intRecipeItemId,	
							dblUnitCost,	dblDensity,	dblRequiredQtyPerSheet,	dblWeightPerUnit,	dblRiskScore,	intStorageLocationId,	
							strStorageLocationName,	strLocationName,	intLocationId,	strSubLocationName,intSubLocationId,	strLotAlias,	ysnParentLot,	strRowState)
							Select TOP 1 0,0,'',i.strItemNo,i.strDescription,@dblRemainingRequiredQty,ri.intItemUOMId,um.strUnitMeasure,@dblRemainingRequiredQty, ri.intItemUOMId,um.strUnitMeasure,--l.intItemUOMId,um1.strUnitMeasure, 
							@intRawItemId,0,0.0,0.0,0.0,1 AS dblWeightPerQty,0.0,0,'','',@intLocationId,'',0,'',0,'Added'
							From tblMFRecipeItem ri 
							Join tblICItem i on ri.intItemId=i.intItemId
							Join tblICItemUOM iu on ri.intItemUOMId=iu.intItemUOMId
							Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
							Where ri.intRecipeItemId=@intRecipeItemId AND ri.intItemId=@intRawItemId
					End
				End
				Else
				Begin
					--Do not pick Substitute
					Delete From @tblInputItem Where intParentItemId=@intRawItemId And ysnIsSubstitute=1
				End
			END

				--IF @intIssuedUOMTypeId = 2
				  --AND 
				  if @intConsumptionMethodId in (2,3) --By FIFO and By Locationn
				  AND Exists (Select 1 From @tblInputItem Where intItemId=@intRawItemId)
			BEGIN
				SELECT @dblRemainingRequiredQty=@dblOriginalRequiredQty - ISNULL(SUM(ISNULL(dblQuantity,0)),0) From #tblBlendSheetLot Where intItemId=@intRawItemId
				IF @dblRemainingRequiredQty > 0
					INSERT INTO @tblRemainingPickedLots(intWorkOrderInputLotId,	intLotId,	strLotNumber,	strItemNo,	strDescription,	dblQuantity,	
					intItemUOMId,	strUOM,	dblIssuedQuantity,	intItemIssuedUOMId,	strIssuedUOM,	intItemId,	intRecipeItemId,	
					dblUnitCost,	dblDensity,	dblRequiredQtyPerSheet,	dblWeightPerUnit,	dblRiskScore,	intStorageLocationId,	
					strStorageLocationName,	strLocationName,	intLocationId,	strSubLocationName,intSubLocationId,	strLotAlias,	ysnParentLot,	strRowState)
					Select TOP 1 0,0,'',i.strItemNo,i.strDescription,@dblRemainingRequiredQty,l.intWeightUOMId,um.strUnitMeasure,@dblRemainingRequiredQty, l.intWeightUOMId,um.strUnitMeasure,--l.intItemUOMId,um1.strUnitMeasure, 
					@intRawItemId,0,0.0,0.0,0.0,l.dblWeightPerQty,0.0,0,'','',@intLocationId,'',0,'',0,'Added'
					From tblICLot l Join tblICItem i on l.intItemId=i.intItemId 
					Join tblICItemUOM iu on l.intWeightUOMId=iu.intItemUOMId
					Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
					Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
					Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
					Where i.intItemId=@intRawItemId ORDER BY l.intLotId DESC
			END

			--Hand Add 
			IF (@intIssuedUOMTypeId <> @intOriginalIssuedUOMTypeId)
				SET @intIssuedUOMTypeId = @intOriginalIssuedUOMTypeId

			NEXT_ITEM:

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblInputItem
			WHERE intRowNo > @intMinRowNo
		END --While Loop End For Per Recipe Item

		SET @intNoOfSheets = @intNoOfSheets - 1
	END -- While Loop End For Per Sheet

	SET @strOrderByFinal = 'Order By ' + LEFT(@strOrderByFinal, LEN(@strOrderByFinal) - 1)

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
			,CSL.intCompanyLocationSubLocationId AS intSubLocationId
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
		UNION --Non Lot Tracked
		Select pl.intItemStockUOMId,-1,'',i.strItemNo,i.strDescription,pl.dblQty,pl.intItemUOMId,um.strUnitMeasure,
		pl.dblQty,pl.intItemUOMId,um.strUnitMeasure,i.intItemId,@intRecipeItemId,0,0,0,1,0,pl.intStorageLocationId,sl.strName,
		cl.strLocationName,pl.intLocationId,csl.strSubLocationName,csl.intCompanyLocationSubLocationId AS intSubLocationId,'',0,'Added'
		From @tblPickedItem pl Join tblICItem i on pl.intItemId=i.intItemId
		Join tblICItemUOM iu on pl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Left Join tblICStorageLocation sl on pl.intStorageLocationId=sl.intStorageLocationId
		Left Join tblSMCompanyLocationSubLocation csl on csl.intCompanyLocationSubLocationId=pl.intSubLocationId
		Join tblSMCompanyLocation cl on pl.intLocationId=cl.intCompanyLocationId 
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
			,'' AS strSubLocationName
			,0 AS intSubLocationId
			,PL.strParentLotAlias AS strLotAlias
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
			,'' AS strSubLocationName
			,0 AS intSubLocationId
			,PL.strParentLotAlias AS strLotAlias
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
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	IF @idoc1 <> 0 EXEC sp_xml_removedocument @idoc1
	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
