CREATE PROCEDURE [dbo].[uspMFCreateStagingOrderDetail] 
					@OrderDetailInformation OrderDetailInformation READONLY
AS
BEGIN TRY
	DECLARE @idoc INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intOrderDetailId INT
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
	FROM @OrderDetailInformation

	SELECT @intLastUpdateById = [intEntityId]
	FROM tblSMUserSecurity
	WHERE strUserName = @strLastUpdateBy

	INSERT INTO tblMFOrderDetail (
		intConcurrencyId
		,intOrderHeaderId
		,intItemId
		,dblQty
		,intItemUOMId
		,dblWeight
		,intWeightUOMId
		,dblWeightPerQty
		,dblRequiredQty 
		,intLotId
		,strLotAlias
		,intUnitsPerLayer
		,intLayersPerPallet
		,intPreferenceId
		,dtmProductionDate
		,intLineNo
		,intSanitizationOrderDetailsId
		,strLineItemNote
		,intStagingLocationId 
		,intCreatedById
		,dtmCreatedOn
		,intLastUpdateById
		,dtmLastUpdateOn
		)
	SELECT 1
		,intOrderHeaderId
		,intItemId
		,dblQty
		,intItemUOMId
		,dblWeight
		,intWeightUOMId
		,dblWeightPerUnit
		,dblRequiredQty 
		,intLotId
		,strLotAlias
		,intUnitsPerLayer
		,intLayersPerPallet
		,intPreferenceId
		,dtmProductionDate
		,intLineNo
		,intSanitizationOrderDetailsId
		,strLineItemNote
		,intStagingLocationId 
		,@intLastUpdateById
		,GETDATE()
		,@intLastUpdateById
		,GETDATE()
	FROM @OrderDetailInformation

	SELECT @intOrderDetailId = SCOPE_IDENTITY()

	--Return the new Order Detail Id
	SELECT @intOrderDetailId

	IF @intLocalTran = 1
		AND @@TRANCOUNT > 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF @intLocalTran = 1
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspMFCreateStagingOrderDetail: ' + @strErrMsg

		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH