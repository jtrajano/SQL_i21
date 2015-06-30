CREATE TABLE [dbo].[tblARProductType]
(
	[intProductTypeId] INT NOT NULL  IDENTITY, 
    [strProductTypeName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strProductTypeDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblARProductType_intProductTypeId] PRIMARY KEY CLUSTERED ([intProductTypeId] ASC)
)
