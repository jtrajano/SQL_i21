CREATE TABLE [dbo].[tblMFCommentType]
(
	[intCommentTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblMFCommentType_intCommentTypeId] PRIMARY KEY ([intCommentTypeId]), 
    CONSTRAINT [UQ_tblMFCommentType_strName] UNIQUE ([strName]) 
)
