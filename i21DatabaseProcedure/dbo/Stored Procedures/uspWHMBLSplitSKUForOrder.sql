CREATE PROCEDURE [dbo].uspWHMBLSplitSKUForOrder   
 @strUserName NVARCHAR(32),   
 @strSourceContainerNo NVARCHAR(32),   
 @dblSplitQty NUMERIC(18, 6),   
 @strDestContainerNo NVARCHAR(32)  
AS  
BEGIN TRY  
 SET NOCOUNT ON  
 SET IMPLICIT_TRANSACTIONS ON  

 DECLARE @intOrderHeaderId INT  
 DECLARE @strSKUNo NVARCHAR(100)
 DECLARE @ysnGeneratePickTask BIT
 DECLARE @intSourceContainerId INT  
 DECLARE @intDestContainerId INT  
 DECLARE @strNewContainerNo NVARCHAR(32)  
 DECLARE @dblSKUdblQty NUMERIC(18, 6)  
 DECLARE @intSKUId INT  
 DECLARE @intNewSKUId INT  
 DECLARE @strSequenceText NVARCHAR(32)  
 DECLARE @intReturnValue INT  
 DECLARE @intTaskId INT  
 DECLARE @intSKUCount INT  
 DECLARE @strBOLNo NVARCHAR(64)  
 DECLARE @dblNegativeSplitQty NUMERIC(18, 6)  
 DECLARE @intMaterialControlId BIT  
 DECLARE @strstrLotCode NVARCHAR(32)  
 DECLARE @intTaskTypeId INT  
 DECLARE @intTaskNoCount INT  
 DECLARE @intAssigneeId INT  
 DECLARE @strErrMsg NVARCHAR(MAX)  
 DECLARE @strTaskType NVARCHAR(32)  
 DECLARE @intContainerNumber INT  
 DECLARE @intSKUNumber INT  
 DECLARE @strCycleCountTitle NVARCHAR(32)  
 DECLARE @intItemId INT  
 DECLARE @dblFullPalletdblQty NUMERIC(18, 6)  
 DECLARE @intComapnyLocationId INT  
 DECLARE @intCompanyLocationSubLocationId INT  
 DECLARE @strSubstituteValueList NVARCHAR(MAX)  
 DECLARE @intRestrictionId INT  
 DECLARE @intLocalTran tinyint  
 DECLARE @intUserId INT  
 DECLARE @dblTaskdblQty NUMERIC(18, 6)  
  
  
