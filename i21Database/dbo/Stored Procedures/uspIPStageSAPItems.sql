CREATE PROCEDURE [dbo].[uspIPStageSAPItems]
	@strXml nvarchar(max),
	@strSessionId NVARCHAR(50) =''
AS

BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
		
	DECLARE @idoc INT
	DECLARE @ErrMsg nvarchar(max)
	If ISNULL(@strSessionId,'')='' Set  @strSessionId=NEWID()

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	DECLARE @tblItem TABLE (
	 strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmCreatedDate DATETIME
	,strCreatedBy nvarchar(50) COLLATE Latin1_General_CI_AS
	,dtmModifiedDate DATETIME
	,strModifiedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMarkForDeletion NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strItemType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strStockUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strSKUItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strShortName NVARCHAR(250) COLLATE Latin1_General_CI_AS
	)

	DECLARE @tblItemUOM TABLE (
	  strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	 ,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	 ,dblNumerator NUMERIC(38,20)
	 ,dblDenominator NUMERIC(38,20)
	 )

	DECLARE @tblItemSubLocation TABLE (
	  strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	 ,strSubLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	 ,strMarkForDeletion NVARCHAR(50) COLLATE Latin1_General_CI_AS
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
		,CASE WHEN ISDATE(ERSDA)=0 THEN NULL ELSE ERSDA END
		,ERNAM
		,CASE WHEN ISDATE(LAEDA)=0 THEN NULL ELSE LAEDA END
		,AENAM
		,LVORM
		,MTART
		,MEINS
		,BMATN
	FROM OPENXML(@idoc, 'MATMAS03/IDOC/E1MARAM', 2) WITH (
			 MATNR NVARCHAR(50)
			,ERSDA NVARCHAR(50)
			,ERNAM NVARCHAR(50)
			,LAEDA NVARCHAR(50)
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
			  MATNR NVARCHAR(50) COLLATE Latin1_General_CI_AS '../MATNR'
			 ,MAKTX NVARCHAR(50)
			 ,SPRAS NVARCHAR(50)) x
			 Join @tblItem i on x.MATNR=i.strItemNo
		Where x.SPRAS='E'

	Insert Into @tblItemUOM(strItemNo,strUOM,dblNumerator,dblDenominator)
		SELECT MATNR
		,MEINH
		,UMREZ
		,UMREN
	FROM OPENXML(@idoc, 'MATMAS03/IDOC/E1MARAM/E1MARMM', 2) WITH (
			 MATNR NVARCHAR(50) '../MATNR'
			,MEINH NVARCHAR(50)
			,UMREZ NUMERIC(38,20)
			,UMREN NUMERIC(38,20)
	)

	Insert Into @tblItemSubLocation(strItemNo,strSubLocation,strMarkForDeletion)
		SELECT MATNR
		,WERKS
		,LVORM
	FROM OPENXML(@idoc, 'MATMAS03/IDOC/E1MARAM/E1MARCM', 2) WITH (
			 MATNR NVARCHAR(50) '../MATNR'
			,WERKS NVARCHAR(50)
			,LVORM NVARCHAR(50)
	)

	Begin Tran

	Update @tblItem set strItemNo=RIGHT(strItemNo,8)
	Update @tblItemUOM set strItemNo=RIGHT(strItemNo,8)
	Update @tblItemSubLocation set strItemNo=RIGHT(strItemNo,8)
	Update @tblItem set strSKUItemNo=RIGHT(strSKUItemNo,8)

	--ZCOM
	--Add to Staging tables
	Insert into tblIPItemStage(strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strDescription,strSessionId)
	Select strItemNo,dtmCreatedDate,strCreatedBy,dtmModifiedDate,strModifiedBy,CASE WHEN ISNULL(strMarkForDeletion,'')='X' THEN 1 ELSE 0 END,strItemType,strStockUOM,strSKUItemNo,strShortName,@strSessionId
	From @tblItem Where (RIGHT(strItemNo,8) like '496%' OR RIGHT(strItemNo,8) like '491%') AND strItemType='ZCOM'

	Insert Into tblIPItemUOMStage(intStageItemId,strItemNo,strUOM,dblNumerator,dblDenominator)
	Select i.intStageItemId,i.strItemNo,strUOM,dblNumerator,dblDenominator
	From @tblItemUOM iu Join tblIPItemStage i on iu.strItemNo=i.strItemNo
	Where (RIGHT(iu.strItemNo,8) like '496%' OR RIGHT(iu.strItemNo,8) like '491%') AND strItemType='ZCOM'

	Insert Into tblIPItemSubLocationStage(intStageItemId,strItemNo,strSubLocation,ysnDeleted)
	Select i.intStageItemId,i.strItemNo,strSubLocation,CASE WHEN ISNULL(strMarkForDeletion,'')='X' THEN 1 ELSE 0 END
	From @tblItemSubLocation iu Join tblIPItemStage i on iu.strItemNo=i.strItemNo
	Where (RIGHT(iu.strItemNo,8) like '496%' OR RIGHT(iu.strItemNo,8) like '491%') AND strItemType='ZCOM'

	--ZMPN
	Insert into tblIPItemStage(strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strDescription,strSessionId)
	Select strItemNo,dtmCreatedDate,strCreatedBy,dtmModifiedDate,strModifiedBy,CASE WHEN ISNULL(strMarkForDeletion,'')='X' THEN 1 ELSE 0 END,strItemType,strStockUOM,strSKUItemNo,strShortName,@strSessionId
	From @tblItem Where strItemType='ZMPN'

	Insert Into tblIPItemUOMStage(intStageItemId,strItemNo,strUOM,dblNumerator,dblDenominator)
	Select i.intStageItemId,i.strItemNo,strUOM,dblNumerator,dblDenominator
	From @tblItemUOM iu Join tblIPItemStage i on iu.strItemNo=i.strItemNo
	Where i.strItemType='ZMPN'

	Commit Tran

	Select TOP 1 strItemNo AS strInfo1,strItemType AS strInfo2,@strSessionId AS strSessionId From @tblItem

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