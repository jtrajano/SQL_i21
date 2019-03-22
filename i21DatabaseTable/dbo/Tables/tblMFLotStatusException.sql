CREATE TABLE [dbo].[tblMFLotStatusException] (
	[intExceptionId] INT NOT NULL IDENTITY(1, 1)
	,[intLotStatusId] INT
	,CONSTRAINT [PK_tblMFLotStatusException_intExceptionId] PRIMARY KEY (intExceptionId)
	)