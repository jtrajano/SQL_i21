CREATE TABLE [dbo].[tblTFOutputDesignerField]
(
	[intOutputDesignerFieldId] INT IDENTITY NOT NULL, 
    [strColumnName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strColumnType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFOutputDesignerField] PRIMARY KEY ([intOutputDesignerFieldId]) 
)
