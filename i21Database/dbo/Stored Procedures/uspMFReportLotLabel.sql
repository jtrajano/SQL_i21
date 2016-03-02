﻿CREATE PROCEDURE uspMFReportLotLabel
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strLotNo NVARCHAR(100), @xmlDocumentId INT
	DECLARE @intLotId INT

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE (
				[fieldname] NVARCHAR(50), 
				condition NVARCHAR(20), 
				[from] NVARCHAR(50), 
				[to] NVARCHAR(50), 
				[join] NVARCHAR(10), 
				[begingroup] NVARCHAR(50), 
				[endgroup] NVARCHAR(50), 
				[datatype] NVARCHAR(50))

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) 
	WITH ([fieldname] NVARCHAR(50), 
		  condition NVARCHAR(20), 
		  [from] NVARCHAR(50), 
		  [to] NVARCHAR(50), 
		  [join] NVARCHAR(10), 
		  [begingroup] NVARCHAR(50), 
		  [endgroup] NVARCHAR(50), 
		  [datatype] NVARCHAR(50))

	SELECT @strLotNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strLotNo'
	
	SELECT @intLotId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intLotId'

	IF ISNULL(@intLotId,0) <> 0 
	BEGIN
		SELECT l.intLotId,
			   l.intItemId, 
			   l.dblQty,
			   um.strUnitMeasure AS strQtyUOM,
			   l.dblWeight, 
			   um1.strUnitMeasure AS strWeightUOM,
			   l.strLotNumber, 
			   i.strItemNo, 
			   i.strDescription,
			   pl.strParentLotNumber
		FROM tblICLot l
		JOIN dbo.tblICItem i ON i.intItemId = l.intItemId
		JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
		LEFT JOIN tblICParentLot pl ON pl.intParentLotId = l.intParentLotId
		LEFT JOIN tblICItemUOM iu1 ON iu1.intItemUOMId = l.intWeightUOMId
		LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = iu1.intUnitMeasureId
		WHERE l.intLotId = @intLotId
	END
	ELSE
	BEGIN
		SELECT l.intLotId,
			   l.intItemId, 
			   l.dblQty,
			   um.strUnitMeasure AS strQtyUOM,
			   l.dblWeight, 
			   um1.strUnitMeasure AS strWeightUOM,
			   l.strLotNumber, 
			   i.strItemNo, 
			   i.strDescription,
			   pl.strParentLotNumber
		FROM tblICLot l
		JOIN dbo.tblICItem i ON i.intItemId = l.intItemId
		JOIN tblICItemUOM iu ON iu.intItemUOMId = l.intItemUOMId
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
		LEFT JOIN tblICParentLot pl ON pl.intParentLotId = l.intParentLotId
		LEFT JOIN tblICItemUOM iu1 ON iu1.intItemUOMId = l.intWeightUOMId
		LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = iu1.intUnitMeasureId
		WHERE l.strLotNumber = @strLotNo AND l.dblQty>0
	END	
	
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspMFReportLotLabel - ' + ERROR_MESSAGE()

	RAISERROR (@strErrMsg, 18, 1, 'WITH NOWAIT')
END CATCH