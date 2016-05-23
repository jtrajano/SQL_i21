
CREATE PROCEDURE uspICReportInventoryShipment 
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strLotNo NVARCHAR(100)
	DECLARE @xmlDocumentId INT
	DECLARE @strShipmentNo NVARCHAR(100)

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

	SELECT @strShipmentNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strShipmentNo'

	IF @strShipmentNo IS NOT NULL
	BEGIN
		SELECT SM.strLocationName [Ship From Address]
			,S.strShipmentNumber [Shipment Number]
			,CASE WHEN S.intOrderType=3 then
			ISNULL(SM.strLocationName,'')+' '+ ISNULL(SM.strAddress,'') + ' '+ISNULL(SM.strCity,'')+' '+ ISNULL(SM.strCountry,'') + ' ' + ISNULL(SM.strStateProvince,'')+' ' +ISNULL(SM.strZipPostalCode,'')
			ELSE
			ISNULL(E.strLocationName,'') +' '+ ISNULL(E.strAddress,'') +' '+ ISNULL(E.strCity,'') +' '+ ISNULL(E.strCountry,'') +' '+ ISNULL(E.strState,'') +' '+ ISNULL(E.strZipCode,'') 
			END [Ship To Address]
			,SO.strSalesOrderNumber [SalesOrder No]
			,I.strItemNo [Item No]
			,I.strDescription [Item]
			,UM.strUnitMeasure [UOM]
			,ISNULL(SI.dblQuantity,0) [Quantity]
			,'' [Pallets]
			, EN.strName
			, S.dtmShipDate
		FROM tblICInventoryShipment S
		LEFT JOIN tblICInventoryShipmentItem SI ON S.intInventoryShipmentId = SI.intInventoryShipmentId
		LEFT JOIN tblICItem I ON I.intItemId = SI.intItemId
		LEFT JOIN tblICItemUOM U ON SI.intItemUOMId = U.intItemUOMId
		LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = U.intUnitMeasureId
		LEFT JOIN tblEMEntityLocation E ON E.intEntityLocationId = S.intShipToLocationId
		LEFT JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = S.intShipToCompanyLocationId
		LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = SI.intOrderId
		LEFT JOIN tblEMEntity EN ON S.intEntityCustomerId = EN.intEntityId
		WHERE S.strShipmentNumber =@strShipmentNo
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspICReportInventoryShipment - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH


