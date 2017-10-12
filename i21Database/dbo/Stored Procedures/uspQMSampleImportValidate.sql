﻿CREATE PROCEDURE uspQMSampleImportValidate
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSampleImportId INT
		,@dtmSampleReceivedDate DATETIME
		,@strSampleNumber NVARCHAR(30)
		,@strItemShortName NVARCHAR(50)
		,@strSampleTypeName NVARCHAR(50)
		,@strVendorName NVARCHAR(100)
		,@strContractNumber NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
		,@strMarks NVARCHAR(100)
		,@dblSequenceQuantity NUMERIC(18, 6)
		,@strSampleStatus NVARCHAR(30)
		,@strPropertyName NVARCHAR(100)
		,@strPropertyValue NVARCHAR(MAX)
		,@strComment NVARCHAR(MAX)
		,@strResult NVARCHAR(20)
		,@intCreatedUserId INT
		,@dtmCreated DATETIME
	DECLARE @strPreviousErrMsg NVARCHAR(MAX) = ''
		,@strSampleRefNo NVARCHAR(30)
		,@intContractHeaderId INT
		,@strEntityName NVARCHAR(100)
		,@intItemId INT
		,@intCategoryId INT
		,@intSampleTypeId INT
		,@intProductId INT
		,@intContractDetailId INT

	BEGIN TRANSACTION

	DELETE
	FROM tblQMSampleImportError

	SELECT @intSampleImportId = MIN(intSampleImportId)
	FROM tblQMSampleImport

	WHILE (ISNULL(@intSampleImportId, 0) > 0)
	BEGIN
		SELECT @dtmSampleReceivedDate = NULL
			,@strSampleNumber = NULL
			,@strItemShortName = NULL
			,@strSampleTypeName = NULL
			,@strVendorName = NULL
			,@strContractNumber = NULL
			,@strContainerNumber = NULL
			,@strMarks = NULL
			,@dblSequenceQuantity = NULL
			,@strSampleStatus = NULL
			,@strPropertyName = NULL
			,@strPropertyValue = NULL
			,@strComment = NULL
			,@strResult = NULL
			,@intCreatedUserId = NULL
			,@dtmCreated = NULL
			,@strSampleRefNo = NULL
			,@intContractHeaderId = NULL
			,@strEntityName = NULL
			,@intItemId = NULL
			,@intCategoryId = NULL
			,@intSampleTypeId = NULL
			,@intProductId = NULL
			,@intContractDetailId = NULL

		SELECT @dtmSampleReceivedDate = CONVERT(DATETIME, dtmSampleReceivedDate, 101)
			,@strSampleNumber = strSampleNumber
			,@strSampleRefNo = strSampleNumber
			,@strItemShortName = strItemShortName
			,@strSampleTypeName = strSampleTypeName
			,@strVendorName = strVendorName
			,@strContractNumber = strContractNumber
			,@strContainerNumber = strContainerNumber
			,@strMarks = strMarks
			,@dblSequenceQuantity = dblSequenceQuantity
			,@strSampleStatus = strSampleStatus
			,@strPropertyName = strPropertyName
			,@strPropertyValue = strPropertyValue
			,@strComment = strComment
			,@strResult = strResult
			,@intCreatedUserId = intCreatedUserId
			,@dtmCreated = dtmCreated
		FROM tblQMSampleImport
		WHERE intSampleImportId = @intSampleImportId

		SELECT @strPreviousErrMsg = ''

		-- Sample No
		IF ISNULL(@strSampleRefNo, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Sample No. '
		ELSE
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM tblQMSample
					WHERE strSampleRefNo = @strSampleRefNo
					)
				SELECT @strPreviousErrMsg += 'Sample No already exists. '
		END

		-- Sample Date
		IF ISNULL(@dtmSampleReceivedDate, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Sample Date. '
		ELSE
		BEGIN
			IF ISDATE(@dtmSampleReceivedDate) = 0
				SELECT @strPreviousErrMsg += 'Invalid Sample Date. '
			ELSE
			BEGIN
				IF CONVERT(DATE, @dtmSampleReceivedDate) > CONVERT(DATE, GETDATE())
					SELECT @strPreviousErrMsg += 'Sample Date cannot be Future Date. '
			END
		END

		-- Item Short Name
		IF ISNULL(@strItemShortName, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Item Short Name. '
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblICItem
					WHERE strShortName = @strItemShortName
					)
				SELECT @strPreviousErrMsg += 'Invalid Item Short Name. '
			ELSE
			BEGIN
				SELECT @intItemId = intItemId
					,@intCategoryId = intCategoryId
				FROM tblICItem
				WHERE strShortName = @strItemShortName
			END
		END

		-- Sample Type
		IF ISNULL(@strSampleTypeName, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Sample Type. '
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblQMSampleType
					WHERE strSampleTypeName = @strSampleTypeName
					)
				SELECT @strPreviousErrMsg += 'Invalid Sample Type. '
			ELSE
			BEGIN
				SELECT @intSampleTypeId = intSampleTypeId
				FROM tblQMSampleType
				WHERE strSampleTypeName = @strSampleTypeName
			END
		END

		-- Quantity
		IF ISNUMERIC(@dblSequenceQuantity) = 0
			SELECT @strPreviousErrMsg += 'Invalid Quantity. '
		ELSE
		BEGIN
			IF @dblSequenceQuantity <= 0
				SELECT @strPreviousErrMsg += 'Invalid Quantity. '
		END

		-- Sample Status
		IF ISNULL(@strSampleStatus, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Sample Status. '
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblQMSampleStatus
					WHERE strStatus = @strSampleStatus
					)
				SELECT @strPreviousErrMsg += 'Invalid Sample Status. '
		END

		-- Contract No
		IF ISNULL(@strContractNumber, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Contract No. '
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblCTContractHeader
					WHERE strContractNumber = @strContractNumber
					)
				SELECT @strPreviousErrMsg += 'Invalid Contract No. '
			ELSE
			BEGIN
				SELECT @intContractHeaderId = CH.intContractHeaderId
					,@strEntityName = E.strName
				FROM tblCTContractHeader CH
				JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
				WHERE CH.strContractNumber = @strContractNumber
			END
		END

		-- Vendor
		IF ISNULL(@strVendorName, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Vendor. '
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM vyuCTEntity
					WHERE (
							strEntityType = 'Vendor'
							OR strEntityType = 'Customer'
							)
						AND strEntityName = @strVendorName
					)
				SELECT @strPreviousErrMsg += 'Invalid Vendor. '
			ELSE
			BEGIN
				IF @strVendorName <> @strEntityName
					SELECT @strPreviousErrMsg += 'Vendor does not belongs to the Contract. '
			END
		END

		-- Property Name and Value
		IF ISNULL(@strPropertyName, '') = ''
			SELECT @strPreviousErrMsg += 'Invalid Property Name. '
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblQMProperty
					WHERE strPropertyName = @strPropertyName
					)
				SELECT @strPreviousErrMsg += 'Invalid Property Name. '
			ELSE
			BEGIN
				IF ISNULL(@strPropertyValue, '') <> ''
				BEGIN
					DECLARE @intDataTypeId INT = 0

					SELECT @intDataTypeId = intDataTypeId
					FROM tblQMProperty
					WHERE strPropertyName = @strPropertyName

					IF @intDataTypeId = 1 -- Integer
					BEGIN
						IF (@strPropertyValue LIKE '%[^0-9]%')
							SELECT @strPreviousErrMsg += 'Property Value should be Whole Number. '
					END
					ELSE IF @intDataTypeId = 2 -- Float
					BEGIN
						IF ISNUMERIC(@strPropertyValue) <> 1
							SELECT @strPreviousErrMsg += 'Property Value should be Whole Number / Decimal Number. '
						ELSE IF CONVERT(FLOAT, @strPropertyValue) < 0
							SELECT @strPreviousErrMsg += 'Property Value cannot be Negative. '
					END
					ELSE IF @intDataTypeId = 4 -- Bit
					BEGIN
						IF (
								LOWER(@strPropertyValue) NOT IN (
									'true'
									,'false'
									)
								)
							SELECT @strPreviousErrMsg += 'Property Value should be true / false. '
					END
					ELSE IF @intDataTypeId = 12 -- DateTime
					BEGIN
						IF ISDATE(@strPropertyValue) = 0
							SELECT @strPreviousErrMsg += 'Property Value should be a Date. '
					END
				END
			END
		END

		-- Result
		IF ISNULL(@strResult, '') <> ''
		BEGIN
			IF @strResult <> 'Passed'
				AND @strResult <> 'Failed'
				AND @strResult <> 'Marginal'
				SELECT @strPreviousErrMsg += 'Invalid Result. '
		END

		-- Contract Sequence Check
		IF ISNULL(@intContractHeaderId, 0) > 0
		BEGIN
			DECLARE @intCRowNo INT
				,@intCContractDetailId INT
				,@intCSampleTypeId INT
				,@intCSampleStatusId INT
			DECLARE @ContractDetail TABLE (
				intRowNo INT IDENTITY(1, 1)
				,intContractDetailId INT
				,dblQuantity NUMERIC(18, 6)
				)

			INSERT INTO @ContractDetail
			SELECT intContractDetailId
				,dblQuantity
			FROM tblCTContractDetail
			WHERE intContractHeaderId = @intContractHeaderId
			ORDER BY intContractSeq

			SELECT @intCRowNo = MIN(intRowNo)
			FROM @ContractDetail

			WHILE (ISNULL(@intCRowNo, 0) > 0)
			BEGIN
				SELECT @intCContractDetailId = NULL
					,@intCSampleTypeId = NULL
					,@intCSampleStatusId = NULL

				SELECT @intCContractDetailId = intContractDetailId
				FROM @ContractDetail
				WHERE intRowNo = @intCRowNo

				SELECT TOP 1 @intCSampleTypeId = S.intSampleTypeId
					,@intCSampleStatusId = S.intSampleStatusId
				FROM tblQMSample S
				JOIN tblQMSampleImportSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
				WHERE S.intContractDetailId = @intCContractDetailId
					AND S.intSampleStatusId = 3 -- Approved
				ORDER BY S.intSampleId DESC

				-- Sequence existing sample and quantity check
				IF ISNULL(@intCSampleTypeId, 0) > 0
				BEGIN
					SELECT @intContractDetailId = NULL
				END
				ELSE
				BEGIN
					SELECT @intContractDetailId = @intCContractDetailId

					BREAK
				END

				SELECT @intCRowNo = MIN(intRowNo)
				FROM @ContractDetail
				WHERE intRowNo > @intCRowNo
			END

			IF ISNULL(@intContractDetailId, 0) = 0
			BEGIN
				SELECT @strPreviousErrMsg += 'Contract already contains Sample. '
			END
			ELSE
			BEGIN
				DECLARE @dblCQuantity NUMERIC(18, 6)
				DECLARE @intSeqItemId INT
				DECLARE @strItemNo NVARCHAR(50)

				SELECT @dblCQuantity = CD.dblQuantity
					,@intSeqItemId = CD.intItemId
					,@strItemNo = I.strItemNo
				FROM tblCTContractDetail CD
				JOIN tblICItem I ON I.intItemId = CD.intItemId
				WHERE CD.intContractDetailId = @intContractDetailId

				IF @intItemId <> @intSeqItemId
					SELECT @strPreviousErrMsg += 'Item is not matching with Contract Sequence Item.(' + LTRIM(@strItemNo) + '). '

				IF ISNUMERIC(@dblSequenceQuantity) = 1
				BEGIN
					IF @dblSequenceQuantity > @dblCQuantity
						SELECT @strPreviousErrMsg += 'Quantity cannot be greater than Contract Sequence Quantity.(' + LTRIM(@dblCQuantity) + '). '
				END
			END
		END

		-- Template and Property Validation
		IF (
				ISNULL(@intItemId, 0) > 0
				AND ISNULL(@intSampleTypeId, 0) > 0
				)
		BEGIN
			SELECT @intProductId = (
					SELECT P.intProductId
					FROM tblQMProduct AS P
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
					WHERE P.intProductTypeId = 2 -- Item
						AND P.intProductValueId = @intItemId
						AND PC.intSampleTypeId = @intSampleTypeId
						AND P.ysnActive = 1
					)

			IF (
					@intProductId IS NULL
					AND ISNULL(@intCategoryId, 0) > 0
					)
				SELECT @intProductId = (
						SELECT P.intProductId
						FROM tblQMProduct AS P
						JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
						WHERE P.intProductTypeId = 1 -- Item Category
							AND P.intProductValueId = @intCategoryId
							AND PC.intSampleTypeId = @intSampleTypeId
							AND P.ysnActive = 1
						)

			IF @intProductId IS NULL
				SELECT @strPreviousErrMsg += 'Quality Template is not configured for the Item and Sample Type. '
			ELSE
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblQMProduct AS PRD
						JOIN tblQMProductProperty AS PP ON PP.intProductId = PRD.intProductId
						JOIN tblQMProductTest AS PT ON PT.intProductId = PP.intProductId
							AND PT.intProductId = PRD.intProductId
						JOIN tblQMTest AS T ON T.intTestId = PP.intTestId
							AND T.intTestId = PT.intTestId
						JOIN tblQMTestProperty AS TP ON TP.intPropertyId = PP.intPropertyId
							AND TP.intTestId = PP.intTestId
							AND TP.intTestId = T.intTestId
							AND TP.intTestId = PT.intTestId
						JOIN tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
							AND PRT.intPropertyId = TP.intPropertyId
						JOIN tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
						WHERE PRD.intProductId = @intProductId
							AND PRT.strPropertyName = @strPropertyName
						)
					SELECT @strPreviousErrMsg += 'Property is not available in the Template. '
			END
		END

		-- Check whether header fields values are same for a sample no
		IF (
				(
					SELECT COUNT(1) AS intCount
					FROM (
						SELECT DISTINCT CONVERT(DATETIME, dtmSampleReceivedDate, 101) dtmSampleReceivedDate
							,strItemShortName
							,strSampleTypeName
							,strVendorName
							,strContractNumber
							,strContainerNumber
							,strMarks
							,dblSequenceQuantity
							,strSampleStatus
						FROM tblQMSampleImport
						WHERE strSampleNumber = @strSampleNumber
						) t
					) > 1
				)
			SELECT @strPreviousErrMsg += 'Sample should have same values for the header fields. '

		-- Check whether a sample no contains the same property name multiple times
		IF EXISTS (
				SELECT 1
				FROM tblQMSampleImport
				WHERE strSampleNumber = @strSampleNumber
					AND strPropertyName = @strPropertyName
				GROUP BY strPropertyName
				HAVING COUNT(*) > 1
				)
			SELECT @strPreviousErrMsg += 'Sample contains same property name multiple times. '

		-- After all validation, insert / update the error
		IF ISNULL(@strPreviousErrMsg, '') <> ''
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM tblQMSampleImportError
					WHERE intSampleImportId = @intSampleImportId
					)
			BEGIN
				INSERT INTO tblQMSampleImportError (
					intSampleImportId
					,intConcurrencyId
					,dtmSampleReceivedDate
					,strSampleNumber
					,strItemShortName
					,strSampleTypeName
					,strVendorName
					,strContractNumber
					,strContainerNumber
					,strMarks
					,dblSequenceQuantity
					,strSampleStatus
					,strPropertyName
					,strPropertyValue
					,strComment
					,strResult
					,strErrorMsg
					,intCreatedUserId
					,dtmCreated
					)
				SELECT intSampleImportId
					,intConcurrencyId
					,CONVERT(DATETIME, dtmSampleReceivedDate, 101)
					,strSampleNumber
					,strItemShortName
					,strSampleTypeName
					,strVendorName
					,strContractNumber
					,strContainerNumber
					,strMarks
					,dblSequenceQuantity
					,strSampleStatus
					,strPropertyName
					,strPropertyValue
					,strComment
					,strResult
					,@strPreviousErrMsg
					,intCreatedUserId
					,dtmCreated
				FROM tblQMSampleImport
				WHERE intSampleImportId = @intSampleImportId
			END
			ELSE
			BEGIN
				UPDATE tblQMSampleImportError
				SET strErrorMsg = strErrorMsg + @strPreviousErrMsg
				WHERE intSampleImportId = @intSampleImportId
			END
		END

		SELECT @intSampleImportId = MIN(intSampleImportId)
		FROM tblQMSampleImport
		WHERE intSampleImportId > @intSampleImportId
	END

	SELECT intSampleImportErrorId
		,intSampleImportId
		,intConcurrencyId
		,CONVERT(DATETIME, dtmSampleReceivedDate, 101) dtmSampleReceivedDate
		,strSampleNumber
		,strItemShortName
		,strSampleTypeName
		,strVendorName
		,strContractNumber
		,strContainerNumber
		,strMarks
		,dblSequenceQuantity
		,strSampleStatus
		,strPropertyName
		,strPropertyValue
		,strComment
		,strResult
		,strErrorMsg
		,intCreatedUserId
		,dtmCreated
	FROM tblQMSampleImportError

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
