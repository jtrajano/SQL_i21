﻿CREATE PROCEDURE [dbo].[uspMFAutoBlendSheetFIFO] @intLocationId INT
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
	DECLARE @intPartialQuantityStorageLocationId INT
	DECLARE @intOriginalIssuedUOMTypeId INT
	DECLARE @intKitStagingLocationId INT
	DECLARE @intBlendStagingLocationId INT
	DECLARE @intMinPartialQtyLotRowNo INT
	DECLARE @dblAvailablePartialQty NUMERIC(38,20)
	DECLARE @idoc int 
	DECLARE @intConsumptionMethodId INT
	DECLARE @intConsumptionStoragelocationId INT
	DECLARE @ysnIsSubstitute bit
	DECLARE @intWorkOrderId INT
	DECLARE @intSequenceNo INT
		,@intSequenceCount INT = 1
		,@strRuleName NVARCHAR(100)
		,@strValue NVARCHAR(50)
		,@strOrderBy NVARCHAR(100) = ''
		,@strOrderByFinal NVARCHAR(100) = ''

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
		strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS,
		ysnParentLot bit,
		strRowState nvarchar(50) COLLATE Latin1_General_CI_AS
	)

	Select TOP 1 @intWorkOrderId=intWorkOrderId From tblMFWorkOrder Where intBlendRequirementId=@intBlendRequirementId AND ISNULL(intSalesOrderLineItemId,0)>0

	--Get Recipe Input Items
	--@strXml (if it has value)- Used For Picking Specific Recipe Items with qty full or remaining qty
	--Called From uspMFGetPickListDetails
	If ISNULL(@strXml,'')=''
	Begin
		If Exists (Select 1 From tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId)
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
			SELECT r.intRecipeId
				,ri.intRecipeItemId
				,ri.intItemId
				,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
				,0 AS ysnIsSubstitute
				,ri.ysnMinorIngredient
				,ri.intConsumptionMethodId
				,ri.intStorageLocationId
				,0
			FROM tblMFWorkOrderRecipeItem ri
			JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
			WHERE r.intWorkOrderId=@intWorkOrderId
				AND ri.intRecipeItemTypeId = 1
	
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
			FROM tblMFWorkOrderRecipeSubstituteItem rs
			JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
			JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
			WHERE r.intWorkOrderId = @intWorkOrderId
				AND rs.intRecipeItemTypeId = 1
			ORDER BY ysnIsSubstitute, ysnMinorIngredient
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
			FROM tblMFRecipeSubstituteItem rs
			JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
			JOIN tblMFRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
			WHERE r.intRecipeId = @intRecipeId
				AND rs.intRecipeItemTypeId = 1
			ORDER BY ysnIsSubstitute,ysnMinorIngredient
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
			)
		 Select intRecipeId,intRecipeItemId,intItemId,dblRequiredQty,ysnIsSubstitute,0,intConsumptionMethodId,intConsumptionStoragelocationId,intParentItemId
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

			if @intConsumptionMethodId in (2,4)
				Set @intIssuedUOMTypeId=1

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
			LEFT JOIN tblSMUserSecurity US ON L.intCreatedEntityId = US.[intEntityUserSecurityId]
			JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
			WHERE L.intItemId = @intRawItemId
				AND L.intLocationId = @intLocationId
				AND LS.strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
				AND L.dtmExpiryDate >= GETDATE()
				AND L.dblWeight >= .01
				AND L.intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					,@intPartialQuantityStorageLocationId
					) --Exclude Kit Staging,Blend Staging,Partial Qty Storage Locations

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
								WHERE SR.intLotId = PL.intParentLotId --Review when Parent Lot Reservation Done
									AND SR.intStorageLocationId = PL.intStorageLocationId
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
			ELSE
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
								WHERE SR.intLotId = PL.intParentLotId
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
			SET @strSQL = 'INSERT INTO #tblInputLot(intParentLotId,intItemId,dblAvailableQty,intStorageLocationId,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId) 
								   SELECT PL.intParentLotId,PL.intItemId,PL.dblAvailableQty,PL.intStorageLocationId,PL.dblWeightPerQty,PL.intItemUOMId,PL.intItemIssuedUOMId 
								   FROM #tblAvailableInputLot PL WHERE PL.dblAvailableQty >= .01 ORDER BY ' + @strOrderByFinal

			EXEC (@strSQL)

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
				IF @dblOriginalRequiredQty < @dblWeightPerQty AND ISNULL(@intPartialQuantityStorageLocationId, 0) > 0 AND @intIssuedUOMTypeId = 2
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
										THEN (
												(
													CASE 
														WHEN Floor(@dblRequiredQty / L.dblWeightPerQty) = 0
															THEN 1
														ELSE Floor(@dblRequiredQty / L.dblWeightPerQty)
														END
													) * L.dblWeightPerQty
												)
									ELSE @dblRequiredQty --To Review ROUND(@dblRequiredQty,3) 
									END AS dblQuantity
								,L.intWeightUOMId AS intItemUOMId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN (
												CASE 
													WHEN Floor(@dblRequiredQty / L.dblWeightPerQty) = 0
														THEN 1
													ELSE Convert(numeric(38,20),Floor(@dblRequiredQty / L.dblWeightPerQty))
													END
												)
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
										THEN (
												(
													CASE 
														WHEN Floor(@dblRequiredQty / L.dblWeightPerQty) = 0
															THEN 1
														ELSE Floor(@dblRequiredQty / L.dblWeightPerQty)
														END
													) * L.dblWeightPerQty
												)
									ELSE @dblRequiredQty -- To Review ROUND(@dblRequiredQty,3) 
									END AS dblQuantity
								,L.intItemUOMId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN (
												CASE 
													WHEN Floor(@dblRequiredQty / L.dblWeightPerQty) = 0
														THEN 1
													ELSE Convert(numeric(38,20),Floor(@dblRequiredQty / L.dblWeightPerQty))
													END
												)
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

						SET @dblRequiredQty = 0

						GOTO LOOP_END;
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
										THEN (
												(
													CASE 
														WHEN Floor(@dblAvailableQty / L.dblWeightPerQty) = 0
															THEN 1
														ELSE Floor(@dblAvailableQty / L.dblWeightPerQty)
														END
													) * L.dblWeightPerQty
												)
									ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
									END AS dblQuantity
								,L.intWeightUOMId AS intItemUOMId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN (
												CASE 
													WHEN Floor(@dblAvailableQty / L.dblWeightPerQty) = 0
														THEN 1
													ELSE Convert(numeric(38,20),Floor(@dblAvailableQty / L.dblWeightPerQty))
													END
												)
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
										THEN (
												(
													CASE 
														WHEN Floor(@dblAvailableQty / L.dblWeightPerQty) = 0
															THEN 1
														ELSE Floor(@dblAvailableQty / L.dblWeightPerQty)
														END
													) * L.dblWeightPerQty
												)
									ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
									END AS dblQuantity
								,L.intItemUOMId
								,CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN (
												CASE 
													WHEN Floor(@dblAvailableQty / L.dblWeightPerQty) = 0
														THEN 1
													ELSE Convert(numeric(38,20),Floor(@dblAvailableQty / L.dblWeightPerQty))
													END
												)
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

					IF @dblRequiredQty < @dblWeightPerQty AND ISNULL(@intPartialQuantityStorageLocationId, 0) > 0 AND @intIssuedUOMTypeId = 2
					--SELECT @intIssuedUOMTypeId = 1
					GOTO LOOP_END

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

			--Hand Add Item added from Hand Add Storage Location
			IF @intIssuedUOMTypeId = 2
				AND ISNULL(@intPartialQuantityStorageLocationId, 0) > 0 --'BAG' 
				AND @intConsumptionMethodId=1 --By Lot 
			BEGIN
				SET @dblPartialQuantity = 0
				if @dblOriginalRequiredQty < @dblWeightPerQty
					SET @dblPartialQuantity=@dblOriginalRequiredQty
				ELSE
					SET @dblPartialQuantity = ISNULL((@dblOriginalRequiredQty % @dblWeightPerQty), 0)

				IF @ysnEnableParentLot = 0
					AND @dblPartialQuantity > 0
					Begin
					INSERT INTO #tblPartialQtyLot (
						intLotId
						,intItemId
						,dblAvailableQty
						,intStorageLocationId
						,dblWeightPerQty
						,intItemUOMId
						,intItemIssuedUOMId
						)
					SELECT L.intLotId
						,L.intItemId
						,L.dblWeight - (
							(
								SELECT ISNULL(SUM(SR.dblQty), 0)
								FROM tblICStockReservation SR
								WHERE SR.intLotId = L.intLotId
								) + (
								SELECT ISNULL(SUM(BS.dblQuantity), 0)
								FROM #tblBlendSheetLot BS
								WHERE BS.intParentLotId = L.intLotId
								)
							) AS dblAvailableQty
						,@intPartialQuantityStorageLocationId AS intStorageLocationId
						,L.dblWeightPerQty
						,L.intWeightUOMId AS intItemUOMId
						,L.intWeightUOMId AS intItemIssuedUOMId
					FROM tblICLot L
					JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
					WHERE L.intItemId = @intRawItemId
						AND L.intStorageLocationId = @intPartialQuantityStorageLocationId
						AND L.dblWeight >= 0.01
						AND LS.strPrimaryStatus IN (
							'Active'
							,'Quarantine'
							)
						AND L.dtmExpiryDate >= GETDATE()
					ORDER BY L.dtmDateCreated

					Delete From #tblPartialQtyLot Where dblAvailableQty < .01
					End

				SELECT @intMinPartialQtyLotRowNo = MIN(intRowNo)
				FROM #tblPartialQtyLot

				WHILE (@intMinPartialQtyLotRowNo IS NOT NULL)
				BEGIN
					SELECT @dblAvailablePartialQty = dblAvailableQty
					FROM #tblPartialQtyLot
					WHERE intRowNo = @intMinPartialQtyLotRowNo

					IF (@dblAvailablePartialQty >= @dblPartialQuantity)
					BEGIN
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
						SELECT intLotId
							,intItemId
							,@dblPartialQuantity
							,intItemUOMId
							,@dblPartialQuantity
							,intItemIssuedUOMId
							,@intRecipeItemId
							,intStorageLocationId
							,dblWeightPerQty
						FROM #tblPartialQtyLot
						WHERE intRowNo = @intMinPartialQtyLotRowNo

						SET @dblPartialQuantity = 0

						GOTO PartialQty
					END
					ELSE
					BEGIN
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
						SELECT intLotId
							,intItemId
							,@dblAvailablePartialQty
							,intItemUOMId
							,@dblAvailablePartialQty
							,intItemIssuedUOMId
							,@intRecipeItemId
							,intStorageLocationId
							,dblWeightPerQty
						FROM #tblPartialQtyLot
						WHERE intRowNo = @intMinPartialQtyLotRowNo

						SET @dblPartialQuantity = @dblPartialQuantity - @dblAvailablePartialQty
					END

					SELECT @intMinPartialQtyLotRowNo = Min(intRowNo)
					FROM #tblPartialQtyLot
					WHERE intRowNo > @intMinPartialQtyLotRowNo
				END

				PartialQty:

				--If no paratial lot found in hand add storage location pick from full add location
				IF (
						SELECT Count(1)
						FROM #tblBlendSheetLot
						WHERE intStorageLocationId = @intPartialQuantityStorageLocationId
						) = 0 AND @dblPartialQuantity > 0
				BEGIN
					SET @dblRequiredQty = @dblPartialQuantity
					SET @intIssuedUOMTypeId = 1

					GOTO LotLoop
				END

				--If selected hand add qty is less than hand add qty , then pick the remaining qty from full add locatiion
				IF (@dblPartialQuantity > 0)
				BEGIN
					SET @dblRequiredQty = @dblPartialQuantity
					SET @intIssuedUOMTypeId = 1

					GOTO LotLoop
				END
			END

			--Pick Substitute 
			IF @ysnIsSubstitute=0
			BEGIN
				SELECT @dblRemainingRequiredQty=@dblOriginalRequiredQty - ISNULL(SUM(ISNULL(dblQuantity,0)),0) From #tblBlendSheetLot Where intItemId=@intRawItemId
				IF @dblRemainingRequiredQty > 0
				Begin
					--if main item qty not there then remaining qty pick from substitute if exists
					If Exists(Select 1 From @tblInputItem Where intParentItemId=@intRawItemId And ysnIsSubstitute=1)
						Begin
							Update @tblInputItem Set dblRequiredQty=@dblRemainingRequiredQty Where intParentItemId=@intRawItemId And ysnIsSubstitute=1
							Delete From @tblInputItem Where intItemId=@intRawItemId And ysnIsSubstitute=0 --Remove the main Item
						End
					Else --substitute does not exists then show 0 for main item
						If ISNULL(@intPartialQuantityStorageLocationId, 0) > 0
							INSERT INTO @tblRemainingPickedLots(intWorkOrderInputLotId,	intLotId,	strLotNumber,	strItemNo,	strDescription,	dblQuantity,	
							intItemUOMId,	strUOM,	dblIssuedQuantity,	intItemIssuedUOMId,	strIssuedUOM,	intItemId,	intRecipeItemId,	
							dblUnitCost,	dblDensity,	dblRequiredQtyPerSheet,	dblWeightPerUnit,	dblRiskScore,	intStorageLocationId,	
							strStorageLocationName,	strLocationName,	intLocationId,	strSubLocationName,	strLotAlias,	ysnParentLot,	strRowState)
							Select TOP 1 0,0,'',i.strItemNo,i.strDescription,@dblRemainingRequiredQty,l.intWeightUOMId,um.strUnitMeasure,@dblRemainingRequiredQty, l.intWeightUOMId,um.strUnitMeasure,--l.intItemUOMId,um1.strUnitMeasure, 
							@intRawItemId,0,0.0,0.0,0.0,l.dblWeightPerQty,0.0,0,'','',@intLocationId,'','',0,'Added'
							From tblICLot l Join tblICItem i on l.intItemId=i.intItemId 
							Join tblICItemUOM iu on l.intWeightUOMId=iu.intItemUOMId
							Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
							Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
							Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
							Where i.intItemId=@intRawItemId ORDER BY l.intLotId DESC
				End
				Else
				Begin
					--Do not pick Substitute
					Delete From @tblInputItem Where intParentItemId=@intRawItemId And ysnIsSubstitute=1
				End
			END

				--IF @intIssuedUOMTypeId = 2
				  --AND 
				  if @intConsumptionMethodId in (2,4) --By FIFO and By Locationn
				  AND Exists (Select 1 From @tblInputItem Where intItemId=@intRawItemId)
			BEGIN
				SELECT @dblRemainingRequiredQty=@dblOriginalRequiredQty - ISNULL(SUM(ISNULL(dblQuantity,0)),0) From #tblBlendSheetLot Where intItemId=@intRawItemId
				IF @dblRemainingRequiredQty > 0
					INSERT INTO @tblRemainingPickedLots(intWorkOrderInputLotId,	intLotId,	strLotNumber,	strItemNo,	strDescription,	dblQuantity,	
					intItemUOMId,	strUOM,	dblIssuedQuantity,	intItemIssuedUOMId,	strIssuedUOM,	intItemId,	intRecipeItemId,	
					dblUnitCost,	dblDensity,	dblRequiredQtyPerSheet,	dblWeightPerUnit,	dblRiskScore,	intStorageLocationId,	
					strStorageLocationName,	strLocationName,	intLocationId,	strSubLocationName,	strLotAlias,	ysnParentLot,	strRowState)
					Select TOP 1 0,0,'',i.strItemNo,i.strDescription,@dblRemainingRequiredQty,l.intWeightUOMId,um.strUnitMeasure,@dblRemainingRequiredQty, l.intWeightUOMId,um.strUnitMeasure,--l.intItemUOMId,um1.strUnitMeasure, 
					@intRawItemId,0,0.0,0.0,0.0,l.dblWeightPerQty,0.0,0,'','',@intLocationId,'','',0,'Added'
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
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
