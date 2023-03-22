CREATE TABLE [dbo].[tblQMImportType]
(
	[intImportTypeId] INT NOT NULL
  , [strName]		  NVARCHAR(50) NULL
  , [strDescription]  NVARCHAR(50) NULL
  , CONSTRAINT [PK_tblQMImportType] PRIMARY KEY (intImportTypeId)
  , CONSTRAINT [UK_tblQMImportType_intImportTypeId_strName] UNIQUE ([intImportTypeId], [strName])
)
