CREATE TABLE [dbo].[tblIPSQLType]
(
	[intSQLTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblIPSQLType_intSQLTypeId] PRIMARY KEY ([intSQLTypeId]), 
    CONSTRAINT [UQ_tblIPSQLType_strName] UNIQUE ([strName])
)