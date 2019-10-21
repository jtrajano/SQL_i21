CREATE PROCEDURE uspQMImportProperty @intUserId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX) = ''
	DECLARE @intRowId INT
		,@strPropertyName NVARCHAR(100)
		,@strDescription NVARCHAR(500)
		,@strAnalysisTypeName NVARCHAR(50)
		,@strDataTypeName NVARCHAR(50)
		,@strListName NVARCHAR(50)
		,@intDecimalPlaces INT
		,@strIsMandatory NVARCHAR(20)
		,@ysnActive BIT
		,@ysnNotify BIT
		,@strItemNo NVARCHAR(50)
		,@dtmValidFrom DATETIME
		,@dtmValidTo DATETIME
		,@dblMinValue NUMERIC(18, 6)
		,@dblMaxValue NUMERIC(18, 6)
		,@strPropertyRangeText NVARCHAR(MAX)
		,@strUnitMeasure NVARCHAR(50)
		,@intPropertyId INT
		,@intAnalysisTypeId INT
		,@intDataTypeId INT
		,@intListId INT
		,@intItemId INT
		,@intUnitMeasureId INT

	IF ISNULL(@intUserId, 0) = 0
	BEGIN
		SELECT TOP 1 @intUserId = intEntityId
		FROM tblSMUserSecurity
		WHERE LOWER(strUserName) = 'irelyadmin'
	END

	SELECT @intRowId = MIN(intImportId)
	FROM tblQMPropertyImport
	WHERE ISNULL(ysnProcessed, 0) = 0

	WHILE (ISNULL(@intRowId, 0) > 0)
	BEGIN
		BEGIN TRY
			SELECT @strPropertyName = ''
				,@strDescription = ''
				,@strAnalysisTypeName = ''
				,@strDataTypeName = ''
				,@strListName = ''
				,@intDecimalPlaces = NULL
				,@strIsMandatory = ''
				,@ysnActive = 1
				,@ysnNotify = 0
				,@strItemNo = ''
				,@dtmValidFrom = NULL
				,@dtmValidTo = NULL
				,@dblMinValue = NULL
				,@dblMaxValue = NULL
				,@strPropertyRangeText = ''
				,@strUnitMeasure = ''
				,@intPropertyId = NULL
				,@intAnalysisTypeId = NULL
				,@intDataTypeId = NULL
				,@intListId = NULL
				,@intItemId = NULL
				,@intUnitMeasureId = NULL

			SELECT @strPropertyName = strPropertyName
				,@strDescription = strDescription
				,@strAnalysisTypeName = strAnalysisTypeName
				,@strDataTypeName = strDataTypeName
				,@strListName = strListName
				,@intDecimalPlaces = intDecimalPlaces
				,@strIsMandatory = strIsMandatory
				,@ysnActive = ysnActive
				,@ysnNotify = ysnNotify
				,@strItemNo = strItemNo
				,@dtmValidFrom = dtmValidFrom
				,@dtmValidTo = dtmValidTo
				,@dblMinValue = dblMinValue
				,@dblMaxValue = dblMaxValue
				,@strPropertyRangeText = strPropertyRangeText
				,@strUnitMeasure = strUnitMeasure
			FROM tblQMPropertyImport
			WHERE intImportId = @intRowId

			IF ISNULL(@strPropertyName, '') = ''
			BEGIN
				RAISERROR (
						'Property Name cannot be empty. '
						,16
						,1
						)
			END

			IF ISNULL(@strDescription, '') = ''
			BEGIN
				RAISERROR (
						'Description cannot be empty. '
						,16
						,1
						)
			END

			IF ISNULL(@strAnalysisTypeName, '') = ''
			BEGIN
				RAISERROR (
						'Analysis Type cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intAnalysisTypeId = intAnalysisTypeId
				FROM tblQMAnalysisType
				WHERE strAnalysisTypeName = @strAnalysisTypeName

				IF ISNULL(@intAnalysisTypeId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Analysis Type. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strDataTypeName, '') = ''
			BEGIN
				RAISERROR (
						'Data Type cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intDataTypeId = intDataTypeId
				FROM tblQMDataType
				WHERE strDataTypeName = @strDataTypeName

				IF ISNULL(@intDataTypeId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Data Type. '
							,16
							,1
							)
				END
			END

			IF @intDataTypeId = 5
				AND ISNULL(@strListName, '') = ''
			BEGIN
				RAISERROR (
						'List Name cannot be blank. '
						,16
						,1
						)
			END

			IF ISNULL(@strListName, '') <> ''
			BEGIN
				SELECT @intListId = intListId
				FROM tblQMList
				WHERE strListName = @strListName

				IF ISNULL(@intListId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid List Name. '
							,16
							,1
							)
				END
				ELSE
				BEGIN
					IF @intDataTypeId <> 5
					BEGIN
						RAISERROR (
								'List Name can be configured only for List Data Type. '
								,16
								,1
								)
					END
					ELSE IF ISNULL(@strPropertyRangeText, '') = ''
					BEGIN
						RAISERROR (
								'Accepted Values cannot be blank. '
								,16
								,1
								)
					END
				END
			END

			IF (
					ISNULL(@intDecimalPlaces, 0) = 0
					AND @intDataTypeId <> 2
					)
			BEGIN
				SELECT @intDecimalPlaces = NULL
			END

			IF @intDataTypeId = 2
				AND ISNULL(@intDecimalPlaces, 0) < 1
			BEGIN
				RAISERROR (
						'Decimal places should be greater than 0. '
						,16
						,1
						)
			END

			IF ISNULL(@intDecimalPlaces, 0) > 0
			BEGIN
				IF @intDataTypeId <> 2
				BEGIN
					RAISERROR (
							'Decimal Places can be configured only for Float Data Type. '
							,16
							,1
							)
				END
				ELSE
				BEGIN
					IF @intDecimalPlaces > 6
					BEGIN
						RAISERROR (
								'Decimal Places cannot be greater than 6. '
								,16
								,1
								)
					END
				END
			END

			IF ISNULL(@strIsMandatory, '') = ''
			BEGIN
				RAISERROR (
						'Mandatory cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				IF (
						@strIsMandatory <> 'Yes'
						AND @strIsMandatory <> 'No'
						)
				BEGIN
					RAISERROR (
							'Invalid Mandatory. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strItemNo, '') <> ''
			BEGIN
				SELECT @intItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strItemNo

				IF ISNULL(@intItemId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Item No. '
							,16
							,1
							)
				END
			END

			IF ISDATE(@dtmValidFrom) = 0
			BEGIN
				RAISERROR (
						'Valid From should be a Date. '
						,16
						,1
						)
			END

			IF ISDATE(@dtmValidTo) = 0
			BEGIN
				RAISERROR (
						'Valid To should be a Date. '
						,16
						,1
						)
			END

			IF ISDATE(@dtmValidFrom) = 1
				AND ISDATE(@dtmValidTo) = 1
			BEGIN
				IF @dtmValidFrom > @dtmValidTo
				BEGIN
					RAISERROR (
							'Valid From date cannot be greater than Valid To date. '
							,16
							,1
							)
				END
			END

			IF @dblMinValue IS NOT NULL
			BEGIN
				IF ISNUMERIC(@dblMinValue) <> 1
				BEGIN
					RAISERROR (
							'Min Value should be Whole Number / Decimal Number. '
							,16
							,1
							)
				END

				IF @intDataTypeId <> 1
					AND @intDataTypeId <> 2
				BEGIN
					SELECT @dblMinValue = NULL
				END
			END

			IF @dblMaxValue IS NOT NULL
			BEGIN
				IF ISNUMERIC(@dblMaxValue) <> 1
				BEGIN
					RAISERROR (
							'Max Value should be Whole Number / Decimal Number. '
							,16
							,1
							)
				END

				IF @intDataTypeId <> 1
					AND @intDataTypeId <> 2
				BEGIN
					SELECT @dblMaxValue = NULL
				END
			END

			IF ISNUMERIC(@dblMinValue) = 1
				AND ISNUMERIC(@dblMaxValue) = 1
			BEGIN
				IF @dblMinValue > @dblMaxValue
				BEGIN
					RAISERROR (
							'Min Value cannot be greater than Max Value. '
							,16
							,1
							)
				END
			END

			IF @intDataTypeId = 4
			BEGIN
				IF ISNULL(@strPropertyRangeText, '') <> ''
				BEGIN
					IF LOWER(@strPropertyRangeText) <> 'false'
						AND LOWER(@strPropertyRangeText) <> 'true'
					BEGIN
						RAISERROR (
								'Accepted Values can be either true / false. '
								,16
								,1
								)
					END
				END
			END

			IF ISNULL(@strUnitMeasure, '') <> ''
			BEGIN
				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strUnitMeasure

				IF ISNULL(@intUnitMeasureId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid UOM. '
							,16
							,1
							)
				END
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblQMProperty
					WHERE strPropertyName = @strPropertyName
					)
			BEGIN
				INSERT INTO tblQMProperty (
					[intAnalysisTypeId]
					,[intConcurrencyId]
					,[strPropertyName]
					,[strDescription]
					,[intDataTypeId]
					,[intListId]
					,[intDecimalPlaces]
					,[strIsMandatory]
					,[ysnActive]
					,[strFormula]
					,[strFormulaParser]
					,[strDefaultValue]
					,[ysnNotify]
					,[intItemId]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT @intAnalysisTypeId
					,1
					,@strPropertyName
					,@strDescription
					,@intDataTypeId
					,@intListId
					,@intDecimalPlaces
					,@strIsMandatory
					,@ysnActive
					,''
					,''
					,''
					,@ysnNotify
					,@intItemId
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()

				SELECT @intPropertyId = SCOPE_IDENTITY()

				INSERT INTO tblQMPropertyValidityPeriod (
					[intPropertyId]
					,[intConcurrencyId]
					,[dtmValidFrom]
					,[dtmValidTo]
					,[strPropertyRangeText]
					,[dblMinValue]
					,[dblMaxValue]
					,[dblLowValue]
					,[dblHighValue]
					,[intUnitMeasureId]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT @intPropertyId
					,1
					,@dtmValidFrom
					,@dtmValidTo
					,@strPropertyRangeText
					,@dblMinValue
					,@dblMaxValue
					,NULL
					,NULL
					,@intUnitMeasureId
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()
			END
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ' ' + ERROR_MESSAGE()

			UPDATE tblQMPropertyImport
			SET strErrorMsg = @ErrMsg
			WHERE intImportId = @intRowId
		END CATCH

		UPDATE tblQMPropertyImport
		SET ysnProcessed = 1
		WHERE intImportId = @intRowId

		SELECT @intRowId = MIN(intImportId)
		FROM tblQMPropertyImport
		WHERE intImportId > @intRowId
			AND ISNULL(ysnProcessed, 0) = 0
	END

	SELECT 'Error'
		,*
	FROM tblQMPropertyImport
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
