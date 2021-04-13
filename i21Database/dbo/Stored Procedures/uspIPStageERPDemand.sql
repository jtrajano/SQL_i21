CREATE PROCEDURE [dbo].[uspIPStageERPDemand] @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblIPDemand TABLE (strDemandName NVARCHAR(MAX))
	DECLARE @tblIPFinalDemand TABLE (strDemandName NVARCHAR(MAX))
	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Demand'

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
			FROM @tblIPDemand

			INSERT INTO dbo.tblIPDemandStage (
				intTrxSequenceNo
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strDemandName
				,intLineTrxSequenceNo
				,strCompanyLocation
				,strItemNo
				,dblQuantity
				,strQuantityUOM
				,dtmDemandDate
				)
			OUTPUT INSERTED.strDemandName
			INTO @tblIPDemand
			SELECT ParentTrxSequenceNo
				,ActionId
				,CreatedDate
				,CreatedBy
				,DemandName
				,TrxSequenceNo
				,CompanyLocation
				,ItemNo
				,Quantity
				,QuantityUOM
				,DemandDate
			FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
					ParentTrxSequenceNo INT '@ParentTrxSequenceNo'
					,ActionId INT '../ActionId'
					,CreatedDate DATETIME '../CreatedDate'
					,CreatedBy NVARCHAR(50) '../CreatedBy'
					,DemandName NVARCHAR(50) '../DemandName'
					,TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,ItemNo NVARCHAR(50)
					,Quantity NUMERIC(18, 6)
					,QuantityUOM NVARCHAR(50)
					,DemandDate DATETIME
					)

			INSERT INTO @tblIPFinalDemand
			SELECT DISTINCT strDemandName
			FROM @tblIPDemand

			SELECT @strInfo1 = @strInfo1 + ISNULL(strDemandName, '') + ','
			FROM @tblIPFinalDemand

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

			INSERT INTO dbo.tblIPInitialAck (
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
				,CreatedBy
				,9 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedBy NVARCHAR(50)
					)
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'Demand'
	END

	IF ISNULL(@strInfo1, '') <> ''
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
