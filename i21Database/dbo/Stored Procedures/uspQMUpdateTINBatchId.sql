CREATE PROCEDURE uspQMUpdateTINBatchId
	  @intTINClearanceId	INT
    , @intBatchId           INT
	, @intEntityId	        INT
AS

BEGIN TRY
	BEGIN TRANSACTION

	UPDATE TIN
	SET ysnEmpty	= CAST(0 AS BIT)
	  , intBatchId	= @intBatchId
	FROM tblQMTINClearance TIN
	WHERE TIN.intTINClearanceId = @intTINClearanceId

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
			
	UNION ALL

	SELECT [Id]			= 2
		, [Action]		= NULL
		, [Change]		= 'Empty'
		, [From]		= 'True'
		, [To]			= 'False'
		, [ParentId]	= 1

	UNION ALL
			
	SELECT [Id]			= 3
		, [Action]		= NULL
		, [Change]		= 'Batch Id'
		, [From]		= NULL
		, [To]			= @strBatchId
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