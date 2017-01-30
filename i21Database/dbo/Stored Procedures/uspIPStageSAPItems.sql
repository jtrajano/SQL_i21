CREATE PROCEDURE [dbo].[uspIPStageSAPItems]
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
	DECLARE @strItemNo NVARCHAR(50)
	DECLARE @intStageItemId int

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	DECLARE @tblItem TABLE (
	 strItemNo NVARCHAR(50)
	,dtmCreatedDate DATETIME
	,strCreatedBy nvarchar(50)
	,dtmModifiedDate DATETIME
	,strModifiedBy NVARCHAR(50)
	,strMarkForDeletion NVARCHAR(50)
	,strItemType NVARCHAR(50)
	,strStockUOM NVARCHAR(50)
	,strSKUItemNo NVARCHAR(50)
	,strShortName NVARCHAR(250)
	)

	DECLARE @tblItemUOM TABLE (
	 strUOM NVARCHAR(50)
	 ,dblNumerator NUMERIC(38,20)
	 ,dblDenominator NUMERIC(38,20)
	 )

	INSERT INTO @tblItem (
		strItemNo
		,dtmCreatedDate
		,strCreatedBy
		,dtmModifiedDate
		,strModifiedBy
		,strMarkForDeletion
		,strItemType
		,strStockUOM
		,strSKUItemNo
		)
	SELECT MATNR
		,ERSDA
		,ERNAM
		,LAEDA
		,AENAM
		,LVORM
		,MTART
		,MEINS
		,BMATN
	FROM OPENXML(@idoc, 'MATMAS03/IDOC/E1MARAM', 2) WITH (
			 MATNR NVARCHAR(50)
			,ERSDA DATETIME
			,ERNAM NVARCHAR(50)
			,LAEDA DATETIME
			,AENAM NVARCHAR(50)
			,LVORM NVARCHAR(50)
			,MTART NVARCHAR(50)
			,MEINS NVARCHAR(50)
			,BMATN NVARCHAR(50)
			)

	If NOT Exists (Select 1 From @tblItem)
		RaisError('Unable to process. Xml tag (MATMAS03/IDOC/E1MARAM) not found.',16,1)

	Update @tblItem Set strShortName=x.MAKTX
		FROM OPENXML(@idoc, 'MATMAS03/IDOC/E1MARAM/E1MAKTM', 2) WITH (
			 MAKTX NVARCHAR(50)
			 ,SPRAS_ISO NVARCHAR(50)) x
		Where x.SPRAS_ISO='EN'

	Insert Into @tblItemUOM(strUOM,dblNumerator,dblDenominator)
		SELECT MEINH
		,UMREZ
		,UMREN
	FROM OPENXML(@idoc, 'MATMAS03/IDOC/E1MARAM/E1MARMM', 2) WITH (
			 MEINH NVARCHAR(50)
			,UMREZ NUMERIC(38,20)
			,UMREN NUMERIC(38,20)
	)

	Select @strItemNo=strItemNo From @tblItem

	Begin Tran

	--Add to Staging tables
	Insert into tblIPItemStage(strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strDescription)
	Select strItemNo,dtmCreatedDate,strCreatedBy,dtmModifiedDate,strModifiedBy,CASE WHEN ISNULL(strMarkForDeletion,'')='X' THEN 1 ELSE 0 END,strItemType,strStockUOM,strSKUItemNo,strShortName
	From @tblItem

	Select @intStageItemId=SCOPE_IDENTITY()

	Insert Into tblIPItemUOMStage(intStageItemId,strItemNo,strUOM,dblNumerator,dblDenominator)
	Select @intStageItemId,@strItemNo,strUOM,dblNumerator,dblDenominator
	From @tblItemUOM

	Commit Tran

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

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