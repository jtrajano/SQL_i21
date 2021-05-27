﻿CREATE PROCEDURE uspIPStageERPRoute @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblIPItem TABLE (strItemNo NVARCHAR(50))
	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Route'

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblIPItem

			INSERT INTO tblIPItemRouteStage (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				)
			OUTPUT INSERTED.strItemNo
			INTO @tblIPItem
			SELECT TrxSequenceNo
				,CompanyLocation
				,ActionId
				,CreatedDate
				,CreatedByUser
				,ItemNo
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,ActionId INT
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					,ItemNo NVARCHAR(50)
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strItemNo, '') + ','
			FROM @tblIPItem

			INSERT INTO tblIPItemRouteDetailStage (
				intItemRouteStageId
				,strItemNo
				,strManufacturingCell
				,strStorageLocation
				,strManufacturingGroup
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				)
			SELECT (
					SELECT TOP 1 intItemRouteStageId
					FROM tblIPItemRouteStage
					WHERE strItemNo = x.ItemNo
					)
				,ItemNo
				,ManufacturingCell
				,StorageLocation
				,ManufacturingGroup
				,TrxSequenceNo
				,parentId
			FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
					ItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS '../ItemNo'
					,ManufacturingCell NVARCHAR(50)
					,StorageLocation NVARCHAR(50)
					,ManufacturingGroup NVARCHAR(50)
					,TrxSequenceNo INT
					,parentId INT '@parentId'
					) x

			UPDATE IRD
			SET IRD.intItemRouteStageId = IR.intItemRouteStageId
			FROM tblIPItemRouteStage IR
			JOIN tblIPItemRouteDetailStage IRD ON IRD.intParentTrxSequenceNo = IR.intTrxSequenceNo

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

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedByUser
				,3
				,0
				,@ErrMsg
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					)

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
			AND strType = 'Route'
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
