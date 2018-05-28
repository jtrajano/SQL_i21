CREATE PROCEDURE uspMFReportLotLabel @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
		,@strLotNo NVARCHAR(MAX)
		,@xmlDocumentId INT
		,@strLotId NVARCHAR(MAX)
		,@strInventoryReceiptItemLotId NVARCHAR(MAX)
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
		,@intNoOfLabel INT
	DECLARE @tblMFInventoryReceiptItemLot TABLE (intInventoryReceiptItemLotId INT)
	DECLARE @tblMFFinalInventoryReceiptItemLot TABLE (intInventoryReceiptItemLotId INT)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(MAX)
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
			,[from] NVARCHAR(MAX)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @strLotNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strLotNo'

	IF @strLotNo IS NULL
		OR @strLotNo = ''
	BEGIN
		SELECT @strLotNo = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strLotNumber'
	END

	SELECT @strLotId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intLotId'

	SELECT @strInventoryReceiptItemLotId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intInventoryReceiptItemLotId'

	SELECT @intNoOfLabel = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNoOfLabel'

	DECLARE @tblMFNoOfLabel TABLE (intId INT)

	WHILE @intNoOfLabel > 0
	BEGIN
		INSERT INTO @tblMFNoOfLabel
		SELECT 1

		SELECT @intNoOfLabel = @intNoOfLabel - 1
	END

	IF ISNULL(@strInventoryReceiptItemLotId, '') <> ''
	BEGIN
		INSERT INTO @tblMFInventoryReceiptItemLot (intInventoryReceiptItemLotId)
		SELECT x.Item COLLATE DATABASE_DEFAULT
		FROM dbo.fnSplitString(@strInventoryReceiptItemLotId, '^') x
		JOIN tblICInventoryReceiptItemLot IRL ON x.Item COLLATE DATABASE_DEFAULT = IRL.intInventoryReceiptItemLotId
		WHERE (
				IRL.strLotNumber = ''
				OR IRL.strParentLotNumber = ''
				)

		INSERT INTO @tblMFFinalInventoryReceiptItemLot (intInventoryReceiptItemLotId)
		SELECT x.Item COLLATE DATABASE_DEFAULT
		FROM dbo.fnSplitString(@strInventoryReceiptItemLotId, '^') x

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

			SELECT @intLocationId = intCompanyLocationId
			FROM tblSMCompanyLocationSubLocation
			WHERE intCompanyLocationSubLocationId = @intSubLocationId

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

		SELECT NULL AS intLotId
			,IRI.intItemId
			,IRL.dblQuantity AS dblQty
			,UM.strUnitMeasure AS strQtyUOM
			,IRL.dblGrossWeight - IsNULL(IRL.dblTareWeight, 0) AS dblWeight
			,UM1.strUnitMeasure AS strWeightUOM
			,IRL.strLotNumber
			,I.strItemNo
			,I.strDescription
			,IRL.strParentLotNumber
			,IRL.strVendorLotId AS strVendorLotNo
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
	END
	ELSE
	BEGIN
		IF ISNULL(@strLotId, '') <> ''
		BEGIN
			SELECT *
			FROM (
				SELECT l.intLotId
					,l.intItemId
					,l.dblQty
					,um.strUnitMeasure AS strQtyUOM
					,CASE 
						WHEN l.intWeightUOMId IS NULL
							THEN l.dblQty * i.dblWeight
						ELSE l.dblWeight
						END AS dblWeight
					,um1.strUnitMeasure AS strWeightUOM
					,l.strLotNumber
					,i.strItemNo
					,i.strDescription
					,pl.strParentLotNumber
					,l.strVendorLotNo
					,(
						SELECT Min(L1.dtmDateCreated)
						FROM tblICLot L1
						WHERE L1.strLotNumber = l.strLotNumber
						) AS dtmDateCreated
					,ISNULL(i.strMaterialSizeCode, '') AS strMaterialSizeCode
				FROM tblICLot l
				JOIN dbo.tblICItem i ON i.intItemId = l.intItemId
				JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId
				JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
				JOIN tblICParentLot pl ON pl.intParentLotId = l.intParentLotId
				LEFT JOIN tblICItemUOM iu1 ON iu1.intItemUOMId = l.intWeightUOMId
				LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = (
						CASE 
							WHEN l.intWeightUOMId IS NULL
								THEN i.intWeightUOMId
							ELSE iu1.intUnitMeasureId
							END
						)
				WHERE l.intLotId IN (
						SELECT *
						FROM dbo.fnSplitString(@strLotId, '^')
						)
				) AS DT
				,@tblMFNoOfLabel
			ORDER BY DT.strParentLotNumber
		END
		ELSE
		BEGIN
			SELECT *
			FROM (
				SELECT l.intLotId
					,l.intItemId
					,l.dblQty
					,um.strUnitMeasure AS strQtyUOM
					,CASE 
						WHEN l.intWeightUOMId IS NULL
							THEN l.dblQty * i.dblWeight
						ELSE l.dblWeight
						END AS dblWeight
					,um1.strUnitMeasure AS strWeightUOM
					,l.strLotNumber
					,i.strItemNo
					,i.strDescription
					,pl.strParentLotNumber
					,l.strVendorLotNo
					,(
						SELECT Min(L1.dtmDateCreated)
						FROM tblICLot L1
						WHERE L1.strLotNumber = l.strLotNumber
						) AS dtmDateCreated
					,ISNULL(i.strMaterialSizeCode, '') AS strMaterialSizeCode
				FROM tblICLot l
				JOIN dbo.tblICItem i ON i.intItemId = l.intItemId
				JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId
				JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
				JOIN tblICParentLot pl ON pl.intParentLotId = l.intParentLotId
				LEFT JOIN tblICItemUOM iu1 ON iu1.intItemUOMId = l.intWeightUOMId
				LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = (
						CASE 
							WHEN l.intWeightUOMId IS NULL
								THEN i.intWeightUOMId
							ELSE iu1.intUnitMeasureId
							END
						)
				WHERE l.strLotNumber IN (
						SELECT Item COLLATE DATABASE_DEFAULT
						FROM dbo.fnSplitString(@strLotNo, '^')
						)
					AND l.dblQty > 0
				) AS DT
				,@tblMFNoOfLabel
			ORDER BY DT.strParentLotNumber
		END
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspMFReportLotLabel - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
