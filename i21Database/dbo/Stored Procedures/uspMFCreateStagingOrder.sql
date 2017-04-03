CREATE PROCEDURE [dbo].[uspMFCreateStagingOrder] 
					@OrderHeaderInformation OrderHeaderInformation READONLY
AS
BEGIN TRY

	DECLARE @strErrMsg NVARCHAR(MAX)
	, @intOrderHeaderId INT
	, @strLastUpdateBy NVARCHAR(50)
	, @intLastUpdateById INT
	, @intLocalTran TINYINT

	SET @strErrMsg = ''
	SET NOCOUNT ON

	IF @@TRANCOUNT = 0
		SET @intLocalTran = 1

	IF @intLocalTran = 1
		BEGIN TRANSACTION

	SELECT @strLastUpdateBy = strLastUpdateBy
	FROM @OrderHeaderInformation

	SELECT @intLastUpdateById = [intEntityId]
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