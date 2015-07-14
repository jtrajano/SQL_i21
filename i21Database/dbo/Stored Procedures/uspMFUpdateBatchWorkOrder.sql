CREATE PROCEDURE [dbo].[uspMFUpdateBatchWorkOrder] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT

	SELECT @intTransactionCount = @@TRANCOUNT


	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML
	
	IF @intTransactionCount = 0
	BEGIN TRANSACTION

	UPDATE tblMFWorkOrder
	SET intStorageLocationId = x.intStorageLocationId
		,strComment = x.strComment
		,dtmLastModified = GetDate()
		,intLastModifiedUserId = x.intUserId
		,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intWorkOrderId INT
			,intStorageLocationId INT
			,strComment NVARCHAR(MAX)
			,intUserId INT
			) x
	WHERE x.intWorkOrderId = tblMFWorkOrder.intWorkOrderId
	
	IF @intTransactionCount = 0
	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0 AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


