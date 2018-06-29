CREATE TABLE dbo.tblMFFloorMovement (
	intFloorMovementId INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_tblMFFloorMovement_intFloorMovementId PRIMARY KEY
	,intSubLocationId INT NOT NULL CONSTRAINT FK_tblMFFloorMovement_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId_intSubLocationId REFERENCES dbo.tblSMCompanyLocationSubLocation(intCompanyLocationSubLocationId)
	,intSourceTypeId INT NOT NULL CONSTRAINT FK_tblMFFloorMovement_tblMFFloorMovementType_intFloorMovementTypeID_intSourceTypeId REFERENCES dbo.tblMFFloorMovementType(intFloorMovementTypeId)
	,intSourceId INT NOT NULL
	,intDestinationTypeId INT NOT NULL CONSTRAINT FK_tblMFFloorMovement_tblMFFloorMovementType_intFloorMovementTypeID_intDestinationTypeId REFERENCES dbo.tblMFFloorMovementType(intFloorMovementTypeId)
	,intDestinationId INT NOT NULL
	,ysnAllowed BIT NOT NULL
	,intStationTypeId INT NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmCreated DATETIME NOT NULL CONSTRAINT DF_tblMFFloorMovement_dtmCreated DEFAULT(getdate())
	,intLastModifiedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL CONSTRAINT DF_tblMFFloorMovement_dtmLastModified DEFAULT(getdate())
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFFloorMovement_intConcurrencyId DEFAULT((0))
	)