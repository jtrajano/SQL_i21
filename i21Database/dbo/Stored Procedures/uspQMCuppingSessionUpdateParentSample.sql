CREATE PROCEDURE [dbo].[uspQMCuppingSessionUpdateParentSample]
	 @intCuppingSampleId AS INT,
	 @intUserEntityId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE
	-- @strTestResultChildrenLog NVARCHAR(MAX)
	@intParentSampleId INT
	,@LogParam SingleAuditLogParam
	,@intParentKeyId INT
	,@intKeyId INT
	,@strCuppingSessionSampleNumber NVARCHAR(50)
	,@strParentSampleNumber NVARCHAR(50)

DECLARE
	@strParentPropertyValue NVARCHAR(MAX)
	,@strCuppingPropertyValue NVARCHAR(MAX)
	,@strParentComment NVARCHAR(MAX)
	,@strCuppingComment NVARCHAR(MAX)
	,@strParentResult NVARCHAR(20)
	,@strCuppingResult NVARCHAR(20)
	,@strTestName NVARCHAR(50)
	,@strPropertyName NVARCHAR(100)
	,@intKeyValue INT

SELECT
	@intParentSampleId = T.intSampleId
	,@strCuppingSessionSampleNumber = S.strSampleNumber
	,@strParentSampleNumber = T.strSampleNumber
FROM tblQMSample S
INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intCuppingSessionDetailId = S.intCuppingSessionDetailId
INNER JOIN tblQMSample T ON T.intSampleId = CSD.intSampleId
WHERE S.intSampleId = @intCuppingSampleId

-- Skip the update to parent if the cupping session sample is not the latest
IF @intCuppingSampleId <> (
	SELECT TOP 1 S.intSampleId
	FROM tblQMSample S
	INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intCuppingSessionDetailId = S.intCuppingSessionDetailId
	INNER JOIN tblQMCuppingSession CS ON CS.intCuppingSessionId = CSD.intCuppingSessionId
	INNER JOIN tblQMSample T ON T.intSampleId = CSD.intSampleId
	WHERE T.intSampleId = @intParentSampleId
	-- The latest cupping session will base on Cupping Date, Cupping Time, and Sample Id
	ORDER BY
		CS.dtmCuppingDate DESC,
		CAST(CS.dtmCuppingTime AS TIME) DESC,
		S.intSampleId DESC
)
BEGIN
	RETURN
END

