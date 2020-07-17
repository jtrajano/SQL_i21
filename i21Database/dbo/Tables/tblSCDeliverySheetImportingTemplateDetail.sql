CREATE TABLE [dbo].[tblSCDeliverySheetImportingTemplateDetail]
(
	[intImportingTemplateDetailId] INT NOT NULL IDENTITY, 
	[intImportingTemplateId] INT NOT NULL, 
	[intFieldNameId] INT NOT NULL, 
    [strFieldName] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intFieldColumnNumber] INT NOT NULL, 
    [strCellColumn] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intItemId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSCDeliverySheetImportingTemplateDetail_intImportingTemplateDetailId] PRIMARY KEY ([intImportingTemplateDetailId]),
	CONSTRAINT [FK_tblSCDeliverySheetImportingTemplateDetail_tblSCDeliverySheetImportingTemplate_intImportingTemplateId] FOREIGN KEY ([intImportingTemplateId]) REFERENCES [tblSCDeliverySheetImportingTemplate]([intImportingTemplateId]),
	CONSTRAINT [FK_tblSCDeliverySheetImportingTemplateDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Detail Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplateDetail',
    @level2type = N'COLUMN',
    @level2name = N'intImportingTemplateDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Database relationship for header',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplateDetail',
    @level2type = N'COLUMN',
    @level2name = N'intImportingTemplateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Field Name Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplateDetail',
    @level2type = N'COLUMN',
    @level2name = N'intFieldNameId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Field Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplateDetail',
    @level2type = N'COLUMN',
    @level2name = N'strFieldName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Field Column Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplateDetail',
    @level2type = N'COLUMN',
    @level2name = N'intFieldColumnNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount schedule Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplateDetail',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplateDetail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'