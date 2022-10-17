CREATE PROCEDURE uspQMUpdateTINBatchId
	  @strTINNumber			NVARCHAR(100) = NULL
    , @intBatchId           INT = NULL
	, @intCompanyLocationId	INT = NULL
	, @intEntityId	        INT 
	, @ysnDelink 			BIT = 0
AS

BEGIN TRY
	BEGIN TRANSACTION

	IF OBJECT_ID('tempdb..#TIN') IS NOT NULL DROP TABLE #TIN

	SET @ysnDelink = ISNULL(@ysnDelink, 0)

	DECLARE @intNewTINClearanceId 	INT = NULL
		  , @intTINClearanceId		INT = NULL

	SELECT TOP 1 @intTINClearanceId = intTINClearanceId
	FROM tblQMTINClearance
	WHERE strTINNumber = @strTINNumber
	  AND intCompanyLocationId = @intCompanyLocationId

	--LINK TIN # TO BATCH
	IF @ysnDelink = 0
		BEGIN
			IF @intTINClearanceId = NULL
				BEGIN 
					INSERT INTO tblQMTINClearance (
						  intCompanyLocationId
						, strTINNumber
						, intBatchId
						, ysnEmpty
					)
					SELECT intCompanyLocationId	= @intCompanyLocationId
						, strTINNumber			= @strTINNumber
						, intBatchId			= intBatchId
						, ysnEmpty				= CAST(0 AS BIT)
					FROM tblMFBatch 
					WHERE intBatchId = @intBatchId

					SET @intNewTINClearanceId = SCOPE_IDENTITY()
					SET @intTINClearanceId = @intNewTINClearanceId
				END
			ELSE 
				BEGIN
					UPDATE TIN
					SET ysnEmpty	= CAST(0 AS BIT)
					  , intBatchId	= @intBatchId
					FROM tblQMTINClearance TIN
					WHERE TIN.intTINClearanceId = @intTINClearanceId
				END
		END
	
	--REMOVE LINK TIN # TO BATCH
	IF @ysnDelink = 1 AND @intTINClearanceId IS NOT NULL
		BEGIN
			UPDATE TIN
			SET ysnEmpty	= CAST(1 AS BIT)
			  , intBatchId	= NULL
			FROM tblQMTINClearance TIN
			WHERE TIN.intTINClearanceId = @intTINClearanceId
		END


	--AUDIT LOG
	DECLARE @SingleAuditLogParam	SingleAuditLogParam
	      , @strBatchId				NVARCHAR(50) = NULL

	SELECT @strBatchId = strBatchId
	FROM tblMFBatch
	WHERE intBatchId = @intBatchId

	DELETE FROM @SingleAuditLogParam
	INSERT INTO @SingleAuditLogParam (
		  [Id]
		, [Action]
		, [Change]
		, [From]
		, [To]
		, [ParentId]
	)
	SELECT [Id]			= 1
		, [Action]		= 'Update TIN Batch Id'
		, [Change]		= 'Updated - Record: ' + CAST(@intTINClearanceId AS NVARCHAR(100))
		, [From]		= NULL
		, [To]			= NULL
		, [ParentId]	= NULL
	WHERE @intNewTINClearanceId IS NULL
			
	UNION ALL

	SELECT [Id]			= 1
		, [Action]		= 'Update TIN Batch Id'
		, [Change]		= 'Created - Record: ' + CAST(@intTINClearanceId AS NVARCHAR(100))
		, [From]		= NULL
		, [To]			= NULL
		, [ParentId]	= NULL
	WHERE @ysnDelink = 0 
	  AND @intNewTINClearanceId IS NOT NULL

	UNION ALL

	SELECT [Id]			= 2
		, [Action]		= NULL
		, [Change]		= 'Empty'
		, [From]		= CASE WHEN @ysnDelink = 0 THEN 'True' ELSE 'False' END
		, [To]			= CASE WHEN @ysnDelink = 0 THEN 'False' ELSE 'True' END
		, [ParentId]	= 1

	UNION ALL
			
	SELECT [Id]			= 3
		, [Action]		= NULL
		, [Change]		= 'Batch Id'
		, [From]		= CASE WHEN @ysnDelink = 0 THEN NULL ELSE @strBatchId END
		, [To]			= CASE WHEN @ysnDelink = 0 THEN @strBatchId ELSE NULL END
		, [ParentId]	= 1

	EXEC uspSMSingleAuditLog @screenName = 'Quality.view.TINClearance'
						   , @recordId = @intTINClearanceId
						   , @entityId = @intEntityId
						   , @AuditLogParam = @SingleAuditLogParam

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH