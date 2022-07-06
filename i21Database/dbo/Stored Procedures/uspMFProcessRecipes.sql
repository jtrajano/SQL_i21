CREATE PROCEDURE dbo.uspMFProcessRecipes (@ysnMinOneInputItemRequired INT = 1)
AS
BEGIN
	DECLARE @strSessionId NVARCHAR(50)
		,@intRecordId INT
		,@intEntityId INT
	DECLARE @tblMFSession TABLE (
		intRecordId INT identity(1, 1)
		,strSessionId NVARCHAR(50) Collate Latin1_General_CI_AS
		,intSortOrder INT
		)
	DECLARE @tblIPInitialAck TABLE (intTrxSequenceNo BIGINT);

	SELECT @intEntityId = intEntityId
	FROM tblSMUserSecurity
	WHERE strUserName = 'IRELYADMIN'

	INSERT INTO @tblMFSession
	SELECT DISTINCT strSessionId
		,1 AS intSortOrder
	FROM tblMFRecipeStage
	WHERE IsNULL(strMessage, '') = ''
		AND intStatusId IS NULL
	
	UNION
	
	SELECT DISTINCT strSessionId
		,2 AS intSortOrder
	FROM tblMFRecipeItemStage
	WHERE IsNULL(strMessage, '') = ''
		AND intStatusId IS NULL
	ORDER BY intSortOrder

	UPDATE tblMFRecipeStage
	SET intStatusId = 3
	WHERE strSessionId IN (
			SELECT strSessionId
			FROM @tblMFSession
			)

	UPDATE tblMFRecipeItemStage
	SET intStatusId = 3
	WHERE strSessionId IN (
			SELECT strSessionId
			FROM @tblMFSession
			)

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFSession

	IF @intRecordId IS NULL
		RETURN

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @strSessionId = NULL

		SELECT @strSessionId = strSessionId
		FROM @tblMFSession
		WHERE intRecordId = @intRecordId

		EXEC dbo.uspMFImportRecipes @strSessionId
			,'Recipe Delete'
			,@intEntityId

		EXEC dbo.uspMFImportRecipes @strSessionId
			,'Recipe Item Delete'
			,@intEntityId

		EXEC dbo.uspMFImportRecipes @strSessionId
			,'Recipe'
			,@intEntityId
			,1

		EXEC dbo.uspMFImportRecipes @strSessionId
			,'Recipe Item'
			,@intEntityId
			,@ysnMinOneInputItemRequired

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFSession
		WHERE intRecordId > @intRecordId
	END

	DELETE
	FROM @tblIPInitialAck

	INSERT INTO dbo.tblIPInitialAck (
		intTrxSequenceNo
		,strCompanyLocation
		,dtmCreatedDate
		,strCreatedBy
		,intMessageTypeId
		,intStatusId
		,strStatusText
		)
	OUTPUT INSERTED.intTrxSequenceNo
	INTO @tblIPInitialAck
	SELECT intTrxSequenceNo
		,CL.strLotOrigin AS CompanyLocation
		,NULL AS CreatedDate
		,NULL AS CreatedBy
		,4 AS intMessageTypeId
		,CASE 
			WHEN strMessage <> 'Success'
				OR EXISTS (
					SELECT TOP 1 *
					FROM tblMFRecipeItemStage RI
					WHERE R.intTrxSequenceNo = RI.intParentTrxSequenceNo
						AND strMessage <> 'Success'
						--AND strSessionId = @strSessionId
						AND RI.ysnInitialAckSent IS NULL
					)
				THEN 0
			ELSE 1
			END AS intStatusId
		,CASE 
			WHEN strMessage <> 'Success'
				THEN strMessage
			ELSE IsNULL((
						SELECT TOP 1 RI.strMessage
						FROM tblMFRecipeItemStage RI
						WHERE R.intTrxSequenceNo = RI.intParentTrxSequenceNo
							AND strMessage <> 'Success'
							AND RI.ysnInitialAckSent IS NULL
						), 'Success')
			END
	FROM tblMFRecipeStage R
	JOIN tblSMCompanyLocation CL ON CL.strLocationName = R.strLocationName
	WHERE R.ysnInitialAckSent IS NULL

	UPDATE R
	SET ysnInitialAckSent = 1
	FROM tblMFRecipeStage R
	JOIN @tblIPInitialAck IA ON IA.intTrxSequenceNo = R.intTrxSequenceNo

	UPDATE RI
	SET ysnInitialAckSent = 1
	FROM tblMFRecipeItemStage RI
	JOIN @tblIPInitialAck IA ON IA.intTrxSequenceNo = RI.intParentTrxSequenceNo

	UPDATE tblMFRecipeStage
	SET intStatusId = NULL
	WHERE strSessionId IN (
			SELECT strSessionId
			FROM @tblMFSession
			)
		AND intStatusId = 3

	UPDATE tblMFRecipeItemStage
	SET intStatusId = NULL
	WHERE strSessionId IN (
			SELECT strSessionId
			FROM @tblMFSession
			)
		AND intStatusId = 3
END
