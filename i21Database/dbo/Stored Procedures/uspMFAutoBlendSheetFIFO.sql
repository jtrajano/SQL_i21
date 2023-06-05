CREATE PROCEDURE [dbo].[uspMFAutoBlendSheetFIFO] @intLocationId INT
	,@intBlendRequirementId INT
	,@dblQtyToProduce NUMERIC(38, 20)
	,@strXml NVARCHAR(MAX) = NULL
	,@ysnFromPickList BIT = 0
	,@strExcludedLotXml NVARCHAR(MAX) = NULL
	,@strWorkOrderIds NVARCHAR(max) = NULL
	,@intItemId INT = NULL
	,@ysnQuality BIT = 1
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	SET NOCOUNT ON

	DECLARE @intBlendItemId INT
		,@strBlendItemNo NVARCHAR(50)
		,@dblRequiredQty NUMERIC(38, 20)
		,@intMinRowNo INT
		,@intRecipeItemId INT
		,@intRawItemId INT
		,@strErrMsg NVARCHAR(MAX)
		,@intIssuedUOMTypeId INT
		,@ysnMinorIngredient BIT
		,@dblPercentageIncrease NUMERIC(38, 20) = 0
		,@intNoOfSheets INT = 1
		,@intStorageLocationId INT
		,@intRecipeId INT
		,@strBlenderName NVARCHAR(50)
		,@strLotNumber NVARCHAR(50)
		,@dblAvailableQty NUMERIC(38, 20)
		,@intEstNoOfSheets INT
		,@dblWeightPerQty NUMERIC(38, 20)
		,@intMachineId INT
		,@strSQL NVARCHAR(MAX)
		,@ysnEnableParentLot BIT = 0
		,@ysnShowAvailableLotsByStorageLocation BIT = 0
		,@intManufacturingProcessId INT
		,@intParentLotId INT
		,@ysnRecipeItemValidityByDueDate BIT = 0
		,@intDayOfYear INT
		,@dtmDate DATETIME
		,@dtmDueDate DATETIME
		,@dblOriginalRequiredQty NUMERIC(38, 20)
		,@dblPartialQuantity NUMERIC(38, 20)
		,@dblRemainingRequiredQty NUMERIC(38, 20)
		,@intPartialQuantitySubLocationId INT
		,@intOriginalIssuedUOMTypeId INT
		,@intKitStagingLocationId INT
		,@intBlendStagingLocationId INT
		,@intMinPartialQtyLotRowNo INT
		,@dblAvailablePartialQty NUMERIC(38, 20)
		,@idoc INT
		,@idoc1 INT
		,@intConsumptionMethodId INT
		,@intConsumptionStoragelocationId INT
		,@ysnIsSubstitute BIT
		,@intWorkOrderId INT
		,@dblBulkItemAvailableQty NUMERIC(38, 20)
		,@dblRecipeQty NUMERIC(38, 20)
		,@strLotTracking NVARCHAR(50)
		,@intItemUOMId INT
		,@index INT
		,@id INT
		,@ysnWOStagePick BIT = 0
		,@ysnIncludeKitStagingLocation BIT = 0
		,@dblDefaultResidueQty NUMERIC(38, 20)
		,@strSourceLocationIds NVARCHAR(MAX)
		,@intSequenceNo INT
		,@intSequenceCount INT = 1
		,@strRuleName NVARCHAR(100)
		,@strValue NVARCHAR(50)
		,@strOrderBy NVARCHAR(500) = ''
		,@strOrderByFinal NVARCHAR(500) = ''
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
		,@intSeq INT
		,@dblTotalPickedQty NUMERIC(38, 20)
		,@dblSuggestedCeilingQty DECIMAL(38, 20)
		,@dblSuggestedFloorQty DECIMAL(38, 20)
		,@dblCeilingQtyDiff DECIMAL(38, 20)
		,@dblFloorQtyDiff DECIMAL(38, 20)
		,@dblOrgRequiredQty DECIMAL(38, 20)
		,@dblAvailableQty1 DECIMAL(38, 20)
		,@intLayerPerPallet INT
		,@intUnitPerLayer INT
		,@dblPalletQty DECIMAL(38, 20)
		,@dblNoOfPallets DECIMAL(18, 2)
		,@ysnRecipeHeaderValidation BIT
		,@intManufacturingCellId INT
		,@strWhere NVARCHAR(MAX)
		,@intValidDate INT
		,@ysnReleaseBlendsheetByNoOfMixes BIT
		,@strFW NVARCHAR(3)
		,@strChar NVARCHAR(1)
		,@intRecordId INT
		,@intOrgNoOfSheets INT
		,@dblAutoLotPicking NUMERIC(38, 20)
		,@ysnDisplayLandedPriceInBlendManagement	INT
	DECLARE @tblInputItemSeq TABLE (
		intRecordId INT
		,intItemId INT
		,intSeq INT
		);
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
		,dblSubstituteRatio NUMERIC(38, 20)
		,dblMaxSubstituteRatio NUMERIC(38, 20)
		,strLotTracking NVARCHAR(50)
		,intItemUOMId INT
		,dblUpperToleranceQty NUMERIC(38, 20)
		,dblLowerToleranceQty NUMERIC(38, 20)
		,ysnComplianceItem BIT
		,dblCompliancePercent NUMERIC(38, 20)
		,dblPickedQty NUMERIC(38, 20)
		);
	/* To hold not available and less qty lots. */
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
		,intSubLocationId INT
		,strLotAlias NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,ysnParentLot BIT
		,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSecondaryStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		);
	DECLARE @tblPickedItem TABLE (
		intRowNo INT IDENTITY
		,intItemStockUOMId INT
		,intItemId INT
		,dblQty NUMERIC(38, 20)
		,intItemUOMId INT
		,intLocationId INT
		,intSubLocationId INT
		,intStorageLocationId INT
		);
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

	DECLARE @tblLotStatus AS TABLE (strStatusName NVARCHAR(50) COLLATE Latin1_General_CI_AS);
	DECLARE @tblSourceStorageLocation AS TABLE (intStorageLocationId INT);

	/* ======================== END OF VARIABLE DECLARATION ================================= */
	/* Get value of Enable Parent Lot from Manufacturing Configuration. */
	IF (@ysnFromPickList = 0)
	BEGIN
		SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
		FROM tblMFCompanyPreference;
	END

	/* Get value of Default Residue Qty from Manufacturing Configuration. */
	SELECT TOP 1 @dblDefaultResidueQty = ISNULL(dblDefaultResidueQty, 0.00001)
		,@ysnRecipeHeaderValidation = IsNULL(ysnRecipeHeaderValidation, 0)
		,@ysnDisplayLandedPriceInBlendManagement=IsNULL(ysnDisplayLandedPriceInBlendManagement,0)
	FROM tblMFCompanyPreference;

	SELECT @strBlendItemNo = Item.strItemNo
		,@intBlendItemId = Item.intItemId
		,@intMachineId = intMachineId
		,@intEstNoOfSheets = (
			CASE 
				WHEN ISNULL(dblEstNoOfBlendSheet, 0) = 0
					THEN 1
				ELSE CEILING(dblEstNoOfBlendSheet)
				END
			)
		,@intNoOfSheets = (
			CASE 
				WHEN ISNULL(dblEstNoOfBlendSheet, 0) = 0
					THEN 1
				ELSE CEILING(dblEstNoOfBlendSheet)
				END
			)
		,@dtmDueDate = dtmDueDate
		,@intManufacturingCellId = intManufacturingCellId
	FROM tblMFBlendRequirement AS BlendRequirement
	JOIN tblICItem AS Item ON BlendRequirement.intItemId = Item.intItemId
	WHERE BlendRequirement.intBlendRequirementId = @intBlendRequirementId;

	SELECT @strValue = a.strValue
	FROM tblMFBlendRequirementRule a
	JOIN tblMFBlendSheetRule b ON a.intBlendSheetRuleId = b.intBlendSheetRuleId
	WHERE intBlendRequirementId = @intBlendRequirementId
		AND b.strName = 'Auto Lot Picking %'

	IF IsNULL(@strValue, '') <> ''
		AND isNumeric(@strValue) = 1
	BEGIN
		SELECT @dblQtyToProduce = @dblQtyToProduce * @strValue / 100
	END

	/* Set Sheet value if there's no Blend Requirement passed from parameter. */
	IF ISNULL(@intBlendRequirementId, 0) = 0
	BEGIN
		SELECT @intBlendItemId = intItemId
			,@strBlendItemNo = strItemNo
		FROM tblICItem
		WHERE intItemId = @intItemId;

		SET @intEstNoOfSheets = 1;
		SET @intNoOfSheets = 1;
		SET @dtmDueDate = GETDATE();
	END

	/* Get Recipe Item Validity By Due Date value from Manufacturing Process based on location. */
	SELECT @ysnRecipeItemValidityByDueDate = (
			CASE 
				WHEN UPPER(ProcessAttribute.strAttributeValue) = 'TRUE'
					THEN 1
				ELSE 0
				END
			)
		,@dtmDate = (
			CASE 
				WHEN UPPER(ProcessAttribute.strAttributeValue) = 'TRUE'
					THEN CONVERT(DATE, @dtmDueDate)
				ELSE CONVERT(DATE, GETDATE())
				END
			)
		,@intDayOfYear = (
			CASE 
				WHEN UPPER(ProcessAttribute.strAttributeValue) = 'TRUE'
					THEN DATEPART(DY, CONVERT(DATE, @dtmDueDate))
				ELSE DATEPART(DY, CONVERT(DATE, GETDATE()))
				END
			)
	FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
	JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
	WHERE intLocationId = @intLocationId
		AND Attribute.strAttributeName = 'Recipe Item Validity By Due Date';

	IF @ysnRecipeHeaderValidation = 1
	BEGIN
		/* Get Recipe and Manufacturing Process ID based on blend output, location and active status. */
		SELECT @intRecipeId = intRecipeId
			,@intManufacturingProcessId = intManufacturingProcessId
		FROM tblMFRecipe
		WHERE intItemId = @intBlendItemId
			AND intLocationId = @intLocationId
			--AND ysnActive = 1
			AND @dtmDate BETWEEN dtmValidFrom
				AND dtmValidTo
	END
	ELSE
	BEGIN
		/* Get Recipe and Manufacturing Process ID based on blend output, location and active status. */
		SELECT @intRecipeId = intRecipeId
			,@intManufacturingProcessId = intManufacturingProcessId
		FROM tblMFRecipe
		WHERE intItemId = @intBlendItemId
			AND intLocationId = @intLocationId
			AND ysnActive = 1;
	END

	/* Get Available Lots By Storage Location value from Manufacturing Process based on location. */
	SELECT @ysnShowAvailableLotsByStorageLocation = (
			CASE 
				WHEN UPPER(ProcessAttribute.strAttributeValue) = 'TRUE'
					THEN 1
				ELSE 0
				END
			)
	FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
	JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND Attribute.strAttributeName = 'Show Available Lots By Storage Location';

	/* Get Partial Quantity Sub Location value from Manufacturing Process based on location. */
	SELECT @intPartialQuantitySubLocationId = ISNULL(ProcessAttribute.strAttributeValue, 0)
	FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
	JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND Attribute.strAttributeName = 'Partial Quantity Sub Location';

	/* Get Kit Staging Location value from Manufacturing Process based on location. */
	SELECT @intKitStagingLocationId = ProcessAttribute.strAttributeValue
	FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
	JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND Attribute.strAttributeName = 'Kit Staging Location';

	/* Get Include Kit Staging Location in Pick List value from Manufacturing Process based on location. */
	SELECT @ysnIncludeKitStagingLocation = (
			CASE 
				WHEN UPPER(ProcessAttribute.strAttributeValue) = 'TRUE'
					THEN 1
				ELSE 0
				END
			)
	FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
	JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND Attribute.strAttributeName = 'Include Kit Staging Location In Pick List';

	/* Get Source Location value from Manufacturing Process based on location. */
	SELECT @strSourceLocationIds = ISNULL(ProcessAttribute.strAttributeValue, '')
	FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
	JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND Attribute.strAttributeName = 'Source Location';

	/* Get Pick By Storage Location from Manufacturing Process based on location. */
	SELECT @strPickByStorageLocation = ISNULL(ProcessAttribute.strAttributeValue, '')
	FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND ProcessAttribute.intAttributeId = 123;

	/* Get Pick By Storage Location from Manufacturing Process based on location. */
	SELECT @ysnReleaseBlendsheetByNoOfMixes = (
			CASE 
				WHEN IsNULL(UPPER(ProcessAttribute.strAttributeValue), 'TRUE') = 'FALSE'
					THEN 0
				ELSE 1
				END
			)
	FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND ProcessAttribute.intAttributeId = 130;

	IF ISNULL(@ysnIncludeKitStagingLocation, 0) = 1
	BEGIN
		SET @intKitStagingLocationId = 0;
	END

	SELECT @intBlendStagingLocationId = ISNULL(intBlendProductionStagingUnitId, 0)
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId;

	SELECT @intIssuedUOMTypeId = ISNULL(intIssuedUOMTypeId, 0)
		,@strBlenderName = strName
		,@intSubLocationId = intSubLocationId
	FROM tblMFMachine
	WHERE intMachineId = @intMachineId;

	IF (ISNULL(@intIssuedUOMTypeId, 0) = 0)
	BEGIN
		SET @intIssuedUOMTypeId = 1;
	END

	SET @intOriginalIssuedUOMTypeId = @intIssuedUOMTypeId;

	/* Create temporary table tblBlendSheetLot. */
	IF (OBJECT_ID('tempdb..#tblBlendSheetLot') IS NOT NULL)
	BEGIN
		DROP TABLE #tblBlendSheetLot;
	END

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
		,intNoOfSheet INT
		,dblNoOfPallets NUMERIC(18, 2)
		,strFW NVARCHAR(3)
		);

	/* Create temporary table tblBlendSheetLotFinal. */
	IF (OBJECT_ID('tempdb..#tblBlendSheetLotFinal') IS NOT NULL)
	BEGIN
		DROP TABLE #tblBlendSheetLotFinal;
	END

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
		,dblNoOfPallets NUMERIC(18, 2)
		,strFW NVARCHAR(3)
		)

	/* Set default value 'Active' for lot status. */
	INSERT INTO @tblLotStatus (strStatusName)
	VALUES ('Active');

	/* Set default value 'Active' for lot status. */
	IF @ysnFromPickList = 0
	BEGIN
		INSERT INTO @tblLotStatus (strStatusName)
		VALUES ('Quarantine');
	END

	/* Condition for Null/Empty Source Locations ID. */
	IF ISNULL(@strSourceLocationIds, '') <> ''
	BEGIN
		INSERT INTO @tblSourceStorageLocation
		SELECT *
		FROM dbo.fnCommaSeparatedValueToTable(@strSourceLocationIds);
	END
	ELSE
	BEGIN
		INSERT INTO @tblSourceStorageLocation
		SELECT intStorageLocationId
		FROM tblICStorageLocation
		WHERE intLocationId = @intLocationId
			AND ISNULL(ysnAllowConsume, 0) = 1;
	END

	DECLARE @tblSourceSubLocation AS TABLE (
		intRecordId INT identity(1, 1)
		,intSubLocationId INT
		);

	IF NOT EXISTS (
			SELECT *
			FROM tblMFManufacturingCellSubLocation
			WHERE intManufacturingCellId = @intManufacturingCellId
			)
	BEGIN
		IF IsNULL(@strPickByStorageLocation, '') = 'True'
		BEGIN
			INSERT INTO @tblSourceSubLocation (intSubLocationId)
			SELECT @intSubLocationId;
		END
		ELSE
		BEGIN
			INSERT INTO @tblSourceSubLocation (intSubLocationId)
			SELECT intCompanyLocationSubLocationId
			FROM tblSMCompanyLocationSubLocation
			WHERE intCompanyLocationId = @intLocationId
		END
	END
	ELSE
	BEGIN
		INSERT INTO @tblSourceSubLocation (intSubLocationId)
		SELECT SL.intCompanyLocationSubLocationId
		FROM dbo.tblMFManufacturingCellSubLocation SL
		WHERE intManufacturingCellId = @intManufacturingCellId
		ORDER BY SL.intManufacturingCellSubLocationId
	END

	DECLARE @tblExcludedLot TABLE (
		intItemId INT
		,intLotId INT
		);
	DECLARE @tblWorkOrder AS TABLE (intWorkOrderId INT);
	DECLARE @tblWOStagingLocation AS TABLE (intStagingLocationId INT);

	/* Get the Comma Separated Work Order Ids into a table. */
	IF ISNULL(@strWorkOrderIds, '') <> ''
	BEGIN
		SET @index = CharIndex(',', @strWorkOrderIds);

		WHILE @index > 0
		BEGIN
			SET @id = SUBSTRING(@strWorkOrderIds, 1, @index - 1);
			SET @strWorkOrderIds = SUBSTRING(@strWorkOrderIds, @index + 1, LEN(@strWorkOrderIds) - @index);

			INSERT INTO @tblWorkOrder
			VALUES (@id);

			SET @index = CharIndex(',', @strWorkOrderIds);
		END

		SET @id = @strWorkOrderIds;

		INSERT INTO @tblWorkOrder
		VALUES (@id);
	END

	/* End of Get the Comma Separated Work Order Ids into a table. */
	/* Get Work Order ID or Set Staging Location. */
	IF (
			SELECT Count(1)
			FROM @tblWorkOrder
			) = 0
	BEGIN
		SELECT TOP 1 @intWorkOrderId = intWorkOrderId
		FROM tblMFWorkOrder
		WHERE intBlendRequirementId = @intBlendRequirementId
			AND ISNULL(intSalesOrderLineItemId, 0) > 0;
	END
	ELSE
	BEGIN
		SELECT TOP 1 @intWorkOrderId = intWorkOrderId
		FROM @tblWorkOrder;

		INSERT INTO @tblWOStagingLocation
		SELECT DISTINCT OrderHeader.intStagingLocationId
		FROM tblMFStageWorkOrder AS StageWorkOrder
		JOIN @tblWorkOrder AS WorkOrder ON StageWorkOrder.intWorkOrderId = WorkOrder.intWorkOrderId
		JOIN tblMFOrderHeader AS OrderHeader ON StageWorkOrder.intOrderHeaderId = OrderHeader.intOrderHeaderId
		WHERE ISNULL(OrderHeader.intStagingLocationId, 0) > 0;

		IF (
				SELECT Count(1)
				FROM @tblWOStagingLocation
				) > 0
		BEGIN
			SET @ysnWOStagePick = 1;
		END
	END

	/* End of Get Work Order ID or Set Staging Location. */
	--Get Recipe Input Items
	--@strXml (if it has value)- Used For Picking Specific Recipe Items with qty full or remaining qty
	--Called From uspMFGetPickListDetails
	IF ISNULL(@strXml, '') = ''
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblMFWorkOrderRecipe
				WHERE intWorkOrderId = @intWorkOrderId
				)
		BEGIN
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
				,dblUpperToleranceQty
				,dblLowerToleranceQty
				,ysnComplianceItem
				,dblCompliancePercent
				)
			SELECT r.intRecipeId
				,ri.intRecipeItemId
				,ri.intItemId
				,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
				,0 AS ysnIsSubstitute
				,(
					CASE 
						WHEN (ri.dblCalculatedQuantity / SUM(ri.dblCalculatedQuantity) OVER ()) * 100 <= 10
							THEN 1
						ELSE 0
						END
					) AS ysnMinorIngredient
				,ri.intConsumptionMethodId
				,ri.intStorageLocationId
				,0
				,0.0
				,0.0
				,i.strLotTracking
				,ri.intItemUOMId
				,(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedUpperTolerance
				,(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedLowerTolerance
				,ri.ysnComplianceItem
				,ri.dblCompliancePercent
			FROM tblMFWorkOrderRecipeItem ri
			JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
			JOIN tblICItem i ON ri.intItemId = i.intItemId
			WHERE r.intWorkOrderId = @intWorkOrderId
				AND ri.intRecipeItemTypeId = 1
				AND ri.intConsumptionMethodId IN (
					1
					,2
					,3
					)
			
			UNION
			
			SELECT r.intRecipeId
				,rs.intRecipeItemId
				,rs.intSubstituteItemId AS intItemId
				,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
				,1 AS ysnIsSubstitute
				,(
					CASE 
						WHEN (ri.dblCalculatedQuantity / SUM(ri.dblCalculatedQuantity) OVER ()) * 100 <= 10
							THEN 1
						ELSE 0
						END
					) AS ysnMinorIngredient
				,ri.intConsumptionMethodId
				,ri.intStorageLocationId
				,ri.intItemId
				,rs.dblSubstituteRatio
				,rs.dblMaxSubstituteRatio
				,i.strLotTracking
				,ri.intItemUOMId
				,(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedUpperTolerance
				,(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedLowerTolerance
				,ri.ysnComplianceItem
				,ri.dblCompliancePercent
			FROM tblMFWorkOrderRecipeSubstituteItem rs
			JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
			JOIN tblMFWorkOrderRecipeItem ri ON rs.intRecipeItemId = ri.intRecipeItemId
				AND ri.intWorkOrderId = r.intWorkOrderId
			JOIN tblICItem i ON rs.intSubstituteItemId = i.intItemId
			WHERE r.intWorkOrderId = @intWorkOrderId
				AND rs.intRecipeItemTypeId = 1
			ORDER BY 4 DESC
				,ysnIsSubstitute
				,ysnMinorIngredient

			SELECT @dblRecipeQty = dblQuantity
			FROM tblMFWorkOrderRecipe
			WHERE intWorkOrderId = @intWorkOrderId
		END
		ELSE
		BEGIN
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
				,dblUpperToleranceQty
				,dblLowerToleranceQty
				,ysnComplianceItem
				,dblCompliancePercent
				)
			SELECT @intRecipeId
				,ri.intRecipeItemId
				,ri.intItemId
				,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
				,0 AS ysnIsSubstitute
				,(
					CASE 
						WHEN (ri.dblCalculatedQuantity / SUM(ri.dblCalculatedQuantity) OVER ()) * 100 <= 10
							THEN 1
						ELSE 0
						END
					) AS ysnMinorIngredient
				,ri.intConsumptionMethodId
				,ri.intStorageLocationId
				,0
				,0.0
				,0.0
				,i.strLotTracking
				,ri.intItemUOMId
				,(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedUpperTolerance
				,(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedLowerTolerance
				,ri.ysnComplianceItem
				,ri.dblCompliancePercent
			FROM tblMFRecipeItem ri
			JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			JOIN tblICItem i ON ri.intItemId = i.intItemId
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
				,rs.intRecipeSubstituteItemId
				,rs.intSubstituteItemId AS intItemId
				,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
				,1 AS ysnIsSubstitute
				,(
					CASE 
						WHEN (ri.dblCalculatedQuantity / SUM(ri.dblCalculatedQuantity) OVER ()) * 100 <= 10
							THEN 1
						ELSE 0
						END
					) AS ysnMinorIngredient
				,1
				,0
				,ri.intItemId
				,rs.dblSubstituteRatio
				,rs.dblMaxSubstituteRatio
				,i.strLotTracking
				,ri.intItemUOMId
				,(ri.dblCalculatedUpperTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedUpperTolerance
				,(ri.dblCalculatedLowerTolerance * (@dblQtyToProduce / r.dblQuantity)) AS dblCalculatedLowerTolerance
				,ri.ysnComplianceItem
				,ri.dblCompliancePercent
			FROM tblMFRecipeSubstituteItem rs
			JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
			JOIN tblMFRecipeItem ri ON rs.intRecipeItemId = ri.intRecipeItemId
			JOIN tblICItem i ON ri.intItemId = i.intItemId
			WHERE r.intRecipeId = @intRecipeId
				AND rs.intRecipeItemTypeId = 1
			ORDER BY 4 DESC
				,ysnIsSubstitute
				,ysnMinorIngredient

			SELECT @dblRecipeQty = dblQuantity
			FROM tblMFRecipe
			WHERE intRecipeId = @intRecipeId
		END

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
	END
	ELSE
	BEGIN
		SET @intNoOfSheets = 1

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strXml

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
		SELECT intRecipeId
			,intRecipeItemId
			,intItemId
			,dblRequiredQty
			,ysnIsSubstitute
			,0
			,intConsumptionMethodId
			,intConsumptionStoragelocationId
			,intParentItemId
			,1
			,100
		FROM OPENXML(@idoc, 'root/item', 2) WITH (
				intRecipeId INT
				,intRecipeItemId INT
				,intItemId INT
				,dblRequiredQty NUMERIC(38, 20)
				,ysnIsSubstitute BIT
				,intConsumptionMethodId INT
				,intConsumptionStoragelocationId INT
				,intParentItemId INT
				)
		ORDER BY ysnIsSubstitute

		IF @idoc <> 0
			EXEC sp_xml_removedocument @idoc

		UPDATE ti
		SET ti.intItemUOMId = ri.intItemUOMId
		FROM @tblInputItem ti
		JOIN tblMFRecipeItem ri ON ti.intRecipeItemId = ri.intRecipeItemId
		WHERE ti.intItemUOMId IS NULL

		UPDATE ti
		SET ti.strLotTracking = i.strLotTracking
		FROM @tblInputItem ti
		JOIN tblICItem i ON ti.intItemId = i.intItemId
		WHERE ISNULL(ti.strLotTracking, '') = ''

		--update substitute ratio
		IF ISNULL(@intWorkOrderId, 0) > 0
			UPDATE ti
			SET ti.dblSubstituteRatio = rs.dblSubstituteRatio
				,ti.dblMaxSubstituteRatio = rs.dblMaxSubstituteRatio
			FROM @tblInputItem ti
			JOIN tblMFWorkOrderRecipeSubstituteItem rs ON ti.intItemId = rs.intSubstituteItemId
				AND ti.intParentItemId = rs.intItemId
			WHERE rs.intWorkOrderId = @intWorkOrderId
				AND ti.ysnIsSubstitute = 1
		ELSE IF ISNULL(@intRecipeId, 0) > 0
			UPDATE ti
			SET ti.dblSubstituteRatio = rs.dblSubstituteRatio
				,ti.dblMaxSubstituteRatio = rs.dblMaxSubstituteRatio
			FROM @tblInputItem ti
			JOIN tblMFRecipeSubstituteItem rs ON ti.intItemId = rs.intSubstituteItemId
				AND ti.intParentItemId = rs.intItemId
			WHERE rs.intRecipeId = @intRecipeId
				AND ti.ysnIsSubstitute = 1
	END

	--Get the Excluded Lots From Pick List/Add Lot
	IF LTRIM(RTRIM(ISNULL(@strExcludedLotXml, ''))) <> ''
	BEGIN
		EXEC sp_xml_preparedocument @idoc1 OUTPUT
			,@strExcludedLotXml

		INSERT INTO @tblExcludedLot (
			intItemId
			,intLotId
			)
		SELECT intItemId
			,intLotId
		FROM OPENXML(@idoc1, 'root/lot', 2) WITH (
				intItemId INT
				,intLotId INT
				)

		IF @idoc1 <> 0
			EXEC sp_xml_removedocument @idoc1
	END

	SELECT @intSequenceNo = MAX(intSequenceNo) + 1
	FROM tblMFBlendRequirementRule
	WHERE intBlendRequirementId = @intBlendRequirementId

	SELECT @strWhere = ''

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
				SET @strOrderBy = 'AvailableInputLot.dtmCreateDate ASC,'
			ELSE IF @strValue = 'LIFO'
				SET @strOrderBy = 'AvailableInputLot.dtmCreateDate DESC,'
			ELSE IF @strValue = 'FEFO'
				SET @strOrderBy = 'AvailableInputLot.dtmExpiryDate ASC,'
			ELSE IF @strValue = 'FENA'
				SET @strOrderBy = 'AvailableInputLot.dtmExpiryDate ASC,AvailableInputLot.dblAvailableQty ASC,AvailableInputLot.strLotNumber ASC,AvailableInputLot.dtmManufacturedDate ASC,'
			ELSE IF @strValue = 'NAFE'
				SET @strOrderBy = 'AvailableInputLot.dblAvailableQty ASC,AvailableInputLot.dtmExpiryDate ASC,AvailableInputLot.strLotNumber ASC,AvailableInputLot.dtmManufacturedDate ASC,'
		END

		IF @strRuleName = 'Is Cost Applicable?'
		BEGIN
			IF @strValue = 'Yes'
				SET @strOrderBy = 'AvailableInputLot.dblUnitCost ASC,'
		END

		IF @strRuleName = 'Warehouse'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And SL.strSubLocationName =''' + @strValue + ''''
		END

		IF @strRuleName = 'Garden'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And IsNULL(GM.strGardenMark,'''') =''' + @strValue + ''''
		END

		IF @strRuleName = 'Volume'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And IsNULL(B.dblTeaVolume,0) =' + @strValue
		END

		IF @strRuleName = 'Age'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And intAge =' + @strValue
		END

		IF @strRuleName = 'Intensity'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And IsNULL(B.dblTeaIntensity,0) =' + @strValue
		END

		IF @strRuleName = 'Mouth Feel'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And IsNULL(B.dblTeaMouthFeel,0) =' + @strValue
		END

		IF @strRuleName = 'Sub Cluster'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And isNull(SC.strDescription,'''') =''' + @strValue + ''''
		END

		IF @strRuleName = 'Appearance'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And IsNULL(B.dblTeaAppearance,0) =' + @strValue
		END

		--IF @strRuleName = 'Tea Group' and @strValue<>''
		--BEGIN
		--	IF len(@strWhere) > 0
		--		SET @strWhere = @strWhere+' And strTeaGroup =''' + @strValue + ''','
		--	ELSE
		--		SET @strWhere = @strWhere+' strTeaGroup =''' + @strValue + ''','
		--END
		IF @strRuleName = 'Origin'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And IsNULL(Origin.strDescription,'''') =''' + @strValue + ''''
		END

		IF @strRuleName = 'Sale Year'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And B.intSalesYear =' + @strValue
		END

		IF @strRuleName = 'Sale No'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And B.intSales =' + @strValue
		END

		IF @strRuleName = 'Taste'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And IsNULL(B.dblTeaTaste,0) =' + @strValue
		END

		IF @strRuleName = 'Hue'
			AND @strValue <> ''
		BEGIN
			SET @strWhere = @strWhere + ' And isNULL(B.dblTeaHue,0) =' + @strValue
		END

		IF @strRuleName = 'Pick By'
			AND @strValue <> ''
		BEGIN
			SELECT @intIssuedUOMTypeId = intIssuedUOMTypeId
			FROM tblMFMachineIssuedUOMType
			WHERE strName = @strValue

			IF @intIssuedUOMTypeId IS NULL
				SELECT @intIssuedUOMTypeId = @intOriginalIssuedUOMTypeId
		END

		SET @strOrderByFinal = @strOrderByFinal + @strOrderBy
		SET @strOrderBy = ''
		SET @intSequenceCount = @intSequenceCount + 1
	END

	IF LEN(@strOrderByFinal) > 0
		SET @strOrderByFinal = LEFT(@strOrderByFinal, LEN(@strOrderByFinal) - 1)

	IF ISNULL(@strOrderByFinal, '') = ''
		SET @strOrderByFinal = 'AvailableInputLot.dtmCreateDate ASC'
	SET @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	UPDATE @tblInputItem
	SET dblPickedQty = dblRequiredQty

	IF @ysnReleaseBlendsheetByNoOfMixes = 0
	BEGIN
		SELECT @intOrgNoOfSheets = NULL

		SELECT @intOrgNoOfSheets = @intNoOfSheets

		SELECT @intNoOfSheets = 1

		SELECT @intEstNoOfSheets = 1
	END

	WHILE @intNoOfSheets > 0
	BEGIN
		SET @strSQL = ''

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
				,@strLotTracking = NULL
				,@intItemUOMId = NULL
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
				,@ysnIsSubstitute = ysnIsSubstitute
				,@strLotTracking = strLotTracking
				,@intItemUOMId = intItemUOMId
				,@dblUpperToleranceQty = (dblUpperToleranceQty / @intEstNoOfSheets)
				,@dblLowerToleranceQty = (dblLowerToleranceQty / @intEstNoOfSheets)
				,@ysnComplianceItem = ysnComplianceItem
				,@dblCompliancePercent = dblCompliancePercent
			FROM @tblInputItem
			WHERE intRowNo = @intMinRowNo

			IF @ysnMinorIngredient = 1
			BEGIN
				IF @ysnPercResetRequired = 0
				BEGIN
					SELECT @sRequiredQty = SUM(dblRequiredQty / @intEstNoOfSheets)
					FROM @tblInputItem
					WHERE ysnMinorIngredient = 0

					SELECT @dblQuantityTaken = Sum(dblQuantity)
					FROM #tblBlendSheetLot BS
					JOIN @tblInputItem I ON I.intItemId = BS.intItemId
					WHERE I.ysnMinorIngredient = 0
						AND BS.intNoOfSheet = @intNoOfSheets

					IF @dblQuantityTaken > @sRequiredQty
					BEGIN
						SELECT @ysnPercResetRequired = 1

						SET @dblPercentageIncrease = (@dblQuantityTaken - @sRequiredQty) / @sRequiredQty * 100
					END
				END

				SET @dblRequiredQty = (@dblRequiredQty + (@dblRequiredQty * ISNULL(@dblPercentageIncrease, 0) / 100))
			END

			SET @dblOriginalRequiredQty = @dblRequiredQty

			IF @intConsumptionMethodId IN (
					2
					,3
					)
				SET @intIssuedUOMTypeId = 1

			IF OBJECT_ID('tempdb..#tblLot') IS NOT NULL
				DROP TABLE #tblLot

			CREATE TABLE #tblLot (
				intRowNo INT IDENTITY
				,intLotId INT
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
				,dtmManufacturedDate DATETIME
				,intAge INT
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
				,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,dtmManufacturedDate DATETIME
				,intAge INT
				)

			IF OBJECT_ID('tempdb..#tblAvailableInputLot') IS NOT NULL
				DROP TABLE #tblAvailableInputLot

			CREATE TABLE #tblAvailableInputLot (
				intParentLotId INT
				,--NVARCHAR(50) COLLATE Latin1_General_CI_AS, --Review
				intItemId INT
				,dblAvailableQty NUMERIC(38, 20)
				,intStorageLocationId INT
				,dblWeightPerQty NUMERIC(38, 20)
				,dtmCreateDate DATETIME
				,dtmExpiryDate DATETIME
				,dblUnitCost NUMERIC(38, 20)
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				,intPreference INT
				,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,dtmManufacturedDate DATETIME
				,intAge INT
				,intSubLocationId INT
				)

			/* Create Temporary tblInputLot. */
			IF OBJECT_ID('tempdb..#tblInputLot') IS NOT NULL
				DROP TABLE #tblInputLot;

			CREATE TABLE #tblInputLot (
				intRecordId INT identity(1, 1)
				,intParentLotId INT
				,intItemId INT
				,dblAvailableQty NUMERIC(38, 20)
				,intStorageLocationId INT
				,dblWeightPerQty NUMERIC(38, 20)
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				,intPreference INT
				,intLayerPerPallet INT
				,intUnitPerLayer INT
				);

			IF OBJECT_ID('tempdb..#tblInputLotHandAdd') IS NOT NULL
				DROP TABLE #tblInputLotHandAdd

			CREATE TABLE #tblInputLotHandAdd (
				intParentLotId INT
				,--NVARCHAR(50) COLLATE Latin1_General_CI_AS, --Review
				intItemId INT
				,dblAvailableQty NUMERIC(38, 20)
				,intStorageLocationId INT
				,dblWeightPerQty NUMERIC(38, 20)
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				,intLayerPerPallet INT
				,intUnitPerLayer INT
				)

			IF OBJECT_ID('tempdb..#tblPartialQtyLot') IS NOT NULL
				DROP TABLE #tblPartialQtyLot

			CREATE TABLE #tblPartialQtyLot (
				intRowNo INT IDENTITY(1, 1)
				,intLotId INT
				,intItemId INT
				,dblAvailableQty NUMERIC(38, 20)
				,intStorageLocationId INT
				,dblWeightPerQty NUMERIC(38, 20)
				,intItemUOMId INT
				,intItemIssuedUOMId INT
				)

			--Non Lot Tracked
			IF @strLotTracking = 'No'
			BEGIN
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
				SELECT sd.intItemStockUOMId
					,''
					,sd.intItemId
					,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId, @intItemUOMId, sd.dblAvailableQty)
					,sd.intLocationId
					,sd.intSubLocationId
					,sd.intStorageLocationId
					,NULL
					,NULL
					,0
					,sd.dblUnitQty
					,''
					,0
					,@intItemUOMId AS intItemUOMId
					,@intItemUOMId AS intItemUOMId
				FROM vyuMFGetItemStockDetail sd
				WHERE sd.intItemId = @intRawItemId
					AND sd.dblAvailableQty > @dblDefaultResidueQty
					AND sd.intLocationId = @intLocationId
					AND ISNULL(sd.intStorageLocationId, - 1) NOT IN (
						ISNULL(@intKitStagingLocationId, 0)
						,ISNULL(@intBlendStagingLocationId, 0)
						)
					AND ISNULL(sd.ysnStockUnit, 0) = 1
				ORDER BY sd.intItemStockUOMId

				DECLARE @intMinItem INT

				SELECT @intMinItem = MIN(intRowNo)
				FROM #tblLot

				WHILE @intMinItem IS NOT NULL
				BEGIN
					SELECT @dblAvailableQty = dblQty
					FROM #tblLot
					WHERE intRowNo = @intMinItem

					IF @dblAvailableQty >= @dblRequiredQty
					BEGIN
						INSERT INTO @tblPickedItem (
							intItemStockUOMId
							,intItemId
							,dblQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId
							)
						SELECT intLotId
							,@intRawItemId
							,@dblRequiredQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId
						FROM #tblLot
						WHERE intRowNo = @intMinItem

						GOTO NEXT_ITEM
					END
					ELSE
					BEGIN
						INSERT INTO @tblPickedItem (
							intItemStockUOMId
							,intItemId
							,dblQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId
							)
						SELECT intLotId
							,@intRawItemId
							,@dblAvailableQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId
						FROM #tblLot
						WHERE intRowNo = @intMinItem

						SET @dblRequiredQty = @dblRequiredQty - @dblAvailableQty
					END

					SELECT @intMinItem = MIN(intRowNo)
					FROM #tblLot
					WHERE intRowNo > @intMinItem
				END

				IF ISNULL(@dblRequiredQty, 0) > 0
					AND NOT EXISTS (
						SELECT *
						FROM @tblPickedItem
						WHERE intItemId = @intRawItemId
						)
					INSERT INTO @tblPickedItem (
						intItemStockUOMId
						,intItemId
						,dblQty
						,intItemUOMId
						,intLocationId
						,intSubLocationId
						,intStorageLocationId
						)
					SELECT - 1
						,@intRawItemId
						,0
						,@intItemUOMId
						,@intLocationId
						,NULL
						,NULL

				GOTO NEXT_ITEM
			END

			IF EXISTS (
					SELECT *
					FROM tblMFManufacturingCellSubLocation
					WHERE intManufacturingCellId = @intManufacturingCellId
					)
			BEGIN
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
					,dtmManufacturedDate
					,intAge
					)
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,CASE 
						WHEN isnull(L.dblWeight, 0) > 0
							THEN L.dblWeight
						ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty)
						END - IsNULL(LI.dblReservedQtyInTBS, 0)
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.dtmDateCreated
					,L.dtmExpiryDate
					,L.dblLastCost
					,L.dblWeightPerQty
					,US.strUserName
					,L.intParentLotId
					,ISNULL(L.intWeightUOMId, L.intItemUOMId)
					,L.intItemUOMId
					--,(
					--	CASE 
					--		WHEN SubLoc.intSubLocationId IS NOT NULL
					--			THEN 1
					--		ELSE 2
					--		END
					--	) AS intPreference
					,(
						CASE 
							WHEN SubLoc.intRecordId IS NOT NULL
								THEN SubLoc.intRecordId
							ELSE 99
							END
						) AS intPreference
					,isNULL(L.dtmManufacturedDate, L.dtmDateCreated)
					,DateDiff(d, isNULL(L.dtmManufacturedDate, L.dtmDateCreated), GETDATE())
				FROM tblICLot L
				LEFT JOIN tblSMUserSecurity US ON L.intCreatedEntityId = US.[intEntityId]
				JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
				JOIN tblICStorageLocation SL ON L.intStorageLocationId = SL.intStorageLocationId
				JOIN @tblSourceStorageLocation tsl ON tsl.intStorageLocationId = SL.intStorageLocationId
				JOIN @tblSourceSubLocation SubLoc ON SubLoc.intSubLocationId = L.intSubLocationId
				JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
				WHERE L.intItemId = @intRawItemId
					AND L.intLocationId = @intLocationId
					AND LS.strPrimaryStatus IN (
						SELECT strStatusName
						FROM @tblLotStatus
						)
					AND (
						L.dtmExpiryDate IS NULL
						OR L.dtmExpiryDate >= GETDATE()
						)
					AND L.dblQty > @dblDefaultResidueQty
					AND (
						CASE 
							WHEN isnull(L.dblWeight, 0) > 0
								THEN L.dblWeight
							ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty)
							END - IsNULL(LI.dblReservedQtyInTBS, 0)
						) > 0
					AND L.intStorageLocationId NOT IN (
						@intKitStagingLocationId
						,@intBlendStagingLocationId
						--,@intPartialQuantitySubLocationId
						) --Exclude Kit Staging,Blend Staging,Partial Qty Storage Locations
					AND ISNULL(SL.ysnAllowConsume, 0) = 1
					AND L.intLotId NOT IN (
						SELECT intLotId
						FROM @tblExcludedLot
						WHERE intItemId = @intRawItemId
						)
			END
			ELSE
			BEGIN
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
					,dtmManufacturedDate
					,intAge
					)
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,CASE 
						WHEN isnull(L.dblWeight, 0) > 0
							THEN L.dblWeight
						ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty)
						END - IsNULL(LI.dblReservedQtyInTBS, 0)
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.dtmDateCreated
					,L.dtmExpiryDate
					,L.dblLastCost
					,L.dblWeightPerQty
					,US.strUserName
					,L.intParentLotId
					,ISNULL(L.intWeightUOMId, L.intItemUOMId)
					,L.intItemUOMId
					--,(
					--	CASE 
					--		WHEN SubLoc.intSubLocationId IS NOT NULL
					--			THEN 1
					--		ELSE 2
					--		END
					--	) AS intPreference
					,(
						CASE 
							WHEN SubLoc.intRecordId IS NOT NULL
								THEN SubLoc.intRecordId
							ELSE 99
							END
						) AS intPreference
					,isNULL(L.dtmManufacturedDate, L.dtmDateCreated)
					,DateDiff(d, isNULL(L.dtmManufacturedDate, L.dtmDateCreated), GETDATE())
				FROM tblICLot L
				LEFT JOIN tblSMUserSecurity US ON L.intCreatedEntityId = US.[intEntityId]
				JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
				JOIN tblICStorageLocation SL ON L.intStorageLocationId = SL.intStorageLocationId
				JOIN @tblSourceStorageLocation tsl ON tsl.intStorageLocationId = SL.intStorageLocationId
				LEFT JOIN @tblSourceSubLocation SubLoc ON SubLoc.intSubLocationId = L.intSubLocationId
				JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
				WHERE L.intItemId = @intRawItemId
					AND L.intLocationId = @intLocationId
					AND LS.strPrimaryStatus IN (
						SELECT strStatusName
						FROM @tblLotStatus
						)
					AND (
						L.dtmExpiryDate IS NULL
						OR L.dtmExpiryDate >= GETDATE()
						)
					AND L.dblQty > @dblDefaultResidueQty
					AND (
						CASE 
							WHEN isnull(L.dblWeight, 0) > 0
								THEN L.dblWeight
							ELSE dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty)
							END - IsNULL(LI.dblReservedQtyInTBS, 0)
						) > 0
					AND L.intStorageLocationId NOT IN (
						@intKitStagingLocationId
						,@intBlendStagingLocationId
						--,@intPartialQuantitySubLocationId
						) --Exclude Kit Staging,Blend Staging,Partial Qty Storage Locations
					AND ISNULL(SL.ysnAllowConsume, 0) = 1
					AND L.intLotId NOT IN (
						SELECT intLotId
						FROM @tblExcludedLot
						WHERE intItemId = @intRawItemId
						)
			END

			--Get Either Parent Lot OR Child Lot Based on Setting
			IF @ysnEnableParentLot = 0
			BEGIN
				--Pick Only Lots From Storage Location if recipe is by location
				IF @intConsumptionMethodId = 2
					DELETE
					FROM #tblLot
					WHERE ISNULL(intStorageLocationId, 0) <> ISNULL(@intConsumptionStoragelocationId, 0)

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
					,dtmManufacturedDate
					,intAge
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
					,TL.dtmManufacturedDate
					,TL.intAge
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
					,intPreference
					)
				SELECT PL.intParentLotId
					,PL.intItemId
					,(
						PL.dblQty - (
							(
								SELECT ISNULL(SUM(SR.dblQty), 0)
								FROM tblICStockReservation SR
								WHERE SR.intParentLotId = PL.intParentLotId --Review when Parent Lot Reservation Done
									AND SR.intStorageLocationId = PL.intStorageLocationId
									AND ISNULL(SR.ysnPosted, 0) = 0
									AND SR.intItemId = PL.intItemId
								) + (
								SELECT ISNULL(SUM(BS.dblQuantity), 0)
								FROM #tblBlendSheetLot BS
								WHERE BS.intParentLotId = PL.intParentLotId
									AND BS.intItemId = PL.intItemId
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
					,PL.intPreference
				FROM #tblParentLot AS PL
				WHERE PL.intItemId = @intRawItemId
			END

			IF @ysnEnableParentLot = 1
				AND @ysnShowAvailableLotsByStorageLocation = 0
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
								WHERE SR.intParentLotId = PL.intParentLotId
									AND ISNULL(SR.ysnPosted, 0) = 0
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
					,strLotNumber
					,dtmManufacturedDate
					,intAge
					,intSubLocationId
					)
				SELECT PL.intParentLotId
					,PL.intItemId
					,(
						PL.dblQty - (
							(
								SELECT ISNULL(SUM(SR.dblQty), 0)
								FROM tblICStockReservation SR
								WHERE SR.intLotId = PL.intParentLotId
									AND ISNULL(SR.ysnPosted, 0) = 0
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
					,PL.strLotNumber
					,PL.dtmManufacturedDate
					,PL.intAge
					,PL.intSubLocationId
				FROM #tblParentLot AS PL
				WHERE PL.intItemId = @intRawItemId
			END

			--Apply Business Rules
			IF ISNULL(@ysnWOStagePick, 0) = 0
			BEGIN
				SET @strSQL = 
					'INSERT INTO #tblInputLot(intParentLotId
														  , intItemId
														  , dblAvailableQty
														  , intStorageLocationId
														  , dblWeightPerQty
														  , intItemUOMId
														  , intItemIssuedUOMId
														  , intPreference
														  , intLayerPerPallet
														  , intUnitPerLayer) 
								   SELECT AvailableInputLot.intParentLotId
										, AvailableInputLot.intItemId
										, AvailableInputLot.dblAvailableQty
										, AvailableInputLot.intStorageLocationId
										, AvailableInputLot.dblWeightPerQty
										, AvailableInputLot.intItemUOMId
										, AvailableInputLot.intItemIssuedUOMId
										, ISNULL(intPreference, 1)  
										, Item.intLayerPerPallet
										, Item.intUnitPerLayer
								   FROM #tblAvailableInputLot AS AvailableInputLot
								   JOIN tblICItem AS Item ON AvailableInputLot.intItemId = Item.intItemId
								   LEFT JOIN vyuMFBatchDetail B on B.intBatchId=AvailableInputLot.intParentLotId
								   LEFT JOIN tblSMCompanyLocationSubLocation SL on SL.intCompanyLocationSubLocationId=AvailableInputLot.intSubLocationId
								   LEFT JOIN tblQMGardenMark GM on GM.intGardenMarkId=B.intGardenMarkId
								   LEFT JOIN tblICCommodityAttribute SC on SC.intCommodityAttributeId=Item.intRegionId
								   LEFT JOIN tblICCommodityAttribute Origin on Origin.intCommodityAttributeId=Item.intOriginId
								   WHERE AvailableInputLot.dblAvailableQty > ' 
					+ CONVERT(VARCHAR(50), @dblDefaultResidueQty) + @strWhere + ' ORDER BY ISNULL(intPreference, 1), ' + @strOrderByFinal + (
						CASE 
							WHEN @ysnQuality = 1
								THEN ' ,dblTeaTasteOrderBy,dblTeaHueOrderBy,dblTeaIntensityOrderBy,dblTeaMouthFeelOrderBy,dblTeaAppearanceOrderBy '
							ELSE ''
							END
						)

				EXEC (@strSQL)
			END
			ELSE
			BEGIN
				INSERT INTO #tblInputLot (
					intParentLotId
					,intItemId
					,dblAvailableQty
					,intStorageLocationId
					,dblWeightPerQty
					,intItemUOMId
					,intItemIssuedUOMId
					,intLayerPerPallet
					,intUnitPerLayer
					)
				SELECT AvailableInputLot.intParentLotId
					,AvailableInputLot.intItemId
					,AvailableInputLot.dblAvailableQty
					,AvailableInputLot.intStorageLocationId
					,AvailableInputLot.dblWeightPerQty
					,AvailableInputLot.intItemUOMId
					,AvailableInputLot.intItemIssuedUOMId
					,Item.intLayerPerPallet
					,Item.intUnitPerLayer
				FROM #tblAvailableInputLot AS AvailableInputLot
				JOIN tblICItem AS Item ON AvailableInputLot.intItemId = Item.intItemId
				WHERE AvailableInputLot.dblAvailableQty > @dblDefaultResidueQty
					AND AvailableInputLot.intStorageLocationId IN (
						SELECT intStagingLocationId
						FROM @tblWOStagingLocation
						)
				ORDER BY AvailableInputLot.dtmCreateDate;

				INSERT INTO #tblInputLot (
					intParentLotId
					,intItemId
					,dblAvailableQty
					,intStorageLocationId
					,dblWeightPerQty
					,intItemUOMId
					,intItemIssuedUOMId
					,intLayerPerPallet
					,intUnitPerLayer
					)
				SELECT AvailableInputLot.intParentLotId
					,AvailableInputLot.intItemId
					,AvailableInputLot.dblAvailableQty
					,AvailableInputLot.intStorageLocationId
					,AvailableInputLot.dblWeightPerQty
					,AvailableInputLot.intItemUOMId
					,AvailableInputLot.intItemIssuedUOMId
					,Item.intLayerPerPallet
					,Item.intUnitPerLayer
				FROM #tblAvailableInputLot AS AvailableInputLot
				JOIN tblICItem AS Item ON AvailableInputLot.intItemId = Item.intItemId
				WHERE AvailableInputLot.dblAvailableQty > @dblDefaultResidueQty
					AND AvailableInputLot.intStorageLocationId NOT IN (
						SELECT intStagingLocationId
						FROM @tblWOStagingLocation
						)
				ORDER BY AvailableInputLot.dtmCreateDate;
			END

			--For Bulk Items Do not consider lot
			IF @intConsumptionMethodId IN (
					2
					,3
					) --By Location/FIFO
			BEGIN
				SET @dblBulkItemAvailableQty = (
						SELECT ISNULL(SUM(ISNULL(dblWeight, 0)), 0)
						FROM tblICLot L
						JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
						JOIN tblICStorageLocation SL ON L.intStorageLocationId = SL.intStorageLocationId
						WHERE L.intItemId = @intRawItemId
							AND L.intLocationId = @intLocationId
							AND LS.strPrimaryStatus IN (
								SELECT strStatusName
								FROM @tblLotStatus
								)
							AND (
								L.dtmExpiryDate IS NULL
								OR L.dtmExpiryDate >= GETDATE()
								)
							AND L.dblWeight > @dblDefaultResidueQty
							AND L.intStorageLocationId NOT IN (
								@intKitStagingLocationId
								,@intBlendStagingLocationId
								) --Exclude Kit Staging,Blend Staging
							AND ISNULL(SL.ysnAllowConsume, 0) = 1
							AND L.intLotId NOT IN (
								SELECT intLotId
								FROM @tblExcludedLot
								WHERE intItemId = @intRawItemId
								)
						) - (
						SELECT ISNULL(SUM(ISNULL(dblQty, 0)), 0)
						FROM tblICStockReservation
						WHERE intItemId = @intRawItemId
							AND intLocationId = @intLocationId
							AND ISNULL(ysnPosted, 0) = 0
							AND intStorageLocationId NOT IN (
								@intKitStagingLocationId
								,@intBlendStagingLocationId
								) --Exclude Kit Staging,Blend Staging				
						) - (
						SELECT ISNULL(SUM(BS.dblQuantity), 0)
						FROM #tblBlendSheetLot BS
						WHERE BS.intItemId = @intRawItemId
						)

				DELETE
				FROM #tblInputLot

				IF @dblBulkItemAvailableQty > 0
					INSERT INTO #tblInputLot (
						intParentLotId
						,intItemId
						,dblAvailableQty
						,intStorageLocationId
						,dblWeightPerQty
						,intItemUOMId
						,intItemIssuedUOMId
						,intLayerPerPallet
						,intUnitPerLayer
						)
					SELECT TOP 1 intLotId
						,Lot.intItemId
						,@dblBulkItemAvailableQty
						,intStorageLocationId
						,1
						,Lot.intWeightUOMId
						,Lot.intWeightUOMId
						,Item.intLayerPerPallet
						,Item.intUnitPerLayer
					FROM tblICLot AS Lot
					JOIN tblICItem AS Item ON Lot.intItemId = Item.intItemId
					WHERE Lot.intItemId = @intRawItemId
						AND Lot.dblWeight > @dblDefaultResidueQty
						AND ISNULL(intStorageLocationId, 0) > 0
						AND intLocationId = @intLocationId
			END

			--Full Bag Pick
			IF ISNULL(@intPartialQuantitySubLocationId, 0) > 0
				AND @intOriginalIssuedUOMTypeId = @intIssuedUOMTypeId
				DELETE
				FROM #tblInputLot
				WHERE intStorageLocationId IN (
						SELECT intStorageLocationId
						FROM tblICStorageLocation
						WHERE intSubLocationId = ISNULL(@intPartialQuantitySubLocationId, 0)
						)

			--Hand Add Pick
			--Pick From Hand Add, remaining pick from Full Bag 
			--#tblInputLotHandAdd table used for ordering of hand add and full bag add location lots
			IF (
					ISNULL(@intPartialQuantitySubLocationId, 0) > 0
					AND @intOriginalIssuedUOMTypeId <> @intIssuedUOMTypeId
					)
			BEGIN
				DELETE
				FROM #tblInputLotHandAdd;

				INSERT INTO #tblInputLotHandAdd
				SELECT *
				FROM #tblInputLot;

				DELETE
				FROM #tblInputLot;

				INSERT INTO #tblInputLot
				SELECT *
				FROM #tblInputLotHandAdd
				WHERE intStorageLocationId IN (
						SELECT intStorageLocationId
						FROM tblICStorageLocation
						WHERE intSubLocationId = ISNULL(@intPartialQuantitySubLocationId, 0)
						);

				INSERT INTO #tblInputLot
				SELECT *
				FROM #tblInputLotHandAdd
				WHERE intStorageLocationId NOT IN (
						SELECT intStorageLocationId
						FROM tblICStorageLocation
						WHERE intSubLocationId = ISNULL(@intPartialQuantitySubLocationId, 0)
						);
			END

			/* If there's no Lot found for item then go to substitute. */
			IF (
					SELECT COUNT(1)
					FROM #tblInputLot
					) = 0
			BEGIN
				GOTO NOLOT;
			END

			UPDATE @tblInputItem
			SET dblPickedQty = 0
			WHERE intItemId = @intRawItemId

			DECLARE Cursor_FetchItem CURSOR LOCAL FAST_FORWARD
			FOR
			SELECT intParentLotId
				,intItemId
				,dblAvailableQty
				,intStorageLocationId
				,dblWeightPerQty
				,intLayerPerPallet
				,intUnitPerLayer
			FROM #tblInputLot
			ORDER BY intRecordId

			OPEN Cursor_FetchItem

			FETCH NEXT
			FROM Cursor_FetchItem
			INTO @intParentLotId
				,@intRawItemId
				,@dblAvailableQty
				,@intStorageLocationId
				,@dblWeightPerQty
				,@intLayerPerPallet
				,@intUnitPerLayer

			WHILE (@@FETCH_STATUS <> - 1)
			BEGIN
				IF @intIssuedUOMTypeId = 2
				BEGIN
					IF @dblRequiredQty < @dblWeightPerQty
						AND ISNULL(@intPartialQuantitySubLocationId, 0) > 0
					BEGIN
						GOTO LOOP_END;
					END
					ELSE IF @dblRequiredQty < @dblWeightPerQty
						AND ISNULL(@intPartialQuantitySubLocationId, 0) = 0
					BEGIN
						SELECT @dblRequiredQty = @dblWeightPerQty;
					END
				END

				/* Packed Issued UOM Type*/
				IF @intIssuedUOMTypeId = 2
				BEGIN
					IF (@dblWeightPerQty - (@dblAvailableQty % @dblWeightPerQty) < 0.01)
					BEGIN
						SET @dblAvailableQty = @dblAvailableQty;
					END
					ELSE
					BEGIN
						SET @dblAvailableQty = @dblAvailableQty - (@dblAvailableQty % @dblWeightPerQty);
					END
				END

				/* End of Packed Issued UOM Type*/
				/* Hybrid Issued UOM Type (Weight and Pack). */
				IF @intIssuedUOMTypeId = 3
					AND @ysnMinorIngredient = 0
				BEGIN
					SET @dblAvailableQty = @dblAvailableQty - (@dblAvailableQty % @dblWeightPerQty);
				END

				IF @intIssuedUOMTypeId = 4
					--AND @ysnMinorIngredient = 0
				BEGIN
					SET @dblAvailableQty = @dblAvailableQty - (@dblAvailableQty % (@dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet));

					IF @dblAvailableQty = 0
					BEGIN
						GOTO NextLot
					END
				END

				SELECT @dblNoOfPallets = @intUnitPerLayer * @intLayerPerPallet

				--/* Pallet Issued UOM Type */
				--IF @intIssuedUOMTypeId = 4
				--	SET @dblPalletQty = 0;
				--BEGIN
				--	DECLARE @dblPallet NUMERIC(18, 2) = 0
				--		,@dblRequiredPallet NUMERIC(18, 2) = 0
				--		,@dblLotPallet NUMERIC(18, 2) = 0
				--		,@dblPickedAvailableQty NUMERIC(18, 2) = 0;
				--	SET @dblPallet = 0;
				--	SET @dblNoOfPallets = 0;
				--	/* Set Calculated Pallet. */
				--	SET @dblPallet = @intUnitPerLayer * @intLayerPerPallet;
				--	BEGIN
				--		IF (
				--				@dblAvailableQty >= @dblRequiredQty
				--				AND (
				--					@intUnitPerLayer <> 0
				--					OR @intLayerPerPallet <> 0
				--					)
				--				)
				--		BEGIN
				--			/* Set Available Lot pallet. */
				--			SET @dblLotPallet = @dblAvailableQty / @dblPallet;
				--			SET @dblPalletQty = (@dblLotPallet / 100) * @dblRequiredPallet;
				--			IF @ysnMinorIngredient = 0
				--			BEGIN
				--				SET @dblPalletQty = @dblRequiredQty;
				--				/* Set No of Pallets on Picked Qty*/
				--				SET @dblNoOfPallets = (@dblRequiredQty / @dblLotPallet) * 100;
				--			END
				--			ELSE
				--			BEGIN
				--				/* Set Required pallet. */
				--				SET @dblRequiredPallet = (
				--						CASE 
				--							WHEN @dblAvailableQty >= @dblUpperToleranceQty
				--								THEN @dblUpperToleranceQty
				--							ELSE @dblRequiredQty
				--							END
				--						) / @dblPallet;
				--				IF (ROUND(@dblRequiredPallet, 0) <> @dblRequiredPallet)
				--				BEGIN
				--					SET @dblRequiredPallet = CEILING(@dblRequiredPallet);
				--				END
				--				/* Set picked avalable qty */
				--				SET @dblPickedAvailableQty = (@dblAvailableQty / @dblLotPallet) * @dblRequiredPallet;
				--				/* check wheter the picked available qty is within the tolerance. */
				--				IF (
				--						@dblPickedAvailableQty >= @dblLowerToleranceQty
				--						AND @dblPickedAvailableQty <= @dblUpperToleranceQty
				--						)
				--				BEGIN
				--					SET @dblPalletQty = @dblPickedAvailableQty;
				--					SET @dblNoOfPallets = (@dblPickedAvailableQty / @dblLotPallet) * 100;
				--				END
				--				ELSE
				--				BEGIN
				--					IF (@dblAvailableQty >= @dblUpperToleranceQty)
				--					BEGIN
				--						SET @dblPalletQty = @dblUpperToleranceQty;
				--						SET @dblNoOfPallets = (@dblUpperToleranceQty / @dblLotPallet) * 100;
				--					END
				--					ELSE
				--					BEGIN
				--						SET @dblPalletQty = @dblRequiredQty;
				--						SET @dblNoOfPallets = (@dblRequiredQty / @dblLotPallet) * 100;
				--					END
				--				END
				--			END
				--		END
				--		ELSE
				--		BEGIN
				--			SET @dblPalletQty = @dblRequiredQty
				--		END
				--	END
				--END
				--/* End of Pallet Issued UOM Type */
				IF @dblAvailableQty > 0
				BEGIN
					IF (@dblAvailableQty >= @dblRequiredQty)
					BEGIN
						IF @ysnEnableParentLot = 0
							SELECT @intParentLotId = L.intLotId
								,@intItemId = L.intItemId
								,@dblQuantity = (
									CASE 
										WHEN @intIssuedUOMTypeId = 2
											THEN Convert(NUMERIC(38, 20), (
														(
															CASE 
																WHEN Round(@dblRequiredQty / L.dblWeightPerQty, 0) = 0
																	THEN 1
																ELSE Round(@dblRequiredQty / L.dblWeightPerQty, 0)
																END
															) * L.dblWeightPerQty
														))
										ELSE @dblRequiredQty --To Review ROUND(@dblRequiredQty,3) 
										END
									)
								,@intItemUOMId = ISNULL(L.intWeightUOMId, @intItemUOMId)
								,@dblIssuedQuantity = CASE 
									WHEN @intIssuedUOMTypeId = 1
										THEN CONVERT(NUMERIC(38, 20), (
													CASE 
														WHEN (@dblRequiredQty / L.dblWeightPerQty) = 0
															THEN 1
														ELSE CONVERT(NUMERIC(38, 20), (@dblRequiredQty / L.dblWeightPerQty))
														END
													))
									WHEN @intIssuedUOMTypeId = 2
										THEN CONVERT(NUMERIC(38, 20), (
													CASE 
														WHEN ROUND(@dblRequiredQty / L.dblWeightPerQty, 0) = 0
															THEN 1
														ELSE CONVERT(NUMERIC(38, 20), Round(@dblRequiredQty / L.dblWeightPerQty, 0))
														END
													))
									ELSE @dblRequiredQty --To Review ROUND(@dblRequiredQty,3) 
									END
								,@intItemIssuedUOMId = L.intItemUOMId
								,@intRecipeItemId = @intRecipeItemId
								,@intStorageLocationId = @intStorageLocationId
								,@dblWeightPerQty = L.dblWeightPerQty
								,@dblUnitCost = L.dblLastCost
								,@dblNoOfPallets = @dblNoOfPallets
							FROM tblICLot L
							JOIN tblICItem AS Item ON L.intItemId = Item.intItemId
							WHERE L.intLotId = @intParentLotId
								AND L.dblQty > @dblDefaultResidueQty
						ELSE
							SELECT TOP 1 @intParentLotId = L.intParentLotId
								,@intItemId = L.intItemId
								,@dblQuantity = @dblRequiredQty -- To Review ROUND(@dblRequiredQty,3) 
								,@intItemUOMId = L.intItemUOMId
								,@dblIssuedQuantity = CASE 
									WHEN @intIssuedUOMTypeId = 4
										THEN @dblPalletQty
									ELSE @dblRequiredQty
									END --To Review ROUND(@dblRequiredQty,3) 
								,@intItemIssuedUOMId = (
									CASE 
										WHEN @intIssuedUOMTypeId IN (
												2
												,3
												)
											THEN L.intItemIssuedUOMId
										ELSE L.intItemUOMId
										END
									)
								,@intStorageLocationId = (
									CASE 
										WHEN @ysnShowAvailableLotsByStorageLocation = 1
											THEN @intStorageLocationId
										ELSE 0
										END
									)
								,@dblWeightPerQty = (
									CASE 
										WHEN L.dblWeightPerQty = 0
											THEN 1
										ELSE L.dblWeightPerQty
										END
									)
								,@dblUnitCost = L.dblUnitCost
								,@dblNoOfPallets = @dblNoOfPallets
							FROM #tblParentLot L
							WHERE L.intParentLotId = @intParentLotId

						IF @intIssuedUOMTypeId = 2
						BEGIN
							SELECT @dblPickedQty = NULL

							SELECT @dblPickedQty = dblPickedQty
							FROM @tblInputItem
							WHERE intItemId = @intRawItemId

							SELECT @dblSuggestedCeilingQty = 0

							SELECT @dblSuggestedCeilingQty = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)) * @dblWeightPerQty)

							SELECT @dblSuggestedFloorQty = 0

							SELECT @dblSuggestedFloorQty = Convert(NUMERIC(38, 20), Floor(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)) * @dblWeightPerQty)

							SELECT @dblCeilingQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedCeilingQty)

							SELECT @dblFloorQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedFloorQty)

							IF abs(@dblFloorQtyDiff) > abs(@dblCeilingQtyDiff)
								AND @dblSuggestedCeilingQty + @dblPickedQty BETWEEN @dblLowerToleranceQty
									AND @dblUpperToleranceQty
								AND (
									@dblAvailableQty >= @dblSuggestedCeilingQty
									OR @dblSuggestedCeilingQty - @dblAvailableQty < 0.01
									)
							BEGIN
								SELECT @dblQuantity = @dblSuggestedCeilingQty
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)))
							END
							ELSE
							BEGIN
								SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty), 0) * @dblWeightPerQty)
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty), 0))
							END

							UPDATE @tblInputItem
							SET dblPickedQty = dblPickedQty + @dblQuantity
							WHERE intItemId = @intRawItemId
						END

						IF @intIssuedUOMTypeId = 3
						BEGIN
							IF @ysnMinorIngredient = 0
							BEGIN
								SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty), 0) * @dblWeightPerQty)
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty), 0))
							END
							ELSE
							BEGIN
								SELECT @dblQuantity = @dblRequiredQty
									,@dblIssuedQuantity = @dblRequiredQty
									,@intItemIssuedUOMId = @intItemUOMId
							END

							IF @dblQuantity = 0
							BEGIN
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
										--@dblPickedQty BETWEEN @dblLowerToleranceQty
										--	AND @dblUpperToleranceQty
										@dblPickedQty <= @dblUpperToleranceQty
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

									SELECT @intSeq = NULL

									SELECT @intSeq = intSeq
									FROM @tblInputItemSeq
									WHERE intItemId = @intRawItemId

									IF @intMinRowNo = @intSeq
									BEGIN
										SELECT @dblTotalPickedQty = NULL

										SELECT @dblTotalPickedQty = Sum(dblPickedQty)
										FROM @tblInputItem

										IF @ysnComplianceItem = 1
											AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
										BEGIN
											UPDATE @tblInputItem
											SET dblPickedQty = dblPickedQty - @dblQuantity
											WHERE intItemId = @intRawItemId

											IF @ysnMinorIngredient = 1
											BEGIN
												SELECT @dblQuantity = @dblRequiredQty
													,@dblIssuedQuantity = @dblRequiredQty
													,@intItemIssuedUOMId = @intItemUOMId
											END
											ELSE
											BEGIN
												SELECT @dblQuantity = @dblRequiredQty
													,@dblIssuedQuantity = dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)
											END

											UPDATE @tblInputItem
											SET dblPickedQty = dblPickedQty + @dblQuantity
											WHERE intItemId = @intRawItemId
										END
									END
									ELSE
									BEGIN
										UPDATE @tblInputItem
										SET dblPickedQty = dblPickedQty - @dblQuantity
										WHERE intItemId = @intRawItemId

										IF @ysnMinorIngredient = 1
										BEGIN
											SELECT @dblQuantity = @dblRequiredQty
												,@dblIssuedQuantity = @dblRequiredQty
												,@intItemIssuedUOMId = @intItemUOMId
										END
										ELSE
										BEGIN
											SELECT @dblQuantity = @dblRequiredQty
												,@dblIssuedQuantity = dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)
										END

										UPDATE @tblInputItem
										SET dblPickedQty = dblPickedQty + @dblQuantity
										WHERE intItemId = @intRawItemId
									END
								END
								ELSE
								BEGIN
									UPDATE @tblInputItem
									SET dblPickedQty = dblPickedQty - @dblQuantity
									WHERE intItemId = @intRawItemId

									IF @ysnMinorIngredient = 1
									BEGIN
										SELECT @dblQuantity = @dblRequiredQty
											,@dblIssuedQuantity = @dblRequiredQty
											,@intItemIssuedUOMId = @intItemUOMId
									END
									ELSE
									BEGIN
										SELECT @dblQuantity = @dblRequiredQty
											,@dblIssuedQuantity = dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)
									END

									UPDATE @tblInputItem
									SET dblPickedQty = dblPickedQty + @dblQuantity
									WHERE intItemId = @intRawItemId
								END
							END
						END

						--IF @intIssuedUOMTypeId = 4
						--BEGIN
						--	IF @ysnMinorIngredient = 0
						--	BEGIN
						--		SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet), 0) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)
						--			,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet), 0)) * @intUnitPerLayer * @intLayerPerPallet
						--	END
						--	ELSE
						--	BEGIN
						--		SELECT @dblQuantity = @dblRequiredQty
						--			,@dblIssuedQuantity = @dblRequiredQty
						--			,@intItemIssuedUOMId = @intItemUOMId
						--	END
						--	IF @dblQuantity = 0
						--	BEGIN
						--		SELECT @dblQuantity = @dblRequiredQty
						--			,@dblIssuedQuantity = @dblRequiredQty
						--			,@intItemIssuedUOMId = @intItemUOMId
						--		UPDATE @tblInputItem
						--		SET dblPickedQty = dblPickedQty + @dblQuantity
						--		WHERE intItemId = @intRawItemId
						--	END
						--	ELSE
						--	BEGIN
						--		UPDATE @tblInputItem
						--		SET dblPickedQty = dblPickedQty + @dblQuantity
						--		WHERE intItemId = @intRawItemId
						--		SELECT @dblPickedQty = NULL
						--		SELECT @dblPickedQty = dblPickedQty
						--		FROM @tblInputItem
						--		WHERE intItemId = @intRawItemId
						--		IF @dblPickedQty <= @dblUpperToleranceQty
						--			AND @dblLowerToleranceQty > 0
						--			AND @dblUpperToleranceQty > 0
						--		BEGIN
						--			DELETE
						--			FROM @tblInputItemSeq
						--			INSERT INTO @tblInputItemSeq (
						--				intItemId
						--				,intSeq
						--				)
						--			SELECT intItemId
						--				,row_number() OVER (
						--					ORDER BY dblPickedQty DESC
						--					)
						--			FROM @tblInputItem
						--			SELECT @intSeq = NULL
						--			SELECT @intSeq = intSeq
						--			FROM @tblInputItemSeq
						--			WHERE intItemId = @intRawItemId
						--			IF 1 = 1
						--			BEGIN
						--				SELECT @dblTotalPickedQty = NULL
						--				SELECT @dblTotalPickedQty = Sum(dblPickedQty)
						--				FROM @tblInputItem
						--				IF @ysnComplianceItem = 1
						--					AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
						--				BEGIN
						--					UPDATE @tblInputItem
						--					SET dblPickedQty = dblPickedQty - @dblQuantity
						--					WHERE intItemId = @intRawItemId
						--					IF @ysnMinorIngredient = 1
						--					BEGIN
						--						SELECT @dblQuantity = @dblRequiredQty
						--							,@dblIssuedQuantity = @dblRequiredQty
						--							,@intItemIssuedUOMId = @intItemUOMId
						--					END
						--					ELSE
						--					BEGIN
						--						SELECT @dblQuantity = @dblRequiredQty
						--							,@dblIssuedQuantity = dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)
						--					END
						--					UPDATE @tblInputItem
						--					SET dblPickedQty = dblPickedQty + @dblQuantity
						--					WHERE intItemId = @intRawItemId
						--				END
						--			END
						--			ELSE
						--			BEGIN
						--				UPDATE @tblInputItem
						--				SET dblPickedQty = dblPickedQty - @dblQuantity
						--				WHERE intItemId = @intRawItemId
						--				IF @ysnMinorIngredient = 1
						--				BEGIN
						--					SELECT @dblQuantity = @dblRequiredQty
						--						,@dblIssuedQuantity = @dblRequiredQty
						--						,@intItemIssuedUOMId = @intItemUOMId
						--				END
						--				ELSE
						--				BEGIN
						--					SELECT @dblQuantity = @dblRequiredQty
						--						,@dblIssuedQuantity = dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)
						--				END
						--				UPDATE @tblInputItem
						--				SET dblPickedQty = dblPickedQty + @dblQuantity
						--				WHERE intItemId = @intRawItemId
						--			END
						--		END
						--		ELSE
						--		BEGIN
						--			UPDATE @tblInputItem
						--			SET dblPickedQty = dblPickedQty - @dblQuantity
						--			WHERE intItemId = @intRawItemId
						--			IF @ysnMinorIngredient = 1
						--			BEGIN
						--				SELECT @dblQuantity = @dblRequiredQty
						--					,@dblIssuedQuantity = @dblRequiredQty
						--					,@intItemIssuedUOMId = @intItemUOMId
						--			END
						--			ELSE
						--			BEGIN
						--				SELECT @dblQuantity = @dblRequiredQty
						--					,@dblIssuedQuantity = dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)
						--			END
						--			UPDATE @tblInputItem
						--			SET dblPickedQty = dblPickedQty + @dblQuantity
						--			WHERE intItemId = @intRawItemId
						--		END
						--	END
						--END
						IF @intIssuedUOMTypeId = 4
						BEGIN
							SELECT @dblPickedQty = NULL

							SELECT @dblPickedQty = dblPickedQty
							FROM @tblInputItem
							WHERE intItemId = @intRawItemId

							SELECT @dblSuggestedCeilingQty = 0

							SELECT @dblSuggestedCeilingQty = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)

							SELECT @dblSuggestedFloorQty = 0

							SELECT @dblSuggestedFloorQty = Convert(NUMERIC(38, 20), Floor(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)

							SELECT @dblCeilingQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedCeilingQty)

							SELECT @dblFloorQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedFloorQty)

							IF abs(@dblFloorQtyDiff) > abs(@dblCeilingQtyDiff)
								AND @dblSuggestedCeilingQty + @dblPickedQty BETWEEN @dblLowerToleranceQty
									AND @dblUpperToleranceQty
								AND (
									@dblAvailableQty >= @dblSuggestedCeilingQty
									OR @dblSuggestedCeilingQty - @dblAvailableQty < 0.01
									)
							BEGIN
								SELECT @dblQuantity = @dblSuggestedCeilingQty
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)))
							END
							ELSE
							BEGIN
								IF Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet), 0) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet) > 0
								BEGIN
									SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet), 0) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)
										,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblQuantity, @dblWeightPerQty), 0))
								END
								ELSE
								BEGIN
									SELECT @dblQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)
										,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)))
								END
							END

							UPDATE @tblInputItem
							SET dblPickedQty = dblPickedQty + @dblQuantity
							WHERE intItemId = @intRawItemId
						END

						IF @dblQuantity > 0
						BEGIN
							IF (@dblIssuedQuantity % @intOrgNoOfSheets) > 0
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
								,intNoOfSheet
								,dblNoOfPallets
								,strFW
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
								,@dblUnitCost
								,@intOrgNoOfSheets
								,CASE 
									WHEN IsNULL(@dblNoOfPallets, 0) = 0
										THEN 0
									ELSE @dblIssuedQuantity / @dblNoOfPallets
									END
								,@strFW

							IF ISNULL(@intPartialQuantitySubLocationId, 0) > 0
								AND @intIssuedUOMTypeId = 2
							BEGIN
								SET @dblRequiredQty = @dblRequiredQty - Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty), 0) * @dblWeightPerQty

								IF @dblRequiredQty = 0
									GOTO LOOP_END;
							END
							ELSE
							BEGIN
								SET @dblRequiredQty = 0

								GOTO LOOP_END;
							END
						END
					END
					ELSE
					BEGIN
						IF @ysnEnableParentLot = 0
							SELECT @intParentLotId = L.intLotId
								,@intItemId = L.intItemId
								,@dblQuantity = (
									CASE 
										WHEN @intIssuedUOMTypeId = 2
											THEN Convert(NUMERIC(38, 20), (
														(
															CASE 
																WHEN Round(@dblAvailableQty / L.dblWeightPerQty, 2) = 0
																	THEN 1
																ELSE Round(@dblAvailableQty / L.dblWeightPerQty, 2)
																END
															) * L.dblWeightPerQty
														))
										ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
										END
									)
								,@intItemUOMId = ISNULL(L.intWeightUOMId, @intItemUOMId)
								,@dblIssuedQuantity = (
									CASE 
										WHEN @intIssuedUOMTypeId = 1
											THEN Convert(NUMERIC(38, 20), (
														CASE 
															WHEN (@dblAvailableQty / L.dblWeightPerQty) = 0
																THEN 1
															ELSE Convert(NUMERIC(38, 20), (@dblAvailableQty / L.dblWeightPerQty))
															END
														))
										WHEN @intIssuedUOMTypeId = 2
											THEN Convert(NUMERIC(38, 20), (
														CASE 
															WHEN Round(@dblAvailableQty / L.dblWeightPerQty, 0) = 0
																THEN 1
															ELSE Convert(NUMERIC(38, 20), Round(@dblAvailableQty / L.dblWeightPerQty, 2))
															END
														))
										ELSE @dblAvailableQty --To Review ROUND(@dblAvailableQty,3) 
										END
									)
								,@intItemIssuedUOMId = L.intItemUOMId
								,@intRecipeItemId = @intRecipeItemId
								,@intStorageLocationId = @intStorageLocationId
								,@dblWeightPerQty = L.dblWeightPerQty
								,@dblUnitCost = L.dblLastCost
								,@dblNoOfPallets = @dblNoOfPallets
							FROM tblICLot L
							WHERE L.intLotId = @intParentLotId
								AND L.dblQty > @dblDefaultResidueQty
						ELSE
							SELECT TOP 1 @intParentLotId = L.intParentLotId
								,@intItemId = L.intItemId
								,@dblQuantity = @dblAvailableQty
								,@intItemUOMId = L.intItemUOMId
								,@dblIssuedQuantity = @dblAvailableQty
								,@intItemIssuedUOMId = CASE 
									WHEN @intIssuedUOMTypeId = 2
										THEN L.intItemIssuedUOMId
									WHEN @intIssuedUOMTypeId = 3
										THEN L.intItemIssuedUOMId
									ELSE L.intItemUOMId
									END
								,@intStorageLocationId = CASE 
									WHEN @ysnShowAvailableLotsByStorageLocation = 1
										THEN @intStorageLocationId
									ELSE 0
									END
								,@dblWeightPerQty = L.dblWeightPerQty
								,@dblUnitCost = L.dblUnitCost
								,@dblNoOfPallets = @dblNoOfPallets
							FROM #tblParentLot L
							WHERE L.intParentLotId = @intParentLotId

						IF @intIssuedUOMTypeId = 2
						BEGIN
							SELECT @dblPickedQty = NULL

							SELECT @dblPickedQty = dblPickedQty
							FROM @tblInputItem
							WHERE intItemId = @intRawItemId

							SELECT @dblSuggestedCeilingQty = 0

							SELECT @dblSuggestedCeilingQty = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty)) * @dblWeightPerQty)

							SELECT @dblSuggestedFloorQty = 0

							SELECT @dblSuggestedFloorQty = Convert(NUMERIC(38, 20), Floor(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty)) * @dblWeightPerQty)

							SELECT @dblCeilingQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedCeilingQty)

							SELECT @dblFloorQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedFloorQty)

							IF abs(@dblFloorQtyDiff) > abs(@dblCeilingQtyDiff)
								AND @dblSuggestedCeilingQty + @dblPickedQty BETWEEN @dblLowerToleranceQty
									AND @dblUpperToleranceQty
								AND (
									@dblAvailableQty >= @dblSuggestedCeilingQty
									OR @dblSuggestedCeilingQty - @dblAvailableQty < 0.01
									)
							BEGIN
								SELECT @dblQuantity = @dblSuggestedCeilingQty
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty)))
							END
							ELSE
							BEGIN
								SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty), 0) * @dblWeightPerQty)
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty), 0))
							END

							UPDATE @tblInputItem
							SET dblPickedQty = dblPickedQty + @dblQuantity
							WHERE intItemId = @intRawItemId
						END

						IF @intIssuedUOMTypeId = 3
						BEGIN
							SELECT @dblAvailableQty1 = 0

							SELECT @dblAvailableQty1 = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty), 0) * @dblWeightPerQty)

							IF @ysnMinorIngredient = 0
								AND (
									@dblAvailableQty >= @dblAvailableQty1
									OR @dblAvailableQty1 - @dblAvailableQty < 0.01
									)
							BEGIN
								SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty), 0) * @dblWeightPerQty)
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty), 0))
							END
							ELSE
							BEGIN
								SELECT @dblQuantity = @dblAvailableQty
									,@dblIssuedQuantity = @dblAvailableQty
									,@intItemIssuedUOMId = @intItemUOMId
							END

							IF @dblQuantity = 0
							BEGIN
								SELECT @dblQuantity = @dblAvailableQty
									,@dblIssuedQuantity = @dblAvailableQty
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
										--@dblPickedQty BETWEEN @dblLowerToleranceQty
										--	AND @dblUpperToleranceQty
										@dblPickedQty <= @dblUpperToleranceQty
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

									SELECT @intSeq = NULL

									SELECT @intSeq = intSeq
									FROM @tblInputItemSeq
									WHERE intItemId = @intRawItemId

									IF @intMinRowNo = @intSeq
									BEGIN
										SELECT @dblTotalPickedQty = NULL

										SELECT @dblTotalPickedQty = Sum(dblPickedQty)
										FROM @tblInputItem

										IF @ysnComplianceItem = 1
											AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
										BEGIN
											UPDATE @tblInputItem
											SET dblPickedQty = dblPickedQty - @dblQuantity
											WHERE intItemId = @intRawItemId

											IF @ysnMinorIngredient = 1
											BEGIN
												SELECT @dblQuantity = @dblAvailableQty
													,@dblIssuedQuantity = @dblAvailableQty
													,@intItemIssuedUOMId = @intItemUOMId
											END
											ELSE
											BEGIN
												SELECT @dblQuantity = @dblAvailableQty
													,@dblIssuedQuantity = dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty)
											END

											UPDATE @tblInputItem
											SET dblPickedQty = dblPickedQty + @dblQuantity
											WHERE intItemId = @intRawItemId
										END
									END
									ELSE
									BEGIN
										UPDATE @tblInputItem
										SET dblPickedQty = dblPickedQty - @dblQuantity
										WHERE intItemId = @intRawItemId

										IF @ysnMinorIngredient = 1
										BEGIN
											SELECT @dblQuantity = @dblAvailableQty
												,@dblIssuedQuantity = @dblAvailableQty
												,@intItemIssuedUOMId = @intItemUOMId
										END
										ELSE
										BEGIN
											SELECT @dblQuantity = @dblAvailableQty
												,@dblIssuedQuantity = dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty)
										END

										UPDATE @tblInputItem
										SET dblPickedQty = dblPickedQty + @dblQuantity
										WHERE intItemId = @intRawItemId
									END
								END
								ELSE
								BEGIN
									UPDATE @tblInputItem
									SET dblPickedQty = dblPickedQty - @dblQuantity
									WHERE intItemId = @intRawItemId

									IF @ysnMinorIngredient = 1
									BEGIN
										SELECT @dblQuantity = @dblAvailableQty
											,@dblIssuedQuantity = @dblAvailableQty
											,@intItemIssuedUOMId = @intItemUOMId
									END
									ELSE
									BEGIN
										SELECT @dblQuantity = @dblAvailableQty
											,@dblIssuedQuantity = dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty)
									END

									UPDATE @tblInputItem
									SET dblPickedQty = dblPickedQty + @dblQuantity
									WHERE intItemId = @intRawItemId
								END
							END
						END

						--IF @intIssuedUOMTypeId = 4
						--BEGIN
						--	IF @ysnMinorIngredient = 0
						--	BEGIN
						--		SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet), 0) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)
						--			,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet), 0)) * @intUnitPerLayer * @intLayerPerPallet
						--	END
						--	ELSE
						--	BEGIN
						--		SELECT @dblQuantity = @dblRequiredQty
						--			,@dblIssuedQuantity = @dblRequiredQty
						--			,@intItemIssuedUOMId = @intItemUOMId
						--	END
						--	IF @dblQuantity = 0
						--	BEGIN
						--		SELECT @dblQuantity = @dblRequiredQty
						--			,@dblIssuedQuantity = @dblRequiredQty
						--			,@intItemIssuedUOMId = @intItemUOMId
						--		UPDATE @tblInputItem
						--		SET dblPickedQty = dblPickedQty + @dblQuantity
						--		WHERE intItemId = @intRawItemId
						--	END
						--	ELSE
						--	BEGIN
						--		UPDATE @tblInputItem
						--		SET dblPickedQty = dblPickedQty + @dblQuantity
						--		WHERE intItemId = @intRawItemId
						--		SELECT @dblPickedQty = NULL
						--		SELECT @dblPickedQty = dblPickedQty
						--		FROM @tblInputItem
						--		WHERE intItemId = @intRawItemId
						--		IF @dblPickedQty <= @dblUpperToleranceQty
						--			AND @dblLowerToleranceQty > 0
						--			AND @dblUpperToleranceQty > 0
						--		BEGIN
						--			DELETE
						--			FROM @tblInputItemSeq
						--			INSERT INTO @tblInputItemSeq (
						--				intItemId
						--				,intSeq
						--				)
						--			SELECT intItemId
						--				,row_number() OVER (
						--					ORDER BY dblPickedQty DESC
						--					)
						--			FROM @tblInputItem
						--			SELECT @intSeq = NULL
						--			SELECT @intSeq = intSeq
						--			FROM @tblInputItemSeq
						--			WHERE intItemId = @intRawItemId
						--			IF 1 = 1
						--			BEGIN
						--				SELECT @dblTotalPickedQty = NULL
						--				SELECT @dblTotalPickedQty = Sum(dblPickedQty)
						--				FROM @tblInputItem
						--				IF @ysnComplianceItem = 1
						--					AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
						--				BEGIN
						--					UPDATE @tblInputItem
						--					SET dblPickedQty = dblPickedQty - @dblQuantity
						--					WHERE intItemId = @intRawItemId
						--					IF @ysnMinorIngredient = 1
						--					BEGIN
						--						SELECT @dblQuantity = @dblRequiredQty
						--							,@dblIssuedQuantity = @dblRequiredQty
						--							,@intItemIssuedUOMId = @intItemUOMId
						--					END
						--					ELSE
						--					BEGIN
						--						SELECT @dblQuantity = @dblRequiredQty
						--							,@dblIssuedQuantity = dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)
						--					END
						--					UPDATE @tblInputItem
						--					SET dblPickedQty = dblPickedQty + @dblQuantity
						--					WHERE intItemId = @intRawItemId
						--				END
						--			END
						--			ELSE
						--			BEGIN
						--				UPDATE @tblInputItem
						--				SET dblPickedQty = dblPickedQty - @dblQuantity
						--				WHERE intItemId = @intRawItemId
						--				IF @ysnMinorIngredient = 1
						--				BEGIN
						--					SELECT @dblQuantity = @dblRequiredQty
						--						,@dblIssuedQuantity = @dblRequiredQty
						--						,@intItemIssuedUOMId = @intItemUOMId
						--				END
						--				ELSE
						--				BEGIN
						--					SELECT @dblQuantity = @dblRequiredQty
						--						,@dblIssuedQuantity = dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)
						--				END
						--				UPDATE @tblInputItem
						--				SET dblPickedQty = dblPickedQty + @dblQuantity
						--				WHERE intItemId = @intRawItemId
						--			END
						--		END
						--		ELSE
						--		BEGIN
						--			UPDATE @tblInputItem
						--			SET dblPickedQty = dblPickedQty - @dblQuantity
						--			WHERE intItemId = @intRawItemId
						--			IF @ysnMinorIngredient = 1
						--			BEGIN
						--				SELECT @dblQuantity = @dblRequiredQty
						--					,@dblIssuedQuantity = @dblRequiredQty
						--					,@intItemIssuedUOMId = @intItemUOMId
						--			END
						--			ELSE
						--			BEGIN
						--				SELECT @dblQuantity = @dblRequiredQty
						--					,@dblIssuedQuantity = dbo.[fnDivide](@dblRequiredQty, @dblWeightPerQty)
						--			END
						--			UPDATE @tblInputItem
						--			SET dblPickedQty = dblPickedQty + @dblQuantity
						--			WHERE intItemId = @intRawItemId
						--		END
						--	END
						--END
						IF @intIssuedUOMTypeId = 4
						BEGIN
							SELECT @dblPickedQty = NULL

							SELECT @dblPickedQty = dblPickedQty
							FROM @tblInputItem
							WHERE intItemId = @intRawItemId

							SELECT @dblSuggestedCeilingQty = 0

							SELECT @dblSuggestedCeilingQty = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)

							SELECT @dblSuggestedFloorQty = 0

							SELECT @dblSuggestedFloorQty = Convert(NUMERIC(38, 20), Floor(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)

							SELECT @dblCeilingQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedCeilingQty)

							SELECT @dblFloorQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedFloorQty)

							IF abs(@dblFloorQtyDiff) > abs(@dblCeilingQtyDiff)
								AND @dblSuggestedCeilingQty + @dblPickedQty BETWEEN @dblLowerToleranceQty
									AND @dblUpperToleranceQty
								AND (
									@dblAvailableQty >= @dblSuggestedCeilingQty
									OR @dblSuggestedCeilingQty - @dblAvailableQty < 0.01
									)
							BEGIN
								SELECT @dblQuantity = @dblSuggestedCeilingQty
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)))
							END
							ELSE
							BEGIN
								IF Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet), 0) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet) > 0
								BEGIN
									SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet), 0) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)
										,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblQuantity, @dblWeightPerQty), 0))
								END
								ELSE
								BEGIN
									SELECT @dblQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)) * @dblWeightPerQty * @intUnitPerLayer * @intLayerPerPallet)
										,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblQuantity, @dblWeightPerQty)))
								END
							END

							UPDATE @tblInputItem
							SET dblPickedQty = dblPickedQty + @dblQuantity
							WHERE intItemId = @intRawItemId
						END

						IF @dblQuantity > 0
						BEGIN
							IF (@dblIssuedQuantity % @intOrgNoOfSheets) > 0
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
								,intNoOfSheet
								,dblNoOfPallets
								,strFW
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
								,@dblUnitCost
								,@intOrgNoOfSheets
								,CASE 
									WHEN IsNULL(@dblNoOfPallets, 0) = 0
										THEN 0
									ELSE @dblIssuedQuantity / @dblNoOfPallets
									END
								,@strFW

							--UPDATE @tblInputItem
							--SET dblPickedQty = dblPickedQty + @dblQuantity
							--WHERE intItemId = @intRawItemId
							SET @dblRequiredQty = @dblRequiredQty - @dblQuantity

							IF @intIssuedUOMTypeId = 2
								AND Round(dbo.[fnDivide](@dblAvailableQty, @dblWeightPerQty), 0) * @dblWeightPerQty = 0
							BEGIN
								SELECT @dblRequiredQty = 0

								GOTO LOOP_END;
							END
						END
					END
				END

				SET @intStorageLocationId = NULL

				NextLot:

				FETCH NEXT
				FROM Cursor_FetchItem
				INTO @intParentLotId
					,@intRawItemId
					,@dblAvailableQty
					,@intStorageLocationId
					,@dblWeightPerQty
					,@intLayerPerPallet
					,@intUnitPerLayer
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
			IF @ysnIsSubstitute = 0
			BEGIN
				SELECT @dblRemainingRequiredQty = @dblOriginalRequiredQty - ISNULL(SUM(ISNULL(dblQuantity, 0)), 0)
				FROM #tblBlendSheetLot
				WHERE intItemId = @intRawItemId

				IF @dblRemainingRequiredQty > 0
				BEGIN
					--if main item qty not there then remaining qty pick from substitute if exists
					IF EXISTS (
							SELECT 1
							FROM @tblInputItem
							WHERE intParentItemId = @intRawItemId
								AND ysnIsSubstitute = 1
							)
					BEGIN
						IF ISNULL(@dblRecipeQty, 0) = 0
							SET @dblRecipeQty = 1

						UPDATE @tblInputItem
						SET dblRequiredQty = @dblRemainingRequiredQty * (dblSubstituteRatio * dblMaxSubstituteRatio / 100)
						WHERE intParentItemId = @intRawItemId
							AND ysnIsSubstitute = 1

						DELETE
						FROM @tblInputItem
						WHERE intItemId = @intRawItemId
							AND ysnIsSubstitute = 0 --Remove the main Item
					END
					ELSE --substitute does not exists then show 0 for main item
					BEGIN
						IF ISNULL(@intPartialQuantitySubLocationId, 0) > 0
							INSERT INTO @tblRemainingPickedLots (
								intWorkOrderInputLotId
								,intLotId
								,strLotNumber
								,strItemNo
								,strDescription
								,dblQuantity
								,intItemUOMId
								,strUOM
								,dblIssuedQuantity
								,intItemIssuedUOMId
								,strIssuedUOM
								,intItemId
								,intRecipeItemId
								,dblUnitCost
								,dblDensity
								,dblRequiredQtyPerSheet
								,dblWeightPerUnit
								,dblRiskScore
								,intStorageLocationId
								,strStorageLocationName
								,strLocationName
								,intLocationId
								,strSubLocationName
								,intSubLocationId
								,strLotAlias
								,ysnParentLot
								,strRowState
								,strSecondaryStatus
								)
							SELECT TOP 1 0
								,0
								,''
								,i.strItemNo
								,i.strDescription
								,@dblRemainingRequiredQty
								,l.intWeightUOMId
								,um.strUnitMeasure
								,@dblRemainingRequiredQty
								,l.intWeightUOMId
								,um.strUnitMeasure
								,--l.intItemUOMId,um1.strUnitMeasure, 
								@intRawItemId
								,0
								,0.0
								,0.0
								,0.0
								,l.dblWeightPerQty
								,0.0
								,0
								,''
								,''
								,@intLocationId
								,''
								,0
								,''
								,0
								,'Added'
								,ls.strSecondaryStatus
							FROM tblICLot l
							JOIN tblICLotStatus ls ON l.intLotStatusId = ls.intLotStatusId
							JOIN tblICItem i ON l.intItemId = i.intItemId
							JOIN tblICItemUOM iu ON l.intWeightUOMId = iu.intItemUOMId
							JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
							JOIN tblICItemUOM iu1 ON l.intItemUOMId = iu1.intItemUOMId
							JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
							WHERE i.intItemId = @intRawItemId
							ORDER BY l.intLotId DESC

						--If No Lots found for Item
						IF (
								SELECT COUNT(1)
								FROM @tblRemainingPickedLots
								) = 0
							AND (
								SELECT COUNT(1)
								FROM tblICLot
								WHERE intItemId = @intRawItemId
								) = 0
							INSERT INTO @tblRemainingPickedLots (
								intWorkOrderInputLotId
								,intLotId
								,strLotNumber
								,strItemNo
								,strDescription
								,dblQuantity
								,intItemUOMId
								,strUOM
								,dblIssuedQuantity
								,intItemIssuedUOMId
								,strIssuedUOM
								,intItemId
								,intRecipeItemId
								,dblUnitCost
								,dblDensity
								,dblRequiredQtyPerSheet
								,dblWeightPerUnit
								,dblRiskScore
								,intStorageLocationId
								,strStorageLocationName
								,strLocationName
								,intLocationId
								,strSubLocationName
								,intSubLocationId
								,strLotAlias
								,ysnParentLot
								,strRowState
								,strSecondaryStatus
								)
							SELECT TOP 1 0
								,0
								,''
								,i.strItemNo
								,i.strDescription
								,@dblRemainingRequiredQty
								,ri.intItemUOMId
								,um.strUnitMeasure
								,@dblRemainingRequiredQty
								,ri.intItemUOMId
								,um.strUnitMeasure
								,--l.intItemUOMId,um1.strUnitMeasure, 
								@intRawItemId
								,0
								,0.0
								,0.0
								,0.0
								,1 AS dblWeightPerQty
								,0.0
								,0
								,''
								,''
								,@intLocationId
								,''
								,0
								,''
								,0
								,'Added'
								,'Active'
							FROM tblMFRecipeItem ri
							JOIN tblICItem i ON ri.intItemId = i.intItemId
							JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId
							JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
							WHERE ri.intRecipeItemId = @intRecipeItemId
								AND ri.intItemId = @intRawItemId
					END
				END
				ELSE
				BEGIN
					--Do not pick Substitute
					DELETE
					FROM @tblInputItem
					WHERE intParentItemId = @intRawItemId
						AND ysnIsSubstitute = 1
				END
			END

			--IF @intIssuedUOMTypeId = 2
			--AND 
			IF @intConsumptionMethodId IN (
					2
					,3
					) --By FIFO and By Locationn
				AND EXISTS (
					SELECT 1
					FROM @tblInputItem
					WHERE intItemId = @intRawItemId
					)
			BEGIN
				SELECT @dblRemainingRequiredQty = @dblOriginalRequiredQty - ISNULL(SUM(ISNULL(dblQuantity, 0)), 0)
				FROM #tblBlendSheetLot
				WHERE intItemId = @intRawItemId

				IF @dblRemainingRequiredQty > 0
					INSERT INTO @tblRemainingPickedLots (
						intWorkOrderInputLotId
						,intLotId
						,strLotNumber
						,strItemNo
						,strDescription
						,dblQuantity
						,intItemUOMId
						,strUOM
						,dblIssuedQuantity
						,intItemIssuedUOMId
						,strIssuedUOM
						,intItemId
						,intRecipeItemId
						,dblUnitCost
						,dblDensity
						,dblRequiredQtyPerSheet
						,dblWeightPerUnit
						,dblRiskScore
						,intStorageLocationId
						,strStorageLocationName
						,strLocationName
						,intLocationId
						,strSubLocationName
						,intSubLocationId
						,strLotAlias
						,ysnParentLot
						,strRowState
						,strSecondaryStatus
						)
					SELECT TOP 1 0
						,0
						,''
						,i.strItemNo
						,i.strDescription
						,@dblRemainingRequiredQty
						,l.intWeightUOMId
						,um.strUnitMeasure
						,@dblRemainingRequiredQty
						,l.intWeightUOMId
						,um.strUnitMeasure
						,--l.intItemUOMId,um1.strUnitMeasure, 
						@intRawItemId
						,0
						,0.0
						,0.0
						,0.0
						,l.dblWeightPerQty
						,0.0
						,0
						,''
						,''
						,@intLocationId
						,''
						,0
						,''
						,0
						,'Added'
						,ls.strSecondaryStatus
					FROM tblICLot l
					JOIN tblICLotStatus ls ON l.intLotStatusId = ls.intLotStatusId
					JOIN tblICItem i ON l.intItemId = i.intItemId
					JOIN tblICItemUOM iu ON l.intWeightUOMId = iu.intItemUOMId
					JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
					JOIN tblICItemUOM iu1 ON l.intItemUOMId = iu1.intItemUOMId
					JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
					WHERE i.intItemId = @intRawItemId
					ORDER BY l.intLotId DESC
			END

			--Hand Add 
			--IF (@intIssuedUOMTypeId <> @intOriginalIssuedUOMTypeId)
			--	SET @intIssuedUOMTypeId = @intOriginalIssuedUOMTypeId
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
		,dblUnitCost
		,dblNoOfPallets
		,strFW
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
		,MAX(dblUnitCost)
		,dblNoOfPallets
		,strFW
	FROM #tblBlendSheetLot
	GROUP BY intParentLotId
		,intItemId
		,intItemUOMId
		,intItemIssuedUOMId
		,intRecipeItemId
		,intStorageLocationId
		,dblNoOfPallets
		,strFW

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
			,Case When @ysnDisplayLandedPriceInBlendManagement=1 Then IsNULL(Batch.dblLandedPrice,0) Else L.dblLastCost End AS dblUnitCost
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
			,ls.strSecondaryStatus
			,dblNoOfPallets
			,BS.strFW
			,MT.strDescription AS strProductType
			,B.strBrandCode
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICLot L ON BS.intParentLotId = L.intLotId
			AND L.dblQty > 0
		INNER JOIN tblICLotStatus ls ON L.intLotStatusId = ls.intLotStatusId
		INNER JOIN tblICItem I ON I.intItemId = L.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId = UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.intItemIssuedUOMId
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId = UM2.intUnitMeasureId
		INNER JOIN tblICStorageLocation SL ON SL.intStorageLocationId = BS.intStorageLocationId
		INNER JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = L.intSubLocationId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
		LEFT JOIN tblICCommodityAttribute MT ON MT.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblICBrand B ON B.intBrandId = I.intBrandId
		LEFT JOIN tblMFLotInventory LI on LI.intLotId=L.intLotId
		LEFT JOIN tblMFBatch Batch on Batch.intBatchId=LI.intBatchId
		WHERE BS.dblQuantity > 0
		
		UNION
		
		SELECT *
			,NULL AS dblNoOfPallets
			,NULL AS strFW
			,NULL AS strProductType
			,NULL AS strBrandCode
		FROM @tblRemainingPickedLots
		
		UNION --Non Lot Tracked
		
		SELECT pl.intItemStockUOMId
			,- 1
			,''
			,i.strItemNo
			,i.strDescription
			,pl.dblQty
			,pl.intItemUOMId
			,um.strUnitMeasure
			,pl.dblQty
			,pl.intItemUOMId
			,um.strUnitMeasure
			,i.intItemId
			,@intRecipeItemId
			,0
			,0
			,0
			,1
			,0
			,pl.intStorageLocationId
			,sl.strName
			,cl.strLocationName
			,pl.intLocationId
			,csl.strSubLocationName
			,csl.intCompanyLocationSubLocationId AS intSubLocationId
			,''
			,0
			,'Added'
			,''
			,NULL AS dblNoOfPallets
			,NULL AS strFW
			,NULL AS strProductType
			,NULL AS strBrandCode
		FROM @tblPickedItem pl
		JOIN tblICItem i ON pl.intItemId = i.intItemId
		JOIN tblICItemUOM iu ON pl.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		LEFT JOIN tblICStorageLocation sl ON pl.intStorageLocationId = sl.intStorageLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation csl ON csl.intCompanyLocationSubLocationId = pl.intSubLocationId
		JOIN tblSMCompanyLocation cl ON pl.intLocationId = cl.intCompanyLocationId
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
			,BS.dblUnitCost AS dblUnitCost
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
			,CLSL.strSubLocationName AS strSubLocationName
			,SL.intSubLocationId AS intSubLocationId
			,PL.strParentLotAlias AS strLotAlias
			,CAST(1 AS BIT) ysnParentLot
			,'Added' AS strRowState
			,ls.strSecondaryStatus
			,dblNoOfPallets
			,NULL AS strFW
			,MT.strDescription AS strProductType
			,B.strBrandCode
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICParentLot PL ON BS.intParentLotId = PL.intParentLotId --AND PL.dblWeight > 0
		INNER JOIN tblICLotStatus ls ON PL.intLotStatusId = ls.intLotStatusId
		INNER JOIN tblICItem I ON I.intItemId = BS.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId = UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.intItemIssuedUOMId
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId = UM2.intUnitMeasureId
		INNER JOIN tblICStorageLocation SL ON SL.intStorageLocationId = BS.intStorageLocationId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
		INNER JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = SL.intSubLocationId
		LEFT JOIN tblICCommodityAttribute MT ON MT.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblICBrand B ON B.intBrandId = I.intBrandId
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
			,BS.dblUnitCost AS dblUnitCost
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
			,'' AS strSubLocationName
			,0 AS intSubLocationId
			,PL.strParentLotAlias AS strLotAlias
			,CAST(1 AS BIT) ysnParentLot
			,'Added' AS strRowState
			,ls.strSecondaryStatus
			,dblNoOfPallets
			,NULL AS strFW
			,MT.strDescription AS strProductType
			,B.strBrandCode
		FROM #tblBlendSheetLotFinal BS
		INNER JOIN tblICParentLot PL ON BS.intParentLotId = PL.intParentLotId --AND PL.dblWeight > 0
		INNER JOIN tblICLotStatus ls ON PL.intLotStatusId = ls.intLotStatusId
		INNER JOIN tblICItem I ON I.intItemId = BS.intItemId
		INNER JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = BS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM1 ON IU1.intUnitMeasureId = UM1.intUnitMeasureId
		INNER JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = BS.intItemIssuedUOMId
		INNER JOIN tblICUnitMeasure UM2 ON IU2.intUnitMeasureId = UM2.intUnitMeasureId
		INNER JOIN tblICStorageLocation SL ON SL.intStorageLocationId = BS.intStorageLocationId
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = @intLocationId
		LEFT JOIN tblICCommodityAttribute MT ON MT.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblICBrand B ON B.intBrandId = I.intBrandId
		WHERE BS.dblQuantity > 0
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	IF @idoc1 <> 0
		EXEC sp_xml_removedocument @idoc1

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
