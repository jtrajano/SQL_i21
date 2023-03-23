﻿CREATE PROCEDURE [dbo].[uspIPStageERPInventoryAdjustment_EK] @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblIPLot TABLE (strLotNo NVARCHAR(250))
	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType IN (
			'Stock Adjustment'
			,'Stock Consumption'
			,'Stock Movement'
			,'Stock Transfer'
			)
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
			FROM @tblIPLot

			INSERT INTO dbo.tblIPInventoryAdjustmentStage (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,intTransactionTypeId
				,strStorageLocation
				,strItemNo
				,strMotherLotNo
				,strLotNo
				,strStorageUnit
				,dblQuantity
				,strQuantityUOM
				,dblNetWeight
				,strNetWeightUOM
				,strStatus
				,strReasonCode
				,strNotes
				,strNewStorageLocation
				,strNewStorageUnit
				,strOrderNo
				,intOrderCompleted
				,dtmExpiryDate
				,strTranferOrderStatus
				)
			OUTPUT INSERTED.strLotNo
			INTO @tblIPLot
			SELECT DocNo
				,CASE 
					WHEN TransactionType IN (
							12
							,20
							)
						THEN SourceLocation
					ELSE Location
					END
				,ActionId
				,IsNULL(CreatedDate, GETDATE())
				,CreatedBy
				,TransactionType
				,CASE 
					WHEN TransactionType IN (
							12
							,20
							)
						THEN SourceStorageLocation
					ELSE StorageLocation
					END
				,ItemNo
				,MotherLotNo
				,LotNo
				,CASE 
					WHEN TransactionType IN (
							12
							,20
							)
						THEN SourceStorageUnit
					ELSE StorageUnit
					END

				,CASE 
					WHEN Quantity = ''
						THEN NULL
					ELSE (
							CASE 
								WHEN TransactionType = 8
									THEN - Convert(numeric(18,6),Quantity)
								ELSE Convert(numeric(18,6),Quantity)
								END
							)
					END
				,QuantityUOM
				,CASE 
					WHEN NetWeight = ''
						THEN NULL
					ELSE (
							CASE 
								WHEN TransactionType = 8
									THEN - Convert(numeric(18,6),NetWeight)
								ELSE Convert(numeric(18,6),NetWeight)
								END
							)
					END
				,NetWeightUOM
				,STATUS
				,ReasonCode
				,Notes
				,NewStorageLocation
				,NewStorageUnit
				,OrderNo
				,OrderCompleted
				,ExpiryDate
				,CASE 
					WHEN TransactionType = 12
						THEN 'Open'
					ELSE NULL
					END
			FROM OPENXML(@idoc, 'root/Header', 2) WITH (
					DocNo BIGINT '../CtrlPoint/DocNo'
					,Location NVARCHAR(6)
					,ActionId INT
					,CreatedDate DATETIME
					,CreatedBy NVARCHAR(50)
					,TransactionType INT
					,StorageLocation NVARCHAR(50)
					,ItemNo NVARCHAR(50)
					,MotherLotNo NVARCHAR(50)
					,LotNo NVARCHAR(50)
					,StorageUnit NVARCHAR(50)
					,Quantity NVARCHAR(50)
					,QuantityUOM NVARCHAR(50)
					,NetWeight NVARCHAR(50)
					,NetWeightUOM NVARCHAR(50)
					,STATUS NVARCHAR(50)
					,ReasonCode NVARCHAR(50)
					,Notes NVARCHAR(2048)
					,SourceLocation NVARCHAR(50)
					,SourceStorageLocation NVARCHAR(50)
					,SourceStorageUnit NVARCHAR(50)
					,NewStorageLocation NVARCHAR(50)
					,NewStorageUnit NVARCHAR(50)
					,OrderNo NVARCHAR(50)
					,OrderCompleted INTEGER
					,ExpiryDate DATETIME
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strLotNo, '') + ','
			FROM @tblIPLot

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
				,(
					CASE 
						WHEN TransactionTypeId = 8 --(Consume)
							THEN 11
						WHEN TransactionTypeId = 10 --Inventory Adjustment - Quantity
							THEN 15
						WHEN TransactionTypeId = 20 --Inventory Adjustment - Lot Move
							THEN 14
						END
					) AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedBy NVARCHAR(50)
					,TransactionTypeId INT
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
