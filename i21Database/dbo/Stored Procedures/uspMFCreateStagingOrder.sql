CREATE PROCEDURE [dbo].[uspMFCreateStagingOrder] 
					@OrderHeaderInformation OrderHeaderInformation READONLY
AS
BEGIN TRY
	DECLARE @idoc INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intOrderHeaderId INT
	DECLARE @strOrderNo NVARCHAR(32)
	DECLARE @strLastUpdateBy NVARCHAR(32)
	DECLARE @intLastUpdateById INT
	DECLARE @intOrderTypeId INT
	DECLARE @strWorkOrderId NVARCHAR(MAX)
	DECLARE @intLocalTran TINYINT

	SET @strErrMsg = ''
	SET NOCOUNT ON

	IF @@TRANCOUNT = 0
		SET @intLocalTran = 1

	IF @intLocalTran = 1
		BEGIN TRANSACTION

	SELECT @strLastUpdateBy = strLastUpdateBy
		  ,@strOrderNo = strOrderNo
		  ,@strWorkOrderId = intWorkOrderId
		  ,@intOrderTypeId = intOrderTypeId
	FROM @OrderHeaderInformation

	SELECT @intLastUpdateById = intEntityUserSecurityId
	FROM tblSMUserSecurity
	WHERE strUserName = @strLastUpdateBy

	INSERT INTO tblMFOrderHeader (
		 intConcurrencyId
		,intOrderStatusId
		,intOrderTypeId
		,intOrderDirectionId
		,strOrderNo
		,strReferenceNo
		,intStagingLocationId
		,strComment
		,dtmOrderDate
		,intCreatedById
		,dtmCreatedOn
		,intLastUpdateById
		,dtmLastUpdateOn
		)
	SELECT 1
		,intOrderStatusId
		,intOrderTypeId
		,intOrderDirectionId
		,strOrderNo
		,strReferenceNo
		,intStagingLocationId
		,strComment
		,dtmOrderDate
		,@intLastUpdateById
		,GETDATE()
		,@intLastUpdateById
		,GETDATE()
	FROM @OrderHeaderInformation

	SELECT @intOrderHeaderId = SCOPE_IDENTITY()

	IF EXISTS (
			SELECT 1
			FROM tblMFOrderHeader OH
			JOIN tblMFOrderType OT ON OH.intOrderTypeId = OT.intOrderTypeId
			WHERE strInternalCode = 'PS'
				AND OH.intOrderTypeId = @intOrderTypeId
				AND OH.intOrderHeaderId = @intOrderHeaderId
			)
	BEGIN
		UPDATE dbo.tblMFWorkOrder
		SET intOrderHeaderId = @intOrderHeaderId
			,strBOLNo = @strOrderNo
		WHERE intWorkOrderId IN 
				(SELECT Item
				 FROM dbo.fnSplitString(@strWorkOrderId, ','))
	END

	--Return the new Order Header Id to the                       
	SELECT @intOrderHeaderId

	IF @intLocalTran = 1
		AND @@TRANCOUNT > 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF @intLocalTran = 1 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspMFCreateStagingOrder: ' + @strErrMsg

		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH