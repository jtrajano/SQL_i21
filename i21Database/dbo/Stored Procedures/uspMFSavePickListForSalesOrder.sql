CREATE PROCEDURE [dbo].[uspMFSavePickListForSalesOrder]
	@strXml nVarchar(Max),
	@intPickListIdOut int = 0 OUT
AS
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrMsg nvarchar(max)
DECLARE @idoc int 
DECLARE @intPickListId int=0
DECLARE @dtmCurrentDate DATETIME=GETDATE()
DECLARE @intConCurrencyId int
DECLARE @strPickListNo nVarchar(50)
DECLARE @intMinPickDetail int
Declare @intLocationId int
Declare @intSalesOrderId INT
Declare @strSalesOrderNumber NVARCHAR(50)
Declare @intItemId INT
Declare @dblReqQty NUMERIC(38,20)
Declare @strItemNo nvarchar(50)
Declare @dblSelQty NUMERIC(38,20)
Declare @strUOM nvarchar(50)
Declare @intItemUOMId int

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

Declare @tblPickList table
(
	intPickListId int,
	strPickListNo nvarchar(50),
	strWorkOrderNo nvarchar(max),
	intAssignedToId int,
	intLocationId int,
	intSalesOrderId int,
	intUserId int
)

Declare @tblPickListDetail table
(
	intRowNo int IDENTITY(1,1),
	intPickListId int,
	intPickListDetailId int,
	intLotId int,
	intParentLotId int,
	intItemId int,
	intStorageLocationId int,
	intSubLocationId int,
	intLocationId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblIssuedQuantity  numeric(38,20),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(38,20),
	intPickUOMId int,
	intUserId int
)

INSERT INTO @tblPickList(
 intPickListId,strPickListNo,strWorkOrderNo,intAssignedToId,intLocationId,intSalesOrderId,intUserId)
 Select intPickListId,strPickListNo,strWorkOrderNo,intAssignedToId,intLocationId,intSalesOrderId,intUserId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intPickListId int, 
	strPickListNo nvarchar(50),
	strWorkOrderNo nvarchar(max),
	intAssignedToId int,
	intLocationId int,
	intSalesOrderId int,
	intUserId int
	)

INSERT INTO @tblPickListDetail(
 intPickListId,intPickListDetailId,intLotId,intParentLotId,intItemId,intStorageLocationId,intSubLocationId,intLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
 dblPickQuantity,intPickUOMId,intUserId)
 Select intPickListId,intPickListDetailId,intLotId,intParentLotId,intItemId,intStorageLocationId,intSubLocationId,intLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
 dblPickQuantity,intPickUOMId,intUserId
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH ( 
	intPickListId int,
	intPickListDetailId int,
	intLotId int,
	intParentLotId int,
	intItemId int,
	intStorageLocationId int,
	intSubLocationId int,
	intLocationId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblIssuedQuantity  numeric(38,20),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(38,20),
	intPickUOMId int,
	intUserId int
	)

Delete From @tblPickListDetail Where ISNULL(dblPickQuantity,0)=0

Select TOP 1 @intSalesOrderId=intSalesOrderId From @tblPickList
Select @strSalesOrderNumber=strSalesOrderNumber,@intLocationId=intCompanyLocationId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId
Select @intPickListId=intPickListId From tblMFPickList Where intSalesOrderId=ISNULL(@intSalesOrderId,0)

If Exists (Select 1 From tblICInventoryShipment sh Join tblICInventoryShipmentItem sd on sh.intInventoryShipmentId=sd.intInventoryShipmentId 
	Where sh.intOrderType=2 AND sd.intOrderId=@intSalesOrderId)
	RaisError('Shipmnet is alredy created for the sales order.',16,1)

Update @tblPickListDetail set intLotId=NULL Where ISNULL(intLotId,0)=0
Update @tblPickListDetail set intSubLocationId=NULL Where ISNULL(intSubLocationId,0)=0
Update @tblPickListDetail set intStorageLocationId=NULL Where ISNULL(intStorageLocationId,0)=0
Update @tblPickListDetail Set intParentLotId=NULL Where ISNULL(intLotId,0)=0

Begin Tran

If ISNULL(@intPickListId,0)=0
Begin
	EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
						,@intItemId = NULL
						,@intManufacturingId = NULL
						,@intSubLocationId = NULL
						,@intLocationId = @intLocationId
						,@intOrderTypeId = NULL
						,@intBlendRequirementId = NULL
						,@intPatternCode = 68
						,@ysnProposed = 0
						,@strPatternString = @strPickListNo OUTPUT

	Insert Into tblMFPickList(strPickListNo,strWorkOrderNo,intKitStatusId,intAssignedToId,intLocationId,intSalesOrderId,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
	Select @strPickListNo,@strSalesOrderNumber,7,intAssignedToId,@intLocationId,@intSalesOrderId,@dtmCurrentDate,intUserId,@dtmCurrentDate,intUserId,1 From @tblPickList

	SET @intPickListId=SCOPE_IDENTITY()

	Insert Into tblMFPickListDetail(intPickListId,intLotId,intParentLotId,intItemId,intStorageLocationId,intSubLocationId,intLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intStageLotId,
	dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
	Select @intPickListId,intLotId,intParentLotId,intItemId,intStorageLocationId,intSubLocationId,intLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intLotId,
	@dtmCurrentDate,intUserId,@dtmCurrentDate,intUserId,1
	from @tblPickListDetail

End
Else
Begin
	Update pld Set pld.dblPickQuantity=tpld.dblPickQuantity,pld.dblQuantity=tpld.dblQuantity,pld.dblIssuedQuantity=tpld.dblIssuedQuantity,
	pld.intLotId=tpld.intLotId,pld.intStageLotId=tpld.intLotId,pld.intParentLotId=tpld.intParentLotId,
	pld.intStorageLocationId=tpld.intStorageLocationId,pld.intSubLocationId=tpld.intSubLocationId,pld.intLocationId=tpld.intLocationId,
	pld.intItemUOMId=tpld.intItemUOMId,pld.intItemIssuedUOMId=tpld.intItemIssuedUOMId,pld.intPickUOMId=tpld.intPickUOMId,
	pld.intLastModifiedUserId=tpld.intUserId,pld.dtmLastModified=@dtmCurrentDate,pld.intConcurrencyId=ISNULL(pld.intConcurrencyId,0) + 1,
	pld.intItemId=tpld.intItemId
	From tblMFPickListDetail pld Join @tblPickListDetail tpld on pld.intPickListDetailId=tpld.intPickListDetailId 
	Where pld.intPickListId=@intPickListId

	--Delete Records if not there in @tblPickListDetail table
	Delete From tblMFPickListDetail Where intPickListId=@intPickListId AND 
	intPickListDetailId NOT IN (Select intPickListDetailId From @tblPickListDetail) AND intLotId=intStageLotId

	--insert new picked lots
	Insert Into tblMFPickListDetail(intPickListId,intLotId,intParentLotId,intItemId,intStorageLocationId,intSubLocationId,intLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intStageLotId,
	dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intConcurrencyId)
	Select @intPickListId,intLotId,intParentLotId,intItemId,intStorageLocationId,intSubLocationId,intLocationId,
	dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblPickQuantity,intPickUOMId,intLotId,
	@dtmCurrentDate,intUserId,@dtmCurrentDate,intUserId,1
	from @tblPickListDetail Where intPickListDetailId=0
End

SET @intPickListIdOut=@intPickListId

--Reserve Lots
Exec [uspMFCreateLotReservationByPickList] @intPickListId,''

Commit Tran

EXEC sp_xml_removedocument @idoc 

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  
