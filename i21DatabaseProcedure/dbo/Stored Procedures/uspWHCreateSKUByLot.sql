CREATE PROCEDURE [dbo].[uspWHCreateSKUByLot]
			@strUserName NVARCHAR(32), 
			@intCompanyLocationSubLocationId INT, 
			@intDefaultStagingLocationId INT, 
			@intItemId INT, 
			@dblQty NUMERIC(18,6), 
			@intLotId INT, 
			@dtmProductionDate DATETIME, 
			@intOwnerAddressId INT, 
			@ysnStatus BIT = 0, 
			@strPalletLotCode NVARCHAR(30) = NULL, 
			@ysnUseContainerPattern BIT = 0, 
			@intUOMId INT = NULL, 
			@intUnitPerLayer INT = NULL, 
			@intLayersPerPallet INT = NULL, 
			@ysnForced BIT = 1, 
			@ysnSanitized BIT = 0, 
			@strBatchNo NVARCHAR(30) = NULL, 
			@intSKUId INT = NULL OUTPUT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intLocalTran TINYINT
	DECLARE @strErrMsg NVARCHAR(MAX)

	SET @strErrMsg = ''

	DECLARE @intContainerId INT
	DECLARE @intContainerTypeId INT
	DECLARE @dblUnitsPerPallet NUMERIC(18,6)
	DECLARE @strSKUNo NVARCHAR(30)
	DECLARE @intCompanyLocationId INT
	DECLARE @ysnCreatePutAwayTask BIT
	DECLARE @intSKUStatusId INT
	DECLARE @strLotCode NVARCHAR(32)
	DECLARE @intYear INT
	DECLARE @intDays INT
	DECLARE @intCurrentDay INT
	DECLARE @intCurrentYear INT
	DECLARE @dtmLotProductionDate DATETIME
	DECLARE @strNewContainerNo NVARCHAR(60)
	DECLARE @dblWeightPerUnit DECIMAL(24, 10)
	DECLARE @intWeightPerUnitUOMId INT
	DECLARE @intUserId INT

	SELECT @strNewContainerNo = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intLotId
	
	SELECT @intUserId = [intEntityId] FROM tblSMUserSecurity WHERE strUserName = @strUserName --this is a hiccup

	SELECT @dblWeightPerUnit = dblWeightPerQty, @intWeightPerUnitUOMId = iu.intUnitMeasureId
	FROM tblICLot l 
	JOIN tblICItemUOM iu ON ISNULL(l.intWeightUOMId,l.intItemUOMId)=iu.intItemUOMId
	WHERE intLotId = @intLotId

	IF @strPalletLotCode IS NULL
		SET @strLotCode = SUBSTRING(@strNewContainerNo, 4, 5)
	ELSE
		SET @strLotCode = @strPalletLotCode

	SET @intSKUStatusId = 0

	-- FG Release happen based on the status.
	-- User release with 'HOLD' status then SKU will create with 'RESTRICTED' status.
	-- User release the FG lot with 'ACTIVE' status then SKU will create with 'STOCK' status.
	IF @ysnStatus = 0
		SELECT TOP 1 @intSKUStatusId = intSKUStatusId
		FROM tblWHSKUStatus
		WHERE UPPER(strSKUStatus) = 'STOCK'
	ELSE
		SELECT TOP 1 @intSKUStatusId = intSKUStatusId
		FROM tblWHSKUStatus
		WHERE UPPER(strSKUStatus) = 'RESTRICTED'

	SET @intContainerTypeId = 0
	SET @intContainerId = 0

	SELECT @intCompanyLocationId = intCompanyLocationId
	FROM tblSMCompanyLocationSubLocation
	WHERE intCompanyLocationSubLocationId = @intCompanyLocationSubLocationId

	--SELECT @ysnCreatePutAwayTask = SettingValue
	--FROM dbo.iMake_AppSettingValue AV
	--INNER JOIN dbo.iMake_AppSetting S ON S.SettingKey = AV.SettingKey
	--WHERE S.SettingName = 'CreatePutAwayTask'
	--	AND IsNull(intCompanyLocationId, @intCompanyLocationId) = @intCompanyLocationId

	IF @@TRANCOUNT = 0
		SET @intLocalTran = 1

	IF @intLocalTran = 1
		BEGIN TRANSACTION

	SELECT @intUOMId = CASE WHEN @intUOMId IS NULL THEN um.intUnitMeasureId ELSE @intUOMId END, @intUnitPerLayer = intUnitPerLayer, @intLayersPerPallet = intLayerPerPallet
	FROM tblICItem i
	JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId AND iu.ysnStockUnit =1
	WHERE i.intItemId = @intItemId

	IF @intUnitPerLayer IS NULL OR @intLayersPerPallet IS NULL
	BEGIN
		RAISERROR ('UnitsPerLayer or LayersPerPallet cannot be zero for the item.', 16, 1)
	END
	ELSE
	BEGIN
		SELECT @dblUnitsPerPallet = @intUnitPerLayer * @intLayersPerPallet
	END

	--SET @dtmLotProductionDate=convert(datetime,dateadd(d,convert(int,right(@strLotCode,3))-1, '01 Jan' + convert(char(4),2000+left(@strLotCode,2))))   
	
	--SET @dtmLotProductionDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETDATE()), @dtmProductionDate) -----------Converting Localtime to UTC Date    
	SET @dtmLotProductionDate = @dtmProductionDate

	IF @dblUnitsPerPallet = 0
	BEGIN
		RAISERROR ('UnitsPerLayer and LayersPerPallet cannot be zero for the item(s).', 16, 1)
	END

	WHILE (@dblQty >= @dblUnitsPerPallet)
	BEGIN
		--EXEC dbo.Pattern_GenerateID @intItemId=0,@intCompanyLocationId=@intCompanyLocationId,@intCompanyLocationSubLocationId=0,@intStorageLocationId=0,@CellKey=0,@UserKey=0,@PatternString=@strContainerNo OUTPUT ,@PatternSettingName='WHPatternContainer'        
		SET @intContainerId = 0

		IF @intContainerTypeId = 0
			SELECT TOP 1 @intContainerTypeId = intContainerTypeId
			FROM tblWHContainerType
			WHERE ysnIsDefault = 1

		IF (@intContainerTypeId = 0)
		BEGIN
			RAISERROR ('No default container type configured.', 16, 1)
		END

		IF @ysnUseContainerPattern = 1
		BEGIN
		    EXEC dbo.uspSMGetStartingNumber 74, @strNewContainerNo OUTPUT
		END



		IF @intContainerId = 0
		BEGIN
			--Create the container                                      
			INSERT INTO tblWHContainer (strContainerNo,intConcurrencyId, intContainerTypeId, intStorageLocationId,intCreatedUserId,dtmCreated, intLastModifiedUserId, dtmLastModified)
			VALUES (@strNewContainerNo,0, @intContainerTypeId, @intDefaultStagingLocationId, @intUserId, GETDATE(), @intUserId, GETDATE())

			SET @intContainerId = SCOPE_IDENTITY()
		END

			EXEC dbo.uspSMGetStartingNumber 73, @strSKUNo  OUTPUT

		SET @intSKUId = 0

		SELECT @intSKUId = intSKUId
		FROM tblWHSKU s
		WHERE strSKUNo = @strSKUNo

		IF EXISTS (
				SELECT strSKUNo
				FROM tblWHSKU
				WHERE intContainerId = @intContainerId
				)
		BEGIN
			RAISERROR ('The scanned container already exists in warehouse.', 16, 1)
		END

		SET @intYear = 2000

		IF (
				(LEN(@strLotCode) <> 5)
				OR (ISNUMERIC(@strLotCode) = 0)
				)
			AND @ysnForced = 0
		BEGIN
			RAISERROR ('The lot code must be of 5 characters in the format YYOOO, 2 digit year and 3 digit day of the year (ordinal).', 16, 1)
		END

		SET @intYear = @intYear + CASE 
				WHEN ISNUMERIC(SUBSTRING(@strLotCode, 0, 3)) = 1
					THEN SUBSTRING(@strLotCode, 0, 3)
				ELSE 0
				END

		IF ((@intYear < year(getdate()) - 3) OR (@intYear > year(getdate())))
			AND @ysnForced = 0
		BEGIN
			RAISERROR ('The year of the lot code is invalid.', 16, 1)
		END

		SET @intDays = (
				CASE 
					WHEN ISNUMERIC(SUBSTRING(@strLotCode, 3, 3)) = 1
						THEN SUBSTRING(@strLotCode, 3, 3)
					ELSE 0
					END
				)

		IF (
				(@intDays <= 0)
				OR (@intDays > 366)
				)
			AND @ysnForced = 0
		BEGIN
			RAISERROR ('The ordinal date portion of the lot code is invalid.', 16, 1)
		END

		SET @intCurrentDay = datepart(dy, getdate())
		SET @intCurrentYear = year(getdate())

		IF (
				@intDays > @intCurrentDay
				AND @intYear = @intCurrentYear
				)
			AND @ysnForced = 0
		BEGIN
			RAISERROR ('The ordinal date portion of the lot code is invalid.', 16, 1)
		END


		--Create SKU on the indicated container                                      
		INSERT INTO tblWHSKU (strSKUNo,intConcurrencyId , intSKUStatusId, strLotCode, dblQty, dtmReceiveDate, dtmProductionDate, intItemId, intContainerId, intOwnerId, intLastModifiedUserId, dtmLastModified, intLotId, intUOMId, intUnitsPerLayer, intLayersPerPallet, ysnIsSanitized, dblWeightPerUnit, intWeightPerUnitUOMId, strBatchNo)
		VALUES (@strSKUNo,0, @intSKUStatusId, @strLotCode, @dblUnitsPerPallet, GETDATE(), @dtmLotProductionDate, @intItemId, @intContainerId, @intOwnerAddressId, @intUserId, GETDATE(), @intLotId, @intUOMId, ISNULL(@intUnitPerLayer,1), ISNULL(@intLayersPerPallet,1), @ysnSanitized, @dblWeightPerUnit, @intWeightPerUnitUOMId, @strBatchNo)

		SET @intSKUId = SCOPE_IDENTITY()

		--EXEC WM_CreateSKUHistory @intSKUId, 11, @intUserId --, @dblUnitsPerPallet     ''BugID:2088     
			-- Based on the application settings task will create                        

		IF @ysnCreatePutAwayTask = 1
		BEGIN
				PRINT 'EXEC WM_FGReleaseCreatePutAwayTask @FromContainerKey = @intContainerId, @intSKUId = @intSKUId, @intCompanyLocationSubLocationId = @intCompanyLocationSubLocationId, @intAddressId = @intAddressId, @intLotId = @intLotId, @dblQty = @dblUnitsPerPallet, @strUserName = @intUserId'
		END

		SET @dblQty = @dblQty - @dblUnitsPerPallet
		

		
	END

	IF @dblQty > 0
	BEGIN
		--EXEC dbo.Pattern_GenerateID @intItemId=0,@intCompanyLocationId=@intCompanyLocationId,@intCompanyLocationSubLocationId=0,@intStorageLocationId=0,@CellKey=0,@UserKey=0,@PatternString=@strContainerNo OUTPUT,@PatternSettingName='WHPatternContainer'        
		--EXEC GEN_GetNextSequence 'CON', @intContainerNumber OUT, @strContainerNo OUT            
		SET @intContainerId = 0

		IF @intContainerTypeId = 0
			SELECT TOP 1 @intContainerTypeId = intContainerTypeId
			FROM tblWHContainerType
			WHERE ysnIsDefault = 1

		IF (@intContainerTypeId = 0)
		BEGIN
			RAISERROR ('No default container type configured to the warehouse.', 16, 1)
		END

		IF @ysnUseContainerPattern = 1
		BEGIN
			EXEC dbo.uspSMGetStartingNumber 74, @strNewContainerNo OUTPUT
		END

		IF @intContainerId = 0
		BEGIN
			--Create the container                                      
			INSERT INTO tblWHContainer (strContainerNo,intConcurrencyId, intContainerTypeId, intStorageLocationId,intCreatedUserId,dtmCreated, intLastModifiedUserId, dtmLastModified)
			VALUES (@strNewContainerNo, 0,@intContainerTypeId, @intDefaultStagingLocationId, @intUserId, GETDATE(), @intUserId, GETDATE())

			SET @intContainerId = SCOPE_IDENTITY()
		END

		EXEC dbo.uspSMGetStartingNumber 73, @strSKUNo  OUTPUT

		--EXEC GEN_GetNextSequence 'SKU', @intSKUNumber OUT, @strSKUNo OUT                                     
		SET @intSKUId = 0

		SELECT @intSKUId = intSKUId
		FROM tblWHSKU s
		WHERE strSKUNo = @strSKUNo

		IF EXISTS (
				SELECT strSKUNo
				FROM tblWHSKU
				WHERE intContainerId = @intContainerId
				)
		BEGIN
			RAISERROR ('The scanned Container already exists. Please scan again.', 16, 1)
		END

		--Create SKU on the indicated container                                      
		INSERT INTO tblWHSKU (strSKUNo,intConcurrencyId, intSKUStatusId, strLotCode, dblQty, dtmReceiveDate, dtmProductionDate, intItemId, intContainerId, intOwnerId, intLastModifiedUserId, dtmLastModified, intLotId, intUOMId, intUnitsPerLayer, intLayersPerPallet, ysnIsSanitized, dblWeightPerUnit, intWeightPerUnitUOMId, strBatchNo)
		VALUES (@strSKUNo,0, @intSKUStatusId, @strLotCode, @dblQty, GETDATE(), @dtmLotProductionDate, @intItemId, @intContainerId, @intOwnerAddressId, @intUserId, GETDATE(), @intLotId, @intUOMId, ISNULL(@intUnitPerLayer,1), ISNULL(@intLayersPerPallet,1), @ysnSanitized, @dblWeightPerUnit, @intWeightPerUnitUOMId, @strBatchNo)

		SET @intSKUId = SCOPE_IDENTITY()

		--EXEC WM_CreateSKUHistory @intSKUId, 11, @intUserId --, @dblUnitsPerPallet commented by sunay for tech id 391                     

		-- Based on the application settings task will create        
		IF @ysnCreatePutAwayTask = 1
		BEGIN
			SELECT 1
			--EXEC WM_FGReleaseCreatePutAwayTask @FromContainerKey = @intContainerId, @intSKUId = @intSKUId, @intCompanyLocationSubLocationId = @intCompanyLocationSubLocationId, @intAddressId = @intAddressId, @intLotId = @intLotId, @dblQty = @dblQty, @intUserId = @intUserId
		END
	END

	IF @intLocalTran = 1
		AND @@TRANCOUNT > 0
		COMMIT TRANSACTION

	SELECT @intSKUId AS intSKUId
END TRY

BEGIN CATCH
	IF @intLocalTran = 1
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspWHCreateSKUByLot: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH