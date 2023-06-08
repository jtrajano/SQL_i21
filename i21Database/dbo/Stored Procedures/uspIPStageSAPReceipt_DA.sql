CREATE PROCEDURE uspIPStageSAPReceipt_DA @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblReceipt TABLE (
		strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmReceiptDate DATETIME
		,strBLNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmCreated DATETIME
		,strSessionId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblReceiptItem TABLE (
		strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strERPPONumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strERPItemNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,intContractSeq INT
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSubLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strStorageLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblQuantity NUMERIC(18, 6)
		,strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblGrossWeight NUMERIC(18, 6)
		,dblTareWeight NUMERIC(18, 6)
		,dblNetWeight NUMERIC(18, 6)
		,strNetWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblCost NUMERIC(18, 6)
		,strCostUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strCostCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strContainerNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,dblCleanGrossWeight NUMERIC(18, 6)
		,dblCleanTareWeight NUMERIC(18, 6)
		,dblCleanNetWeight NUMERIC(18, 6)
		,strCleanNetWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @intStageReceiptId INT

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage WITH (NOLOCK)
	WHERE strType = 'Goods Receipt'

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage WITH (NOLOCK)
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblReceipt

			DELETE
			FROM @tblReceiptItem

			INSERT INTO @tblReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,strBLNumber
				,strLocationName
				,strCreatedBy
				,dtmCreated
				,strSessionId
				,strTransactionType
				)
			SELECT RECEIPT_NO
				,CASE 
					WHEN ISDATE(RECEIPT_DATE) = 0
						OR RECEIPT_DATE = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE RECEIPT_DATE
					END
				,BOL_NO
				,LOCATION_NO
				,CREATED_BY
				,CASE 
					WHEN ISDATE(CREATE_DATE) = 0
						OR CREATE_DATE = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE CREATE_DATE
					END
				,DOC_NO
				,MSG_TYPE
			FROM OPENXML(@idoc, 'ROOT_RECEIPT/HEADER', 2) WITH (
					RECEIPT_NO NVARCHAR(50)
					,RECEIPT_DATE DATETIME
					,BOL_NO NVARCHAR(100)
					,LOCATION_NO NVARCHAR(50)
					,CREATED_BY NVARCHAR(50)
					,CREATE_DATE DATETIME
					,DOC_NO INT '../CTRL_POINT/DOC_NO'
					,MSG_TYPE NVARCHAR(50) '../CTRL_POINT/MSG_TYPE'
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strReceiptNumber, '') + ','
			FROM @tblReceipt

			INSERT INTO @tblReceiptItem (
				strReceiptNumber
				,strERPPONumber
				,strERPItemNumber
				,intContractSeq
				,strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
				,dblCleanGrossWeight
				,dblCleanTareWeight
				,dblCleanNetWeight
				,strCleanNetWeightUOM
				)
			SELECT RECEIPT_NO
				,PO_NUMBER
				,PO_LINE_ITEM_NO
				,CASE 
					WHEN ISNUMERIC(SEQUENCE_NO) = 0
						THEN NULL
					ELSE SEQUENCE_NO
					END
				,ITEM_NO
				,LOCATION_NO
				,SUB_LOCATION
				,STORAGE_LOCATION
				,CASE 
					WHEN ISNUMERIC(QUANTITY) = 0
						THEN NULL
					ELSE QUANTITY
					END
				,QUANTITY_UOM
				,CASE 
					WHEN ISNUMERIC(GROSS_WEIGHT) = 0
						THEN NULL
					ELSE GROSS_WEIGHT
					END
				,CASE 
					WHEN ISNUMERIC(TARE_WEIGHT) = 0
						THEN NULL
					ELSE TARE_WEIGHT
					END
				,CASE 
					WHEN ISNUMERIC(NET_WEIGHT) = 0
						THEN NULL
					ELSE NET_WEIGHT
					END
				,NET_WEIGHT_UOM
				,CASE 
					WHEN ISNUMERIC(COST) = 0
						THEN NULL
					ELSE COST
					END
				,COST_UOM
				,COST_CURRENCY
				,CONTAINER_NO
				,CASE 
					WHEN ISNUMERIC(CLEAN_GROSS_WEIGHT) = 0
						THEN NULL
					ELSE CLEAN_GROSS_WEIGHT
					END
				,CASE 
					WHEN ISNUMERIC(CLEAN_TARE_WEIGHT) = 0
						THEN NULL
					ELSE CLEAN_TARE_WEIGHT
					END
				,CASE 
					WHEN ISNUMERIC(CLEAN_NET_WEIGHT) = 0
						THEN NULL
					ELSE CLEAN_NET_WEIGHT
					END
				,CLEAN_NET_WEIGHT_UOM
			FROM OPENXML(@idoc, 'ROOT_RECEIPT/LINE_ITEM', 2) WITH (
					RECEIPT_NO NVARCHAR(50) COLLATE Latin1_General_CI_AS '../HEADER/RECEIPT_NO'
					,PO_NUMBER NVARCHAR(100)
					,PO_LINE_ITEM_NO NVARCHAR(100)
					,SEQUENCE_NO INT
					,ITEM_NO NVARCHAR(50)
					,LOCATION_NO NVARCHAR(50)
					,SUB_LOCATION NVARCHAR(50)
					,STORAGE_LOCATION NVARCHAR(50)
					,QUANTITY NVARCHAR(50)
					,QUANTITY_UOM NVARCHAR(50)
					,GROSS_WEIGHT NVARCHAR(50)
					,TARE_WEIGHT NVARCHAR(50)
					,NET_WEIGHT NVARCHAR(50)
					,NET_WEIGHT_UOM NVARCHAR(50)
					,COST NVARCHAR(50)
					,COST_UOM NVARCHAR(50)
					,COST_CURRENCY NVARCHAR(50)
					,CONTAINER_NO NVARCHAR(100)
					,CLEAN_GROSS_WEIGHT NVARCHAR(50)
					,CLEAN_TARE_WEIGHT NVARCHAR(50)
					,CLEAN_NET_WEIGHT NVARCHAR(50)
					,CLEAN_NET_WEIGHT_UOM NVARCHAR(50)
					) x
			--WHERE ISNULL(x.PO_NUMBER, '') <> ''

			SELECT @strInfo2 = @strInfo2 + ISNULL(strERPPONumber, '') + ' / ' + LTRIM(intContractSeq) + ','
			FROM @tblReceiptItem

			--Add to Staging tables
			INSERT INTO tblIPInvReceiptStage (
				strReceiptNumber
				,dtmReceiptDate
				,strBLNumber
				,strLocationName
				,strCreatedBy
				,dtmCreated
				,strSessionId
				,strTransactionType
				)
			SELECT strReceiptNumber
				,dtmReceiptDate
				,strBLNumber
				,strLocationName
				,strCreatedBy
				,dtmCreated
				,strSessionId
				,strTransactionType
			FROM @tblReceipt

			SELECT @intStageReceiptId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemStage (
				intStageReceiptId
				,strReceiptNumber
				,strERPPONumber
				,strERPItemNumber
				,intContractSeq
				,strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
				,dblCleanGrossWeight
				,dblCleanTareWeight
				,dblCleanNetWeight
				,strCleanNetWeightUOM
				)
			SELECT @intStageReceiptId
				,strReceiptNumber
				,strERPPONumber
				,strERPItemNumber
				,intContractSeq
				,strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,dbo.fnIPConvertSAPUOMToi21(strQuantityUOM)
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,dbo.fnIPConvertSAPUOMToi21(strNetWeightUOM)
				,dblCost
				,dbo.fnIPConvertSAPUOMToi21(strCostUOM)
				,strCostCurrency
				,strContainerNumber
				,dblCleanGrossWeight
				,dblCleanTareWeight
				,dblCleanNetWeight
				,strCleanNetWeightUOM
			FROM @tblReceiptItem

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
		FROM tblIPIDOCXMLStage WITH (NOLOCK)
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'Goods Receipt'
	END

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF (ISNULL(@strInfo2, '')) <> ''
		SELECT @strInfo2 = LEFT(@strInfo2, LEN(@strInfo2) - 1)

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
