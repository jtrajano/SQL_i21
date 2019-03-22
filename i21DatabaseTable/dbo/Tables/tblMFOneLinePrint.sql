CREATE TABLE [dbo].[tblMFOneLinePrint]
(
	[intOneLinePrintId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblMFOneLinePrint_intOneLinePrintId] PRIMARY KEY ([intOneLinePrintId]), 
    CONSTRAINT [UQ_tblMFOneLinePrint_strName] UNIQUE ([strName]) 
)