BEGIN TRANSACTION
BEGIN TRY

	-- Main Log
	INSERT INTO @LogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
	SELECT 1, '', 'Updated', 'Updated (Updated from: '+ @strCuppingSessionSampleNumber +') - Record: ' + @strParentSampleNumber, NULL, NULL, NULL, NULL, NULL, NULL
	UNION ALL
	SELECT 2, '', '', 'tblQMTestResults', NULL, NULL, 'Test Detail (Updated from: '+ @strCuppingSessionSampleNumber +')', NULL, NULL, 1
	
	SET @intKeyId = 2

	-- Loop through each sample testing details
	DECLARE @C AS CURSOR;
	SET @C = CURSOR FAST_FORWARD FOR
		SELECT
			[strParentPropertyValue] = A.strPropertyValue
			,[strCuppingPropertyValue] = B.strPropertyValue
			,[strParentComment] = A.strComment
			,[strCuppingComment] = B.strComment
			,[strParentResult] = A.strResult
			,[strCuppingResult] = B.strResult
			,[strTestName] = QT.strTestName
			,[strPropertyName] = QP.strPropertyName
			,[intKeyValue] = A.intTestResultId
		FROM tblQMSample S
		INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intCuppingSessionDetailId = S.intCuppingSessionDetailId
		INNER JOIN tblQMSample T ON T.intSampleId = CSD.intSampleId
		-- A = Test Results From Parent Sample
		INNER JOIN tblQMTestResult A ON A.intSampleId = T.intSampleId
		INNER JOIN tblQMTest QT ON QT.intTestId = A.intTestId
		INNER JOIN tblQMProperty QP ON QP.intPropertyId = A.intPropertyId
		-- B = Test Results From Cupping Sample
		INNER JOIN tblQMTestResult B
			ON B.intSampleId = S.intSampleId
			AND B.intTestId = A.intTestId
			AND B.intPropertyId = A.intPropertyId
		WHERE S.intSampleId = @intCuppingSampleId
	OPEN @C 
	FETCH NEXT FROM @C INTO
		@strParentPropertyValue
		,@strCuppingPropertyValue
		,@strParentComment
		,@strCuppingComment
		,@strParentResult
		,@strCuppingResult
		,@strTestName
		,@strPropertyName
		,@intKeyValue
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @intKeyId = @intKeyId + 1
		SET @intParentKeyId = @intKeyId

		-- Test Detail Parent Log
		INSERT INTO @LogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
		SELECT @intParentKeyId, '', 'Updated', 'Updated - Record: ' + @strTestName + ' - ' + @strPropertyName, NULL, NULL, NULL, NULL, NULL, 2
		
		-- Property Value
		IF NOT (ISNULL(@strParentPropertyValue, '') = ISNULL(@strCuppingPropertyValue, '') OR (@strParentPropertyValue IS NULL AND @strCuppingPropertyValue IS NULL))
		BEGIN
			SET @intKeyId = @intKeyId + 1
			INSERT INTO @LogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
			SELECT @intKeyId, '', '', 'Actual Value', @strParentPropertyValue, @strCuppingPropertyValue, NULL, NULL, NULL, @intParentKeyId
		END
		-- Result
		IF NOT (ISNULL(@strParentResult, '') = ISNULL(@strCuppingResult, '') OR (@strParentResult IS NULL AND @strCuppingResult IS NULL))
		BEGIN
			SET @intKeyId = @intKeyId + 1
			INSERT INTO @LogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
			SELECT @intKeyId, '', '', 'Result', @strParentResult, @strCuppingResult, NULL, NULL, NULL, @intParentKeyId
		END
		-- Comment
		IF NOT (ISNULL(@strParentComment, '') = ISNULL(@strCuppingComment, '') OR (@strParentComment IS NULL AND @strCuppingComment IS NULL))
		BEGIN
			SET @intKeyId = @intKeyId + 1
			INSERT INTO @LogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
			SELECT @intKeyId, '', '', 'Comment', @strParentComment, @strCuppingComment, NULL, NULL, NULL, @intParentKeyId
		END

		-- Delete parent log if there is no child log
		IF @intParentKeyId = @intKeyId
			DELETE FROM @LogParam WHERE Id = @intParentKeyId

		FETCH NEXT FROM @C INTO
			@strParentPropertyValue
			,@strCuppingPropertyValue
			,@strParentComment
			,@strCuppingComment
			,@strParentResult
			,@strCuppingResult
			,@strTestName
			,@strPropertyName
			,@intKeyValue
	END
	CLOSE @C
	DEALLOCATE @C

	-- Actual update for parent sample test results
	UPDATE A
	SET
		intConcurrencyId = A.intConcurrencyId + 1
		,strPropertyValue = B.strPropertyValue
		,strResult = B.strResult
		,strComment = B.strComment
		-- ,intCreatedUserId = B.intCreatedUserId
		-- ,dtmCreated = B.dtmCreated
		,intLastModifiedUserId = B.intLastModifiedUserId
		,dtmLastModified = B.dtmLastModified
	FROM tblQMSample S
	INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intCuppingSessionDetailId = S.intCuppingSessionDetailId
	INNER JOIN tblQMSample T ON T.intSampleId = CSD.intSampleId
	-- A = Test Results From Parent Sample
	INNER JOIN tblQMTestResult A ON A.intSampleId = T.intSampleId
	INNER JOIN tblQMTest QT ON QT.intTestId = A.intTestId
	INNER JOIN tblQMProperty QP ON QP.intPropertyId = A.intPropertyId
	-- B = Test Results From Cupping Sample
	INNER JOIN tblQMTestResult B
		ON B.intSampleId = S.intSampleId
		AND B.intTestId = A.intTestId
		AND B.intPropertyId = A.intPropertyId
	WHERE S.intSampleId = @intCuppingSampleId
	-- Added this condition so that only the test results that has changes to property value, result, or comment will have the last modified copied from cupping session sample.
	AND (
		NOT (ISNULL(A.strPropertyValue, '') = ISNULL(B.strPropertyValue, '') OR (A.strPropertyValue IS NULL AND B.strPropertyValue IS NULL))
		OR NOT (ISNULL(A.strResult, '') = ISNULL(B.strResult, '') OR (A.strResult IS NULL AND B.strResult IS NULL))
		OR NOT (ISNULL(A.strComment, '') = ISNULL(B.strComment, '') OR (A.strComment IS NULL AND B.strComment IS NULL))
	)

	-- Post audit logs
	IF @intKeyId > 2
	BEGIN
		EXEC uspSMSingleAuditLog
		@screenName     = 'Quality.view.QualitySample',
		@recordId       = @intParentSampleId,
		@entityId       = @intUserEntityId,
		@AuditLogParam  = @LogParam
	END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	DECLARE @msg VARCHAR(MAX) = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@msg, 11, 1) 
END CATCH 
GO