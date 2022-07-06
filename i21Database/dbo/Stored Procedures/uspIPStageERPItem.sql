CREATE PROCEDURE uspIPStageERPItem @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Item'
		AND intStatusId IS NULL

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM @tblIPIDOCXMLStage

	IF @intRowNo IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId

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

			INSERT INTO tblIPItemStage (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreated
				,strCreatedUserName
				,strItemNo
				,strDescription
				,strShortName
				,strCommodity
				,strCategoryCode
				,strLotTracking
				,intLifeTime
				,strLifeTimeType
				,strItemStatus
				,ysnFairTradeCompliance
				,ysnOrganicItem
				,ysnRainForestCertified
				,strExternalGroup
				,strOrigin
				,strProductType
				,ysnOtherChargeItem
				)
			OUTPUT INSERTED.strItemNo
			INTO @tblIPItem
			SELECT TrxSequenceNo
				,CompanyLocation
				,ActionId
				,CreatedDate
				,CreatedByUser
				,ItemNo
				,[Description]
				,ShortName
				,CommodityCode
				,CategoryCode
				,CASE 
					WHEN LotTracking = '1'
						THEN 'Yes - Manual'
					WHEN LotTracking = '2'
						THEN 'Yes - Serial Number'
					WHEN LotTracking = '3'
						THEN 'Yes - Manual/Serial Number'
					WHEN LotTracking = '4'
						THEN 'No'
					END AS LotTracking
				,[LifeTime]
				,CASE 
					WHEN LifeTimeUnit = '1'
						THEN 'Days'
					WHEN LifeTimeUnit = '2'
						THEN 'Months'
					WHEN LifeTimeUnit = '3'
						THEN 'Years'
					END AS LifeTimeUnit
				,(
					CASE 
						WHEN [Status] = '1'
							THEN 'Active'
						WHEN [Status] = '2'
							THEN 'Phased Out'
						WHEN [Status] = '3'
							THEN 'Discontinued'
						END
					)
				,FairTradeCompliance
				,OrganicItem
				,RainForestCertified
				,ExternalGroup
				,Origin
				,ProductType
				,OtherChargeItem
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
					,CompanyLocation NVARCHAR(6)
					,ActionId INT
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					,ItemNo NVARCHAR(50)
					,[Description] NVARCHAR(100)
					,ShortName NVARCHAR(50)
					,CommodityCode NVARCHAR(50)
					,CategoryCode NVARCHAR(50)
					,LotTracking NVARCHAR(50)
					,[LifeTime] INT
					,LifeTimeUnit NVARCHAR(50)
					,[Status] NVARCHAR(50)
					,FairTradeCompliance INT
					,OrganicItem INT
					,RainForestCertified INT
					,ExternalGroup NVARCHAR(50)
					,Origin NVARCHAR(100)
					,ProductType NVARCHAR(50)
					,OtherChargeItem INT
					) x

			SELECT @strInfo1 = @strInfo1 + ISNULL(strItemNo, '') + ','
			FROM @tblIPItem

			INSERT INTO tblIPItemUOMStage (
				intStageItemId
				,strItemNo
				,strUOM
				,dblNumerator
				,dblDenominator
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,ysnStockUnit
				)
			SELECT (
					SELECT TOP 1 intStageItemId
					FROM tblIPItemStage
					WHERE strItemNo = x.ItemNo
					)
				,ItemNo
				,UOM
				,UnitQty
				,1
				,TrxSequenceNo
				,parentId
				,IsStockUOM
			FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
					ItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS '../ItemNo'
					,UOM NVARCHAR(50)
					,UnitQty NUMERIC(18, 6)
					,TrxSequenceNo BIGINT
					,parentId BIGINT '@parentId'
					,IsStockUOM INT
					) x

			UPDATE IUOM
			SET IUOM.intStageItemId = I.intStageItemId
			FROM tblIPItemStage I
			JOIN tblIPItemUOMStage IUOM ON IUOM.intParentTrxSequenceNo = I.intTrxSequenceNo

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
				,1
				,0
				,@ErrMsg
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
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
		FROM @tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
	END

	UPDATE S
	SET S.intStatusId = NULL
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId
	WHERE S.intStatusId = - 1

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
