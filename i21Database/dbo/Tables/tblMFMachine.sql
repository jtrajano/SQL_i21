	CREATE TABLE [dbo].[tblMFMachine]
	(
		[intMachineId] INT NOT NULL IDENTITY, 
		[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFMachine_intConcurrencyId] DEFAULT 0, 
		[strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[intLocationId] INT NOT NULL, 
		[intSubLocationId] INT NULL, 
		[intParentMachineId] INT NULL, 
		[ysnCycleCounted] BIT NOT NULL CONSTRAINT [DF_tblMFMachine_ysnCycleCounted] DEFAULT 0, 
		[dblMinBatchSize] NUMERIC(18, 6) NULL CONSTRAINT [DF_tblMFMachine_dblMinBatchSize] DEFAULT 0, 
		[dblBatchSize] NUMERIC(18, 6) NULL CONSTRAINT [DF_tblMFMachine_dblBatchSize] DEFAULT 0, 
		[intBatchSizeUOMId] INT NULL, 
		[intChildCount] INT NOT NULL CONSTRAINT [DF_tblMFMachine_intChildCount] DEFAULT 0, 
		[ysnActive] BIT NOT NULL CONSTRAINT [DF_tblMFMachine_ysnActive] DEFAULT 0, 
		[intCreatedUserId] [int] NULL,
		[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblMFMachine_dtmCreated] DEFAULT GetDate(),
		[intLastModifiedUserId] [int] NULL,
		[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblMFMachine_dtmLastModified] DEFAULT GetDate(),	 				

		CONSTRAINT [PK_tblMFMachine] PRIMARY KEY ([intMachineId]), 
		CONSTRAINT [AK_tblMFMachine_strName_intLocationId_intSubLocationId] UNIQUE ([strName],[intLocationId],[intSubLocationId]), 
		CONSTRAINT [FK_tblMFMachine_tblMFMachine] FOREIGN KEY ([intParentMachineId]) REFERENCES [tblMFMachine]([intMachineId]),
		CONSTRAINT [FK_tblMFMachine_tblICUnitMeasure] FOREIGN KEY ([intBatchSizeUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
		CONSTRAINT [FK_tblMFMachine_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
		CONSTRAINT [FK_tblMFMachine_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId])  
		
	)

	GO
	