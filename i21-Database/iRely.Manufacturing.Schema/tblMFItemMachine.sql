CREATE TABLE [dbo].[tblMFItemMachine]
(
	[intItemMachineId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
    [intMachineId] INT NOT NULL, 
    [intLocationId] INT NOT NULL,
	[ysnDefault] bit NULL CONSTRAINT [DF_tblMFItemMachine_ysnDefault] DEFAULT 0,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblMFItemMachine_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblMFItemMachine_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFItemMachine_intConcurrencyId] DEFAULT 0,  
	CONSTRAINT [PK_tblMFItemMachine_intItemMachineId] PRIMARY KEY (intItemMachineId), 
	CONSTRAINT [FK_tblMFItemMachine_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])  ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFItemMachine_tblMFMachine_intMachineId] FOREIGN KEY ([intMachineId]) REFERENCES [tblMFMachine]([intMachineId]),
	CONSTRAINT [FK_tblMFItemMachine_tblSMCompanyLocation_intCompanyLocationId_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [UQ_tblMFItemMachine_intItemId_intMachineId_intLocationId] UNIQUE ([intItemId],[intLocationId],[intMachineId])
)
