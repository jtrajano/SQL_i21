CREATE TABLE [dbo].[tblIPDelimiter]
(
	[intDelimiterId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblIPDelimiter_intDelimeterId] PRIMARY KEY ([intDelimiterId]), 
    CONSTRAINT [UQ_tblIPDelimiter_strName] UNIQUE ([strName])
)
