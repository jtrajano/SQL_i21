CREATE PROCEDURE [dbo].[uspWHDeleteSKUForWarehouse] 
				@intSKUId INT, 
				@strUserName NVARCHAR(32)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intLocalTran TINYINT

	IF @@TRANCOUNT = 0
		SET @intLocalTran = 1

	IF @intLocalTran = 1
		BEGIN TRANSACTION

	DECLARE @strErrMsg NVARCHAR(MAX)

	SET @strErrMsg = ''

	DECLARE @strSKUNo NVARCHAR(32)
	DECLARE @intContainerId INT
	DECLARE @intCount INT
	DECLARE @intLotId INT
	DECLARE @dblSKUQty INT
	DECLARE @dblLotQty INT
	DECLARE @strLotNo NVARCHAR(30)
	DECLARE @dblAdjustQty DECIMAL(24, 10)
	DECLARE @intUOMId INT
	DECLARE @intLastUpdateById INT
	DECLARE @strReasonCode NVARCHAR(64)
	DECLARE @TransactionKey INT
	DECLARE @ysnLifetimeUnitMonthEndofMonth BIT

	--SELECT @ysnLifetimeUnitMonthEndofMonth = SettingValue
	--FROM dbo.iMake_AppSetting S
	--JOIN dbo.iMake_AppSettingValue SV ON S.SettingKey = SV.SettingKey
	--WHERE SettingName = 'Lifetime-UnitMonth-EndofMonth'

	SET @intCount = 0

	SELECT @intContainerId = intContainerId, @strSKUNo = strSKUNo
	FROM tblWHSKU
	WHERE intSKUId = @intSKUId

	SELECT @intLastUpdateById = [intEntityId]
	FROM tblSMUserSecurity
	WHERE strUserName = @strUserName

	--Add SKU History record                
	INSERT INTO tblWHSKUHistory (intConcurrencyId,strSKUNo, strSKUStatus, strItemNo, strItemDescription, strLotCode, dblQty, dblSplitQty, dblCountQty, dtmReceiveDate, dtmProductionDate, strContainerNo, strAddressTitle, strStorageLocationName, strOwnerTitle, strTaskType, strBOLNo, intLastUpdateId, dtmLastUpdateOn, intUOMId, strReasonCode, strComment)
	SELECT 0,s.strSKUNo, ss.strInternalCode SKUStatus, p.strItemNo, p.strDescription, s.strLotCode, s.dblQty, 0 dblSplitQty, 0 dblCountQty, s.dtmReceiveDate, s.dtmProductionDate, c.strContainerNo, a.strLocationName, l.strName, a2.strName strOwnerTitle, tt.strInternalCode strTaskType, h.strBOLNo, @intLastUpdateById intLastUpdateById, GETUTCDATE() LastUpdateOn, s.intUOMId, s.strReasonCode, s.strComment
	FROM tblWHSKU s
	INNER JOIN tblWHSKUStatus ss ON s.intSKUStatusId = ss.intSKUStatusId
	INNER JOIN tblICItem p ON p.intItemId = s.intItemId
	INNER JOIN tblWHContainer c ON s.intContainerId = c.intContainerId
	INNER JOIN tblICStorageLocation l ON l.intStorageLocationId = c.intStorageLocationId
	INNER JOIN tblSMCompanyLocationSubLocation loc ON loc.intCompanyLocationSubLocationId = l.intSubLocationId
	INNER JOIN tblWHTaskType tt ON tt.intTaskTypeId = 12
	INNER JOIN tblSMCompanyLocation a ON a.intCompanyLocationId = loc.intCompanyLocationId
	LEFT OUTER JOIN tblEMEntity a2 ON a2.intEntityId = s.intOwnerId
	LEFT OUTER JOIN tblWHTask t ON t.intSKUId = s.intSKUId
	LEFT OUTER JOIN tblWHOrderHeader h ON h.intOrderHeaderId = t.intOrderHeaderId
	WHERE s.intSKUId = @intSKUId

	--Delete the SKU from open and released orders                
	DELETE
	FROM tblWHOrderManifest
	WHERE intSKUId = @intSKUId

	--Delete any task referencing this SKU                
	DELETE
	FROM tblWHTask
	WHERE intSKUId = @intSKUId

	--Determine if there was only one SKU on the container                
	SELECT @intCount = Count(*)
	FROM tblWHSKU
	WHERE intContainerId = @intContainerId
		AND intSKUId <> @intSKUId

	--Delete the SKU history                
	DELETE
	FROM tblWHSKUHistory
	WHERE strSKUNo = @strSKUNo

	--Delete the SKU                
	DELETE
	FROM tblWHSKU
	WHERE intSKUId = @intSKUId

	--Delete the empty container                
	IF @intCount = 0
	BEGIN
		DELETE
		FROM tblWHContainer
		WHERE intContainerId = @intContainerId
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
		SET @strErrMsg = 'uspWHDeleteSKUForWarehouse: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH