CREATE PROCEDURE uspMFGetHandheldUserMenu (@intUserId INT)
AS
BEGIN
	SELECT M.intHandheldMenuItemId
		,M.strHandheldMenuItemName
		,(
			CASE 
				WHEN UM.intUserSecurityId IS NULL
					THEN CAST(0 AS BIT)
				ELSE CAST(1 AS BIT)
				END
			) AS ysnPermission
	FROM tblMFHandheldMenuItem M
	LEFT JOIN tblMFHaldheldUserMenuItemMap UM ON M.intHandheldMenuItemId = UM.intHandheldMenuItemId
		AND UM.intUserSecurityId = @intUserId
END
