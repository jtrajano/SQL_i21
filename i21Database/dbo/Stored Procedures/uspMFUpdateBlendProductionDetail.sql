CREATE PROCEDURE [dbo].[uspMFUpdateBlendProductionDetail]
	@strXml nVarchar(Max)
AS
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intWorkOrderId int
Declare @intStorageLocationId int
Declare @intUserId int
DECLARE @idoc int 
Declare @ErrMsg nVarchar(Max)
Declare @intBlendItemId int

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

 Select @intWorkOrderId=intWorkOrderId,
		@intStorageLocationId=intStorageLocationId ,
		@intUserId=intUserId,
		@intBlendItemId=intItemId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intWorkOrderId int, 
	intStorageLocationId int,
	intUserId int,
	intItemId int
	)

If @intStorageLocationId=0 
	Set @intStorageLocationId=null

Declare @tblLot table
(
	intRowNo int Identity(1,1),
	intWorkOrderId int,
	intWorkOrderConsumedLotId int,
	intLotId int,
	intItemId int,
	dblQty numeric(38,20),
	dblIssuedQuantity numeric(38,20),
	dblWeightPerUnit numeric(38,20),
	intItemUOMId int,
	intItemIssuedUOMId int,
	intRecipeItemId int,
	ysnStaged bit,
	intSubLocationId int,
	intStorageLocationId int
)

INSERT INTO @tblLot(
 intWorkOrderId,intWorkOrderConsumedLotId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,ysnStaged,intSubLocationId,intStorageLocationId)
 Select intWorkOrderId,intWorkOrderConsumedLotId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,ysnStaged,intSubLocationId,intStorageLocationId
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH (  
	intWorkOrderId int,
	intWorkOrderConsumedLotId int,
	intLotId int,
	intItemId int,
	dblQty numeric(38,20),
	intItemUOMId int,
	dblIssuedQuantity numeric(38,20),
	intItemIssuedUOMId int,
	dblWeightPerUnit numeric(38,20),
	intRecipeItemId int,
	ysnStaged bit,
	intSubLocationId int,
	intStorageLocationId int
	)

If (Select strLotTracking From tblICItem Where intItemId=@intBlendItemId)='No'
	Update @tblLot Set intLotId=NULL

Update @tblLot Set intSubLocationId=NULL Where intSubLocationId=0
Update @tblLot Set intStorageLocationId=NULL Where intStorageLocationId=0

Begin Tran

Delete From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId 
And intWorkOrderConsumedLotId not in (Select intWorkOrderConsumedLotId From @tblLot)

Insert into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,ysnStaged,intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified,intSubLocationId,intStorageLocationId)
Select intWorkOrderId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,ysnStaged,@intUserId,GetDate(),@intUserId,GetDate(),intSubLocationId,intStorageLocationId 
From @tblLot Where ISNULL(intWorkOrderConsumedLotId,0)=0

Update a Set a.intLotId=b.intLotId,
a.intItemId=b.intItemId,
a.dblQuantity=b.dblQty,
a.intItemUOMId=b.intItemUOMId,
a.dblIssuedQuantity=b.dblIssuedQuantity,
a.intItemIssuedUOMId=b.intItemIssuedUOMId,
a.intRecipeItemId=b.intRecipeItemId,
a.ysnStaged=b.ysnStaged,
a.intLastModifiedUserId=@intUserId,
a.dtmLastModified=GetDate(),
a.intSubLocationId=b.intSubLocationId,
a.intStorageLocationId=b.intStorageLocationId
From tblMFWorkOrderConsumedLot a Join @tblLot b  on a.intWorkOrderConsumedLotId=b.intWorkOrderConsumedLotId

Update tblMFWorkOrder 
Set dblQuantity=(Select sum(dblQuantity) From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId),
intStorageLocationId=@intStorageLocationId
Where intWorkOrderId=@intWorkOrderId

Commit Tran

EXEC sp_xml_removedocument @idoc 

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  