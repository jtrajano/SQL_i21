CREATE TABLE [dbo].[tblMFManufacturingProcess]
(
	[intManufacturingProcessId] INT NOT NULL IDENTITY(1,1) , 
    [strProcessName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
	[strWorkInstruction] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[intCreatedUserId] [int] NOT NULL,
	[dtmCreated] [datetime] NOT NULL CONSTRAINT [DF_tblMFManufacturingProcess_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NOT NULL,
	[dtmLastModified] [datetime] NOT NULL CONSTRAINT [DF_tblMFManufacturingProcess_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFManufacturingProcess_intConcurrencyId] DEFAULT 0, 
    CONSTRAINT [PK_tblMFManufacturingProcess_intManufacturingProcessId] PRIMARY KEY ([intManufacturingProcessId])
)
