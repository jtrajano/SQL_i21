CREATE TABLE [dbo].[tblIPScheduleType]
(
	[intScheduleTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblIPScheduleType_intScheduleTypeId] PRIMARY KEY ([intScheduleTypeId]), 
    CONSTRAINT [UQ_tblIPScheduleType_strName] UNIQUE ([strName])
)
