CREATE PROCEDURE uspQMGetSampleNumber @intProductTypeId INT
	,@intProductValueId INT
	,@intUserRoleID INT = 0
	,@ysnSampleBasedOnControlPoint BIT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @tblMFLot TABLE (strLotNumber NVARCHAR(50) Collate Latin1_General_CI_AS)
DECLARE @tblMFFinalLot TABLE (
	strLotNumber NVARCHAR(50) Collate Latin1_General_CI_AS
	,intSampleTypeId INT
	)
DECLARE @strSampleId NVARCHAR(MAX)
	,@ysnEnableSampleTypeByUserRole BIT
	,@intParentLotId INT
	,@strWarehouseRefNo NVARCHAR(50)
	,@strContainerNo NVARCHAR(50)
	,@strLotAlias NVARCHAR(50)
	,@intItemId INT
	,@intLotId INT
	,@intPreProductionControlPointId INT

SELECT TOP 1 @ysnEnableSampleTypeByUserRole = ISNULL(ysnEnableSampleTypeByUserRole, 0)
FROM tblQMCompanyPreference

SELECT TOP 1 @intPreProductionControlPointId = intPreProductionControlPointId
FROM tblMFCompanyPreference

IF @intProductTypeId = 6 -- Take all samples from the multiple Lot ID
BEGIN
	INSERT INTO @tblMFLot
	SELECT strLotNumber
	FROM tblICLot
	WHERE intLotId = @intProductValueId

	INSERT INTO @tblMFFinalLot (
		strLotNumber
		,intSampleTypeId
		)
	SELECT L.strLotNumber
		,-1
	FROM @tblMFLot L

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Parent Lot'
			)
	BEGIN
		SELECT @intParentLotId = intParentLotId
		FROM tblICLot
		WHERE intLotId = @intProductValueId

		INSERT INTO @tblMFLot
		SELECT strLotNumber
		FROM tblICLot
		WHERE intParentLotId = @intParentLotId

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Parent Lot'
	END

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Warehouse Ref No'
			)
	BEGIN
		SELECT @strWarehouseRefNo = strWarehouseRefNo
		FROM tblMFLotInventory
		WHERE intLotId = @intProductValueId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
		WHERE LI.strWarehouseRefNo = @strWarehouseRefNo

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Warehouse Ref No'
	END

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Warehouse Ref No & Parent Lot'
			)
	BEGIN
		SELECT @strWarehouseRefNo = strWarehouseRefNo
		FROM tblMFLotInventory
		WHERE intLotId = @intProductValueId

		SELECT @intParentLotId = intParentLotId
		FROM tblICLot
		WHERE intLotId = @intProductValueId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
			AND L.intParentLotId = @intParentLotId
		WHERE LI.strWarehouseRefNo = @strWarehouseRefNo

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Warehouse Ref No & Parent Lot'
	END

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Container'
			)
	BEGIN
		SELECT @strContainerNo = strContainerNo
		FROM tblICLot
		WHERE intLotId = @intProductValueId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		WHERE L.strContainerNo = @strContainerNo

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Container'
	END

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Work Order'
			)
	BEGIN
		SELECT @strLotAlias = strLotAlias
		FROM tblICLot
		WHERE intLotId = @intProductValueId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		WHERE L.strLotAlias = @strLotAlias

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Work Order'
	END

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Item & Parent Lot'
			)
	BEGIN
		SELECT @intItemId = intItemId
			,@intParentLotId = intParentLotId
		FROM tblICLot
		WHERE intLotId = @intProductValueId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		WHERE intItemId = @intItemId
			AND intParentLotId = @intParentLotId

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Item & Parent Lot'
	END

	IF @ysnEnableSampleTypeByUserRole = 1
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
			AND SU.intUserRoleID = @intUserRoleID
		JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		JOIN tblQMControlPoint C ON C.intControlPointId = ST.intControlPointId
		WHERE S.intProductTypeId = @intProductTypeId
			AND C.intControlPointId = (CASE WHEN @intPreProductionControlPointId IS NOT NULL AND @ysnSampleBasedOnControlPoint = 1 THEN @intPreProductionControlPointId ELSE C.intControlPointId END)
			AND EXISTS (
				SELECT *
				FROM @tblMFFinalLot L
				WHERE L.strLotNumber = S.strLotNumber
					AND (Case When L.intSampleTypeId = -1 Then S.intSampleTypeId  Else L.intSampleTypeId End)=S.intSampleTypeId 
				)
		ORDER BY S.intSampleId DESC
	END
	ELSE
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		JOIN tblQMControlPoint C ON C.intControlPointId = ST.intControlPointId
		WHERE S.intProductTypeId = @intProductTypeId
			AND C.intControlPointId = (CASE WHEN @intPreProductionControlPointId IS NOT NULL AND @ysnSampleBasedOnControlPoint = 1 THEN @intPreProductionControlPointId ELSE C.intControlPointId END)
			AND EXISTS (
				SELECT *
				FROM @tblMFFinalLot L
				WHERE L.strLotNumber = S.strLotNumber
					AND (Case When L.intSampleTypeId = -1 Then S.intSampleTypeId  Else L.intSampleTypeId End)=S.intSampleTypeId
				)
		ORDER BY S.intSampleId DESC
	END
