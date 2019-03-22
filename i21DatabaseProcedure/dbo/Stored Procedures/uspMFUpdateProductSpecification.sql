CREATE PROCEDURE [dbo].[uspMFUpdateProductSpecification] (
	@strXML NVARCHAR(MAX)
	,@intConcurrencyId INT OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intUserId INT
		,@intTransactionCount INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intUserId INT
			)

	SELECT @intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF EXISTS (
		SELECT *
		FROM (
			SELECT strParameterName
				,ROW_NUMBER() OVER (
					PARTITION BY strParameterName+strParameterValue ORDER BY strParameterName+strParameterValue
					) as intRowNumber
			FROM OPENXML(@idoc, 'root/WorkOrderProductSpecifications/WorkOrderProductSpecification', 2) WITH (
					intWorkOrderProductSpecificationId INT
					,strParameterName NVARCHAR(50)
					,strParameterValue NVARCHAR(MAX)
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intWorkOrderProductSpecificationId = 0
				AND x.strRowState = 'ADDED'
		) AS DT WHERE DT.intRowNumber > 1 )
	BEGIN
		RAISERROR (
				'Product specification entered should be unique.'
				,11
				,1
				)
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
	BEGIN TRANSACTION

	INSERT INTO dbo.tblMFWorkOrderProductSpecification (
		intWorkOrderId
		,strParameterName
		,strParameterValue
		,intConcurrencyId
		)
	SELECT @intWorkOrderId
		,strParameterName
		,strParameterValue
		,1
	FROM OPENXML(@idoc, 'root/WorkOrderProductSpecifications/WorkOrderProductSpecification', 2) WITH (
			intWorkOrderProductSpecificationId INT
			,strParameterName NVARCHAR(50)
			,strParameterValue NVARCHAR(MAX)
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intWorkOrderProductSpecificationId = 0
		AND x.strRowState = 'ADDED'

	UPDATE tblMFWorkOrderProductSpecification
	SET strParameterName = x.strParameterName
		,strParameterValue = x.strParameterValue
		,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
	FROM OPENXML(@idoc, 'root/WorkOrderProductSpecifications/WorkOrderProductSpecification', 2) WITH (
			intWorkOrderProductSpecificationId INT
			,strParameterName NVARCHAR(50)
			,strParameterValue NVARCHAR(MAX)
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intWorkOrderProductSpecificationId = tblMFWorkOrderProductSpecification.intWorkOrderProductSpecificationId
		AND x.strRowState = 'MODIFIED'

	DELETE
	FROM dbo.tblMFWorkOrderProductSpecification
	WHERE intWorkOrderId = @intWorkOrderId
		AND EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/WorkOrderProductSpecifications/WorkOrderProductSpecification', 2) WITH (
					intWorkOrderProductSpecificationId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intWorkOrderProductSpecificationId = tblMFWorkOrderProductSpecification.intWorkOrderProductSpecificationId
				AND x.strRowState = 'DELETE'
			)
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


