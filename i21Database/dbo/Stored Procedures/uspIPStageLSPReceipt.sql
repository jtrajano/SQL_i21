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
	DECLARE @intStageReceiptId int

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	--Receipt
	INSERT INTO tblIPReceiptStage(
		 strDeliveryNo
		,dtmReceiptDate
		)
	SELECT   VBELN
			,CASE WHEN ISDATE(NTANF)=0 THEN NULL ELSE NTANF END
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/E1EDL20/E1EDL13', 2) WITH (
			 VBELN NVARCHAR(100) '../VBELN' 
			,NTANF DATETIME 
			)

	Select @intStageReceiptId=SCOPE_IDENTITY()

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
	SELECT 	 @intStageReceiptId
			,POSNR  
			,MATNR  
			,WERKS  
			,LGORT  
			,CHARG  
			,LFIMG  
			,VRKME  
			,HIPOS 
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/E1EDL20/E1EDL24', 2) WITH (
			 POSNR  NVARCHAR(100)
			,MATNR  NVARCHAR(100)
			,WERKS  NVARCHAR(100)
			,LGORT  NVARCHAR(100)
			,CHARG  NVARCHAR(100)
			,LFIMG  NUMERIC(38,20)
			,VRKME  NVARCHAR(100)
			,HIPOS  NVARCHAR(100)
			)

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
	SELECT 	 @intStageReceiptId
			,EXIDV   
			,VHILM  
			,VBELN   
			,POSNR   
			,VEMNG   
			,VEMEH   
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44', 2) WITH (
			 EXIDV   NVARCHAR(100) '../EXIDV' 
			,VHILM   NVARCHAR(100) '../VHILM' 
			,VBELN   NVARCHAR(100)
			,POSNR   NVARCHAR(100)
			,VEMNG   NUMERIC(38,20)
			,VEMEH   NVARCHAR(100)
			)

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