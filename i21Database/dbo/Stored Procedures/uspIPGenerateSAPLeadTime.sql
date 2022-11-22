CREATE PROCEDURE dbo.uspIPGenerateSAPLeadTime (@ysnUpdateFeedStatus BIT = 1)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)



	SELECT '0' AS id
		,'<root><DocNo>930</DocNo><MsgType>Lead_Time</MsgType><Sender>iRely</Sender><Receiver>ICRON</Receiver><Header><Origin>Uganda</Origin><BuyingCenter>KEMB</BuyingCenter><StorageLocation>KA01</StorageLocation><Channel>NAC</Channel><PlantCode>5248</PlantCode><PlantDescription>LAMPA FOODS</PlantDescription><FromShippingUnit>KEMBA</FromShippingUnit><FromShipUnitDesc>MOMBASA</FromShipUnitDesc><ToShippingUnit>CLSAI</ToShippingUnit><ToShipUnitDesc>SAN ANTONIO</ToShipUnitDesc><P_S>15</P_S><P_P>16</P_P><P_MU>3</P_MU><MU_B>28</MU_B><SendDate>2022-09-16T00:00:00</SendDate></Header></root>' AS strXml
		,'MOMBASA' AS strInfo1
		,'SAN ANTONIO' AS strInfo2
		,'' AS strOnFailureCallbackSql
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
