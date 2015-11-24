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

	SELECT l.intItemId, 
		   l.dblWeight dblQty, 
		   l.strLotNumber, 
		   l.dblWeight, 
		   i.strItemNo, 
		   i.strDescription,
		   um.strUnitMeasure
	FROM dbo.tblICLot l
	INNER JOIN dbo.tblICItem i ON i.intItemId = l.intItemId
	INNER JOIN dbo.tblICItemUOM iu ON iu.intItemId = l.intItemId
	INNER JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
	WHERE iu.ysnStockUnit = 1 AND l.strLotNumber = @strLotNo 
	
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspMFReportLotLabel - ' + ERROR_MESSAGE()

	RAISERROR (@strErrMsg, 18, 1, 'WITH NOWAIT')
END CATCH