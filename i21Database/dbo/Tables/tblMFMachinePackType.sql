	CREATE TABLE [dbo].[tblMFMachinePackType]
	(
		[intMachinePackTypeId] INT NOT NULL IDENTITY, 
		[intMachineId] INT NOT NULL, 
		[intPackTypeId] INT NULL, 
		[dblMachineCapacity] NUMERIC(18, 6) NULL CONSTRAINT [DF_tblMFMachinePackType_dblMachineCapacity] DEFAULT 0, 
		[intMachineUOMId] INT NULL, 
		[intMachineRateUOMId] INT NULL, 
		[intSequenceNo] INT NULL, 
		[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFMachinePackType_intConcurrencyId] DEFAULT 0, 
		[intCreatedUserId] [int] NULL,
		[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblMFMachinePackType_dtmCreated] DEFAULT GetDate(),
		[intLastModifiedUserId] [int] NULL,
		[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblMFMachinePackType_dtmLastModified] DEFAULT GetDate(),	 		

		CONSTRAINT [PK_tblMFMachinePackType] PRIMARY KEY ([intMachinePackTypeId]), 
		CONSTRAINT [AK_tblMFMachinePackType_intMachineId_intPackTypeId] UNIQUE ([intMachineId],[intPackTypeId]), 
		CONSTRAINT [FK_tblMFMachinePackType_tblMFMachine] FOREIGN KEY ([intMachineId]) REFERENCES [tblMFMachine]([intMachineId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblMFMachinePackType_tblICPackType] FOREIGN KEY ([intPackTypeId]) REFERENCES [tblICPackType]([intPackTypeId]), 
		CONSTRAINT [FK_tblMFMachinePackType_tblICUnitMeasure_intMachineUOMId] FOREIGN KEY ([intMachineUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
		CONSTRAINT [FK_tblMFMachinePackType_tblICUnitMeasure_intMachineRateUOMId] FOREIGN KEY ([intMachineRateUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) 
		 
	)

	GO
	