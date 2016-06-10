CREATE TABLE tblETExportFilterCategory(  
    [intExportFilterCategoryId] int IDENTITY(1,1) NOT NULL,
	[intCategoryId] int NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
CONSTRAINT [PK_tblETExportFilterCategory] PRIMARY KEY CLUSTERED 
(
	[intExportFilterCategoryId] ASC
),CONSTRAINT [FK_tblETExportFilterCategory_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) ON DELETE CASCADE)