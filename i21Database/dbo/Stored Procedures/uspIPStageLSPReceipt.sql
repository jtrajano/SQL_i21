CREATE PROCEDURE [dbo].[uspIPStageLSPReceipt]
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
	DECLARE @strPartnerNo nvarchar(100)

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	Select @strPartnerNo = RCVPRN 
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/EDI_DC40', 2) WITH ( 
		RCVPRN NVARCHAR(100)
	)

	--Receipt
	INSERT INTO tblIPReceiptStage(
		  strDeliveryNo
		 ,strExternalRefNo
		 ,dtmReceiptDate
		 ,strPartnerNo
		)
	SELECT   VBELN
			,LIFEX
			,CASE WHEN ISDATE(NTANF)=0 THEN NULL ELSE NTANF END
			,@strPartnerNo
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/E1EDL20/E1EDT13', 2) WITH (
			 VBELN NVARCHAR(100) '../VBELN' 
			,LIFEX NVARCHAR(100) '../LIFEX' 
			,NTANF DATETIME 
			)

	--Receipt Items
	Insert Into tblIPReceiptItemStage(
		intStageReceiptId
		,strDeliveryItemNo
		,strItemNo
		,strSubLocation
		,strStorageLocation
		,strBatchNo
		,dblQuantity
		,strUOM
		,strHigherPositionRefNo
	)
	SELECT 	 s.intStageReceiptId
			,POSNR  
			,RIGHT(MATNR,8)  
			,WERKS  
			,LGORT  
			,CHARG  
			,CASE WHEN ISNUMERIC(LFIMG)=1 THEN CAST(LFIMG AS NUMERIC(38,20)) ELSE 0.0 END
			,VRKME  
			,HIPOS 
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/E1EDL20/E1EDL24', 2) WITH (
			 VBELN NVARCHAR(100) COLLATE Latin1_General_CI_AS '../VBELN' 
			,POSNR  NVARCHAR(100)
			,MATNR  NVARCHAR(100)
			,WERKS  NVARCHAR(100)
			,LGORT  NVARCHAR(100)
			,CHARG  NVARCHAR(100)
			,LFIMG  NVARCHAR(100)
			,VRKME  NVARCHAR(100)
			,HIPOS  NVARCHAR(100)
			) x Join tblIPReceiptStage s on x.VBELN=s.strDeliveryNo

	--Containers
	Insert Into tblIPReceiptItemContainerStage(
		 intStageReceiptId
		,strContainerNo
		,strContainerSize
		,strDeliveryNo
		,strDeliveryItemNo
		,dblQuantity
		,strUOM
	)
	SELECT 	 s.intStageReceiptId
			,EXIDV   
			,VHILM  
			,VBELN   
			,POSNR   
			,CASE WHEN ISNUMERIC(VEMNG)=1 THEN CAST(VEMNG AS NUMERIC(38,20)) ELSE 0.0 END   
			,VEMEH   
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44', 2) WITH (
			 EXIDV   NVARCHAR(100) '../EXIDV' 
			,VHILM   NVARCHAR(100) '../VHILM' 
			,VBELN   NVARCHAR(100) COLLATE Latin1_General_CI_AS
			,POSNR   NVARCHAR(100)
			,VEMNG   NVARCHAR(100)
			,VEMEH   NVARCHAR(100)
			) x Join tblIPReceiptStage s on x.VBELN=s.strDeliveryNo

	Select TOP 1 strDeliveryNo AS strInfo1, '' strInfo2 From tblIPReceiptStage

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