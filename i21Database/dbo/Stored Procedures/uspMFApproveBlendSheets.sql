CREATE PROCEDURE [dbo].[uspMFApproveBlendSheets]
	@strWorkOrderIds nvarchar(max),
	@intUserId int
AS
Begin Try

Declare @ErrMsg nvarchar(max)
Declare @dtmCurrentDateTime DateTime=GETDATE()
Declare @index int
Declare @id int

Declare @tblWorkOrder table
(
	intWorkOrderId int
)

--Get the Comma Separated Work Order Ids into a table
SET @index = CharIndex(',',@strWorkOrderIds)
WHILE @index > 0
BEGIN
        SET @id = SUBSTRING(@strWorkOrderIds,1,@index-1)
        SET @strWorkOrderIds = SUBSTRING(@strWorkOrderIds,@index+1,LEN(@strWorkOrderIds)-@index)

        INSERT INTO @tblWorkOrder(intWorkOrderId) values (@id)
        SET @index = CharIndex(',',@strWorkOrderIds)
END
SET @id=@strWorkOrderIds
INSERT INTO @tblWorkOrder(intWorkOrderId) values (@id)

IF EXISTS(SELECT 1 FROM tblMFWorkOrder WHERE intStatusId=9 AND intWorkOrderId IN (Select intWorkOrderId From @tblWorkOrder))
 BEGIN 
	RAISERROR('Some of the selected blend sheets are already approved.',16,1) 
 END

 UPDATE tblMFWorkOrder SET intStatusId = 9,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime 
 WHERE intWorkOrderId IN (Select intWorkOrderId From @tblWorkOrder)

 END TRY  
  
BEGIN CATCH  
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH