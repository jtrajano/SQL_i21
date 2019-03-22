CREATE TABLE [dbo].[tblMFReadingPoint]
(
	[intReadingPointId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblMFReadingPoint_intReadingPointId] PRIMARY KEY ([intReadingPointId]), 
    CONSTRAINT [UQ_tblMFReadingPoint_strName] UNIQUE ([strName]) 
)
