CREATE TABLE [dbo].[tblSCScaleDevice]
(
	[intScaleDeviceId] INT NOT NULL IDENTITY, 
    [intPhysicalEquipmentId] INT NOT NULL, 
    [strDeviceDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [intDeviceTypeId] INT NOT NULL, 
    [intConnectionMethod] INT NOT NULL, 
    [strFilePath] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strFileName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strIPAddress] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [intIPPort] INT NULL, 
    [intComPort] INT NULL, 
    [intBaudRate] INT NULL, 
    [intDataBits] INT NULL, 
    [intStopBits] INT NULL, 
    [intParityBits] INT NULL, 
    [intFlowControl] INT NULL, 
    [intGraderModel] INT NULL, 
    [ysnVerifyCommodityCode] BIT NULL, 
	[ysnVerifyDateTime] BIT NULL, 
    [ysnDateTimeCheck] BIT NULL, 
    [ysnDateTimeFixedLocation] BIT NULL, 
    [intDateTimeStartingLocation] INT NULL, 
    [intDateTimeLength] INT NULL, 
    [strDateTimeValidationString] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [ysnMotionDetection] BIT NULL, 
    [ysnMotionFixedLocation] BIT NULL, 
    [intMotionStartingLocation] INT NULL, 
    [intMotionLength] INT NULL, 
    [strMotionValidationString] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [intWeightStabilityCheck] INT NULL, 
    [ysnWeightFixedLocation] BIT NULL, 
    [intWeightStartingLocation] INT NULL, 
    [intWeightLength] INT NULL, 
    [strNTEPCapacity] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSCScaleDevice_intScaleDeviceId] PRIMARY KEY ([intScaleDeviceId]), 
    CONSTRAINT [UK_tblSCScaleDevice_intPhysicalEquipmentId_intDeviceTypeId] UNIQUE ([intPhysicalEquipmentId],[intDeviceTypeId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intScaleDeviceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phisical Equipment ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intPhysicalEquipmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'strDeviceDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intDeviceTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Connection Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intConnectionMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'File Path',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'strFilePath'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'File Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'strFileName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'IP Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'strIPAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'IP Port',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intIPPort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'COM Port',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intComPort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'BAUD Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intBaudRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Data Bits',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intDataBits'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Stop Bits',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intStopBits'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Parity Bits',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intParityBits'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Flow Control',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intFlowControl'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grader Model',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intGraderModel'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Verify Commodity Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'ysnVerifyCommodityCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Time Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'ysnDateTimeCheck'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Time Fixed Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = 'ysnDateTimeFixedLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Time Starting Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intDateTimeStartingLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Time Length',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intDateTimeLength'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Time Validation String',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'strDateTimeValidationString'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Motion Detection',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'ysnMotionDetection'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Motion Fixed Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'ysnMotionFixedLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Motion Starting Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = 'intMotionStartingLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Motion Length',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intMotionLength'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Motion Validation String',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'strMotionValidationString'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Stability',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = 'intWeightStabilityCheck'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Fixed Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'ysnWeightFixedLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Starting Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intWeightStartingLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Length',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intWeightLength'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'NTEP Capacity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'strNTEPCapacity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Verify Date Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCScaleDevice',
    @level2type = N'COLUMN',
    @level2name = N'ysnVerifyDateTime'