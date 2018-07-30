CREATE PROCEDURE uspIPStageSAPItems_HE @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@dtmCreatedDate DATETIME
		,@strItemType NVARCHAR(50)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblItem TABLE (
		strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strDescription NVARCHAR(250) COLLATE Latin1_General_CI_AS
		,strProductType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strStockUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strItemType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strMarkForDeletion NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblItemUOM TABLE (
		strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Item'

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@dtmCreatedDate = NULL
				,@strItemType = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			DELETE
			FROM @tblItem

			DELETE
			FROM @tblItemUOM

			SELECT @strXml = strXml
				,@dtmCreatedDate = dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			INSERT INTO @tblItem (
				strItemNo
				,strProductType
				,strStockUOM
				,strItemType
				,strMarkForDeletion
				)
			SELECT MATNR
				,MATKL
				,MEINS
				,MTART
				,LVORM
			FROM OPENXML(@idoc, 'MATMAS/IDOC/E1MARAM', 2) WITH (
					MATNR NVARCHAR(50)
					,MATKL NVARCHAR(100)
					,MEINS NVARCHAR(50)
					,MTART NVARCHAR(50)
					,LVORM NVARCHAR(50)
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strItemNo, '') + ','
			FROM @tblItem

			UPDATE @tblItem
			SET strDescription = x.MAKTX
			FROM OPENXML(@idoc, 'MATMAS/IDOC/E1MARAM/E1MAKTM', 2) WITH (
					MATNR NVARCHAR(50) COLLATE Latin1_General_CI_AS '../MATNR'
					,MAKTX NVARCHAR(250)
					,SPRAS NVARCHAR(50)
					) x
			JOIN @tblItem i ON x.MATNR = i.strItemNo
			WHERE x.SPRAS = 'E'

			IF NOT EXISTS (
					SELECT 1
					FROM @tblItem
					)
				RAISERROR (
						'Xml tag (MATMAS/IDOC/E1MARAM) not found.'
						,16
						,1
						)

			IF EXISTS (
					SELECT strItemNo
					FROM @tblItem
					WHERE LEN(strItemNo) < 9
					)
				RAISERROR (
						'Item contains less than 9 characters.'
						,16
						,1
						)

			INSERT INTO @tblItemUOM (
				strItemNo
				,strUOM
				)
			SELECT MATNR
				,MEINS
			FROM OPENXML(@idoc, 'MATMAS/IDOC/E1MARAM', 2) WITH (
					MATNR NVARCHAR(50)
					,MEINS NVARCHAR(50)
					) x
			WHERE ISNULL(x.MEINS, '') <> ''

			-- Item no data manipulation
			UPDATE @tblItem
			SET strItemNo = SUBSTRING(strItemNo, 1, LEN(strItemNo) - 8) + '-' + RIGHT(SUBSTRING(strItemNo, 1, LEN(strItemNo) - 3), 5) + '-' + RIGHT(strItemNo, 3)

			UPDATE @tblItemUOM
			SET strItemNo = SUBSTRING(strItemNo, 1, LEN(strItemNo) - 8) + '-' + RIGHT(SUBSTRING(strItemNo, 1, LEN(strItemNo) - 3), 5) + '-' + RIGHT(strItemNo, 3)

			-- Fill Item Type as 'commodity'
			SELECT @strItemType = strCategoryCode
			FROM tblICCategory
			WHERE LOWER(strCategoryCode) = 'commodity'

			IF ISNULL(@strItemType, '') = ''
				RAISERROR (
						'Category Code ''Commodity'' is not available.'
						,16
						,1
						)

			--Add to Staging tables
			INSERT INTO tblIPItemStage (
				strItemNo
				,strDescription
				,strProductType
				,strStockUOM
				,strItemType
				,ysnDeleted
				,dtmCreated
				)
			SELECT strItemNo
				,strDescription
				,strProductType
				,strStockUOM
				,@strItemType
				,CASE 
					WHEN ISNULL(strMarkForDeletion, '') = 'X'
						THEN 1
					ELSE 0
					END
				,@dtmCreatedDate
			FROM @tblItem

			INSERT INTO tblIPItemUOMStage (
				intStageItemId
				,strItemNo
				,strUOM
				,dblNumerator
				,dblDenominator
				)
			SELECT I.intStageItemId
				,I.strItemNo
				,IU.strUOM
				,1
				,1
			FROM @tblItemUOM IU
			JOIN tblIPItemStage I ON IU.strItemNo = I.strItemNo

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPIDOCXMLError (
				strXml
				,strType
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,@ErrMsg
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'Item'
	END

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF @strFinalErrMsg <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
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
