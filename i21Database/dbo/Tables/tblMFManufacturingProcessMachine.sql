CREATE TABLE [dbo].[tblMFManufacturingProcessMachine]
(
	[intManufacturingProcessMachineId] INT NOT NULL IDENTITY(1,1) , 
    [intManufacturingProcessId] INT NOT NULL, 
	[intMachineId] INT NOT NULL,
	[intLocationId] [int] NOT NULL,
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFManufacturingProcessMachine_intConcurrencyId] DEFAULT 0, 
    CONSTRAINT [PK_tblMFManufacturingProcessMachine_intManufacturingProcessMachineId] PRIMARY KEY ([intManufacturingProcessMachineId]),
	CONSTRAINT [FK_tblMFManufacturingProcessMachine_tblMFManufacturingProcess_intManufacturingProcessId] FOREIGN KEY ([intManufacturingProcessId]) REFERENCES [tblMFManufacturingProcess]([intManufacturingProcessId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFManufacturingProcessMachine_tblMFMachine_intMachineId] FOREIGN KEY ([intMachineId]) REFERENCES [tblMFMachine]([intMachineId]),
	CONSTRAINT [FK_tblMFManufacturingProcessMachine_tblSMCompanyLocation_intCompanyLocationId_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)
