CREATE TABLE tblMFHaldheldUserMenuItemMap
(
	intHaldheldUserMenuItemMapId INT PRIMARY KEY IDENTITY(1,1),
	intUserSecurityId INT,
	intHandheldMenuItemId INT,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFHaldheldUserMenuItemMap_intConcurrencyId DEFAULT 0,

	intCreatedUserId int NULL,
	dtmCreated datetime NULL CONSTRAINT DF_tblMFHaldheldUserMenuItemMap_dtmCreated DEFAULT GetDate(),
	intLastModifiedUserId int NULL,
	dtmLastModified datetime NULL CONSTRAINT DF_tblMFHaldheldUserMenuItemMap_dtmLastModified DEFAULT GetDate()
)