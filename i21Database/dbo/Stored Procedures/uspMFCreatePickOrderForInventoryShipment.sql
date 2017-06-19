CREATE PROCEDURE uspMFCreatePickOrderForInventoryShipment
		 @intInventoryShipmentId INT
		,@intUserId INT 
		,@intOrderHeaderId INT OUTPUT

AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intInventoryShipmentItemId INT
	DECLARE @strInventoryShipmentNo NVARCHAR(100)
	DECLARE @tblMFOrderHeader TABLE (intOrderHeaderId INT)
	DECLARE @intShipFromLocationId INT
	DECLARE @strOrderNo NVARCHAR(100)
	DECLARE @OrderHeaderInformation AS OrderHeaderInformation
	DECLARE @OrderDetailInformation AS OrderDetailInformation
	DECLARE @intStageLocationId INT
	DECLARE @dtmCurrentDate DATETIME
	DECLARE @strUserName NVARCHAR(100)
			,@strReferenceNo nvarchar(50)

	SELECT @strInventoryShipmentNo = strShipmentNumber,
		   @intShipFromLocationId = intShipFromLocationId,
		   @dtmCurrentDate = GETDATE(),
		   @strReferenceNo='Ref. # '+strReferenceNumber
	FROM tblICInventoryShipment
	WHERE intInventoryShipmentId = @intInventoryShipmentId

	SELECT @strUserName = strUserName
	FROM tblSMUserSecurity
	WHERE intEntityUserSecurityId = @intUserId

	EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
								   ,@intItemId = NULL
								   ,@intManufacturingId = NULL
								   ,@intSubLocationId = NULL
								   ,@intLocationId = @intShipFromLocationId
								   ,@intOrderTypeId = 6
								   ,@intBlendRequirementId = NULL
								   ,@intPatternCode = 75
								   ,@ysnProposed = 0
								   ,@strPatternString = @strOrderNo OUTPUT
								  
	SELECT @intStageLocationId = intDefaultShipmentStagingLocation FROM tblMFCompanyPreference

	IF EXISTS(SELECT 1 FROM tblMFOrderHeader WHERE strReferenceNo = @strInventoryShipmentNo)
	BEGIN
		SET @strErrMsg = 'Pick order has already been created for inventory shipment ' + @strInventoryShipmentNo +'.'
		RAISERROR(@strErrMsg,16,1)
	END

	INSERT INTO @OrderHeaderInformation (
		intOrderStatusId
		,intOrderTypeId
		,intOrderDirectionId
		,strOrderNo
		,strReferenceNo
		,intStagingLocationId
		,strComment
		,dtmOrderDate
		,strLastUpdateBy
		)
	SELECT 1
		,5
		,2
		,@strOrderNo
		,@strInventoryShipmentNo
		,@intStageLocationId
		,@strReferenceNo
		,@dtmCurrentDate
		,@strUserName
		
	INSERT INTO @tblMFOrderHeader
	EXEC dbo.uspMFCreateStagingOrder @OrderHeaderInformation = @OrderHeaderInformation

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM @tblMFOrderHeader

	INSERT INTO @OrderDetailInformation (
			intOrderHeaderId
			,intItemId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerUnit
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
			)
	SELECT @intOrderHeaderId
			,SHI.intItemId
			,SHI.dblQuantity
			,SHI.intItemUOMId
			,SHI.dblQuantity*I.dblWeight 
			,IU.intItemUOMId
			,I.dblWeight
			,ISNULL(NULL, I.intUnitPerLayer)
			,ISNULL(NULL, I.intLayerPerPallet)
			,(SELECT TOP 1 intPickListPreferenceId  FROM tblMFPickListPreference ) 
			,Row_Number() OVER (ORDER BY SHI.intInventoryShipmentItemId)
			,NULL
			,''
	FROM dbo.tblICInventoryShipment ISH
	JOIN tblICInventoryShipmentItem SHI ON SHI.intInventoryShipmentId = ISH.intInventoryShipmentId
	JOIN dbo.tblICItem I ON I.intItemId = SHI.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId and IU.intUnitMeasureId =I.intWeightUOMId
	--JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
	--JOIN dbo.tblICItem P ON SHI.intItemId = P.intItemId
	WHERE ISH.intInventoryShipmentId = @intInventoryShipmentId	

	EXEC dbo.uspMFCreateStagingOrderDetail @OrderDetailInformation = @OrderDetailInformation

END TRY

BEGIN CATCH
	
	SET @strErrMsg= ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')

END CATCH