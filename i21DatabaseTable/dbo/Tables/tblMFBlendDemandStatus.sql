CREATE TABLE [dbo].[tblMFBlendDemandStatus]
(
	[intStatusId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFBlendDemandStatus_intBlendDemandStatusId] PRIMARY KEY ([intStatusId]), 
    CONSTRAINT [UQ_tblMFBlendDemandStatus_strName] UNIQUE ([strName]) 
)
