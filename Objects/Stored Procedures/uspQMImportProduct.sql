CREATE PROCEDURE uspQMImportProduct @intUserId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX) = ''
	DECLARE @intRowId INT
		,@strProductTypeName NVARCHAR(50)
		,@strProductValue NVARCHAR(50)
		,@strNote NVARCHAR(500)
		,@strUnitMeasure NVARCHAR(50)
		,@ysnActive BIT
		,@strApprovalLotStatus NVARCHAR(50)
		,@strRejectionLotStatus NVARCHAR(50)
		,@strBondedApprovalLotStatus NVARCHAR(50)
		,@strBondedRejectionLotStatus NVARCHAR(50)
		,@strSampleTypeName NVARCHAR(50)
		,@strTestName NVARCHAR(50)
		,@intProductTypeId INT
		,@intProductValueId INT
		,@intUnitMeasureId INT
		,@intApprovalLotStatusId INT
		,@intRejectionLotStatusId INT
		,@intBondedApprovalLotStatusId INT
		,@intBondedRejectionLotStatusId INT
		,@intSampleTypeId INT
		,@intTestId INT
		,@intProductId INT
		,@intControlPointId INT
		,@intSequenceNo INT

	IF ISNULL(@intUserId, 0) = 0
	BEGIN
		SELECT TOP 1 @intUserId = intEntityId
		FROM tblSMUserSecurity
		WHERE LOWER(strUserName) = 'irelyadmin'
	END

	SELECT @intRowId = MIN(intImportId)
	FROM tblQMProductImport
	WHERE ISNULL(ysnProcessed, 0) = 0

	WHILE (ISNULL(@intRowId, 0) > 0)
	BEGIN
		BEGIN TRY
			SELECT @strProductTypeName = ''
				,@strProductValue = ''
				,@strNote = ''
				,@strUnitMeasure = ''
				,@ysnActive = 1
				,@strApprovalLotStatus = ''
				,@strRejectionLotStatus = ''
				,@strBondedApprovalLotStatus = ''
				,@strBondedRejectionLotStatus = ''
				,@strSampleTypeName = ''
				,@strTestName = ''
				,@intProductTypeId = NULL
				,@intProductValueId = NULL
				,@intUnitMeasureId = NULL
				,@intApprovalLotStatusId = NULL
				,@intRejectionLotStatusId = NULL
				,@intBondedApprovalLotStatusId = NULL
				,@intBondedRejectionLotStatusId = NULL
				,@intSampleTypeId = NULL
				,@intTestId = NULL
				,@intProductId = NULL
				,@intControlPointId = NULL
				,@intSequenceNo = 0

			SELECT @strProductTypeName = strProductTypeName
				,@strProductValue = strProductValue
				,@strNote = strNote
				,@strUnitMeasure = strUnitMeasure
				,@ysnActive = ysnActive
				,@strApprovalLotStatus = strApprovalLotStatus
				,@strRejectionLotStatus = strRejectionLotStatus
				,@strBondedApprovalLotStatus = strBondedApprovalLotStatus
				,@strBondedRejectionLotStatus = strBondedRejectionLotStatus
				,@strSampleTypeName = strSampleTypeName
				,@strTestName = strTestName
			FROM tblQMProductImport
			WHERE intImportId = @intRowId

			IF ISNULL(@strProductTypeName, '') = ''
			BEGIN
				RAISERROR (
						'Product Type cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intProductTypeId = intProductTypeId
				FROM tblQMProductType
				WHERE strProductTypeName = @strProductTypeName

				IF ISNULL(@intProductTypeId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Product Type. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strProductValue, '') = ''
			BEGIN
				RAISERROR (
						'Product Value cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				IF @intProductTypeId = 1
				BEGIN
					SELECT @intProductValueId = intCategoryId
					FROM tblICCategory
					WHERE strCategoryCode = @strProductValue
				END
				ELSE IF @intProductTypeId = 2
				BEGIN
					SELECT @intProductValueId = intItemId
					FROM tblICItem
					WHERE strItemNo = @strProductValue
				END
			END

			IF ISNULL(@intProductValueId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Product Value. '
						,16
						,1
						)
			END

			IF ISNULL(@strUnitMeasure, '') <> ''
			BEGIN
				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strUnitMeasure

				IF ISNULL(@intUnitMeasureId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Item UOM. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strApprovalLotStatus, '') <> ''
			BEGIN
				SELECT @intApprovalLotStatusId = intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strApprovalLotStatus

				IF ISNULL(@intApprovalLotStatusId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Approval Lot Status. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strRejectionLotStatus, '') <> ''
			BEGIN
				SELECT @intRejectionLotStatusId = intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strRejectionLotStatus

				IF ISNULL(@intRejectionLotStatusId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Rejection Lot Status. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strBondedApprovalLotStatus, '') <> ''
			BEGIN
				SELECT @intBondedApprovalLotStatusId = intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strBondedApprovalLotStatus

				IF ISNULL(@intBondedApprovalLotStatusId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Bonded Approval Lot Status. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strBondedRejectionLotStatus, '') <> ''
			BEGIN
				SELECT @intBondedRejectionLotStatusId = intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strBondedRejectionLotStatus

				IF ISNULL(@intBondedRejectionLotStatusId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Bonded Rejection Lot Status. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strSampleTypeName, '') = ''
			BEGIN
				RAISERROR (
						'Sample Type Name cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intSampleTypeId = intSampleTypeId
					,@intControlPointId = intControlPointId
				FROM tblQMSampleType
				WHERE strSampleTypeName = @strSampleTypeName

				IF ISNULL(@intSampleTypeId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Sample Type Name. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strTestName, '') = ''
			BEGIN
				RAISERROR (
						'Test Name cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intTestId = intTestId
				FROM tblQMTest
				WHERE strTestName = @strTestName

				IF ISNULL(@intTestId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Test Name. '
							,16
							,1
							)
				END
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblQMProduct
					WHERE intProductTypeId = @intProductTypeId
						AND intProductValueId = @intProductValueId
					)
			BEGIN
				INSERT INTO tblQMProduct (
					[intConcurrencyId]
					,[intProductTypeId]
					,[intProductValueId]
					,[strDirections]
					,[strNote]
					,[ysnActive]
					,[intApprovalLotStatusId]
					,[intRejectionLotStatusId]
					,[intBondedApprovalLotStatusId]
					,[intBondedRejectionLotStatusId]
					,[intUnitMeasureId]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT 1
					,@intProductTypeId
					,@intProductValueId
					,''
					,@strNote
					,@ysnActive
					,@intApprovalLotStatusId
					,@intRejectionLotStatusId
					,@intBondedApprovalLotStatusId
					,@intBondedRejectionLotStatusId
					,@intUnitMeasureId
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()

				SELECT @intProductId = SCOPE_IDENTITY()

				INSERT INTO tblQMProductControlPoint (
					[intConcurrencyId]
					,[intProductId]
					,[intControlPointId]
					,[intSampleTypeId]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT 1
					,@intProductId
					,@intControlPointId
					,@intSampleTypeId
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()

				INSERT INTO tblQMProductTest (
					[intConcurrencyId]
					,[intProductId]
					,[intTestId]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT 1
					,@intProductId
					,@intTestId
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()

				INSERT INTO tblQMProductProperty (
					[intConcurrencyId]
					,[intProductId]
					,[intTestId]
					,[intPropertyId]
					,[strFormulaParser]
					,[strComputationMethod]
					,[intSequenceNo]
					,[intComputationTypeId]
					,[strFormulaField]
					,[strIsMandatory]
					,[ysnPrintInLabel]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT 1
					,@intProductId
					,@intTestId
					,TP.intPropertyId
					,''
					,''
					,TP.intSequenceNo
					,1
					,''
					,PR.strIsMandatory
					,0
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()
				FROM tblQMTestProperty TP
				JOIN tblQMTest T ON T.intTestId = TP.intTestId
					AND TP.intTestId = @intTestId
				JOIN tblQMProperty PR ON PR.intPropertyId = TP.intPropertyId
				ORDER BY TP.intSequenceNo

				UPDATE tblQMProductProperty
				SET @intSequenceNo = intSequenceNo = @intSequenceNo + 1
				WHERE intProductId = @intProductId

				INSERT INTO tblQMProductPropertyValidityPeriod (
					[intConcurrencyId]
					,[intProductPropertyId]
					,[dtmValidFrom]
					,[dtmValidTo]
					,[strPropertyRangeText]
					,[dblMinValue]
					,[dblMaxValue]
					,[dblLowValue]
					,[dblHighValue]
					,[intUnitMeasureId]
					,[strFormula]
					,[strFormulaParser]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT 1
					,PP.intProductPropertyId
					,PV.dtmValidFrom
					,PV.dtmValidTo
					,PV.strPropertyRangeText
					,PV.dblMinValue
					,PV.dblMaxValue
					,PV.dblLowValue
					,PV.dblHighValue
					,PV.intUnitMeasureId
					,P.strFormula
					,P.strFormulaParser
					,PP.intCreatedUserId
					,PP.dtmCreated
					,PP.intLastModifiedUserId
					,PP.dtmLastModified
				FROM tblQMPropertyValidityPeriod AS PV
				JOIN tblQMProductProperty AS PP ON PP.intPropertyId = PV.intPropertyId
				JOIN tblQMProperty AS P ON P.intPropertyId = PP.intPropertyId
					AND PV.intPropertyId = P.intPropertyId
					AND PP.intProductId = @intProductId
					AND PP.intTestId = @intTestId
				ORDER BY PP.intProductPropertyId
			END
			ELSE
			BEGIN
				SELECT @intProductId = intProductId
				FROM tblQMProduct
				WHERE intProductTypeId = @intProductTypeId
					AND intProductValueId = @intProductValueId

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMProductControlPoint
						WHERE intProductId = @intProductId
							AND intSampleTypeId = @intSampleTypeId
						)
				BEGIN
					INSERT INTO tblQMProductControlPoint (
						[intConcurrencyId]
						,[intProductId]
						,[intControlPointId]
						,[intSampleTypeId]
						,[intCreatedUserId]
						,[dtmCreated]
						,[intLastModifiedUserId]
						,[dtmLastModified]
						)
					SELECT 1
						,@intProductId
						,@intControlPointId
						,@intSampleTypeId
						,@intUserId
						,GETDATE()
						,@intUserId
						,GETDATE()
				END

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMProductTest
						WHERE intProductId = @intProductId
							AND intTestId = @intTestId
						)
				BEGIN
					INSERT INTO tblQMProductTest (
						[intConcurrencyId]
						,[intProductId]
						,[intTestId]
						,[intCreatedUserId]
						,[dtmCreated]
						,[intLastModifiedUserId]
						,[dtmLastModified]
						)
					SELECT 1
						,@intProductId
						,@intTestId
						,@intUserId
						,GETDATE()
						,@intUserId
						,GETDATE()

					INSERT INTO tblQMProductProperty (
						[intConcurrencyId]
						,[intProductId]
						,[intTestId]
						,[intPropertyId]
						,[strFormulaParser]
						,[strComputationMethod]
						,[intSequenceNo]
						,[intComputationTypeId]
						,[strFormulaField]
						,[strIsMandatory]
						,[ysnPrintInLabel]
						,[intCreatedUserId]
						,[dtmCreated]
						,[intLastModifiedUserId]
						,[dtmLastModified]
						)
					SELECT 1
						,@intProductId
						,@intTestId
						,TP.intPropertyId
						,''
						,''
						,TP.intSequenceNo
						,1
						,''
						,PR.strIsMandatory
						,0
						,@intUserId
						,GETDATE()
						,@intUserId
						,GETDATE()
					FROM tblQMTestProperty TP
					JOIN tblQMTest T ON T.intTestId = TP.intTestId
						AND TP.intTestId = @intTestId
					JOIN tblQMProperty PR ON PR.intPropertyId = TP.intPropertyId
					ORDER BY TP.intSequenceNo

					UPDATE tblQMProductProperty
					SET @intSequenceNo = intSequenceNo = @intSequenceNo + 1
					WHERE intProductId = @intProductId

					INSERT INTO tblQMProductPropertyValidityPeriod (
						[intConcurrencyId]
						,[intProductPropertyId]
						,[dtmValidFrom]
						,[dtmValidTo]
						,[strPropertyRangeText]
						,[dblMinValue]
						,[dblMaxValue]
						,[dblLowValue]
						,[dblHighValue]
						,[intUnitMeasureId]
						,[strFormula]
						,[strFormulaParser]
						,[intCreatedUserId]
						,[dtmCreated]
						,[intLastModifiedUserId]
						,[dtmLastModified]
						)
					SELECT 1
						,PP.intProductPropertyId
						,PV.dtmValidFrom
						,PV.dtmValidTo
						,PV.strPropertyRangeText
						,PV.dblMinValue
						,PV.dblMaxValue
						,PV.dblLowValue
						,PV.dblHighValue
						,PV.intUnitMeasureId
						,P.strFormula
						,P.strFormulaParser
						,PP.intCreatedUserId
						,PP.dtmCreated
						,PP.intLastModifiedUserId
						,PP.dtmLastModified
					FROM tblQMPropertyValidityPeriod AS PV
					JOIN tblQMProductProperty AS PP ON PP.intPropertyId = PV.intPropertyId
					JOIN tblQMProperty AS P ON P.intPropertyId = PP.intPropertyId
						AND PV.intPropertyId = P.intPropertyId
						AND PP.intProductId = @intProductId
						AND PP.intTestId = @intTestId
					ORDER BY PP.intProductPropertyId
				END
			END
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ' ' + ERROR_MESSAGE()

			UPDATE tblQMProductImport
			SET strErrorMsg = @ErrMsg
			WHERE intImportId = @intRowId
		END CATCH

		UPDATE tblQMProductImport
		SET ysnProcessed = 1
		WHERE intImportId = @intRowId

		SELECT @intRowId = MIN(intImportId)
		FROM tblQMProductImport
		WHERE intImportId > @intRowId
			AND ISNULL(ysnProcessed, 0) = 0
	END

	SELECT 'Error'
		,*
	FROM tblQMProductImport
	WHERE ISNULL(ysnProcessed, 0) = 1
		AND ISNULL(strErrorMsg, '') <> ''
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