IF @@TRANCOUNT = 0 SET @intLocalTran= 1                  
IF @intLocalTran= 1 BEGIN TRANSACTION                  
  
 SET @strErrMsg = ''  
 SET @intSourceContainerId = 0  
 SET @intDestContainerId = 0  
 SET @dblSKUdblQty = 0.0  
 SET @intSKUId = 0  
 SET @strSequenceText = ''  
 SET @intTaskId = 0  
 SET @intSKUCount = 0  
 SET @strstrLotCode = ''  
 SET @dblTaskdblQty = 0.0  
 SET @intTaskTypeId = 0  
 SET @intItemId = 0  
 SET @dblFullPalletdblQty = 0.0  
 SET @intRestrictionId = 0  
 SET @intUserId = 0  
  
 SELECT @intUserId = [intEntityId] FROM tblSMUserSecurity WHERE strUserName = @strUserName--this is a hiccup  
 --Check the destination tblWHContainer code is at least 5 digits                
 IF LEN(@strDestContainerNo) > 0  
 BEGIN  
  IF LEN(@strDestContainerNo) < 3  
  BEGIN  
   --RAISERROR('The destination tblWHContainer code must be at least 3 characters.', 16, 1, 'WITH NOWAIT')               
   RAISERROR ('The destination Container No must be at least 3 characters.', 11, 1)  
  END  
 END  
   
 --Get BOL No  
 SELECT @strBOLNo = strBOLNo FROM tblWHOrderHeader WHERE intOrderHeaderId = @intOrderHeaderId  
   
 --Check that the Source tblWHContainer exists  
 SELECT @intSourceContainerId = c.intContainerId  
 FROM tblWHContainer c  
 INNER JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId  
 INNER JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId --AND l.intAddressId = @intAddressId  
 WHERE c.strContainerNo = @strSourceContainerNo  
  
  SELECT @strSKUNo=strSKUNo FROM tblWHSKU s
  JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
  WHERE c.strContainerNo = @strSourceContainerNo
  
 --To pull intCompanyLocationId and tblSMCompanyLocationSubLocation from source tblWHContainer  
 SELECT @intComapnyLocationId = l.intCompanyLocationId, @intCompanyLocationSubLocationId = l.intCompanyLocationSubLocationId  
 FROM tblWHContainer c  
 JOIN tblICStorageLocation u ON c.intStorageLocationId = u.intStorageLocationId  
 JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId  
 WHERE intContainerId = @intSourceContainerId  
  
 IF @intSourceContainerId = 0  
 BEGIN  
  RAISERROR ('The source Container no is invalid.', 11, 1)  
 END  
  
 --Check that the source tblWHContainer contains the SKU  
 SELECT @intSKUId = intSKUId, @dblSKUdblQty = dblQty, @strstrLotCode = strLotCode, @intItemId = intItemId  
 FROM tblWHSKU s  
 WHERE s.intContainerId = @intSourceContainerId  
  AND s.strSKUNo = @strSKUNo  
  
 IF @intSKUId = 0  
 BEGIN  
  RAISERROR ('The source container does not contain the expected SKU.', 11, 1)  
 END  
  
 IF @dblSplitQty > @dblSKUdblQty  
 BEGIN  
  RAISERROR ('The split quantity is invalid because it is greater than the SKU quantity.', 11, 1)  
 END  
  
 SELECT @dblFullPalletdblQty = intUnitsPerLayer * intLayersPerPallet  
 FROM tblWHSKU  
 WHERE intSKUId = @intSKUId  
  
 IF @dblSplitQty > ISNULL(@dblFullPalletdblQty, 1)  
 BEGIN  
  RAISERROR ('The split quantity is invalid because it is greater than the Cases per pallet.', 11, 1)  
 END  
  
 --Check if the SKU is associated with a load or ship task  
 SELECT @intTaskNoCount = COUNT(t.intTaskId)  
 FROM tblWHTask t  
 JOIN tblWHTaskType tt ON tt.intTaskTypeId = t.intTaskTypeId  
 WHERE t.intSKUId = @intSKUId AND tt.intTaskTypeId IN (3,4) --('LOAD,SHIP)  
  
 IF @intTaskNoCount > 0  
 BEGIN  
  RAISERROR ('Split is not allowed when the SKU is associated with load/ship task.', 11, 1)  
 END  
  
 SELECT @intTaskId = t.intTaskId, @intTaskTypeId = t.intTaskTypeId, @intAssigneeId = t.intAssigneeId, @dblTaskdblQty = t.dblQty, @strTaskType = tt.strTaskType  
 FROM tblWHTask t  
 LEFT JOIN tblWHTaskType tt ON tt.intTaskTypeId = t.intTaskTypeId  
 WHERE t.intSKUId = @intSKUId  
  AND t.strTaskNo = @strBOLNo -- Order wise update (Sep 11 - Pick Task)  
  AND t.intFromContainerId = @intSourceContainerId  
  AND (t.intTaskTypeId = 2 OR t.intTaskTypeId = 7 OR t.intTaskTypeId = 13) --PICK or SPLIT or PUT_BACK  
  AND t.intTaskStateId <> 5 --CANCELLED  
  
 --Determine if the SKU Product is lot tracked  
 --Tracking Type ID 1 means the product is lot tracked                              
  
 --Check that the Destination tblWHContainer exists  
 SELECT @intDestContainerId = c.intContainerId  
 FROM tblWHContainer c  
 INNER JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId  
 INNER JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId --AND l.intAddressId = @intAddressId  
 WHERE c.strContainerNo = @strDestContainerNo  
  
 IF EXISTS (SELECT * FROM tblWHContainer c JOIN tblWHSKU s ON s.intContainerId = c.intContainerId AND s.intContainerId = @intDestContainerId)  
 BEGIN  
  RAISERROR ('Split/Put back is not allowed because destination container already has an SKU. Please scan a new destination container.', 11, 1)  
 END  
  
 --If the destination tblWHContainer does not exists then create it.  
 IF ISNULL(@intDestContainerId,0) = 0  
 BEGIN  
  IF LEN(@strDestContainerNo) = 0  
  BEGIN  
   WHILE (1 = 1)  
   BEGIN  
       EXEC dbo.uspSMGetStartingNumber 74, @strNewContainerNo OUTPUT  
      
    IF NOT EXISTS (  
      SELECT *  
      FROM tblWHContainer c  
      INNER JOIN tblICStorageLocation u ON u.intStorageLocationId = c.intStorageLocationId  
      INNER JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationSubLocationId = u.intSubLocationId --AND l.intAddressId = @intAddressId    
      WHERE c.strContainerNo = @strNewContainerNo  
      )  
     BREAK;  
   END  
  
   SET @strDestContainerNo = @strNewContainerNo  
  END  
  
  INSERT INTO tblWHContainer (strContainerNo, intConcurrencyId, intContainerTypeId, intStorageLocationId)  
  SELECT @strDestContainerNo strContainerNo, 0, c2.intContainerTypeId, c2.intStorageLocationId  
  FROM tblWHContainer c2  
  WHERE c2.intContainerId = @intSourceContainerId  
  
  SET @intDestContainerId = SCOPE_IDENTITY()  
 END  
  
 --Need to delete and regenerate the task (pick/put back/ split)                
 --This value (0 or 1) is used (return back) in the webservice: MobileWS -> Web method:'SplitSKU'                   
 --to decide whether the method ‘Order_GeneratePickTasks’ (the task(s) needs to delete and regenerate)                   
 --needs to be call or not                  
 IF (  
   @dblTaskdblQty = @dblSplitQty  
   OR @intTaskTypeId = 0  
   )  
  AND @dblSplitQty <> @dblSKUdblQty  
  SET @ysnGeneratePickTask = 0 -- Not required to delete and regenerate the task (Means skip the method OrderRevisePickTasks)                          
 ELSE  
  SET @ysnGeneratePickTask = 1 -- Delete and regenerate the task (pick/put back/ split) (Means call the method OrderRevisePickTasks)                    
  
 IF EXISTS (SELECT *  
    FROM tblWHTask t  
    JOIN tblWHSKU s ON s.intSKUId = t.intSKUId  
    JOIN tblWHOrderHeader h ON h.intOrderHeaderId = t.intOrderHeaderId  
     AND h.strBOLNo <> @strBOLNo  
     AND t.intFromContainerId = @intSourceContainerId)  
       
  SET @ysnGeneratePickTask = 1 -- Delete and regenerate the task (pick/put back/ split) (Means call the method OrderRevisePickTasks)                    
  
 --If the split quantity is equal to the SKU quantity then we are just moving the SKU to a new tblWHContainer (merge)  
 IF @dblSKUdblQty = @dblSplitQty  
 BEGIN  
  UPDATE tblWHSKU  
  SET intContainerId = @intDestContainerId  
  WHERE intSKUId = @intSKUId  
  
  IF NOT EXISTS (  
    SELECT *  
    FROM tblWHSKU  
    WHERE intContainerId = @intSourceContainerId  
    )  
   DELETE tblWHContainer  
   WHERE intContainerId = @intSourceContainerId  
  
  UPDATE tblWHTask  
  SET intFromContainerId = @intDestContainerId, intLastModifiedUserId = @intUserId, dtmLastModified = GETDATE()  
  WHERE intTaskId = @intTaskId  
  
  SET @intNewSKUId = @intSKUId  
   --Update the SKU History  
   --EXEC WM_CreateSKUHistory @intSKUId, 10, @strUserName, @dblSplitQty  
 END  
  
  
 --If the split quantity is less than the SKU quantity then   
 --we need to create a new SKU on the destination tblWHContainer (split)  
  
  
 IF @dblSplitQty < @dblSKUdblQty  
 BEGIN  
  WHILE (1 = 1)  
  BEGIN  
   --Get the SKU code  
   --     EXEC @intReturnValue = [dbo].[GEN_GetNextSequence] 'SKU', @intSKUNumber OUT, @strSequenceText OUTPUT                        
   --       EXEC dbo.Pattern_GenerateID @intItemId=0,@intComapnyLocationId=@intComapnyLocationId,@intCompanyLocationSubLocationId=0,@intStorageLocationId=0,@CellKey=0,@intUserId=0,@PatternString=@strSKUNo OUTPUT,@PatternSettingName='WHPatternSKU'         
                                         
   EXEC dbo.uspSMGetStartingNumber 73, @strSKUNo OUTPUT  
     
   IF NOT EXISTS (SELECT * FROM tblWHSKU WHERE strSKUNo = @strSKUNo)  
    BREAK;  
  END  
  
  
  SELECT @intRestrictionId = intRestrictionId  
  FROM tblICStorageLocation  
  WHERE intStorageLocationId IN (  
    SELECT intStorageLocationId  
    FROM tblWHContainer  
    WHERE intContainerId = @intDestContainerId  
    )  
  
  EXEC dbo.uspSMGetStartingNumber 73,@strSKUNo OUTPUT  
  
  INSERT INTO tblWHSKU (strSKUNo, intConcurrencyId, intSKUStatusId, strLotCode, dblQty, dtmReceiveDate, dtmProductionDate, intItemId, intContainerId, intOwnerId, intLastModifiedUserId, dtmLastModified, intLotId, intUOMId, intParentSKUId, strParentSKUNo, intUnitsPerLayer, intLayersPerPallet, dblWeightPerUnit, intWeightPerUnitUOMId,strReasonCode,strComment)  
  SELECT @strSKUNo strSKUNo, 0, CASE   
    WHEN @intRestrictionId = 5  
     THEN 2  
    WHEN @intRestrictionId = 1  
     THEN intSKUStatusId  
    ELSE 1  
    END, strLotCode, @dblSplitQty dblQty, dtmReceiveDate, dtmProductionDate, intItemId, @intDestContainerId intContainerId, intOwnerId, @intUserId intLastModifiedUserId, GETDATE() dtmLastModified, intLotId, intUOMId, intSKUId, strSKUNo, intUnitsPerLayer, 
intLayersPerPallet, dblWeightPerUnit, intWeightPerUnitUOMId,'Split For Order',''  
  FROM tblWHSKU  
  WHERE intSKUId = @intSKUId;  
  
  SET @intNewSKUId = SCOPE_IDENTITY()  
  
  --Decrease the quantity of the source SKU                                               
  UPDATE tblWHSKU  
  SET dblQty = dblQty - @dblSplitQty, intLastModifiedUserId = @intUserId, dtmLastModified = GETDATE()  
  WHERE intSKUId = @intSKUId  
  
  --Update the SKU History  
  SET @dblNegativeSplitQty = @dblSplitQty * - 1  
   --EXEC WM_CreateSKUHistory @intSKUId, 7, @strUserName, @dblNegativeSplitQty  
   --EXEC WM_CreateSKUHistory @intNewSKUId, 7, @strUserName, @dblSplitQty  
 END  
  
  
 --If there is a SPLIT task for the SourceContainer then                                        
 --we need to change the task type to a PICK and set the state to in-progress                                              
 IF @intTaskId > 0  
 BEGIN  
  IF @intTaskTypeId = 7 --SPLIT  
  BEGIN  
   IF @dblSplitQty < @dblTaskdblQty  
   BEGIN  
    UPDATE tblWHTask  
    SET intTaskTypeId = 2, --PICK  
     intSKUId = @intSKUId,   
     intAssigneeId = @intAssigneeId,   
     intFromContainerId = @intSourceContainerId,   
     intLastModifiedUserId = @intUserId,   
     dtmLastModified = GETDATE()  
    WHERE intTaskId = @intTaskId  
   END  
   ELSE IF @dblSplitQty = @dblTaskdblQty  
   BEGIN  
    UPDATE tblWHTask  
    SET intTaskTypeId = 2, --PICK          
     intAssigneeId = @intAssigneeId,   
     intSKUId = @intNewSKUId,   
     intFromContainerId = @intDestContainerId,   
     intLastModifiedUserId = @intUserId,   
     dtmLastModified = GETDATE()  
    WHERE intTaskId = @intTaskId  
   END  
  END  
  
  IF @intTaskTypeId = 13 --PUT_BACK  The source tblWHContainer will have the quantity we need to pick  
  BEGIN  
   IF @dblSplitQty = @dblTaskdblQty  
   BEGIN  
    UPDATE tblWHTask  
    SET intTaskTypeId = 2, --PICK  
     intSKUId = @intSKUId,   
     intAssigneeId = @intAssigneeId,   
     dblQty = @dblSKUdblQty - @dblSplitQty,   
     intLastModifiedUserId = @intUserId,   
     dtmLastModified = GETDATE()  
    WHERE intTaskId = @intTaskId  
   END  
  END  
 END  
  
 IF @intLocalTran= 1 AND @@TRANCOUNT > 0 COMMIT TRANSACTION   
  
 SET IMPLICIT_TRANSACTIONS OFF  
END TRY  
  
BEGIN CATCH  
 IF @intLocalTran= 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION   
  
 SET IMPLICIT_TRANSACTIONS OFF  
 SET @strErrMsg = ERROR_MESSAGE()  
  
 IF @strErrMsg != ''  
 BEGIN  
  SET @strErrMsg = 'uspWHSplitSKUForOrder: ' + @strErrMsg  
  
  RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')  
 END  
END CATCH