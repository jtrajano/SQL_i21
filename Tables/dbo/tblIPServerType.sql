CREATE TABLE [dbo].[tblIPServerType]
(
	[intServerTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblIPServerType_intServerTypeId] PRIMARY KEY ([intServerTypeId]), 
    CONSTRAINT [UQ_tblIPServerType_strName] UNIQUE ([strName])
)
