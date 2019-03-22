CREATE PROCEDURE uspWHTransferKit 
				@strPickListNo NVARCHAR(100), 
				@intCompanyLocationId INT, 
				@intUserId INT
AS
BEGIN TRY
	DECLARE @strWorkOrderIds NVARCHAR(MAX)
	DECLARE @intBlendLocationId INT
	DECLARE @intBlendStagingLocationId INT
	DECLARE @intPickListId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT @intBlendStagingLocationId = intBlendProductionStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intCompanyLocationId
	
	SELECT @intPickListId = intPickListId
	FROM tblMFPickList
	WHERE strPickListNo = @strPickListNo
		AND intLocationId = @intCompanyLocationId

	IF ISNULL(@intBlendStagingLocationId,0) = 0 
	BEGIN
		RAISERROR('DEFAULT BLEND PRODUCTION STAGING AREA NOT CONFIGURED FOR THE LOGGED ON LOCATION.',16,1)
	END
	
	SET @intBlendLocationId = @intCompanyLocationId

	SELECT @strWorkOrderIds = STUFF((
				SELECT ',' + convert(VARCHAR, intWorkOrderId)
				FROM tblMFWorkOrder
				WHERE intPickListId = @intPickListId
				FOR XML PATH('')
				), 1, 1, '')

	BEGIN TRANSACTION

			EXEC [uspMFTransferKit] @strWorkOrderIds = @strWorkOrderIds, 
									@intLoggedOnLocationId = @intCompanyLocationId, 
									@intBlendLocationId = @intBlendLocationId, 
									@intBlendStagingLocationId = @intBlendStagingLocationId, 
									@intUserId = @intUserId


			DELETE FROM tblWHPickForKitting WHERE intPickListId = @intPickListId
			
	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @TransactionCount = 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH