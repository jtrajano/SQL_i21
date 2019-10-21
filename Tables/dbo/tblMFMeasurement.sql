CREATE TABLE [dbo].[tblMFMeasurement]
(
	[intMeasurementId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strType] NVARCHAR(8) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblMFMeasurement_intMeasurementId] PRIMARY KEY ([intMeasurementId]), 
    CONSTRAINT [UQ_tblMFMeasurement_strName] UNIQUE ([strName]) 
)
