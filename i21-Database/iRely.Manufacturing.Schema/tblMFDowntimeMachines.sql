CREATE TABLE [dbo].[tblMFDowntimeMachines]
(
	intDowntimeMachineId INT NOT NULL IDENTITY,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFDowntimeMachines_intConcurrencyId DEFAULT 0,
	intDowntimeId INT NOT NULL,
	intMachineId INT NOT NULL,

	intCreatedUserId int NULL,
	dtmCreated datetime NULL CONSTRAINT DF_tblMFDowntimeMachines_dtmCreated DEFAULT GetDate(),
	intLastModifiedUserId int NULL,
	dtmLastModified datetime NULL CONSTRAINT DF_tblMFDowntimeMachines_dtmLastModified DEFAULT GetDate(),
		
	CONSTRAINT PK_tblMFDowntimeMachines PRIMARY KEY (intDowntimeMachineId), 
	CONSTRAINT AK_tblMFDowntimeMachines_intDowntimeId_intMachineId UNIQUE (
		intDowntimeId,
		intMachineId),
	CONSTRAINT FK_tblMFDowntimeMachines_tblMFDowntime FOREIGN KEY (intDowntimeId) REFERENCES tblMFDowntime(intDowntimeId) ON DELETE CASCADE,
	CONSTRAINT FK_tblMFDowntimeMachines_tblMFMachine FOREIGN KEY (intMachineId) REFERENCES tblMFMachine(intMachineId)
)