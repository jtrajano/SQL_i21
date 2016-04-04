CREATE TABLE [dbo].[tblIPFileType]
(
	[intFileTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblIPFileType_intFileTypeId] PRIMARY KEY ([intFileTypeId]), 
    CONSTRAINT [UQ_tblIPFileType_strName] UNIQUE ([strName])
)
