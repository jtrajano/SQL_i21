CREATE PROCEDURE uspWHLotExists
  
 @strLotNo nvarchar(30)  
AS  
  
BEGIN  
  
 DECLARE @intCount int  
  
 SET @intCount = 0  
  
 SELECT @intCount = Count(*) FROM tblICLot WHERE strLotNumber = @strLotNo
  
 IF @intCount IS NULL  
  SET @intCount = 0  
  
 SELECT @intCount  intLotCount
  
END