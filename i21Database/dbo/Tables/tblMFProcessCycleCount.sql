CREATE TABLE dbo.tblMFProcessCycleCount (
	intCycleCountId INT IDENTITY(1, 1) NOT NULL
	,intCycleCountSessionId INT NOT NULL
	,intMachineId INT NOT NULL
	,intLotId INT NULL
	,intItemId INT NOT NULL
	,dblQuantity NUMERIC(18, 6) NULL
	,dblSystemQty NUMERIC(18, 6) NULL
	,intCreatedUserId INT NOT NULL
	,dtmCreated DATETIME NOT NULL CONSTRAINT DF_tblMFProcessCycleCount_dtmCreated DEFAULT(getdate())
	,intLastModifiedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL CONSTRAINT DF_tblMFProcessCycleCount_dtmLastModified DEFAULT(getdate())
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFProcessCycleCount_intConcurrencyId DEFAULT((0))
	,CONSTRAINT PK_tblMFProcessCycleCount_intCycleCountId PRIMARY KEY (intCycleCountId)
	,CONSTRAINT FK_tblMFProcessCycleCount_tblMFProcessCycleCountSession_intCycleCountSessionId FOREIGN KEY (intCycleCountSessionId) REFERENCES dbo.tblMFProcessCycleCountSession(intCycleCountSessionId)
	,CONSTRAINT FK_tblMFProcessCycleCount_tblMFMachine_intMachineId FOREIGN KEY (intMachineId) REFERENCES dbo.tblMFMachine(intMachineId)
	,CONSTRAINT FK_tblMFProcessCycleCount_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES dbo.tblICItem(intItemId)
	)
