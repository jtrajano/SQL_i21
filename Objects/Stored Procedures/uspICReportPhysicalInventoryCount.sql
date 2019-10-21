CREATE PROCEDURE [dbo].[uspICReportPhysicalInventoryCount] @xmlParam NVARCHAR(MAX) = NULL
AS
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	IF ISNULL(@xmlParam, '') = ''
	BEGIN
		SELECT '' AS 'dtmCountDate'
		    ,'' AS 'strInvCountDesc'
		 	,'' AS 'strCountNo'
			,'' AS 'intLotId'
			,'' AS 'strLotName'
			,'' AS 'intLocationId'
			,'' AS 'strLocationName'
			,'' AS 'intSubLocationId'
			,'' AS 'strSubLocationName'
			,'' AS 'intStorageLocationId'
			,'' AS 'strStorageLocationName'
			,'' AS 'strStorageUnitNo'
			,'' AS 'intItemId'
			,'' AS 'strItemNo'
			,'' AS 'strItemDesc'
			,'' AS 'intItemUOMId'
			,'' AS 'strUnitMeasure'
			,'' AS 'dblPallets'
			,'' AS 'dblQtyPerPallet'
			,'' AS 'strCountLine'
			,'' AS 'ysnScannedCountEntry'
			,'' AS 'ysnCountByLots'
			,'' AS 'ysnCountByPallets'
			,'' AS 'ysnIncludeOnHand'
			,'' AS 'dblOnHand'
			,'' AS 'dblPhysicalCount'
		RETURN
	END

	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT
	DECLARE @strCountNo NVARCHAR(100)

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

	SELECT @strCountNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCountNo'
	
	IF @strCountNo IS NOT NULL
	BEGIN
		SELECT *
		FROM (
			SELECT InvCount.dtmCountDate	
				   ,strInvCountDesc = InvCount.strDescription
				   ,InvCount.strCountNo 
				   ,InvCountDetail.intLotId
				   ,strLotName = 
								CASE 
									WHEN Lot.strLotAlias IS NULL OR Lot.strLotAlias=''
									THEN ISNULL(Lot.strLotNumber, '') 
									ELSE Lot.strLotNumber + ' / ' + Lot.strLotAlias
								END
				   ,InvCount.intLocationId
				   ,CompanyLocation.strLocationName
				   ,InvCountDetail.intSubLocationId
				   ,SubLocation.strSubLocationName
				   ,InvCountDetail.intStorageLocationId
				   ,strStorageLocationName = StorageLocation.strName
				   ,ItemLocation.strStorageUnitNo
				   ,InvCountDetail.intItemId
				   ,Item.strItemNo
				   ,strItemDesc = Item.strDescription
				   ,InvCountDetail.intItemUOMId
				   ,UnitMeasure.strUnitMeasure
				   ,InvCountDetail.dblPallets
				   ,InvCountDetail.dblQtyPerPallet
				   ,InvCountDetail.strCountLine
				   ,InvCount.ysnScannedCountEntry
				   ,InvCount.ysnCountByLots
				   ,InvCount.ysnCountByPallets
				   ,InvCount.ysnIncludeOnHand
				   ,dblOnHand = InvCountDetail.dblSystemCount
				   ,dblPhysicalCount = InvCountDetail.dblPhysicalCount --ISNULL(InvCountDetail.dblPallets, 0) * ISNULL(InvCountDetail.dblQtyPerPallet, 0) 
			FROM tblICInventoryCount InvCount 
				 LEFT JOIN tblICInventoryCountDetail InvCountDetail ON InvCount.intInventoryCountId = InvCountDetail.intInventoryCountId
				 LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = InvCountDetail.intItemLocationId
				 LEFT JOIN tblICItem Item ON InvCountDetail.intItemId = Item.intItemId
				 LEFT JOIN tblSMCompanyLocation CompanyLocation ON InvCount.intLocationId = CompanyLocation.intCompanyLocationId
				 LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON InvCountDetail.intSubLocationId = SubLocation.intCompanyLocationSubLocationId
				 LEFT JOIN tblICStorageLocation StorageLocation ON InvCountDetail.intStorageLocationId = StorageLocation.intStorageLocationId
				 LEFT JOIN tblICLot Lot ON InvCountDetail.intLotId = Lot.intLotId
				 LEFT JOIN tblICItemUOM ItemUOM ON InvCountDetail.intItemUOMId = ItemUOM.intItemUOMId
				 LEFT JOIN tblICUnitMeasure UnitMeasure ON ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
				
			) AS a
		WHERE strCountNo = @strCountNo 
		ORDER BY strSubLocationName ASC, strStorageLocationName ASC
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspICPhysicalInventoryCount - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH