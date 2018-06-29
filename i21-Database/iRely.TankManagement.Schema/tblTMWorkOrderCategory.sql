CREATE TABLE [dbo].[tblTMWorkOrderCategory]
(
	[intWorkOrderCategoryId] INT NOT NULL  IDENTITY, 
    [strWorkOrderCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnDefault] BIT NOT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    [strDescription] NVARCHAR(200)  COLLATE Latin1_General_CI_AS  NULL,
	CONSTRAINT [PK_tblTMWorkOrderCategory] PRIMARY KEY CLUSTERED ([intWorkOrderCategoryId] ASC),
	CONSTRAINT [UQ_tblTMWorkOrderCategory_strWorkOrderCategory] UNIQUE NONCLUSTERED ([strWorkOrderCategory] ASC) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrderCategory',
    @level2type = N'COLUMN',
    @level2name = 'intWorkOrderCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Work Order Category',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrderCategory',
    @level2type = N'COLUMN',
    @level2name = N'strWorkOrderCategory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrderCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrderCategory',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

CREATE INDEX [IX_tblTMWorkOrderCategory_strWorkOrderCategory] ON [dbo].[tblTMWorkOrderCategory] ([strWorkOrderCategory])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrderCategory',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'