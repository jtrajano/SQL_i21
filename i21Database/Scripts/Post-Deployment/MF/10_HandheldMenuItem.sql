IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'View Lot'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('View Lot')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Move/Put Away'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Move/Put Away')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Merge/Split'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Merge/Split')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'FG Release'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('FG Release')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Pick For Shipment'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Pick For Shipment')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Pick For Kitting'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Pick For Kitting')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Transfer Kit'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Transfer Kit')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'WO Staging'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('WO Staging')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Print Label'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Print Label')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Inventory Count'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Inventory Count')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Load In'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Load In')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Adj Qty'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Adj Qty')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Adj Status'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Adj Status')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Receipt Put Away'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Receipt Put Away')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Stock By Item'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Stock By Item')
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHandheldMenuItem
		WHERE strHandheldMenuItemName = 'Stock By Storage Unit'
		)
BEGIN
	INSERT INTO tblMFHandheldMenuItem
	VALUES ('Stock By Storage Unit')
END
GO

--INSERT INTO tblMFHaldheldUserMenuItemMap
--SELECT b.intEntityId
-- ,intHandheldMenuItemId
--FROM tblMFHandheldMenuItem a
-- ,tblSMUserSecurity b
--WHERE b.intEntityId NOT IN (
--  SELECT intUserSecurityId
--  FROM tblMFHaldheldUserMenuItemMap
--  )
