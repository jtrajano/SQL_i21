CREATE PROCEDURE [dbo].[uspMFCreateUpdateParentLotNumber]
	@strParentLotNumber NVARCHAR(50),
	@strParentLotAlias  NVARCHAR(50),
	@intItemId			INT,
	@dtmExpiryDate		DATETIME,
	@intLotStatusId		INT,
	@intUserId			INT,
	@dtmDate			DATETIME,
	@intLotId int
AS
Begin Try

Declare @ErrMsg nvarchar(Max)

Declare @intParentLotId int

Select @intParentLotId=intParentLotId From tblICParentLot Where strParentLotNumber=@strParentLotNumber

If @dtmDate is null Set @dtmDate=GETDATE()

If Not Exists (Select 1 From tblICLot Where intLotId=@intLotId)
	RaisError('Lot does not exist for parent lot creation.',16,1)

If ISNULL(@intParentLotId,0)=0
Begin
	INSERT INTO tblICParentLot(strParentLotNumber,strParentLotAlias,intItemId,dtmExpiryDate,intLotStatusId,intCreatedUserId,dtmDateCreated)
	Values(@strParentLotNumber,@strParentLotAlias,@intItemId,@dtmExpiryDate,@intLotStatusId,@intUserId,@dtmDate)

	Select @intParentLotId=SCOPE_IDENTITY()
	
	Update tblICLot Set intParentLotId=@intParentLotId Where intLotId=@intLotId
End
Else
Begin
	If (Select intItemId From tblICParentLot Where intParentLotId =@intParentLotId ) <> @intItemId
		RaisError('Lot and Parent Lot cannot have different item.',16,1)

	Update tblICLot Set intParentLotId=@intParentLotId Where intLotId=@intLotId	
End

End Try

Begin Catch
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
End Catch