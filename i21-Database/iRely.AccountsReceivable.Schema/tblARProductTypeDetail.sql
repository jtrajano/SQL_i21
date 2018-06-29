CREATE TABLE [dbo].[tblARProductTypeDetail]
(
	[intProductTypeDetailId] INT NOT NULL  IDENTITY, 
    [intProductTypeId]		 INT NOT NULL, 
    [intCategoryId]			 INT NULL, 
    [intConcurrencyId]		 INT NOT NULL, 
	CONSTRAINT [PK_tblARProductTypeDetail_intProductTypeDetailId] PRIMARY KEY CLUSTERED ([intProductTypeDetailId] ASC),
	CONSTRAINT [FK_tblARProductTypeDetail_tblARProductType] FOREIGN KEY ([intProductTypeId]) REFERENCES [dbo].[tblARProductType]([intProductTypeId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblARProductTypeDetail_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory]([intCategoryId]),
	CONSTRAINT [UK_tblARProductTypeDetail_intCategoryId] UNIQUE (intCategoryId)
)
