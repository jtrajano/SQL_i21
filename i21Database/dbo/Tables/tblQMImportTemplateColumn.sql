CREATE TABLE [dbo].[tblQMImportTemplateColumn]
(
	[intImportTemplateColumnId] INT IDENTITY (1, 1) NOT NULL
  , [intImportTypeId]			INT NOT NULL
  , [strInternalColumnName]		NVARCHAR(50) NULL
  , [strTemplateColumnName]		NVARCHAR(50) NULL
  , [ysnActive] BIT
  , CONSTRAINT [PK_tblQMImportTemplateColumn] PRIMARY KEY (intImportTemplateColumnId)
  , CONSTRAINT [UK_tblQMImportType_intImportTypeId_strInternalColumnName_ysnActive] UNIQUE ([intImportTypeId], [strInternalColumnName], [ysnActive])
)
