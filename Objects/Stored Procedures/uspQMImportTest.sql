CREATE PROCEDURE uspQMImportTest @intUserId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX) = ''
	DECLARE @intRowId INT
		,@strTestName NVARCHAR(50)
		,@strDescription NVARCHAR(100)
		,@strAnalysisTypeName NVARCHAR(50)
		,@strTestMethod NVARCHAR(50)
		,@strIndustryStandards NVARCHAR(50)
		,@strSensComments NVARCHAR(100)
		,@ysnActive BIT
		,@strPropertyName NVARCHAR(100)
		,@intTestId INT
		,@intAnalysisTypeId INT
		,@intPropertyId INT
		,@intSequenceNo INT

	IF ISNULL(@intUserId, 0) = 0
	BEGIN
		SELECT TOP 1 @intUserId = intEntityId
		FROM tblSMUserSecurity
		WHERE LOWER(strUserName) = 'irelyadmin'
	END

	SELECT @intRowId = MIN(intImportId)
	FROM tblQMTestImport
	WHERE ISNULL(ysnProcessed, 0) = 0

	WHILE (ISNULL(@intRowId, 0) > 0)
	BEGIN
		BEGIN TRY
			SELECT @strTestName = ''
				,@strDescription = ''
				,@strAnalysisTypeName = ''
				,@strTestMethod = ''
				,@strIndustryStandards = ''
				,@strSensComments = ''
				,@ysnActive = 1
				,@strPropertyName = ''
				,@intTestId = NULL
				,@intAnalysisTypeId = NULL
				,@intPropertyId = NULL
				,@intSequenceNo = NULL

			SELECT @strTestName = strTestName
				,@strDescription = strDescription
				,@strAnalysisTypeName = strAnalysisTypeName
				,@strTestMethod = strTestMethod
				,@strIndustryStandards = strIndustryStandards
				,@strSensComments = strSensComments
				,@ysnActive = ysnActive
				,@strPropertyName = strPropertyName
			FROM tblQMTestImport
			WHERE intImportId = @intRowId

			IF ISNULL(@strTestName, '') = ''
			BEGIN
				RAISERROR (
						'Test Name cannot be empty. '
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

			IF ISNULL(@strPropertyName, '') = ''
			BEGIN
				RAISERROR (
						'Property Name cannot be empty. '
						,16
						,1
						)
			END
			ELSE
			BEGIN
				SELECT @intPropertyId = intPropertyId
				FROM tblQMProperty
				WHERE strPropertyName = @strPropertyName

				IF ISNULL(@intPropertyId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Property Name. '
							,16
							,1
							)
				END
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblQMTest
					WHERE strTestName = @strTestName
					)
			BEGIN
				INSERT INTO tblQMTest (
					[intAnalysisTypeId]
					,[intConcurrencyId]
					,[strTestName]
					,[strDescription]
					,[strTestMethod]
					,[strIndustryStandards]
					,[intReplications]
					,[strSensComments]
					,[ysnAutoCapture]
					,[ysnIgnoreSubSample]
					,[ysnActive]
					,[intCreatedUserId]
					,[dtmCreated]
					,[intLastModifiedUserId]
					,[dtmLastModified]
					)
				SELECT @intAnalysisTypeId
					,1
					,@strTestName
					,@strDescription
					,@strTestMethod
					,@strIndustryStandards
					,1
					,@strSensComments
					,0
					,0
					,@ysnActive
					,@intUserId
					,GETDATE()
					,@intUserId
					,GETDATE()

				SELECT @intTestId = SCOPE_IDENTITY()

				IF ISNULL(@intPropertyId, 0) > 0
				BEGIN
					SELECT @intSequenceNo = ISNULL(MAX(intSequenceNo), 0)
					FROM tblQMTestProperty
					WHERE intTestId = @intTestId

					INSERT INTO tblQMTestProperty (
						[intTestId]
						,[intPropertyId]
						,[intConcurrencyId]
						,[intFormulaID]
						,[intSequenceNo]
						,[intCreatedUserId]
						,[dtmCreated]
						,[intLastModifiedUserId]
						,[dtmLastModified]
						)
					SELECT @intTestId
						,@intPropertyId
						,1
						,0
						,(@intSequenceNo + 1)
						,@intUserId
						,GETDATE()
						,@intUserId
						,GETDATE()
				END
			END
			ELSE IF ISNULL(@intPropertyId, 0) > 0
			BEGIN
				SELECT @intTestId = intTestId
				FROM tblQMTest
				WHERE strTestName = @strTestName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMTestProperty
						WHERE intTestId = @intTestId
							AND intPropertyId = @intPropertyId
						)
				BEGIN
					SELECT @intSequenceNo = ISNULL(MAX(intSequenceNo), 0)
					FROM tblQMTestProperty
					WHERE intTestId = @intTestId

					INSERT INTO tblQMTestProperty (
						[intTestId]
						,[intPropertyId]
						,[intConcurrencyId]
						,[intFormulaID]
						,[intSequenceNo]
						,[intCreatedUserId]
						,[dtmCreated]
						,[intLastModifiedUserId]
						,[dtmLastModified]
						)
					SELECT @intTestId
						,@intPropertyId
						,1
						,0
						,(@intSequenceNo + 1)
						,@intUserId
						,GETDATE()
						,@intUserId
						,GETDATE()
				END
			END
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ' ' + ERROR_MESSAGE()

			UPDATE tblQMTestImport
			SET strErrorMsg = @ErrMsg
			WHERE intImportId = @intRowId
		END CATCH

		UPDATE tblQMTestImport
		SET ysnProcessed = 1
		WHERE intImportId = @intRowId

		SELECT @intRowId = MIN(intImportId)
		FROM tblQMTestImport
		WHERE intImportId > @intRowId
			AND ISNULL(ysnProcessed, 0) = 0
	END

	SELECT 'Error'
		,*
	FROM tblQMTestImport
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
