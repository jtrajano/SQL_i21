CREATE PROCEDURE [dbo].[uspIPStageSAPStock]
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

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	DECLARE @tblStock TABLE (
	[strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSubLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strStockType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblQuantity] NUMERIC(38,20)
	)

	INSERT INTO @tblStock (
		strItemNo
		,strSubLocation
		,strStockType
		,dblQuantity
		)
	SELECT MATNR
		,WERKS
		,DELKZ
		,MNG01
	FROM OPENXML(@idoc, 'LOISTD01/IDOC/E1MDSTL', 2) WITH (
			 MATNR NVARCHAR(100) 
			,WERKS NVARCHAR(100) 
			,DELKZ NVARCHAR(50) 'E1PLSEL/E1MDPSL/DELKZ'
			,MNG01 NUMERIC(38,20) 'E1PLSEL/E1MDPSL/MNG01'
			)

	If NOT Exists (Select 1 From @tblStock)
		RaisError('Unable to process. Xml tag (LOISTD01/IDOC/E1MDSTL) not found.',16,1)

	--Add to Staging tables
	Insert into tblIPStockStage(strItemNo,strSubLocation,strStockType,dblQuantity,strSessionId)
	Select strItemNo,strSubLocation,strStockType,dblQuantity,@strSessionId
	From @tblStock Where UPPER(strStockType) like 'WB%' OR UPPER(strStockType) like 'KB%' OR UPPER(strStockType) like 'LK%'

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