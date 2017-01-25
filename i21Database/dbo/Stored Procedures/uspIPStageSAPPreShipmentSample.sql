CREATE PROCEDURE [dbo].[uspIPStageSAPPreShipmentSample]
	@strXml nvarchar(max)
AS

BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
		
	DECLARE @idoc INT
	DECLARE @ErrMsg nvarchar(max)
	DECLARE @strSessionId nvarchar(50)=NEWID()

	Set @strXml= REPLACE(@strXml,'utf-8','utf-16')

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	Insert Into tblIPPreShipmentSampleStage(dtmSampleDate,strPOItemNo,strItemNo,dblQuantity,strUOM,strSampleNo,strReferenceNo,strStatus,strLotNo,strSessionId)
	SELECT   DATUM + ' ' + (select STUFF(STUFF(REPLICATE('0',6-LEN(ISNULL(UZEIT,''))) + convert(VARCHAR(6),ISNULL(UZEIT,'')),3,0,':'),6,0,':'))
			,POSNR
			,ITEMNUM
			,QUANTITY
			,UNIT
			,BELNR
			,IHREZ
			,SSFBIN
			,INSPECTION_LOT
			,@strSessionId
	FROM OPENXML(@idoc, 'QALITY02/IDOC/E1EDLIN', 2) WITH (
			 DATUM NVARCHAR(50) '../E1EDK03/DATUM'
			,UZEIT NVARCHAR(50) '../E1EDK03/UZEIT'
			,POSNR NVARCHAR(100) '../E1EDK02/POSNR'
			,ITEMNUM NVARCHAR(100)
			,QUANTITY NUMERIC(38,20)
			,UNIT NVARCHAR(50)
			,BELNR NVARCHAR(100) 'E1EDP02/BELNR'
			,IHREZ NVARCHAR(100) 'E1EDP02/IHREZ'
			,SSFBIN NVARCHAR(100) 'E1DSIGN/SSFBIN'
			,INSPECTION_LOT NVARCHAR(100) 'E1CCI01/INSPECTION_LOT'
			)

	Update tblIPPreShipmentSampleStage Set strPONo= 
	(
		Select 	BELNR			
			FROM OPENXML(@idoc, 'QALITY02/IDOC/E1EDK02', 2) WITH (
				BELNR NVARCHAR(100)
			)
	) Where strSessionId=@strSessionId

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