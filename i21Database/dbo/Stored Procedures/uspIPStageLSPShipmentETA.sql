CREATE PROCEDURE [dbo].[uspIPStageLSPShipmentETA]
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

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	--Receipt
	INSERT INTO tblIPShipmentETAStage(
		 strDeliveryNo
		,dtmETA
		)
	SELECT   VBELN
			,CASE WHEN ISDATE(NTANF)=0 THEN NULL ELSE NTANF END
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/E1EDL20/E1EDL13', 2) WITH (
			 VBELN NVARCHAR(100) '../VBELN' 
			,NTANF DATETIME 
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