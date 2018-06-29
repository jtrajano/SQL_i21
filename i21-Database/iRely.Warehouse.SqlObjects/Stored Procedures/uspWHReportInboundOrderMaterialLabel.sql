CREATE PROCEDURE uspWHReportInboundOrderMaterialLabel 
					@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strSKUNo NVARCHAR(100)
	DECLARE @xmlDocumentId INT
	
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
		  
	SELECT @strSKUNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strSKUNo'
	
	SELECT cl.strLocationName, 
		   i.strItemNo, 
		   i.strDescription, 
		   s.strLotCode, 
		   c.strContainerNo
	FROM tblWHContainer c
	INNER JOIN tblWHSKU s ON s.intContainerId = c.intContainerId
	INNER JOIN tblICItem i ON i.intItemId = s.intItemId
	INNER JOIN tblICStorageLocation sl ON sl.intStorageLocationId = c.intStorageLocationId
	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = sl.intLocationId
	WHERE strSKUNo = @strSKUNo
	
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspWHReportInboundOrderMaterialLabel - ' + ERROR_MESSAGE() 
	RAISERROR(@strErrMsg, 18, 1, 'WITH NOWAIT')
END CATCH