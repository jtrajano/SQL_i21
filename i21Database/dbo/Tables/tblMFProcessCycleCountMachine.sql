CREATE TABLE dbo.tblMFProcessCycleCountMachine (
	intCycleCountMachineId INT IDENTITY(1, 1) NOT NULL
	,intCycleCountId INT NOT NULL
	,intMachineId INT NOT NULL
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFProcessCycleCountMachine_intConcurrencyId DEFAULT((0))
	,CONSTRAINT PK_tblMFProcessCycleCountMachine_intCycleCountMachineId PRIMARY KEY (intCycleCountMachineId)
	,CONSTRAINT FK_tblMFProcessCycleCountMachine_tblMFProcessCycleCount_intCycleCountId FOREIGN KEY (intCycleCountId) REFERENCES dbo.tblMFProcessCycleCount(intCycleCountId)
	,CONSTRAINT FK_tblMFProcessCycleCountMachine_tblMFMachine_intMachineId FOREIGN KEY (intMachineId) REFERENCES dbo.tblMFMachine(intMachineId)
	)