CREATE TABLE [dbo].[tblMFManufacturingProcessMachine]
(
	[intManufacturingProcessMachineId] INT NOT NULL IDENTITY(1,1) , 
    [intManufacturingProcessId] INT NOT NULL, 
	[intMachineId] INT NOT NULL,
	[intLocationId] [int] NOT NULL,
	[ysnDefault] bit CONSTRAINT [DF_tblMFManufacturingProcessMachine_ysnDefault] DEFAULT 0,
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFManufacturingProcessMachine_intConcurrencyId] DEFAULT 0, 
	[strStagingLocationType] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intStagingLocationId] INT,
	[intProductionStagingLocationId] INT,

    CONSTRAINT [PK_tblMFManufacturingProcessMachine_intManufacturingProcessMachineId] PRIMARY KEY ([intManufacturingProcessMachineId]),
	CONSTRAINT [FK_tblMFManufacturingProcessMachine_tblMFManufacturingProcess_intManufacturingProcessId] FOREIGN KEY ([intManufacturingProcessId]) REFERENCES [tblMFManufacturingProcess]([intManufacturingProcessId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFManufacturingProcessMachine_tblMFMachine_intMachineId] FOREIGN KEY ([intMachineId]) REFERENCES [tblMFMachine]([intMachineId]),
	CONSTRAINT [FK_tblMFManufacturingProcessMachine_tblSMCompanyLocation_intCompanyLocationId_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblMFManufacturingProcessMachine_tblICStorageLocation_intStagingLocationId] FOREIGN KEY ([intStagingLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
	CONSTRAINT [FK_tblMFManufacturingProcessMachine_tblICStorageLocation_intProductionStagingLocationId] FOREIGN KEY ([intProductionStagingLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId])
)
