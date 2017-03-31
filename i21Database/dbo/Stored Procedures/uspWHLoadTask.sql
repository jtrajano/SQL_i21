CREATE PROCEDURE [dbo].[uspWHLoadTask]
			@intOrderHeaderId INT, 
			@strUserName NVARCHAR(32), 			
			@ysnCycleCount BIT = 0
AS	
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intContainerId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intTaskId INT
	DECLARE @intUserSecurityId INT
	DECLARE @intSKUId INT
	DECLARE @intTaskTypeId INT
	DECLARE @intDockDoorLocationId INT
	DECLARE @intStagingLocationId INT
	DECLARE @intSourceLocationId INT
	DECLARE @intSKUsPerContainer INT
	DECLARE @intTasksPerContainer INT
	DECLARE @intOrdersPerContainer INT
	DECLARE @intSKUHistoryId INT
	DECLARE @intSplitTaskCount INT
	DECLARE @intOrderStatusId INT
	DECLARE @intOrderDirectionId INT
	DECLARE @intToLocationId INT
	DECLARE @intStorageLocationRestrictionId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @intTaskStateId INT
	DECLARE @intSourceSubLocationId INT
	DECLARE @intTaskRecordId INT
		
	DECLARE @strTaskType NVARCHAR(32)
	DECLARE @strTaskState NVARCHAR(32)
	DECLARE @strSourceStorageLocationType NVARCHAR(32)
	DECLARE @strDestStorageLocationType NVARCHAR(32)
	DECLARE @strCycleCountTitle NVARCHAR(32)
	DECLARE @strICStorageLocationRestriction NVARCHAR(50)
	DECLARE @strSubstituteValueList NVARCHAR(MAX)
	DECLARE @strStorageLocationRestriction NVARCHAR(MAX) --BugID:1702           
	DECLARE @strSSCCNo NVARCHAR(MAX)
	DECLARE @strBarCodeText NVARCHAR(MAX)
	DECLARE @strAllowCreateSKUContainer NVARCHAR(10)
	DECLARE @strAllowMoveContainerFromSourceStorageLocation NVARCHAR(MAX)
	DECLARE @strErrMsg NVARCHAR(MAX)
	
	DECLARE @ysnAllowMoveAssignedTask BIT
	DECLARE @intLocalTran TINYINT
	

	IF @@TRANCOUNT = 0
		SET @intLocalTran = 1

	IF @intLocalTran = 1
		BEGIN TRANSACTION
		
	SET @strErrMsg = ''
	SET @intContainerId = 0
	SET @intStorageLocationId = 0
	SET @intTaskId = 0
	SET @intSKUId = 0
	SET @intTaskTypeId = 0
	SET @intDockDoorLocationId = 0
	SET @intStagingLocationId = 0
	SET @intSKUsPerContainer = 0
	SET @intTasksPerContainer = 0
	SET @intOrdersPerContainer = 0
	SET @intSplitTaskCount = 0
	SET @strSSCCNo = ''
	SET @ysnAllowMoveAssignedTask = 0

	BEGIN
	
		DECLARE @tblTask TABLE 
		(intTaskRecordId INT Identity(1, 1),
		intOrderHeaderId INT, 
		intTaskId INT,
		intFromContainerId INT
		)
		--Get Container Id
	--	SELECT @intContainerId = intContainerId FROM tblWHContainer WHERE strContainerNo = @strContainerNo
	
		--GET ALL THE TASKS
		INSERT INTO @tblTask (
					intOrderHeaderId, 
					intTaskId, 
					intFromContainerId)
		SELECT intOrderHeaderId, 
			   intTaskId, 
			   intFromContainerId
		FROM tblWHTask
		WHERE intOrderHeaderId = @intOrderHeaderId AND intTaskTypeId = 3
		
		SELECT @intTaskRecordId = MIN(intTaskRecordId) FROM @tblTask
		 
		WHILE (@intTaskRecordId IS NOT NULL)
		BEGIN
		
			SELECT @intTaskId = intTaskId 
			FROM @tblTask 
			WHERE intTaskRecordId = @intTaskRecordId				

		--Get all the information based on the supplied container no.
			SELECT @intSKUId=t.intSKUId,                                                 
				   @intOrderHeaderId=t.intOrderHeaderId,                                                
				   @intTaskTypeId=t.intTaskTypeId,                                                
				   @strTaskType=tt.strInternalCode,                                                
				   @strTaskState=ts.strInternalCode,
				   @intToLocationId = intToStorageLocationId
			FROM tblWHTask t                                                
			INNER JOIN tblWHTaskState ts ON ts.intTaskStateId= t.intTaskStateId                                               
			INNER JOIN tblWHTaskType tt ON tt.intTaskTypeId = t.intTaskTypeId                                                
			WHERE intTaskId = @intTaskId
			AND ts.strInternalCode <> 'CANCELLED'  
		
	
		--Get all the info we need to process the tasks for each SKU on this container
			SELECT @intDockDoorLocationId = ISNULL(t.intDockDoorLocationId, 0), 
				   @intStagingLocationId = ISNULL(h.intStagingLocationId, 0)
			FROM tblWHOrderHeader h
			LEFT JOIN tblWHTruck t ON t.intTruckId = h.intTruckId
			WHERE h.intOrderHeaderId = @intOrderHeaderId
			
		 --Check that the StorageLocation exists        	
			SELECT @intStorageLocationId = u.intStorageLocationId, 
				   @strDestStorageLocationType = ut.strInternalCode, 
				   @strICStorageLocationRestriction = ur.strDisplayMember
			FROM tblICStorageLocation u                            
			INNER JOIN tblICStorageUnitType ut ON ut.intStorageUnitTypeId = u.intStorageUnitTypeId 
			INNER JOIN tblICRestriction ur ON ur.intRestrictionId=u.intRestrictionId     
			INNER JOIN tblSMCompanyLocationSubLocation l ON u.intSubLocationId = l.intCompanyLocationSubLocationId                                                 
			WHERE u.intStorageLocationId = @intToLocationId
			
		--Get the User Id 
			SELECT @intUserSecurityId = [intEntityId] FROM tblSMUserSecurity WHERE strUserName = @strUserName--this is a hiccup
			
			IF @intStorageLocationId = 0                                                 
			BEGIN                                                
				RAISERROR('The destination location code is invalid or not active',11,1)                                              
			END 


			IF @strTaskType = 'PICK' OR @strTaskType = 'LOAD' OR @strTaskType = 'SHIP'
			BEGIN
				-- If the destination tblSMCompanyLocationSubLocation is the staging tblSMCompanyLocationSubLocation then set the state to "IN-PROGRESS" and change the type to "LOAD"                                                
				IF @intStorageLocationId = @intStagingLocationId
				BEGIN
					UPDATE tblWHTask
					SET intTaskStateId = 3, --IN-PROGRESS                     
						intTaskTypeId = 3, --LOAD                
						intFromStorageLocationId = @intStorageLocationId, 
						intToStorageLocationId = @intDockDoorLocationId
					WHERE intTaskId = @intTaskId

					
					UPDATE c 
					SET intStorageLocationId = t.intFromStorageLocationId,
						intLastModifiedUserId = @intUserSecurityId,                        
						dtmLastModified = GETDATE()     
					FROM tblWHContainer c
					JOIN tblWHTask t ON t.intFromContainerId = c.intContainerId
					JOIN tblICStorageLocation l ON l.intStorageLocationId = t.intFromStorageLocationId 
					JOIN tblICStorageLocation l1 ON l1.intStorageLocationId = c.intStorageLocationId 
					WHERE intTaskId = @intTaskId

				END

				-- If the destination tblSMCompanyLocationSubLocation is the dock door tblSMCompanyLocationSubLocation then set the state to "COMPLETED" and change the type to "SHIP"                                                
				IF @intStorageLocationId = @intDockDoorLocationId
				BEGIN
					UPDATE tblWHTask
					SET intTaskStateId = 4, --COMPLETED                                                
						intTaskTypeId = 4, --SHIP                   
						intFromStorageLocationId = @intStorageLocationId, 
						intToStorageLocationId = @intStorageLocationId, 
						intLastModifiedUserId = @intUserSecurityId, 
						dtmLastModified = GETDATE()
					WHERE intTaskId = @intTaskId
					
					UPDATE c 
					SET intStorageLocationId = t.intFromStorageLocationId,
						intLastModifiedUserId = @intUserSecurityId,                        
						dtmLastModified = GETDATE()     
					FROM tblWHContainer c
					JOIN tblWHTask t ON t.intFromContainerId = c.intContainerId
					JOIN tblICStorageLocation l ON l.intStorageLocationId = t.intFromStorageLocationId 
					JOIN tblICStorageLocation l1 ON l1.intStorageLocationId = c.intStorageLocationId 
					WHERE intTaskId = @intTaskId

				END

				SELECT @intTaskStateId = intTaskStateId
				FROM tblWHTask
				WHERE intTaskId = @intTaskId

				IF @intTaskStateId = 4
					AND @strDestStorageLocationType <> ('WH_DOCK_DOOR')
				BEGIN
					UPDATE tblWHTask
					SET intTaskStateId = 3 -- IN_Progress  
					WHERE intTaskId = @intTaskId
				END

				--The container is being moved to a tblSMCompanyLocationSubLocation othen than staging or dock door tblSMCompanyLocationSubLocation            
				IF (@intStorageLocationId <> @intStagingLocationId)
					AND (@intStorageLocationId <> @intDockDoorLocationId)
					AND @strDestStorageLocationType = 'WH_Transport'
				BEGIN
					UPDATE tblWHTask
					SET intTaskStateId = 3 --IN-PROCESS                                                  
					WHERE intTaskId = @intTaskId
				END

				IF (@intStorageLocationId <> @intStagingLocationId)
					AND (@intStorageLocationId <> @intDockDoorLocationId)
				BEGIN
					UPDATE tblWHTask
					SET intTaskTypeId = 2, --PICK                                                
						intFromStorageLocationId = @intStorageLocationId, 
						intToStorageLocationId = @intStagingLocationId, 
						intLastModifiedUserId = @intUserSecurityId, 
						dtmLastModified = GETDATE()
					WHERE intTaskId = @intTaskId

					DELETE
					FROM tblWHOrderManifest
					WHERE intSKUId = @intSKUId
				END

				--Update the order manifest                                   
				IF (@intStorageLocationId = @intStagingLocationId)
					OR (@intStorageLocationId = @intDockDoorLocationId)
				BEGIN
					DELETE
					FROM tblWHOrderManifest
					WHERE intSKUId = @intSKUId

					--Create a Manifest record                                                
					INSERT INTO tblWHOrderManifest (intConcurrencyId,intOrderLineItemId, intOrderHeaderId, strManifestItemNote, intSKUId, intLastUpdateId, dtmLastUpdateOn, strSSCCNo)
					SELECT 0,i.intOrderLineItemId, h.intOrderHeaderId, '' ManifestItemNote, s.intSKUId, 1 intLastModifiedUserId, GETDATE() dtmLastModified, 1
					FROM tblWHOrderHeader h
					INNER JOIN tblWHOrderLineItem i ON i.intOrderHeaderId = h.intOrderHeaderId
					INNER JOIN tblWHSKU s ON s.intItemId = i.intItemId
						AND s.intSKUId = @intSKUId
						AND s.strLotCode = (
							CASE 
								WHEN i.strLotAlias <> ''
									THEN i.strLotAlias
								ELSE s.strLotCode
								END
							)
						AND ISNULL(s.intLotId, 0) = (
							CASE 
								WHEN ISNULL(i.intLotId, 0) > 0
									THEN ISNULL(i.intLotId, 0)
								ELSE ISNULL(s.intLotId, 0)
								END
							)
					WHERE h.intOrderHeaderId = @intOrderHeaderId
				END
			END --IF @strTaskType = 'PICK' OR @strTaskType = 'LOAD' OR @strTaskType = 'SHIP'       
			
			                                          
			IF (@strSourceStorageLocationType IN ('WH_STAGING','WH_DOCK_DOOR')) AND @strDestStorageLocationType = 'WH_FG_STORAGE'
			BEGIN
				UPDATE tblWHTask
				SET intTaskStateId = 3 --IN-PROGRESS                                                
				WHERE intTaskId = @intTaskId
			END


			SELECT @intOrderDirectionId = intOrderDirectionId
			FROM tblWHOrderHeader
			WHERE intOrderHeaderId = @intOrderHeaderId


			IF @intOrderDirectionId = 2
			BEGIN
			
				IF (	SELECT count(*)
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId AND intTaskTypeId IN (2,7,13)) --PICK,SPLIT,PUT_BACK                                          
					= 
				   (
						SELECT count(*)
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId
				   )
				BEGIN
					SELECT @intOrderStatusId = intOrderStatusId
					FROM tblWHOrderStatus
					WHERE strOrderStatus = 'RELEASED'

					UPDATE tblWHOrderHeader
					SET intOrderStatusId = @intOrderStatusId
					WHERE intOrderHeaderId = @intOrderHeaderId
				END
				ELSE IF (
						SELECT count(*)
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId
							AND intTaskTypeId = 3
						) --LOAD                                                
					= (
						SELECT count(*)
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId
						)
				BEGIN
					SELECT @intOrderStatusId = intOrderStatusId
					FROM tblWHOrderStatus
					WHERE strOrderStatus = 'STAGED'

					UPDATE tblWHOrderHeader
					SET intOrderStatusId = @intOrderStatusId
					WHERE intOrderHeaderId = @intOrderHeaderId
				END
				ELSE IF (
						SELECT count(*)
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId
							AND intTaskTypeId = 4
						) --SHIP                                                
					= (
						SELECT count(*)
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId
						)
				BEGIN
					SELECT @intOrderStatusId = intOrderStatusId
					FROM tblWHOrderStatus
					WHERE strOrderStatus = 'LOADED'

					UPDATE tblWHOrderHeader
					SET intOrderStatusId = @intOrderStatusId
					WHERE intOrderHeaderId = @intOrderHeaderId
				END
				ELSE IF EXISTS (
						SELECT *
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId
							AND intTaskTypeId IN (
								2
								,7
								,13
								)
						) --'PICK','SPLIT','PUT_BACK'                                               
				BEGIN
					SELECT @intOrderStatusId = intOrderStatusId
					FROM tblWHOrderStatus
					WHERE strOrderStatus = 'PICKING'

					UPDATE tblWHOrderHeader
					SET intOrderStatusId = @intOrderStatusId
					WHERE intOrderHeaderId = @intOrderHeaderId
				END
				ELSE IF EXISTS (
						SELECT *
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId
							AND intTaskTypeId IN (3)
						) --LOAD                                      
				BEGIN
					SELECT @intOrderStatusId = intOrderStatusId
					FROM tblWHOrderStatus
					WHERE strOrderStatus = 'LOADING'

					UPDATE tblWHOrderHeader
					SET intOrderStatusId = @intOrderStatusId
					WHERE intOrderHeaderId = @intOrderHeaderId
				END
			END

			IF @intOrderDirectionId = 1
			BEGIN
				IF (
						SELECT count(*)
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId
							AND intTaskStateId = 4
						) = (
						SELECT count(*)
						FROM tblWHTask
						WHERE intOrderHeaderId = @intOrderHeaderId
						)
					UPDATE tblWHOrderHeader
					SET intOrderStatusId = 256
					WHERE intOrderHeaderId = @intOrderHeaderId --PUT-AWAY                                                
			END
			SELECT @intTaskRecordId = MIN(intTaskRecordId)
			FROM @tblTask WHERE intTaskRecordId > @intTaskRecordId	
		END


	END
	
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
		SET @strErrMsg = 'uspWHCompleteTask: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH
