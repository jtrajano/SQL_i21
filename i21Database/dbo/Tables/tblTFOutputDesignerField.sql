CREATE TABLE [dbo].[tblTFOutputDesignerField]
(
	[intOutputDesignerFieldId] INT IDENTITY NOT NULL, 
    [strColumnName] NVARCHAR(50) NULL, 
    [strColumnType] NVARCHAR(50) NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFOutputDesignerField] PRIMARY KEY ([intOutputDesignerFieldId]) 
)
