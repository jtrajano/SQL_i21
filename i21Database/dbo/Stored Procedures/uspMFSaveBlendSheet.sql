CREATE PROCEDURE [dbo].[uspMFSaveBlendSheet] (
	@strXml NVARCHAR(MAX)
	,@intWorkOrderId INT OUT
	)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@ysnEnableParentLot BIT = 0
		,@intBlendItemId INT
		,@intLocationId INT
		,@dblPlannedQuantity NUMERIC(38, 20)
		,@dblBulkReqQuantity NUMERIC(38, 20)
		,@intCategoryId INT
		,@intCellId INT
		,@strPackagingCategoryId NVARCHAR(MAX)
		,@dblWOQuantity NUMERIC(38, 20)
		,@intPlannedShiftId INT
		,@intBlendRequirementId INT
		,@strDemandNo NVARCHAR(50)
		,@intManufacturingProcessId INT
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@dtmCurrentDateTime DATETIME = GETDATE()
		,@dtmProductionDate DATETIME
		,@strReferenceNo NVARCHAR(50)
		,@intMinRowNo INT
		,@strRowState NVARCHAR(50)
		,@intWorkOrderInputLotId INT
		,@strChar NVARCHAR(1)
		,@intSeq INT
		,@dblIssuedQuantity NUMERIC(18, 6)
		,@intItemId INT
		,@intIssuedUOMTypeId INT
		,@intNoOfSheets INT
		,@strFW NVARCHAR(3)
		,@intRecordId INT
		,@strValue NVARCHAR(50)
		,@ysnCopyRecipeOnSave BIT
		,@intCreatedUserId INT
		,@intRecipeItemId INT
		,@intRecipeId INT
		,@ysnOverrideRecipe BIT
		,@dtmValidFrom DATETIME
		,@dtmValidTo DATETIME
		,@ysnTBSReserveOnSave BIT
		,@dblTBSQuantity NUMERIC(18, 6)
		,@intLotId int
		,@dblWeight numeric(18,6)
	DECLARE @dblInputAvlQty NUMERIC(38, 20)
	DECLARE @dblInputReqQty NUMERIC(38, 20)
	DECLARE @intInputLotId INT
	DECLARE @intInputItemId INT
	DECLARE @strInputLotNumber NVARCHAR(50)
	DECLARE @strInputItemNo NVARCHAR(50)
	--Available Qty Check
	DECLARE @tblLotSummary AS TABLE (
		intRowNo INT IDENTITY
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38, 20)
		,intRecipeItemId INT
		)
	DECLARE @tblFW TABLE (
		strChar CHAR(1)
		,intItemId INT
		,intSeq INT
		,intRecordId INT identity(1, 1)
		);

	INSERT INTO @tblFW (strChar)
	SELECT 'A'

	INSERT INTO @tblFW (strChar)
	SELECT 'B'

	INSERT INTO @tblFW (strChar)
	SELECT 'C'

	INSERT INTO @tblFW (strChar)
	SELECT 'D'

	INSERT INTO @tblFW (strChar)
	SELECT 'E'

	INSERT INTO @tblFW (strChar)
	SELECT 'F'

	INSERT INTO @tblFW (strChar)
	SELECT 'G'

	INSERT INTO @tblFW (strChar)
	SELECT 'H'

	INSERT INTO @tblFW (strChar)
	SELECT 'I'

	INSERT INTO @tblFW (strChar)
	SELECT 'J'

	INSERT INTO @tblFW (strChar)
	SELECT 'K'

	INSERT INTO @tblFW (strChar)
	SELECT 'L'

	INSERT INTO @tblFW (strChar)
	SELECT 'M'

	INSERT INTO @tblFW (strChar)
	SELECT 'N'

	INSERT INTO @tblFW (strChar)
	SELECT 'O'

	INSERT INTO @tblFW (strChar)
	SELECT 'P'

	INSERT INTO @tblFW (strChar)
	SELECT 'Q'

	INSERT INTO @tblFW (strChar)
	SELECT 'R'

	INSERT INTO @tblFW (strChar)
	SELECT 'S'

	INSERT INTO @tblFW (strChar)
	SELECT 'T'

	INSERT INTO @tblFW (strChar)
	SELECT 'U'

	INSERT INTO @tblFW (strChar)
	SELECT 'V'

	INSERT INTO @tblFW (strChar)
	SELECT 'W'

	INSERT INTO @tblFW (strChar)
	SELECT 'X'

	INSERT INTO @tblFW (strChar)
	SELECT 'Y'

	INSERT INTO @tblFW (strChar)
	SELECT 'Z'

	SET @intWorkOrderId = 0;

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @tblBlendSheet TABLE (
		intWorkOrderId INT
		,strWorkOrderNo NVARCHAR(50)
		,intBlendRequirementId INT
		,intItemId INT
		,intCellId INT
		,intMachineId INT
		,dtmDueDate DATETIME
		,dblQtyToProduce NUMERIC(38, 20)
		,dblPlannedQuantity NUMERIC(38, 20)
		,intItemUOMId INT
		,dblBinSize NUMERIC(38, 20)
		,strComment NVARCHAR(MAX)
		,ysnUseTemplate BIT
		,ysnKittingEnabled BIT
		,ysnDietarySupplements BIT
		,intLocationId INT
		,intPlannedShiftId INT
		,intUserId INT
		,intConcurrencyId INT
		,intIssuedUOMTypeId INT
		,ysnOverrideRecipe BIT NULL
		,dblUpperTolerance NUMERIC(38, 20) NULL
		,dblLowerTolerance NUMERIC(38, 20) NULL
		,dblCalculatedUpperTolerance NUMERIC(38, 20) NULL
		,dblCalculatedLowerTolerance NUMERIC(38, 20) NULL
		)
	DECLARE @tblLot TABLE (
		intRowNo INT Identity(1, 1)
		,intWorkOrderInputLotId INT
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38, 20)
		,intItemUOMId INT
		,dblIssuedQuantity NUMERIC(38, 20)
		,intItemIssuedUOMId INT
		,dblWeightPerUnit NUMERIC(38, 20)
		,intUserId INT
		,strRowState NVARCHAR(50)
		,intRecipeItemId INT
		,intLocationId INT
		,intStorageLocationId INT
		,ysnParentLot BIT
		,strFW NVARCHAR(3)
		,ysnOverrideRecipe BIT
		)
	DECLARE @tblPackagingCategoryId TABLE (intCategoryId INT)

	INSERT INTO @tblBlendSheet (
		intWorkOrderId
		,strWorkOrderNo
		,intBlendRequirementId
		,intItemId
		,intCellId
		,intMachineId
		,dtmDueDate
		,dblQtyToProduce
		,dblPlannedQuantity
		,intItemUOMId
		,dblBinSize
		,strComment
		,ysnUseTemplate
		,ysnKittingEnabled
		,ysnDietarySupplements
		,intLocationId
		,intPlannedShiftId
		,intUserId
		,intConcurrencyId
		,intIssuedUOMTypeId
		,ysnOverrideRecipe
		,dblUpperTolerance
		,dblLowerTolerance
		,dblCalculatedUpperTolerance
		,dblCalculatedLowerTolerance
		)
	SELECT intWorkOrderId
		,strWorkOrderNo
		,intBlendRequirementId
		,intItemId
		,intCellId
		,intMachineId
		,dtmDueDate
		,dblQtyToProduce
		,dblPlannedQuantity
		,intItemUOMId
		,dblBinSize
		,strComment
		,ysnUseTemplate
		,ysnKittingEnabled
		,ysnDietarySupplements
		,intLocationId
		,intPlannedShiftId
		,intUserId
		,intConcurrencyId
		,intIssuedUOMTypeId
		,NULLIF(ysnOverrideRecipe, '')
		,CASE 
			WHEN NULLIF(dblUpperTolerance, '') IS NULL
				THEN 0
			ELSE CAST(dblUpperTolerance AS NUMERIC(38, 20))
			END
		,CASE 
			WHEN NULLIF(dblLowerTolerance, '') IS NULL
				THEN 0
			ELSE CAST(dblLowerTolerance AS NUMERIC(38, 20))
			END
		,CASE 
			WHEN NULLIF(dblCalculatedUpperTolerance, '') IS NULL
				THEN 0
			ELSE CAST(dblCalculatedUpperTolerance AS NUMERIC(38, 20))
			END
		,CASE 
			WHEN NULLIF(dblCalculatedLowerTolerance, '') IS NULL
				THEN 0
			ELSE CAST(dblCalculatedLowerTolerance AS NUMERIC(38, 20))
			END
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,strWorkOrderNo NVARCHAR(50)
			,intBlendRequirementId INT
			,intItemId INT
			,intCellId INT
			,intMachineId INT
			,dtmDueDate DATETIME
			,dblQtyToProduce NUMERIC(38, 20)
			,dblPlannedQuantity NUMERIC(38, 20)
			,intItemUOMId INT
			,dblBinSize NUMERIC(38, 20)
			,strComment NVARCHAR(MAX)
			,ysnUseTemplate BIT
			,ysnKittingEnabled BIT
			,ysnDietarySupplements BIT
			,intLocationId INT
			,intPlannedShiftId INT
			,intUserId INT
			,intConcurrencyId INT
			,intIssuedUOMTypeId INT
			,ysnOverrideRecipe BIT
			,dblUpperTolerance NVARCHAR(MAX)
			,dblLowerTolerance NVARCHAR(MAX)
			,dblCalculatedUpperTolerance NVARCHAR(MAX)
			,dblCalculatedLowerTolerance NVARCHAR(MAX)
			)

	INSERT INTO @tblLot (
		intWorkOrderInputLotId
		,intLotId
		,intItemId
		,dblQty
		,intItemUOMId
		,dblIssuedQuantity
		,intItemIssuedUOMId
		,dblWeightPerUnit
		,intUserId
		,strRowState
		,intRecipeItemId
		,intLocationId
		,intStorageLocationId
		,ysnParentLot
		,strFW
		,ysnOverrideRecipe
		)
	SELECT intWorkOrderInputLotId
		,intLotId
		,intItemId
		,dblQty
		,intItemUOMId
		,dblIssuedQuantity
		,intItemIssuedUOMId
		,dblWeightPerUnit
		,intUserId
		,strRowState
		,intRecipeItemId
		,intLocationId
		,intStorageLocationId
		,ysnParentLot
		,strFW
		,ysnOverrideRecipe
	FROM OPENXML(@idoc, 'root/lot', 2) WITH (
			intWorkOrderInputLotId INT
			,intLotId INT
			,intItemId INT
			,dblQty NUMERIC(38, 20)
			,intItemUOMId INT
			,dblIssuedQuantity NUMERIC(38, 20)
			,intItemIssuedUOMId INT
			,dblWeightPerUnit NUMERIC(38, 20)
			,intUserId INT
			,strRowState NVARCHAR(50)
			,intRecipeItemId INT
			,intLocationId INT
			,intStorageLocationId INT
			,ysnParentLot BIT
			,strFW NVARCHAR(3)
			,ysnOverrideRecipe BIT
			)

	INSERT INTO @tblLotSummary (
		intLotId
		,intItemId
		,dblQty
		)
	SELECT intLotId
		,intItemId
		,SUM(dblQty)
	FROM @tblLot
	GROUP BY intLotId
		,intItemId

	DECLARE @intMinLot INT

	SELECT @intMinLot = Min(intRowNo)
	FROM @tblLotSummary

	WHILE (@intMinLot IS NOT NULL)
		AND @ysnEnableParentLot = 0
	BEGIN
		SELECT @intInputLotId = NULL
			,@dblInputReqQty = NULL
			,@intInputItemId = NULL

		SELECT @intInputLotId = intLotId
			,@dblInputReqQty = dblQty
			,@intInputItemId = intItemId
		FROM @tblLotSummary
		WHERE intRowNo = @intMinLot

		SELECT @dblInputAvlQty = NULL

		SELECT @dblInputAvlQty = CASE 
				WHEN isnull(l.dblWeight, 0) > 0
					THEN l.dblWeight
				ELSE dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId, tl.intItemUOMId, l.dblQty)
				END - (
				SELECT ISNULL(SUM(ISNULL(dblQty, 0)), 0)
				FROM tblICStockReservation
				WHERE intLotId = @intInputLotId
					AND ISNULL(ysnPosted, 0) = 0
				)
		FROM tblICLot l
		JOIN @tblLot tl ON l.intLotId = tl.intLotId
		WHERE l.intLotId = @intInputLotId

		IF @dblInputReqQty > @dblInputAvlQty
			AND ABS(@dblInputReqQty - @dblInputAvlQty) > 1
		BEGIN
			SELECT @strInputLotNumber = NULL

			SELECT @strInputLotNumber = strLotNumber
			FROM tblICLot
			WHERE intLotId = @intInputLotId

			SELECT @strInputItemNo = NULL

			SELECT @strInputItemNo = strItemNo
			FROM tblICItem
			WHERE intItemId = @intInputItemId

			SET @ErrMsg = 'Quantity of ' + [dbo].[fnRemoveTrailingZeroes](@dblInputReqQty) + ' from lot ' + @strInputLotNumber + ' of item ' + CONVERT(NVARCHAR, @strInputItemNo) + + ' cannot be added to blend sheet because the lot has available qty of ' + [dbo].[fnRemoveTrailingZeroes](@dblInputAvlQty) + '.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END

		SELECT @intMinLot = Min(intRowNo)
		FROM @tblLotSummary
		WHERE intRowNo > @intMinLot
	END

	UPDATE @tblLot
	SET intStorageLocationId = NULL
	WHERE intStorageLocationId = 0;

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
		,@ysnCopyRecipeOnSave = IsNULL(ysnCopyRecipeOnSave, 0)
		,@ysnTBSReserveOnSave = IsNULL(ysnTBSReserveOnSave, 0)
	FROM tblMFCompanyPreference

	IF @ysnEnableParentLot = 0
	BEGIN
		UPDATE VarLot
		SET VarLot.dblWeightPerUnit = Lot.dblWeightPerQty
		FROM @tblLot AS VarLot
		JOIN tblICLot AS Lot ON VarLot.intLotId = Lot.intLotId
	END
	ELSE
	BEGIN
		UPDATE VarLot
		SET VarLot.dblWeightPerUnit = (
				SELECT TOP 1 dblWeightPerQty
				FROM tblICLot
				WHERE intParentLotId = ParentLot.intParentLotId
				)
		FROM @tblLot AS VarLot
		JOIN tblICParentLot AS ParentLot ON VarLot.intLotId = ParentLot.intParentLotId
	END

	SELECT @intWorkOrderId = intWorkOrderId
		,@intBlendRequirementId = intBlendRequirementId
		,@intCellId = intCellId
		,@intIssuedUOMTypeId = intIssuedUOMTypeId
		,@intCreatedUserId = intUserId
		,@ysnOverrideRecipe = ysnOverrideRecipe
	FROM @tblBlendSheet;

	SELECT @strDemandNo = strDemandNo
		,@strReferenceNo = strReferenceNo
		,@intNoOfSheets = (
			CASE 
				WHEN ISNULL(dblEstNoOfBlendSheet, 0) = 0
					THEN 1
				ELSE CEILING(dblEstNoOfBlendSheet)
				END
			)
	FROM tblMFBlendRequirement
	WHERE intBlendRequirementId = @intBlendRequirementId;

	IF (SELECT ysnRecipeHeaderValidation FROM tblMFCompanyPreference) = 1
		BEGIN
			SELECT TOP 1 @intManufacturingProcessId = Recipe.intManufacturingProcessId
			FROM tblMFRecipe AS Recipe
			JOIN @tblBlendSheet AS BlendSheet ON Recipe.intItemId = BlendSheet.intItemId 
											 AND Recipe.intLocationId = BlendSheet.intLocationId
											 AND ysnActive = 1
			WHERE GETDATE() BETWEEN Recipe.dtmValidFrom AND Recipe.dtmValidTo
		END
	ELSE
		BEGIN
			SELECT TOP 1 @intManufacturingProcessId = Recipe.intManufacturingProcessId
			FROM tblMFRecipe AS Recipe
			JOIN @tblBlendSheet AS BlendSheet ON Recipe.intItemId = BlendSheet.intItemId 
											 AND Recipe.intLocationId = BlendSheet.intLocationId
											 AND ysnActive = 1
		END

	SELECT @intBlendItemId = intItemId
		,@intLocationId = intLocationId
		,@dblPlannedQuantity = dblPlannedQuantity
	FROM @tblBlendSheet;

	SELECT @intCategoryId = intCategoryId
	FROM tblICItem
	WHERE intItemId = @intBlendItemId;

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	SELECT @strPackagingCategoryId = ISNULL(ProcessAttribute.strAttributeValue, '')
	FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
	JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND Attribute.strAttributeName = 'Packaging Category';

	SELECT @intPlannedShiftId = intPlannedShiftId
	FROM @tblBlendSheet;

	IF ISNULL(@intPlannedShiftId, 0) = 0
	BEGIN
		SELECT @intPlannedShiftId = intShiftId
		FROM dbo.tblMFShift
		WHERE intLocationId = @intLocationId
			AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
				AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

		IF @intPlannedShiftId IS NULL
		BEGIN
			SELECT @intPlannedShiftId = intShiftId
			FROM dbo.tblMFShift
			WHERE intLocationId = @intLocationId
				AND intShiftSequence = 1;
		END

		UPDATE @tblBlendSheet
		SET intPlannedShiftId = @intPlannedShiftId
	END

	BEGIN TRANSACTION

	IF @intWorkOrderId = 0
	BEGIN
		DECLARE @strNextWONo NVARCHAR(50)

		IF (SELECT ysnAllowToCreateMultipleBlendSheetOnDemand FROM tblMFCompanyPreference) = 0 AND EXISTS (SELECT TOP 1 * FROM tblMFWorkOrder WHERE intBlendRequirementId = @intBlendRequirementId)
			BEGIN
				SET @ErrMsg = 'You cannot create multiple Blend for Demand:' + @strDemandNo + '';

				RAISERROR 
				(
					@ErrMsg
				  , 16
				  , 1
				)
			END

		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intBlendItemId
			,@intManufacturingId = @intCellId
			,@intSubLocationId = 0
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = @intBlendRequirementId
			,@intPatternCode = 93
			,@ysnProposed = 0
			,@strPatternString = @strNextWONo OUTPUT

		/* Exclude Packing category while summing weight. */
		UPDATE @tblBlendSheet
		SET dblQtyToProduce = (
				SELECT SUM(ISNULL(dblQty, 0))
				FROM @tblLot AS VarLot
				JOIN tblICItem AS Item ON VarLot.intItemId = Item.intItemId
				WHERE Item.intCategoryId NOT IN (
						SELECT *
						FROM dbo.fnCommaSeparatedValueToTable(@strPackagingCategoryId)
						)
				);

		INSERT INTO tblMFWorkOrder (
			strWorkOrderNo
			,intItemId
			,dblQuantity
			,intItemUOMId
			,intStatusId
			,intManufacturingCellId
			,intMachineId
			,intLocationId
			,dblBinSize
			,dtmExpectedDate
			,intExecutionOrder
			,intProductionTypeId
			,dblPlannedQuantity
			,intBlendRequirementId
			,ysnKittingEnabled
			,ysnDietarySupplements
			,ysnUseTemplate
			,strComment
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			,intConcurrencyId
			,intManufacturingProcessId
			,intTransactionFrom
			,intPlannedShiftId
			,dtmPlannedDate
			,strERPOrderNo
			,intIssuedUOMTypeId
			,ysnOverrideRecipe
			,dblUpperTolerance
			,dblLowerTolerance
			,dblCalculatedUpperTolerance
			,dblCalculatedLowerTolerance
			)
		SELECT @strNextWONo
			,intItemId
			,dblQtyToProduce
			,intItemUOMId
			,2
			,intCellId
			,intMachineId
			,intLocationId
			,dblBinSize
			,dtmDueDate
			,0
			,1
			,dblPlannedQuantity
			,intBlendRequirementId
			,ysnKittingEnabled
			,ysnDietarySupplements
			,ysnUseTemplate
			,strComment
			,GetDate()
			,intUserId
			,GetDate()
			,intUserId
			,intConcurrencyId + 1
			,@intManufacturingProcessId
			,1
			,intPlannedShiftId
			,dtmDueDate
			,@strReferenceNo
			,intIssuedUOMTypeId
			,ysnOverrideRecipe
			,dblUpperTolerance
			,dblLowerTolerance
			,dblCalculatedUpperTolerance
			,dblCalculatedLowerTolerance
		FROM @tblBlendSheet

		SET @intWorkOrderId = SCOPE_IDENTITY()

		IF @ysnCopyRecipeOnSave = 1
		BEGIN
			EXEC dbo.uspMFCopyRecipe @intItemId = @intBlendItemId
				,@intLocationId = @intLocationId
				,@intUserId = @intCreatedUserId
				,@intWorkOrderId = @intWorkOrderId
		END
	END
	ELSE
	BEGIN
		UPDATE WorkOrder
		SET WorkOrder.intManufacturingCellId = VarBlendSheet.intCellId
			,WorkOrder.intMachineId = VarBlendSheet.intMachineId
			,WorkOrder.dblBinSize = VarBlendSheet.dblBinSize
			,WorkOrder.dtmExpectedDate = VarBlendSheet.dtmDueDate
			,WorkOrder.dblPlannedQuantity = VarBlendSheet.dblPlannedQuantity
			,WorkOrder.ysnKittingEnabled = VarBlendSheet.ysnKittingEnabled
			,WorkOrder.ysnDietarySupplements = VarBlendSheet.ysnDietarySupplements
			,WorkOrder.ysnUseTemplate = VarBlendSheet.ysnUseTemplate
			,WorkOrder.strComment = VarBlendSheet.strComment
			,WorkOrder.intLastModifiedUserId = VarBlendSheet.intUserId
			,WorkOrder.dtmLastModified = GETDATE()
			,WorkOrder.intConcurrencyId = WorkOrder.intConcurrencyId + 1
			,WorkOrder.intPlannedShiftId = VarBlendSheet.intPlannedShiftId
			,WorkOrder.dtmPlannedDate = VarBlendSheet.dtmDueDate
			,WorkOrder.ysnOverrideRecipe = VarBlendSheet.ysnOverrideRecipe
			,WorkOrder.dblUpperTolerance = VarBlendSheet.dblUpperTolerance
			,WorkOrder.dblLowerTolerance = VarBlendSheet.dblLowerTolerance
			,WorkOrder.dblCalculatedUpperTolerance = VarBlendSheet.dblCalculatedUpperTolerance
			,WorkOrder.dblCalculatedLowerTolerance = VarBlendSheet.dblCalculatedLowerTolerance
		FROM tblMFWorkOrder AS WorkOrder
		JOIN @tblBlendSheet AS VarBlendSheet ON WorkOrder.intWorkOrderId = VarBlendSheet.intWorkOrderId
	END

	SELECT @dtmProductionDate = dtmExpectedDate
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId;

	SELECT @intIssuedUOMTypeId = NULL

	IF @intIssuedUOMTypeId IS NULL
	BEGIN
		SELECT @strValue = a.strValue
		FROM tblMFBlendRequirementRule a
		JOIN tblMFBlendSheetRule b ON a.intBlendSheetRuleId = b.intBlendSheetRuleId
		WHERE intBlendRequirementId = @intBlendRequirementId
			AND b.strName = 'Pick By'

		SELECT @intIssuedUOMTypeId = intIssuedUOMTypeId
		FROM tblMFMachineIssuedUOMType
		WHERE strName = @strValue

		IF @intIssuedUOMTypeId IS NULL
		BEGIN
			SELECT @intIssuedUOMTypeId = intIssuedUOMTypeId
			FROM tblMFMachine
			WHERE intLocationId = @intLocationId
				AND intIssuedUOMTypeId IS NOT NULL
		END

		IF @intIssuedUOMTypeId IS NULL
			SELECT @intIssuedUOMTypeId = 1
	END

	SELECT @intMinRowNo = Min(intRowNo)
	FROM @tblLot;

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		SELECT @strRowState = strRowState
			,@intWorkOrderInputLotId = intWorkOrderInputLotId
		FROM @tblLot
		WHERE intRowNo = @intMinRowNo;

		/* New Record. */
		IF @strRowState = 'ADDED'
		BEGIN
			/* For Enable Parent Lot Configuration. */
			IF @ysnEnableParentLot = 0
			BEGIN
				SELECT @intItemId = intItemId
					,@dblIssuedQuantity = dblIssuedQuantity
				FROM @tblLot
				WHERE intRowNo = @intMinRowNo

				--IF (@dblIssuedQuantity % @intNoOfSheets) > 0
				--	AND @intIssuedUOMTypeId = 4
				--BEGIN
				--	IF EXISTS (
				--			SELECT *
				--			FROM @tblFW
				--			WHERE intItemId = @intItemId
				--			)
				--	BEGIN
				--		SELECT @strChar = NULL
				--			,@intSeq = NULL
				--		SELECT @strChar = strChar
				--			,@intSeq = intSeq + 1
				--		FROM @tblFW
				--		WHERE intItemId = @intItemId
				--		UPDATE @tblFW
				--		SET intSeq = @intSeq
				--		WHERE intItemId = @intItemId
				--		SELECT @strFW = @strChar + ltrim(@intSeq)
				--	END
				--	ELSE
				--	BEGIN
				--		SELECT @intRecordId = NULL
				--			,@strChar = NULL
				--			,@intSeq = 1
				--		SELECT TOP 1 @intRecordId = intRecordId
				--			,@strChar = strChar
				--		FROM @tblFW
				--		WHERE intItemId IS NULL
				--		ORDER BY intRecordId ASC
				--		UPDATE @tblFW
				--		SET intItemId = @intItemId
				--			,intSeq = 1
				--		WHERE intRecordId = @intRecordId
				--		SELECT @strFW = @strChar + ltrim(@intSeq)
				--	END
				--END
				INSERT INTO tblMFWorkOrderInputLot (
					intWorkOrderId
					,intLotId
					,intItemId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intSequenceNo
					,dtmCreated
					,intCreatedUserId
					,dtmLastModified
					,intLastModifiedUserId
					,intRecipeItemId
					,dtmProductionDate
					,dtmBusinessDate
					,intBusinessShiftId
					,strFW
					,ysnOverrideRecipe
					)
				SELECT @intWorkOrderId
					,intLotId
					,intItemId
					,dblQty
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,NULL
					,GetDate()
					,intUserId
					,GetDate()
					,intUserId
					,intRecipeItemId
					,@dtmProductionDate
					,@dtmBusinessDate
					,@intBusinessShiftId
					,@strFW
					,ysnOverrideRecipe
				FROM @tblLot
				WHERE intRowNo = @intMinRowNo

				SET @intWorkOrderInputLotId = SCOPE_IDENTITY()

				IF @ysnOverrideRecipe = 1
				AND EXISTS(SELECT 1
					FROM tblMFWorkOrderRecipe
					WHERE intWorkOrderId = @intWorkOrderId)
				BEGIN
					SELECT @intRecipeId = NULL
						,@dtmValidFrom = NULL
						,@dtmValidTo = NULL

					SELECT @intRecipeId = intRecipeId
						,@dtmValidFrom = dtmValidFrom
						,@dtmValidTo = dtmValidTo
					FROM tblMFWorkOrderRecipe
					WHERE intWorkOrderId = @intWorkOrderId

					SELECT @intRecipeItemId = NULL

					SELECT @intRecipeItemId = Max(intRecipeItemId) + 1
					FROM tblMFWorkOrderRecipeItem

					IF @intRecipeId IS NOT NULL
					BEGIN
						INSERT INTO tblMFWorkOrderRecipeItem (
							intRecipeItemId
							,intRecipeId
							,intItemId
							,dblQuantity
							,dblCalculatedQuantity
							,[intItemUOMId]
							,intRecipeItemTypeId
							,strItemGroupName
							,dblUpperTolerance
							,dblLowerTolerance
							,dblCalculatedUpperTolerance
							,dblCalculatedLowerTolerance
							,dblShrinkage
							,ysnScaled
							,intConsumptionMethodId
							,intStorageLocationId
							,dtmValidFrom
							,dtmValidTo
							,ysnYearValidationRequired
							,ysnMinorIngredient
							,intReferenceRecipeId
							,ysnOutputItemMandatory
							,dblScrap
							,ysnConsumptionRequired
							,dblPercentage
							,intMarginById
							,dblMargin
							,ysnCostAppliedAtInvoice
							,ysnPartialFillConsumption
							,intManufacturingCellId
							,intWorkOrderId
							,intCreatedUserId
							,dtmCreated
							,intLastModifiedUserId
							,dtmLastModified
							,intConcurrencyId
							,intCostDriverId
							,dblCostRate
							,ysnLock
							)
						SELECT intRecipeItemId = @intRecipeItemId
							,intRecipeId = @intRecipeId
							,intItemId = L.intItemId
							,dblQuantity = 1
							,dblCalculatedQuantity = 1
							,[intItemUOMId] = L.intItemUOMId
							,intRecipeItemTypeId = 1
							,strItemGroupName = ''
							,dblUpperTolerance = 100
							,dblLowerTolerance = 100
							,dblCalculatedUpperTolerance = 2
							,dblCalculatedLowerTolerance = 1
							,dblShrinkage = 0
							,ysnScaled = 1
							,intConsumptionMethodId = 1
							,intStorageLocationId = NULL
							,dtmValidFrom = @dtmValidFrom
							,dtmValidTo = @dtmValidTo
							,ysnYearValidationRequired = 1
							,ysnMinorIngredient = 0
							,intReferenceRecipeId = NULL
							,ysnOutputItemMandatory = 0
							,dblScrap = 0
							,ysnConsumptionRequired = 0
							,[dblCostAllocationPercentage] = NULL
							,intMarginById = NULL
							,dblMargin = NULL
							,ysnCostAppliedAtInvoice = NULL
							,ysnPartialFillConsumption = 1
							,intManufacturingCellId = NULL
							,intWorkOrderId = @intWorkOrderId
							,intCreatedUserId = @intCreatedUserId
							,dtmCreated = @dtmCurrentDateTime
							,intLastModifiedUserId = @intCreatedUserId
							,dtmLastModified = @dtmCurrentDateTime
							,intConcurrencyId = 1
							,intCostDriverId = NULL
							,dblCostRate = NULL
							,ysnLock = 1
						FROM @tblLot L
						WHERE intRowNo = @intMinRowNo
							AND NOT EXISTS (
								SELECT *
								FROM tblMFWorkOrderRecipeItem RI
								WHERE RI.intWorkOrderId = @intWorkOrderId
									AND RI.intItemId = L.intItemId
								)
					END
				END

				IF @ysnTBSReserveOnSave = 1
				BEGIN
					SELECT @dblTBSQuantity = 0

					SELECT @dblTBSQuantity = dblQty
					FROM @tblLot
					WHERE intRowNo = @intMinRowNo

					EXEC [dbo].[uspMFTrialBlendSheet] @intWorkOrderId = @intWorkOrderId
						,@intWorkOrderInputLotId = @intWorkOrderInputLotId
						,@ysnKeep = 1
						,@type = 'Confirm'
						,@UserId = @intCreatedUserId
						,@dblTBSQuantity = @dblTBSQuantity
				END
			END
					/*End of For Enable Parent Lot Configuration. */
			ELSE
			BEGIN
				INSERT INTO tblMFWorkOrderInputParentLot (
					intWorkOrderId
					,intParentLotId
					,intItemId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intSequenceNo
					,dtmCreated
					,intCreatedUserId
					,dtmLastModified
					,intLastModifiedUserId
					,intRecipeItemId
					,dblWeightPerUnit
					,intLocationId
					,intStorageLocationId
					)
				SELECT @intWorkOrderId
					,intLotId
					,intItemId
					,dblQty
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,NULL
					,GETDATE()
					,intUserId
					,GETDATE()
					,intUserId
					,intRecipeItemId
					,dblWeightPerUnit
					,intLocationId
					,intStorageLocationId
				FROM @tblLot
				WHERE intRowNo = @intMinRowNo;
			END
					/* End of New Record. */
		END

		/* Update Record. */
		IF @strRowState = 'MODIFIED'
		BEGIN
			/* For Enable Parent Lot Configuration. */
			IF @ysnEnableParentLot = 0
			BEGIN
				IF @ysnTBSReserveOnSave = 1
				BEGIN
					UPDATE LI
					SET dblReservedQtyInTBS = IsNULL(LI.dblReservedQtyInTBS, 0) - WI.dblQuantity
					FROM dbo.tblMFLotInventory LI
					JOIN dbo.tblMFWorkOrderInputLot WI ON WI.intLotId = LI.intLotId
					WHERE WI.intWorkOrderId = @intWorkOrderId
						AND intWorkOrderInputLotId = IsNULL(@intWorkOrderInputLotId, intWorkOrderInputLotId)
				END

				UPDATE tblMFWorkOrderInputLot
				SET dblQuantity = (
						SELECT dblQty
						FROM @tblLot
						WHERE intRowNo = @intMinRowNo
						)
					,dblIssuedQuantity = (
						SELECT dblIssuedQuantity
						FROM @tblLot
						WHERE intRowNo = @intMinRowNo
						)
					,dtmProductionDate = @dtmProductionDate
					,dtmBusinessDate = @dtmBusinessDate
					,intBusinessShiftId = @intBusinessShiftId
					,strFW = (
						SELECT strFW
						FROM @tblLot
						WHERE intRowNo = @intMinRowNo
						)
					,dblTBSQuantity = CASE 
						WHEN @ysnTBSReserveOnSave = 1
							THEN (
									SELECT dblQty
									FROM @tblLot
									WHERE intRowNo = @intMinRowNo
									)
						ELSE dblTBSQuantity
						END
					,ysnTBSReserved = CASE 
						WHEN @ysnTBSReserveOnSave = 1
							THEN 1
						ELSE ysnTBSReserved
						END
				WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

				IF @ysnOverrideRecipe = 1 
					AND EXISTS(SELECT 1
					FROM tblMFWorkOrderRecipe
					WHERE intWorkOrderId = @intWorkOrderId)
				BEGIN
					SELECT @intRecipeId = NULL
						,@dtmValidFrom = NULL
						,@dtmValidTo = NULL

					SELECT @intRecipeId = intRecipeId
						,@dtmValidFrom = dtmValidFrom
						,@dtmValidTo = dtmValidTo
					FROM tblMFWorkOrderRecipe
					WHERE intWorkOrderId = @intWorkOrderId

					SELECT @intRecipeItemId = NULL

					SELECT @intRecipeItemId = Max(intRecipeItemId) + 1
					FROM tblMFWorkOrderRecipeItem

					IF @intRecipeId IS NOT NULL
					BEGIN
						INSERT INTO tblMFWorkOrderRecipeItem (
							intRecipeItemId
							,intRecipeId
							,intItemId
							,dblQuantity
							,dblCalculatedQuantity
							,[intItemUOMId]
							,intRecipeItemTypeId
							,strItemGroupName
							,dblUpperTolerance
							,dblLowerTolerance
							,dblCalculatedUpperTolerance
							,dblCalculatedLowerTolerance
							,dblShrinkage
							,ysnScaled
							,intConsumptionMethodId
							,intStorageLocationId
							,dtmValidFrom
							,dtmValidTo
							,ysnYearValidationRequired
							,ysnMinorIngredient
							,intReferenceRecipeId
							,ysnOutputItemMandatory
							,dblScrap
							,ysnConsumptionRequired
							,dblPercentage
							,intMarginById
							,dblMargin
							,ysnCostAppliedAtInvoice
							,ysnPartialFillConsumption
							,intManufacturingCellId
							,intWorkOrderId
							,intCreatedUserId
							,dtmCreated
							,intLastModifiedUserId
							,dtmLastModified
							,intConcurrencyId
							,intCostDriverId
							,dblCostRate
							,ysnLock
							)
						SELECT intRecipeItemId = @intRecipeItemId
							,intRecipeId = @intRecipeId
							,intItemId = L.intItemId
							,dblQuantity = 1
							,dblCalculatedQuantity = 1
							,[intItemUOMId] = L.intItemUOMId
							,intRecipeItemTypeId = 1
							,strItemGroupName = ''
							,dblUpperTolerance = 100
							,dblLowerTolerance = 100
							,dblCalculatedUpperTolerance = 2
							,dblCalculatedLowerTolerance = 1
							,dblShrinkage = 0
							,ysnScaled = 1
							,intConsumptionMethodId = 1
							,intStorageLocationId = NULL
							,dtmValidFrom = @dtmValidFrom
							,dtmValidTo = @dtmValidTo
							,ysnYearValidationRequired = 1
							,ysnMinorIngredient = 0
							,intReferenceRecipeId = NULL
							,ysnOutputItemMandatory = 0
							,dblScrap = 0
							,ysnConsumptionRequired = 0
							,[dblCostAllocationPercentage] = NULL
							,intMarginById = NULL
							,dblMargin = NULL
							,ysnCostAppliedAtInvoice = NULL
							,ysnPartialFillConsumption = 1
							,intManufacturingCellId = NULL
							,intWorkOrderId = @intWorkOrderId
							,intCreatedUserId = @intCreatedUserId
							,dtmCreated = @dtmCurrentDateTime
							,intLastModifiedUserId = @intCreatedUserId
							,dtmLastModified = @dtmCurrentDateTime
							,intConcurrencyId = 1
							,intCostDriverId = NULL
							,dblCostRate = NULL
							,ysnLock = 1
						FROM @tblLot L
						WHERE intRowNo = @intMinRowNo
							AND NOT EXISTS (
								SELECT *
								FROM tblMFWorkOrderRecipeItem RI
								WHERE RI.intWorkOrderId = @intWorkOrderId
									AND RI.intItemId = L.intItemId
								)
						END
				END

				IF @ysnTBSReserveOnSave = 1
				BEGIN
					EXEC [dbo].[uspMFUpdateTrialBlendSheetReservation] @intWorkOrderId
																 , @intWorkOrderInputLotId
				END
			END
			ELSE
			BEGIN
				UPDATE tblMFWorkOrderInputParentLot
				SET dblQuantity = (
						SELECT dblQty
						FROM @tblLot
						WHERE intRowNo = @intMinRowNo
						)
					,dblIssuedQuantity = (
						SELECT dblIssuedQuantity
						FROM @tblLot
						WHERE intRowNo = @intMinRowNo
						)
				WHERE intWorkOrderInputParentLotId = @intWorkOrderInputLotId
			END
					/* End of Update Record. */
		END

		/* Delete Record. */
		IF @strRowState = 'DELETE'
		BEGIN
			IF @ysnEnableParentLot = 0
			BEGIN
				EXEC [dbo].[uspMFDeleteTrialBlendSheetReservation] @intWorkOrderId
														 , @intWorkOrderInputLotId
				DELETE
				FROM tblMFWorkOrderInputLot
				WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId;
			END
			ELSE
			BEGIN
				DELETE
				FROM tblMFWorkOrderInputParentLot
				WHERE intWorkOrderInputParentLotId = @intWorkOrderInputLotId;
			END
					/* End of Delete Record. */
		END

		SELECT @intMinRowNo = Min(intRowNo)
		FROM @tblLot
		WHERE intRowNo > @intMinRowNo
			/* End of WHILE. */
	END

	/* Update Bulk Item(By Location or FIFO) Standard Required Qty Calculated Using Planned Qty. */
	SELECT @dblBulkReqQuantity = ISNULL(SUM((RecipeItem.dblCalculatedQuantity * (@dblPlannedQuantity / Recipe.dblQuantity))), 0)
	FROM tblMFRecipeItem AS RecipeItem
	JOIN tblMFRecipe AS Recipe ON Recipe.intRecipeId = RecipeItem.intRecipeId
	WHERE Recipe.intItemId = @intBlendItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1
		AND RecipeItem.intRecipeItemTypeId = 1
		AND RecipeItem.intConsumptionMethodId IN (
			2
			,3
			);

	IF @ysnEnableParentLot = 0
	BEGIN
		SELECT @dblWOQuantity = SUM(ISNULL(dblQuantity, 0))
		FROM tblMFWorkOrderInputLot AS InputLot
		JOIN tblICItem AS Item ON InputLot.intItemId = Item.intItemId
		WHERE InputLot.intWorkOrderId = @intWorkOrderId
			AND Item.intCategoryId NOT IN (
				SELECT *
				FROM dbo.fnCommaSeparatedValueToTable(@strPackagingCategoryId)
				);
	END
	ELSE
	BEGIN
		SELECT @dblWOQuantity = SUM(ISNULL(dblQuantity, 0))
		FROM tblMFWorkOrderInputParentLot AS InputLot
		JOIN tblICItem AS Item ON InputLot.intItemId = Item.intItemId
		WHERE InputLot.intWorkOrderId = @intWorkOrderId
			AND Item.intCategoryId NOT IN (
				SELECT *
				FROM dbo.fnCommaSeparatedValueToTable(@strPackagingCategoryId)
				);
	END

	UPDATE tblMFWorkOrder
	SET dblQuantity = ISNULL(@dblWOQuantity, 0) + ISNULL(@dblBulkReqQuantity, 0)
	WHERE intWorkOrderId = @intWorkOrderId;

	UPDATE tblMFBlendRequirement
	SET dblIssuedQty = (
			SELECT SUM(dblQuantity)
			FROM tblMFWorkOrder
			WHERE intBlendRequirementId = @intBlendRequirementId
			)
	WHERE intBlendRequirementId = @intBlendRequirementId;

	UPDATE tblMFBlendRequirement
	SET intStatusId = 2
	WHERE intBlendRequirementId = @intBlendRequirementId
		AND ISNULL(dblIssuedQty, 0) >= dblQuantity

	/* Create Quality Computations. */
	EXEC uspMFCreateBlendRecipeComputation @intWorkOrderId = @intWorkOrderId
		,@intTypeId = 1
		,@strXml = @strXml

	--FW
	SELECT @intWorkOrderInputLotId = NULL

	SELECT @intWorkOrderInputLotId = min(intWorkOrderInputLotId)
	FROM tblMFWorkOrderInputLot
	WHERE intWorkOrderId = @intWorkOrderId

	WHILE @intWorkOrderInputLotId IS NOT NULL
	BEGIN
		SELECT @intItemId = NULL
			,@dblIssuedQuantity = NULL
			,@strFW=NULL
			,@intLotId =NULL
			,@dblWeight=NULL

		SELECT @intItemId = intItemId
			,@dblIssuedQuantity = dblIssuedQuantity
			,@intLotId=intLotId
		FROM tblMFWorkOrderInputLot
		WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

		SELECT @dblTBSQuantity=SUM(dblTBSQuantity) 
		FROM tblMFWorkOrderInputLot
		WHERE intLotId = @intLotId

		Select @dblInputAvlQty=dblWeight  
		from tblICLot 
		Where intLotId=@intLotId
		
		if @dblTBSQuantity>@dblInputAvlQty AND ABS(@dblTBSQuantity-@dblInputAvlQty)>1
		Begin
			SELECT @strInputLotNumber = NULL

			SELECT @strInputLotNumber = strLotNumber
			FROM tblICLot
			WHERE intLotId = @intLotId

			SELECT @strInputItemNo = NULL

			SELECT @strInputItemNo = strItemNo
			FROM tblICItem
			WHERE intItemId = @intItemId

			SET @ErrMsg = 'Quantity of ' + [dbo].[fnRemoveTrailingZeroes](@dblTBSQuantity) + ' from lot ' + @strInputLotNumber + ' of item ' + CONVERT(NVARCHAR, @strInputItemNo) + + ' cannot be added to blend sheet because the lot has available qty of ' + [dbo].[fnRemoveTrailingZeroes](@dblInputAvlQty) + '.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		End

		IF (@dblIssuedQuantity % @intNoOfSheets) > 0
			AND @intIssuedUOMTypeId = 4
		BEGIN
			IF EXISTS (
					SELECT *
					FROM @tblFW
					WHERE intItemId = @intItemId
					)
			BEGIN
				SELECT @strChar = NULL
					,@intSeq = NULL

				SELECT @strChar = strChar
					,@intSeq = intSeq + 1
				FROM @tblFW
				WHERE intItemId = @intItemId

				UPDATE @tblFW
				SET intSeq = @intSeq
				WHERE intItemId = @intItemId

				SELECT @strFW = @strChar + ltrim(@intSeq)
			END
			ELSE
			BEGIN
				SELECT @intRecordId = NULL
					,@strChar = NULL
					,@intSeq = 1

				SELECT TOP 1 @intRecordId = intRecordId
					,@strChar = strChar
				FROM @tblFW
				WHERE intItemId IS NULL
				ORDER BY intRecordId ASC

				UPDATE @tblFW
				SET intItemId = @intItemId
					,intSeq = 1
				WHERE intRecordId = @intRecordId

				SELECT @strFW = @strChar + ltrim(@intSeq)
			END
		END

		UPDATE tblMFWorkOrderInputLot
		SET strFW = @strFW, ysnKeep =Case When @dblInputAvlQty>@dblTBSQuantity then 1 Else 0 End
		WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

		SELECT @intWorkOrderInputLotId = min(intWorkOrderInputLotId)
		FROM tblMFWorkOrderInputLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND intWorkOrderInputLotId > @intWorkOrderInputLotId
	END

	COMMIT TRANSACTION

	SELECT @intWorkOrderId AS intWorkOrderId
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
