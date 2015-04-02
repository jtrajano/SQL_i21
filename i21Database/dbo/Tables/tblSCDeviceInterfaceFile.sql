CREATE TABLE [dbo].[tblSCDeviceInterfaceFile]
(
	[intDeviceInterfaceFileId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intScaleDeviceId] INT NOT NULL, 
    [dtmTicketVoidDateTime] DATETIME NULL, 
    [strDeviceCommodity] NVARCHAR(20) NULL, 
    [strDeviceData] NVARCHAR(256) NOT NULL, 
    CONSTRAINT [PK_tblSCDeviceInterfaceFile_intDeviceInterfaceFileId] PRIMARY KEY ([intDeviceInterfaceFileId]), 
    CONSTRAINT [FK_tblSCDeviceInterfaceFile_tblSCScaleDevice_intScaleDeviceId] FOREIGN KEY ([intScaleDeviceId]) REFERENCES [tblSCScaleDevice]([intScaleDeviceId]) 
)