END
ELSE IF @intProductTypeId = 11 -- Parent Lot
BEGIN
	INSERT INTO @tblMFLot
	SELECT strLotNumber
	FROM tblICLot
	WHERE intParentLotId = @intProductValueId

	INSERT INTO @tblMFFinalLot (
		strLotNumber
		,intSampleTypeId
		)
	SELECT L.strLotNumber
		,-1
	FROM @tblMFLot L

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Warehouse Ref No'
			)
	BEGIN
		SELECT @intLotId = intLotId
		FROM tblICLot
		WHERE intParentLotId = @intProductValueId

		SELECT @strWarehouseRefNo = strWarehouseRefNo
		FROM tblMFLotInventory
		WHERE intLotId = @intLotId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
		WHERE LI.strWarehouseRefNo = @strWarehouseRefNo

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Warehouse Ref No'
	END

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Warehouse Ref No & Parent Lot'
			)
	BEGIN
		SELECT @intLotId = intLotId
		FROM tblICLot
		WHERE intParentLotId = @intProductValueId

		SELECT @strWarehouseRefNo = strWarehouseRefNo
		FROM tblMFLotInventory
		WHERE intLotId = @intLotId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
			AND L.intParentLotId = @intProductValueId
		WHERE LI.strWarehouseRefNo = @strWarehouseRefNo

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Warehouse Ref No & Parent Lot'
	END

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Container'
			)
	BEGIN
		SELECT @strContainerNo = strContainerNo
		FROM tblICLot
		WHERE intParentLotId = @intProductValueId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		WHERE L.strContainerNo = @strContainerNo

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Container'
	END

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Work Order'
			)
	BEGIN
		SELECT @strLotAlias = strLotAlias
		FROM tblICLot
		WHERE intParentLotId = @intProductValueId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		WHERE L.strLotAlias = @strLotAlias

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Work Order'
	END

	IF EXISTS (
			SELECT *
			FROM tblQMSampleType
			WHERE strApprovalBase = 'Item & Parent Lot'
			)
	BEGIN
		SELECT @intItemId = intItemId
		FROM tblICLot
		WHERE intParentLotId = @intProductValueId

		INSERT INTO @tblMFLot
		SELECT L.strLotNumber
		FROM tblICLot L
		WHERE intItemId = @intItemId
			AND intParentLotId = @intProductValueId

		INSERT INTO @tblMFFinalLot (
			strLotNumber
			,intSampleTypeId
			)
		SELECT L.strLotNumber
			,ST.intSampleTypeId
		FROM @tblMFLot L
			,tblQMSampleType ST
		WHERE ST.strApprovalBase = 'Item & Parent Lot'
	END

	IF @ysnEnableSampleTypeByUserRole = 1
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
			AND SU.intUserRoleID = @intUserRoleID
		WHERE S.intProductTypeId = @intProductTypeId
			AND EXISTS (
				SELECT *
				FROM @tblMFFinalLot L
				WHERE L.strLotNumber = S.strLotNumber
					AND (Case When L.intSampleTypeId = -1 Then S.intSampleTypeId  Else L.intSampleTypeId End)=S.intSampleTypeId
				)
		ORDER BY S.intSampleId DESC
	END
	ELSE
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		WHERE S.intProductTypeId = @intProductTypeId
			AND EXISTS (
				SELECT *
				FROM @tblMFFinalLot L
				WHERE L.strLotNumber = S.strLotNumber
					AND (Case When L.intSampleTypeId = -1 Then S.intSampleTypeId  Else L.intSampleTypeId End)=S.intSampleTypeId
				)
		ORDER BY S.intSampleId DESC
	END
END
ELSE
BEGIN
	IF @ysnEnableSampleTypeByUserRole = 1
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
			AND SU.intUserRoleID = @intUserRoleID
		WHERE S.intProductTypeId = @intProductTypeId
			AND S.intProductValueId = @intProductValueId
		ORDER BY S.intSampleId DESC
	END
	ELSE
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		WHERE S.intProductTypeId = @intProductTypeId
			AND S.intProductValueId = @intProductValueId
		ORDER BY S.intSampleId DESC
	END
END

IF @strSampleId IS NULL
	SELECT '0' AS strSampleId
ELSE
	SELECT @strSampleId AS strSampleId
