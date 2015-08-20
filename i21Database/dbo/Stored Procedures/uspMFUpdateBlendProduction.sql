CREATE PROCEDURE [dbo].[uspMFUpdateBlendProduction]
	@intWorkOrderId int,
	@intStatusId int,
	@dtmDueDate DateTime,
	@intExecutionOrder int,
	@intStorageLocationId int,
	@strComment nVarchar(Max),
	@intUserId int
AS

Declare @intCurrentExecutionOrder int
Declare @dtmCurrentDueDate DateTime

If @intStorageLocationId=0 
	Set @intStorageLocationId=null


If @intStatusId=9 
Begin
	Declare @tblWO as table
	(
		intWOId int,
		intExecNo int
	)
	Select @dtmCurrentDueDate=dtmExpectedDate,@intCurrentExecutionOrder=intExecutionOrder From tblMFWorkOrder where intWorkOrderId=@intWorkOrderId

	If Convert(date,@dtmDueDate) <> convert(date,@dtmCurrentDueDate)
		Begin
			Select @intExecutionOrder = ISNULL(Max(intExecutionOrder),0) + 1 From tblMFWorkOrder Where Convert(date,dtmExpectedDate) =convert(date,@dtmDueDate)

			insert into @tblWO(intWOId,intExecNo)
			Select intWorkOrderId,intExecutionOrder-1 From tblMFWorkOrder 
			where intExecutionOrder>@intCurrentExecutionOrder 
			And Convert(date,dtmExpectedDate) = convert(date,@dtmCurrentDueDate) 
			Order by intExecutionOrder
		End
	Else
		Begin
			If @intExecutionOrder > @intCurrentExecutionOrder
				Begin
					insert into @tblWO(intWOId,intExecNo)
					Select intWorkOrderId,intExecutionOrder-1 From tblMFWorkOrder 
					where intExecutionOrder>@intCurrentExecutionOrder And intExecutionOrder<=@intExecutionOrder 
					And Convert(date,dtmExpectedDate) = convert(date,@dtmCurrentDueDate) 
					Order by intExecutionOrder
				End

			If @intExecutionOrder < @intCurrentExecutionOrder
				Begin
					insert into @tblWO(intWOId,intExecNo)
					Select intWorkOrderId,intExecutionOrder+1 From tblMFWorkOrder 
					where intExecutionOrder>=@intExecutionOrder And intExecutionOrder<@intCurrentExecutionOrder  
					And Convert(date,dtmExpectedDate) = convert(date,@dtmCurrentDueDate) 
					Order by intExecutionOrder
				End
		End

	Update tblMFWorkOrder Set intStorageLocationId=@intStorageLocationId,strComment=@strComment,
	dtmExpectedDate=Convert(date,@dtmDueDate),intExecutionOrder=@intExecutionOrder,
	dtmLastModified=GetDate(),intLastModifiedUserId=@intUserId 
	Where intWorkOrderId=@intWorkOrderId

	If (Select count(1) From @tblWO) > 0
		Update a Set a.intExecutionOrder=b.intExecNo From tblMFWorkOrder a Join @tblWO b on a.intWorkOrderId=b.intWOId
End
Else
Begin
	Update tblMFWorkOrder Set intStorageLocationId=@intStorageLocationId,strComment=@strComment,
	dtmLastModified=GetDate(),intLastModifiedUserId=@intUserId 
	Where intWorkOrderId=@intWorkOrderId
End