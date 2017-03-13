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
	DECLARE @strPartnerNo nvarchar(100)

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	Select @strPartnerNo = RCVPRN 
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/EDI_DC40', 2) WITH ( 
		RCVPRN NVARCHAR(100)
	)

	--ETA
	INSERT INTO tblIPShipmentETAStage(
		 strDeliveryNo
		,dtmETA
		,strPartnerNo
		)
	SELECT   VBELN
			,CASE WHEN ISDATE(NTANF)=0 THEN NULL ELSE NTANF END,@strPartnerNo
	FROM OPENXML(@idoc, 'DELVRY07/IDOC/E1EDL20/E1EDT13', 2) WITH (
			 VBELN NVARCHAR(100) '../VBELN' 
			,NTANF DATETIME
			,QUALF NVARCHAR(50) 
			) x
			Where x.QUALF='007'

	Select TOP 1 strDeliveryNo AS strInfo1,ISNULL(CONVERT(VARCHAR(10),dtmETA,121),'') AS strInfo2 From tblIPShipmentETAStage

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