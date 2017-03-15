CREATE PROCEDURE [dbo].[uspIPStageSAPStock]
	@strXml nvarchar(max),
	@strSessionId nvarchar(50) = '' out
AS

BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
		
	DECLARE @idoc INT
	DECLARE @ErrMsg nvarchar(max)
	Set @strSessionId = NEWID()

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	DECLARE @tblStock TABLE (
	[strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSubLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strStockType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblInspectionQuantity] NUMERIC(38,20),
	[dblBlockedQuantity] NUMERIC(38,20),
	[dblQuantity] NUMERIC(38,20)
	)

	INSERT INTO @tblStock (
		strItemNo
		,strSubLocation
		,strStockType
		,dblInspectionQuantity
		,dblBlockedQuantity
		,dblQuantity
		)
	SELECT MATNR
		,WERKS
		,DELKZ
		,INSME
		,SPEME
		,MNG01
	FROM OPENXML(@idoc, 'LOISTD01/IDOC/E1MDSTL/E1PLSEL/E1MDPSL', 2) WITH (
			 MATNR NVARCHAR(100) '../../MATNR'
			,WERKS NVARCHAR(100) '../../WERKS'
			,DELKZ NVARCHAR(50) 
			,INSME NUMERIC(38,20) '../../INSME'
			,SPEME NUMERIC(38,20) '../../SPEME'
			,MNG01 NUMERIC(38,20) 
			)

	If NOT Exists (Select 1 From @tblStock)
		RaisError('Unable to process. Xml tag (LOISTD01/IDOC/E1MDSTL) not found.',16,1)

	--Add to Staging tables
	Insert into tblIPStockStage(strItemNo,strSubLocation,strStockType,dblInspectionQuantity,dblBlockedQuantity,dblQuantity,strSessionId)
	Select '0000000000' + strItemNo,strSubLocation,strStockType,dblInspectionQuantity,dblBlockedQuantity,dblQuantity,@strSessionId
	From @tblStock Where (UPPER(strStockType) like 'WB%' OR UPPER(strStockType) like 'KB%' OR UPPER(strStockType) like 'LK%')
	AND (RIGHT(strItemNo,8) like '496%' OR RIGHT(strItemNo,8) like '491%')

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