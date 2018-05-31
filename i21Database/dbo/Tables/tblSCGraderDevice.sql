CREATE TABLE [dbo].[tblSCGraderDevice]
(
	[intGraderDeviceId] INT NOT NULL IDENTITY, 
	[intScaleDeviceId] INT NULL, 
    [strFieldName] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intFieldColumnNumber] INT NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSCGraderDevice_intGraderDeviceId] PRIMARY KEY ([intGraderDeviceId]),
	CONSTRAINT [FK_tblSCGraderDevice_tblSCScaleDevice_intScaleDeviceId] FOREIGN KEY ([intScaleDeviceId]) REFERENCES [tblSCScaleDevice]([intScaleDeviceId]) ON DELETE CASCADE
)