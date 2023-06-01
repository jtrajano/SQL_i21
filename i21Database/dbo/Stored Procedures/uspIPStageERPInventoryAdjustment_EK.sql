CREATE PROCEDURE [dbo].[uspIPStageERPInventoryAdjustment_EK] @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
				,strNewLocation
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
							8
							)
						THEN ''
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
									THEN - Convert(NUMERIC(18, 6), Quantity)
								WHEN TransactionType = 20
									THEN Convert(NUMERIC(18, 6), NetWeight)
								ELSE Convert(NUMERIC(18, 6), Quantity)
								END
							)
					END
				,CASE WHEN TransactionType = 20 THEN NetWeightUOM ELSE QuantityUOM END
				,CASE 
					WHEN NetWeight = ''
						THEN NULL
					ELSE (
							CASE 
								WHEN TransactionType = 8
									THEN - Convert(NUMERIC(18, 6), NetWeight)
								ELSE Convert(NUMERIC(18, 6), NetWeight)
								END
							)
					END
				,CASE 
					WHEN TransactionType = 12
						AND NewLocation = 1711
						AND NetWeightUOM = 'KG'
						THEN 'LB'
					WHEN TransactionType = 12
						AND NewLocation <> 1711
						AND NetWeightUOM = 'LB'
						THEN 'KG'
					ELSE NetWeightUOM
					END
				,Status
				,ReasonCode
				,Notes
				,NewLocation
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
					,Status NVARCHAR(50)
					,ReasonCode NVARCHAR(50)
					,Notes NVARCHAR(2048)
					,SourceLocation NVARCHAR(50)
					,SourceStorageLocation NVARCHAR(50)
					,SourceStorageUnit NVARCHAR(50)
					,NewLocation NVARCHAR(50)
					,NewStorageLocation NVARCHAR(50)
					,NewStorageUnit NVARCHAR(50)
					,OrderNo NVARCHAR(50)
					,OrderCompleted INTEGER
					,ExpiryDate DATETIME
					)
			ORDER BY TransactionType DESC
				,OrderNo
				,Notes
				,12

			UPDATE b
			SET strCompanyLocation = a.strCompanyLocation
				,strStorageLocation = a.strStorageLocation
			FROM tblIPInventoryAdjustmentStage a
			JOIN tblIPInventoryAdjustmentStage b ON a.strNotes = b.strNotes
				AND a.strLotNo = b.strLotNo
			WHERE a.intTransactionTypeId = 12
				AND b.intTransactionTypeId = 12
				AND a.dblQuantity < 0
				AND b.dblQuantity > 0
				AND b.strCompanyLocation = ''
				AND b.strStorageLocation = ''

			UPDATE b
			SET strCompanyLocation = a.strCompanyLocation
				,strStorageLocation = a.strStorageLocation
			FROM tblIPInventoryAdjustmentArchive  a
			JOIN tblIPInventoryAdjustmentStage b ON a.strNotes = b.strNotes
				AND a.strLotNo = b.strLotNo
			WHERE a.intTransactionTypeId = 12
				AND b.intTransactionTypeId = 12
				AND a.dblQuantity < 0
				AND b.dblQuantity > 0
				AND b.strCompanyLocation = ''
				AND b.strStorageLocation = ''

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
