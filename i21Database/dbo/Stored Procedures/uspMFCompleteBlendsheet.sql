CREATE PROCEDURE [dbo].[uspMFCompleteBlendSheet] 
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@strErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intItemId int
		,@dblQtyToProduce NUMERIC(18, 6)
		,@intItemUOMId INT
		,@dblIssuedQuantity NUMERIC(18, 6)
		,@intItemIssuedUOMId INT
		,@dblWeightPerUnit NUMERIC(18, 6)
		,@intUserId INT
		,@strRetBatchId nVarchar(40)
		,@intStatusId int
		,@strWONo nvarchar(50)
		,@strProduceXml nvarchar(Max)
		,@intManufacturingProcessId int
		,@intLocationId int
		,@intSubLocationId int
		,@intStorageLocationId int
		,@strOutputLotNumber nvarchar(50)
		,@intAttributeId int
		,@ysnIsNegativeQuantityAllowed bit
		,@strIsNegativeQuantityAllowed nvarchar(50)
		,@dtmCurrentDate datetime=GetDate()
		,@intLotStatusId int
		,@strVesselNo nvarchar(50)

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	SELECT	 @intWorkOrderId = intWorkOrderId
			,@intItemId=intItemId
			,@dblQtyToProduce = dblQtyToProduce
			,@intItemUOMId = intItemUOMId
			,@dblIssuedQuantity = dblIssuedQuantity
			,@intItemIssuedUOMId = intItemIssuedUOMId
			,@dblWeightPerUnit = dblWeightPerUnit
			,@intUserId = intUserId
			,@intLocationId = intLocationId
			,@intStorageLocationId = intStorageLocationId
			,@strVesselNo = strVesselNo
	FROM OPENXML(@idoc, 'root', 2) WITH (
			 intWorkOrderId INT
			,intItemId int
			,dblQtyToProduce NUMERIC(18, 6)
			,intItemUOMId INT
			,dblIssuedQuantity NUMERIC(18, 6)
			,intItemIssuedUOMId INT
			,dblWeightPerUnit NUMERIC(18, 6)
			,intUserId INT
			,intLocationId int
			,intStorageLocationId int
			,strVesselNo nvarchar(50)
			)

	Select @intStatusId=intStatusId,@strWONo=strWorkOrderNo,@intManufacturingProcessId=ISNULL(intManufacturingProcessId,0) 
		From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
	
	If @intManufacturingProcessId=0
			Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId

	if(@intStatusId<>12)
		Begin
			Set @strErrMsg='Blend Sheet ' + @strWONo + ' is either not staged or already produced. Please reload the blend sheet.'
			RaisError(@strErrMsg,16,1)
		End

	Select @intSubLocationId = intSubLocationId From tblICStorageLocation Where intStorageLocationId=@intStorageLocationId

	Select @intLotStatusId=strAttributeValue
	From tblMFManufacturingProcessAttribute pa join tblMFAttribute at on pa.intAttributeId=at.intAttributeId 
	Where pa.intManufacturingProcessId=@intManufacturingProcessId and pa.intLocationId=@intLocationId and at.strAttributeName='Produce Lot Status'
	if @intLotStatusId=0 OR @intLotStatusId is null
			Set @intLotStatusId=1

	If @dblIssuedQuantity=0
	Begin
		Set @dblIssuedQuantity=@dblQtyToProduce
		Set @intItemIssuedUOMId=@intItemUOMId
		Set @dblWeightPerUnit=1
	End

	Begin Transaction

	Exec uspMFUpdateBlendProductionDetail @strXml=@strXml

	Set @strProduceXml='<root>'
	Set @strProduceXml=@strProduceXml + '<intWorkOrderId>' + convert(varchar,@intWorkOrderId) + '</intWorkOrderId>'
	Set @strProduceXml=@strProduceXml + '<intManufacturingProcessId>' + convert(varchar,@intManufacturingProcessId) + '</intManufacturingProcessId>'
	Set @strProduceXml=@strProduceXml + '<intStatusId>' + convert(varchar,12) + '</intStatusId>'
	Set @strProduceXml=@strProduceXml + '<intItemId>' + convert(varchar,@intItemId) + '</intItemId>'
	Set @strProduceXml=@strProduceXml + '<dblProduceQty>' + convert(varchar,@dblQtyToProduce) + '</dblProduceQty>'
	Set @strProduceXml=@strProduceXml + '<intProduceUnitMeasureId>' + convert(varchar,@intItemUOMId) + '</intProduceUnitMeasureId>'

	--If @dblIssuedQuantity>0
	--Begin
		Set @strProduceXml=@strProduceXml + '<dblPhysicalCount>' + convert(varchar,@dblIssuedQuantity) + '</dblPhysicalCount>'
		Set @strProduceXml=@strProduceXml + '<intPhysicalItemUOMId>' + convert(varchar,@intItemIssuedUOMId) + '</intPhysicalItemUOMId>'
		Set @strProduceXml=@strProduceXml + '<dblUnitQty>' + convert(varchar,@dblWeightPerUnit) + '</dblUnitQty>'
	--End

	Set @strProduceXml=@strProduceXml + '<strVesselNo>' + convert(varchar,@strVesselNo) + '</strVesselNo>'
	Set @strProduceXml=@strProduceXml + '<intUserId>' + convert(varchar,@intUserId) + '</intUserId>'
	--Set @strProduceXml=@strProduceXml + '<strOutputLotNumber>' + convert(varchar,'') + '</strOutputLotNumber>'
	Set @strProduceXml=@strProduceXml + '<intLocationId>' + convert(varchar,@intLocationId) + '</intLocationId>'
	Set @strProduceXml=@strProduceXml + '<intSubLocationId>' + convert(varchar,@intSubLocationId) + '</intSubLocationId>'
	Set @strProduceXml=@strProduceXml + '<intStorageLocationId>' + convert(varchar,@intStorageLocationId) + '</intStorageLocationId>'
	--Set @strProduceXml=@strProduceXml + '<ysnSubLotAllowed>' + convert(varchar,@intWorkOrderId) + '</ysnSubLotAllowed>'
	Set @strProduceXml=@strProduceXml + '<intProductionTypeId>' + convert(varchar,2) + '</intProductionTypeId>'
	Set @strProduceXml=@strProduceXml + '<strLotAlias>' + convert(varchar,@strWONo) + '</strLotAlias>'
	Set @strProduceXml=@strProduceXml + '<strVendorLotNo>' + convert(varchar,@strVesselNo) + '</strVendorLotNo>'
	Set @strProduceXml=@strProduceXml + '<intLotStatusId>' + convert(varchar,@intLotStatusId) + '</intLotStatusId>'
	Set @strProduceXml=@strProduceXml + '</root>'

	Exec uspMFCompleteWorkOrder @strXML=@strProduceXml,@strOutputLotNumber=@strOutputLotNumber OUT

	Update tblMFWorkOrder Set intStatusId=13,dtmActualProductionEndDate=@dtmCurrentDate,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDate 
	Where intWorkOrderId=@intWorkOrderId

	Commit Transaction

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
 
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @strErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  

END CATCH
