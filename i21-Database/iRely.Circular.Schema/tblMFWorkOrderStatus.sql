CREATE TABLE [dbo].[tblMFWorkOrderStatus]
(
	[intStatusId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strBackColorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intSequenceNo int,
	CONSTRAINT [PK_tblMFWorkOrderStatus_intStatusId] PRIMARY KEY ([intStatusId]), 
    CONSTRAINT [UQ_tblMFWorkOrderStatus_strName] UNIQUE ([strName]) 
)
