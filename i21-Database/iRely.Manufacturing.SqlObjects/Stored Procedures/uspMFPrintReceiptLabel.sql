CREATE PROCEDURE uspMFPrintReceiptLabel (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intInventoryReceiptItemLotId INT
		,@strParentLotNumber NVARCHAR(50)
		,@strLotNumber NVARCHAR(50)
		,@intLocationId INT
		,@intEntityUserSecurityId INT
		,@intInventoryReceiptId INT
		,@intShiftId INT
		,@intItemId INT
		,@intCategoryId INT
		,@intInventoryReceiptItemId INT
		,@intSubLocationId INT
		,@dtmManufacturedDate DATETIME
		,@intManufacturingId INT
		,@intOrderTypeId INT
		,@intBlendRequirementId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	DECLARE @tblMFInventoryReceiptItemLot TABLE (intInventoryReceiptItemLotId INT)
	DECLARE @tblMFFinalInventoryReceiptItemLot TABLE (intInventoryReceiptItemLotId INT)

	SELECT @intLocationId = intLocationId
		,@intEntityUserSecurityId = intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intEntityUserSecurityId INT
			)

	INSERT INTO @tblMFInventoryReceiptItemLot (intInventoryReceiptItemLotId)
	SELECT x.intInventoryReceiptItemLotId
	FROM OPENXML(@idoc, 'root/intInventoryReceiptItemLotIds', 2) WITH (intInventoryReceiptItemLotId INT) x
	JOIN tblICInventoryReceiptItemLot IRL ON x.intInventoryReceiptItemLotId = IRL.intInventoryReceiptItemLotId
	WHERE (
			IRL.strLotNumber = ''
			OR IRL.strParentLotNumber = ''
			)

	INSERT INTO @tblMFFinalInventoryReceiptItemLot (intInventoryReceiptItemLotId)
	SELECT x.intInventoryReceiptItemLotId
	FROM OPENXML(@idoc, 'root/intInventoryReceiptItemLotIds', 2) WITH (intInventoryReceiptItemLotId INT) x

	SELECT @intInventoryReceiptItemLotId = MIN(intInventoryReceiptItemLotId)
	FROM @tblMFInventoryReceiptItemLot

	WHILE @intInventoryReceiptItemLotId IS NOT NULL
	BEGIN
		SELECT @strParentLotNumber = NULL
			,@strLotNumber = NULL
			,@intItemId = NULL
			,@intCategoryId = NULL
			,@intSubLocationId = NULL
			,@intInventoryReceiptId = NULL

		SELECT @strParentLotNumber = strParentLotNumber
			,@strLotNumber = strLotNumber
			,@intInventoryReceiptItemId = intInventoryReceiptItemId
			,@dtmManufacturedDate = dtmManufacturedDate
		FROM tblICInventoryReceiptItemLot
		WHERE intInventoryReceiptItemLotId = @intInventoryReceiptItemLotId

		SELECT @intItemId = intItemId
			,@intSubLocationId = intSubLocationId
			,@intInventoryReceiptId = intInventoryReceiptId
		FROM tblICInventoryReceiptItem
		WHERE intInventoryReceiptItemId = @intInventoryReceiptItemId

		SELECT @intCategoryId = intCategoryId
		FROM tblICItem
		WHERE intItemId = @intItemId

		IF @strParentLotNumber = ''
		BEGIN
			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
				,@intItemId = @intItemId
				,@intManufacturingId = NULL
				,@intSubLocationId = @intSubLocationId
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 78
				,@ysnProposed = 0
				,@strPatternString = @strParentLotNumber OUTPUT
				,@intEntityId = @intEntityUserSecurityId
				,@intShiftId = @intShiftId
				,@dtmDate = @dtmManufacturedDate
				,@strParentLotNumber = NULL
				,@intInventoryReceiptId = @intInventoryReceiptId
				,@intInventoryReceiptItemId = @intInventoryReceiptItemId
				,@intInventoryReceiptItemLotId = @intInventoryReceiptItemLotId
				,@intTransactionTypeId = 4
		END

		IF @strLotNumber = ''
		BEGIN
			EXEC dbo.uspMFGeneratePatternId @intCategoryId
				,@intItemId
				,@intManufacturingId
				,@intSubLocationId
				,@intLocationId
				,@intOrderTypeId
				,@intBlendRequirementId
				,24
				,0
				,@strLotNumber OUTPUT
				,@intEntityUserSecurityId
				,@intShiftId
				,@dtmManufacturedDate
				,@strParentLotNumber
				,@intInventoryReceiptId
				,@intInventoryReceiptItemId
				,@intInventoryReceiptItemLotId
				,4
		END

		UPDATE tblICInventoryReceiptItemLot
		SET strParentLotNumber = @strParentLotNumber
			,strLotNumber = @strLotNumber
		WHERE intInventoryReceiptItemLotId = @intInventoryReceiptItemLotId

		SELECT @intInventoryReceiptItemLotId = MIN(intInventoryReceiptItemLotId)
		FROM @tblMFInventoryReceiptItemLot
		WHERE intInventoryReceiptItemLotId > @intInventoryReceiptItemLotId
	END

	SELECT IRL.intInventoryReceiptItemLotId
		,IRI.intItemId
		,IRL.dblQuantity
		,UM.strUnitMeasure AS strQtyUOM
		,IRL.dblGrossWeight - IsNULL(IRL.dblTareWeight, 0) AS dblWeight
		,UM1.strUnitMeasure AS strWeightUOM
		,IRL.strLotNumber
		,I.strItemNo
		,I.strDescription
		,IRL.strParentLotNumber
		,IRL.strVendorLotId
		,IR.dtmReceiptDate AS dtmDateCreated
		,ISNULL(I.strMaterialSizeCode, '') AS strMaterialSizeCode
	FROM tblICInventoryReceiptItemLot IRL
	JOIN @tblMFFinalInventoryReceiptItemLot FIRL ON FIRL.intInventoryReceiptItemLotId = IRL.intInventoryReceiptItemLotId
	JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRL.intInventoryReceiptItemId
	JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	JOIN dbo.tblICItem I ON I.intItemId = IRI.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = IRL.intItemUnitMeasureId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = IRI.intWeightUOMId
	LEFT JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
	ORDER BY IRL.strParentLotNumber
		,IRL.strLotNumber

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
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

