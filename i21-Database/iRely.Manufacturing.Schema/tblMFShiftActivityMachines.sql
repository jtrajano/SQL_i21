CREATE TABLE [dbo].[tblMFShiftActivityMachines]
(
	intShiftActivityMachineId INT NOT NULL IDENTITY,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFShiftActivityMachines_intConcurrencyId DEFAULT 0,
	intShiftActivityId INT NOT NULL,
	intMachineId INT NOT NULL,
	dblMachCapacity NUMERIC(18, 6) NOT NULL CONSTRAINT DF_tblMFShiftActivityMachines_dblMachCapacity DEFAULT 0,

	intCreatedUserId int NULL,
	dtmCreated datetime NULL CONSTRAINT DF_tblMFShiftActivityMachines_dtmCreated DEFAULT GetDate(),
	intLastModifiedUserId int NULL,
	dtmLastModified datetime NULL CONSTRAINT DF_tblMFShiftActivityMachines_dtmLastModified DEFAULT GetDate(),
		
	CONSTRAINT PK_tblMFShiftActivityMachines PRIMARY KEY (intShiftActivityMachineId), 
	CONSTRAINT AK_tblMFShiftActivityMachines_intShiftActivityId_intMachineId UNIQUE (
		intShiftActivityId,
		intMachineId),
	CONSTRAINT FK_tblMFShiftActivityMachines_tblMFShiftActivity FOREIGN KEY (intShiftActivityId) REFERENCES tblMFShiftActivity(intShiftActivityId) ON DELETE CASCADE,
	CONSTRAINT FK_tblMFShiftActivityMachines_tblMFMachine FOREIGN KEY (intMachineId) REFERENCES tblMFMachine(intMachineId)
)