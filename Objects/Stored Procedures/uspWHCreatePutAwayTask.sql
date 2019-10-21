CREATE PROCEDURE uspWHCreatePutAwayTask 
				@intOrderHeaderId INT, 
				@intSKUId INT, 
				@strUserName NVARCHAR(32), 
				@intCompanyLocationId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intLocalTran TINYINT
	DECLARE @intAddressId INT
	DECLARE @intToStorageLocationId INT
	DECLARE @intFromStorageLocationId INT
	DECLARE @intFromContainerId INT
	DECLARE @strTaskNo NVARCHAR(32)
	DECLARE @strTaskState NVARCHAR(16)
	DECLARE @dblQty FLOAT
	DECLARE @strAssignerComment NVARCHAR(max)
	DECLARE @intOrderStatusId INT
	DECLARE @intOrderTypeId INT
	DECLARE @intStatusId INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @tblTaskTable TABLE (intStorageLocationId INT, strStorageLocationName NVARCHAR(50))
	DECLARE @tblTempStorageLocationId TABLE (intStorageLocationId INT, strStorageLocationName NVARCHAR(50))
	DECLARE @tblTempEmptyStorageLocationId TABLE (intStorageLocationId INT)
	DECLARE @strSubstituteValueList NVARCHAR(MAX)
	DECLARE @tblItemTypeStorageLocationSuggestion TABLE (id INT Identity(1, 1), intItemCategoryId NUMERIC(18, 0), strSuggestion NVARCHAR(50), intPreference INT)
	DECLARE @intId INT
	DECLARE @strSuggestion NVARCHAR(50)
	DECLARE @ysnAllowCreateSKUContainer BIT
	DECLARE @strPutAway1 NVARCHAR(16)
	DECLARE @strPutAway2 NVARCHAR(16)
	DECLARE @strPutAway3 NVARCHAR(16)
	DECLARE @strAllowPutAwayUnitTypes NVARCHAR(MAX)
	DECLARE @intUserId INT
	DECLARE @intItemId INT
	
	


	SET @ysnAllowCreateSKUContainer = 1
	--SELECT @ysnAllowCreateSKUContainer = sv.SettingValue
	--FROM iMake_AppSetting s
	--JOIN iMake_AppSettingValue sv ON sv.SettingKey = s.SettingKey
	--WHERE s.SettingName = 'AllowCreateSKU/tblWHContainer'
	--	AND FactoryKey = IsNULL(@intCompanyLocationId, 0)
	
	SELECT @intUserId = [intEntityId] FROM tblSMUserSecurity WHERE strUserName = @strUserName
	SELECT @intItemId = intItemId FROM tblWHSKU WHERE intSKUId = @intSKUId
	
	SET @strAllowPutAwayUnitTypes = 'WH_FG_Storage,WH_RM_Storage'
	--SELECT @strAllowPutAwayUnitTypes = sv.SettingValue
	--FROM iMake_AppSetting s
	--JOIN iMake_AppSettingValue sv ON sv.SettingKey = s.SettingKey
	--WHERE s.SettingName = 'AllowPutAwayUnitTypes'
	--	AND FactoryKey = IsNULL(@intCompanyLocationId, 0)

	SET @strErrMsg = ''

	--If the task for this SKU has already been completed then exit    
	SELECT @strTaskState = ts.strInternalCode
	FROM tblWHTask t
	INNER JOIN tblWHTaskState ts ON ts.intTaskStateId = t.intTaskStateId
	WHERE intSKUId = @intSKUId
		AND intOrderHeaderId = @intOrderHeaderId
		AND intTaskTypeId = 5

	IF @strTaskState = 'COMPLETED'
		RETURN

	IF @@TRANCOUNT = 0
		SET @intLocalTran = 1

	IF @intLocalTran = 1
		BEGIN TRANSACTION

	--If a put away task already exists for this SKU then delete the task    
	DELETE
	FROM tblWHTask
	WHERE intSKUId = @intSKUId
		AND intOrderHeaderId = @intOrderHeaderId
		AND intTaskTypeId = 5 --PUT_AWAY    

	SELECT @intAddressId = intShipToAddressId, 
		   @strTaskNo = strBOLNo, 
		   @intFromStorageLocationId = intStagingLocationId, 
		   @strAssignerComment = strComment
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	--Get the source container id    
	SELECT @intFromContainerId = intContainerId, @dblQty = dblQty
	FROM tblWHSKU
	WHERE intSKUId = @intSKUId

	SELECT TOP 1 @intToStorageLocationId = intToStorageLocationId
	FROM tblWHTask
	WHERE intTaskStateId <> 4
		AND strTaskNo = @strTaskNo
		AND intTaskTypeId = 5

	IF (
			IsNull(@ysnAllowCreateSKUContainer, 0) = 1
			AND ISNULL(@intToStorageLocationId, 0) <> 0
			)
		GOTO label1

	INSERT INTO @tblTaskTable
	SELECT intStorageLocationId, u.strName
	FROM tblICStorageLocation u
	INNER JOIN tblSMCompanyLocationSubLocation loc ON loc.intCompanyLocationSubLocationId = u.intSubLocationId
		--AND LOC.intAddressId = @intAddressId
	INNER JOIN tblICStorageUnitType ut ON ut.intStorageUnitTypeId = u.intStorageUnitTypeId
		AND ut.strInternalCode IN ('WH_FG_STORAGE') --= 'WH_FG_STORAGE'  
	ORDER BY u.strName

	IF (IsNull(@ysnAllowCreateSKUContainer, 0) = 1)
	BEGIN
		--get a directed put-away location  
		IF IsNULL(@intToStorageLocationId, 0) = 0
		BEGIN
			DELETE
			FROM @tblTempStorageLocationId

			INSERT INTO @tblTempStorageLocationId (intStorageLocationId, strStorageLocationName)
			SELECT u.intStorageLocationId, u.strStorageLocationName
			FROM @tblTaskTable u
			INNER JOIN tblWHSKU s ON s.intSKUId = @intSKUId
			JOIN tblICItem m ON m.intItemId = s.intItemId
			JOIN tblICCategory mt ON mt.intCategoryId = m.intCategoryId
			--JOIN UnitMaterialTypeRestrictionMapping UMR ON umr.intItemCategoryId = mt.intItemCategoryId
			--	AND UMR.intStorageLocationId = u.intStorageLocationId
				AND u.intStorageLocationId NOT IN (
					SELECT DISTINCT IsNULL(intToStorageLocationId, 0)
					FROM tblWHTask
					WHERE intToStorageLocationId NOT IN (
							SELECT DISTINCT IsNULL(intToStorageLocationId, 0)
							FROM tblWHTask
							WHERE intTaskStateId <> 4
								AND strTaskNo = @strTaskNo
							)
					
					UNION ALL
					
					SELECT DISTINCT IsNULL(intStorageLocationId, 0)
					FROM tblWHContainer
					)
			ORDER BY u.strStorageLocationName
		END

		IF EXISTS (
				SELECT 1
				FROM @tblTempStorageLocationId
				)
		BEGIN
			SELECT @strPutAway1 = strMask1, @strPutAway2 = strMask2, @strPutAway3 = strMask3
			FROM tblWHSKU s
			JOIN tblICItem i ON i.intItemId = s.intItemId
			WHERE s.intSKUId = @intSKUId

			SELECT TOP 1 @intToStorageLocationId = intStorageLocationId
			FROM @tblTempStorageLocationId
			WHERE strStorageLocationName LIKE @strPutAway1

			--get a directed put-away location (2nd option)    
			IF IsNULL(@intToStorageLocationId, 0) = 0
				SELECT TOP 1 @intToStorageLocationId = intStorageLocationId
				FROM @tblTempStorageLocationId
				WHERE strStorageLocationName LIKE @strPutAway2

			--get a directed put-away location (3nd option)  
			IF IsNULL(@intToStorageLocationId, 0) = 0
				SELECT TOP 1 @intToStorageLocationId = intStorageLocationId
				FROM @tblTempStorageLocationId
				WHERE strStorageLocationName LIKE @strPutAway3

			--get a directed put-away location (material type suggestion)  
			--IF IsNULL(@intToStorageLocationId, 0) = 0
			--BEGIN
			--	DELETE
			--	FROM @tblItemTypeStorageLocationSuggestion

			--	INSERT INTO @tblItemTypeStorageLocationSuggestion (intItemCategoryId, strSuggestion, intPreference)
			--	SELECT ms.intItemCategoryId, strSuggestion, intPreference
			--	FROM MaterialTypeUnitSuggestion ms
			--	INNER JOIN tblICCategory mt ON mt.intItemCategoryId = ms.intItemCategoryId
			--	INNER JOIN tblICItem m ON m.intItemCategoryId = mt.intItemCategoryId
			--	INNER JOIN tblWHSKU s ON s.intItemId = m.intItemId
			--	WHERE s.intSKUId = @intSKUId
			--	ORDER BY intPreference

			--	SELECT @intId = MIN(id)
			--	FROM @tblItemTypeStorageLocationSuggestion

			--	WHILE (
			--			IsNull(@intId, 0) > 0
			--			AND IsNULL(@intToStorageLocationId, 0) = 0
			--			)
			--	BEGIN
			--		SELECT @strSuggestion = strSuggestion + '%'
			--		FROM @tblItemTypeStorageLocationSuggestion
			--		WHERE id = @intId

			--		SELECT TOP 1 @intToStorageLocationId = intStorageLocationId
			--		FROM @tblTempStorageLocationId
			--		WHERE strStorageLocationName LIKE @strSuggestion

			--		SELECT @intId = MIN(id)
			--		FROM @tblItemTypeStorageLocationSuggestion
			--		WHERE id > @intId
			--	END
			--END

			--if there was no directed put away location then find any empty location
			IF IsNULL(@intToStorageLocationId, 0) = 0
			BEGIN
				SELECT TOP 1 @intToStorageLocationId = intStorageLocationId
				FROM @tblTempStorageLocationId
			END
		END
		ELSE IF IsNULL(@intToStorageLocationId, 0) = 0
		BEGIN
			--SELECT TOP 1 @intToStorageLocationId = u.intStorageLocationId
			--FROM @tblTaskTable u
			--INNER JOIN tblWHSKU s ON s.intSKUId = @intSKUId
			----INNER JOIN MaterialPutAway p ON p.intItemId = s.intItemId AND p.intAddressId = @intAddressId 
			--JOIN tblICItem m ON m.intItemId = s.intItemId
			--JOIN tblICCategory mt ON mt.intCategoryId = m.intCategoryId
			--JOIN UnitMaterialTypeRestrictionMapping UMR ON umr.intItemCategoryId = mt.intItemCategoryId
			--	AND UMR.intStorageLocationId = u.intStorageLocationId
			--ORDER BY u.strStorageLocationName
						
			SELECT TOP 1 @intToStorageLocationId = sl.intStorageLocationId
			FROM tblICStorageLocation sl 
			JOIN tblICStorageUnitType ut ON ut.intStorageUnitTypeId = sl.intStorageUnitTypeId WHERE strInternalCode Like 'WH_FG_Storage%'

			IF IsNULL(@intToStorageLocationId, 0) = 0
			BEGIN
				SELECT @strSubstituteValueList = mt.strCategoryCode
				FROM tblWHSKU s
				JOIN tblICItem m ON m.intItemId = s.intItemId
				JOIN tblICCategory mt ON mt.intCategoryId = m.intCategoryId
				WHERE intSKUId = @intSKUId

				SET @strSubstituteValueList = @strSubstituteValueList + CHAR(182)
				RAISERROR ('No unit is configured for the tblICItem type. Please configure the required unit and proceed.', 16, 1)
			END
		END
	END

	label1:

	INSERT INTO tblWHTask (strTaskNo,intConcurrencyId, intTaskTypeId, intTaskStateId, intAddressId, intOrderHeaderId, intTaskPriorityId,intItemId, intFromStorageLocationId, intToStorageLocationId, intFromContainerId, intSKUId, dblQty, intCreatedUserId, dtmCreated, intLastModifiedUserId, dtmLastModified, strAssignerComment)
	VALUES (@strTaskNo,1, 5, 1, @intAddressId, @intOrderHeaderId, 2,@intItemId, @intFromStorageLocationId, @intToStorageLocationId, @intFromContainerId, @intSKUId, @dblQty, @intUserId, getutcdate(), @intUserId, getutcdate(), @strAssignerComment)

	SELECT SCOPE_IDENTITY()

	SELECT @intOrderStatusId = intOrderStatusId, @intOrderTypeId = intOrderTypeId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	IF @intOrderStatusId = 8
		AND @intOrderTypeId = 1
	BEGIN
		SELECT @intStatusId = TypeKey
		FROM WM_OrderStatus
		WHERE DisplayMember = 'CHECK-IN'

		UPDATE tblWHOrderHeader
		SET intOrderStatusId = @intStatusId
		WHERE intOrderHeaderId = @intOrderHeaderId
	END

	DELETE
	FROM tblWHTask
	WHERE dblQty <= 0

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
		SET @strErrMsg = 'uspWHCreatePutAwayTask: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH
