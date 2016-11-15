CREATE TABLE tblMFHaldheldUserMenuItemMap
(
	intHaldheldUserMenuItemMapId INT PRIMARY KEY IDENTITY(1,1),
	intUserSecurityId INT,
	intHandheldMenuItemId INT
)