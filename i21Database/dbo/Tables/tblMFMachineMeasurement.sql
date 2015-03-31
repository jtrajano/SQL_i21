	CREATE TABLE [dbo].[tblMFMachineMeasurement]
	(
		[intMachineMeasurementId] INT NOT NULL IDENTITY, 
		[intMachineId] INT NOT NULL, 
		[intMeasurementId] INT NULL, 
		[intReadingPointId] INT NULL, 
		[ysnSelected] BIT NULL CONSTRAINT [DF_tblMFMachineMeasurement_ysnSelected] DEFAULT 0, 
		[intSequenceNo] INT NOT NULL, 
		[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFMachineMeasurement_intConcurrencyId] DEFAULT 0, 
		[intCreatedUserId] [int] NULL,
		[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblMFMachineMeasurement_dtmCreated] DEFAULT GetDate(),
		[intLastModifiedUserId] [int] NULL,
		[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblMFMachineMeasurement_dtmLastModified] DEFAULT GetDate(),	 		

		CONSTRAINT [PK_tblMFMachineMeasurement] PRIMARY KEY ([intMachineMeasurementId]), 
		CONSTRAINT [FK_tblMFMachineMeasurement_tblMFMachine] FOREIGN KEY ([intMachineId]) REFERENCES [tblMFMachine]([intMachineId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblMFMachineMeasurement_tblICMeasurement] FOREIGN KEY ([intMeasurementId]) REFERENCES [tblICMeasurement]([intMeasurementId]),
		CONSTRAINT [FK_tblMFMachineMeasurement_tblICReadingPoint] FOREIGN KEY ([intReadingPointId]) REFERENCES [tblICReadingPoint]([intReadingPointId])  
	)

	GO
	