CREATE PROCEDURE uspIPStageSAPSample_ST @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
	DECLARE @tblSample TABLE (
		strERPPONumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strERPItemNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSAPPONumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strContainerNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strSampleNumber NVARCHAR(30) COLLATE Latin1_General_CI_AS
		,strSampleTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strVendor NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblQuantity NUMERIC(18, 6)
		,strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSampleRefNo NVARCHAR(30) COLLATE Latin1_General_CI_AS
		,strSampleNote NVARCHAR(512) COLLATE Latin1_General_CI_AS
		,strSampleStatus NVARCHAR(30) COLLATE Latin1_General_CI_AS
		,strRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strMarks NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strSamplingMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSubLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strCourier NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strCourierRef NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmCreated DATETIME
		,strSessionId NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblSampleTestResult TABLE (
		strSampleNumber NVARCHAR(30) COLLATE Latin1_General_CI_AS
		,strTestName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strActualValue NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,strTestComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		)
	DECLARE @intStageSampleId INT

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage WITH (NOLOCK)
	WHERE strType = 'QualitySample'

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
			FROM @tblSample

			DELETE
			FROM @tblSampleTestResult

			INSERT INTO @tblSample (
				strERPPONumber
				,strERPItemNumber
				,strContractNumber
				,strSAPPONumber
				,strContainerNumber
				,strSampleNumber
				,strSampleTypeName
				,strItemNo
				,strVendor
				,dblQuantity
				,strQuantityUOM
				,strSampleRefNo
				,strSampleNote
				,strSampleStatus
				,strRefNo
				,strMarks
				,strSamplingMethod
				,strSubLocationName
				,strCourier
				,strCourierRef
				,strComment
				,strCreatedBy
				,dtmCreated
				,strSessionId
				,strTransactionType
				)
			SELECT PO_NUMBER
				,PO_LINE_ITEM_NO
				,SO_NUMBER
				,ERP_PO_NUMBER
				,CONTAINER_NO
				,SAMPLE_NO
				,SAMPLE_TYPE
				,ITEM_NO
				,VENDOR
				,CASE 
					WHEN ISNUMERIC(QUANTITY) = 0
						THEN NULL
					ELSE QUANTITY
					END
				,QUANTITY_UOM
				,SAMPLE_REF_NO
				,SAMPLE_NOTE
				,SAMPLE_STATUS
				,REFERENCE_NO
				,MARKS
				,SAMPLING_METHOD
				,WAREHOUSE
				,COURIER
				,COURIER_REF
				,COMMENTS
				,CREATED_BY
				,CASE 
					WHEN ISDATE(CREATED_DATE) = 0
						OR CREATED_DATE = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE CREATED_DATE
					END
				,DOC_NO
				,MSG_TYPE
			FROM OPENXML(@idoc, 'ROOT/HEADER', 2) WITH (
					PO_NUMBER NVARCHAR(50)
					,PO_LINE_ITEM_NO NVARCHAR(50)
					,SO_NUMBER NVARCHAR(50)
					,ERP_PO_NUMBER NVARCHAR(100)
					,CONTAINER_NO NVARCHAR(100)
					,SAMPLE_NO NVARCHAR(30)
					,SAMPLE_TYPE NVARCHAR(50)
					,ITEM_NO NVARCHAR(50)
					,VENDOR NVARCHAR(50)
					,QUANTITY NUMERIC(18, 6)
					,QUANTITY_UOM NVARCHAR(50)
					,SAMPLE_REF_NO NVARCHAR(30)
					,SAMPLE_NOTE NVARCHAR(500)
					,SAMPLE_STATUS NVARCHAR(30)
					,REFERENCE_NO NVARCHAR(100)
					,MARKS NVARCHAR(100)
					,SAMPLING_METHOD NVARCHAR(50)
					,WAREHOUSE NVARCHAR(50)
					,COURIER NVARCHAR(50)
					,COURIER_REF NVARCHAR(50)
					,COMMENTS NVARCHAR(500)
					,CREATED_BY NVARCHAR(50)
					,CREATED_DATE DATETIME
					,DOC_NO INT '../CTRL_POINT/DOC_NO'
					,MSG_TYPE NVARCHAR(50) '../CTRL_POINT/MSG_TYPE'
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strSampleNumber, '') + ','
			FROM @tblSample

			SELECT @strInfo2 = @strInfo2 + ISNULL(strERPPONumber, '') + ' / ' + ISNULL(strERPItemNumber, '') + ','
			FROM @tblSample

			INSERT INTO @tblSampleTestResult (
				strSampleNumber
				,strTestName
				,strPropertyName
				,strActualValue
				,strTestComment
				)
			SELECT SAMPLE_NO
				,TEST_NAME
				,PROPERTY_NAME
				,ACTUAL_VALUE
				,TEST_COMMENT
			FROM OPENXML(@idoc, 'ROOT/TEST_RESULTS/TEST_RESULT', 2) WITH (
					SAMPLE_NO NVARCHAR(30) COLLATE Latin1_General_CI_AS '../../HEADER/SAMPLE_NO'
					,TEST_NAME NVARCHAR(50)
					,PROPERTY_NAME NVARCHAR(100)
					,ACTUAL_VALUE NVARCHAR(500)
					,TEST_COMMENT NVARCHAR(500)
					) x
			WHERE ISNULL(x.TEST_NAME, '') <> ''

			--Add to Staging tables
			INSERT INTO tblIPSampleStage (
				strERPPONumber
				,strERPItemNumber
				,strContractNumber
				,strSAPPONumber
				,strContainerNumber
				,strSampleNumber
				,strSampleTypeName
				,strItemNo
				,strVendor
				,dblQuantity
				,strQuantityUOM
				,strSampleRefNo
				,strSampleNote
				,strSampleStatus
				,strRefNo
				,strMarks
				,strSamplingMethod
				,strSubLocationName
				,strCourier
				,strCourierRef
				,strComment
				,strCreatedBy
				,dtmCreated
				,strSessionId
				,strTransactionType
				)
			SELECT strERPPONumber
				,strERPItemNumber
				,strContractNumber
				,strSAPPONumber
				,strContainerNumber
				,strSampleNumber
				,strSampleTypeName
				,strItemNo
				,strVendor
				,dblQuantity
				,strQuantityUOM
				,strSampleRefNo
				,strSampleNote
				,strSampleStatus
				,strRefNo
				,strMarks
				,strSamplingMethod
				,strSubLocationName
				,strCourier
				,strCourierRef
				,strComment
				,strCreatedBy
				,dtmCreated
				,strSessionId
				,strTransactionType
			FROM @tblSample

			SELECT @intStageSampleId = SCOPE_IDENTITY()

			INSERT INTO tblIPSampleTestResultStage (
				intStageSampleId
				,strSampleNumber
				,strTestName
				,strPropertyName
				,strActualValue
				,strTestComment
				)
			SELECT @intStageSampleId
				,strSampleNumber
				,strTestName
				,strPropertyName
				,strActualValue
				,strTestComment
			FROM @tblSampleTestResult

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
			AND strType = 'QualitySample'
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
