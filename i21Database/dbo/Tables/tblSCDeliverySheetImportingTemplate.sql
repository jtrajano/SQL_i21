﻿CREATE TABLE [dbo].[tblSCDeliverySheetImportingTemplate]
(
	[intImportingTemplateId] INT NOT NULL IDENTITY, 
    [strTemplateCode] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strTemplateDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnActive] BIT NOT NULL DEFAULT 1, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSCDeliverySheetImportingTemplate_intImportingTemplateId] PRIMARY KEY ([intImportingTemplateId]), 
    CONSTRAINT [UK_tblSCDeliverySheetImportingTemplate_strTemplateCode] UNIQUE ([strTemplateCode])
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplate',
    @level2type = N'COLUMN',
    @level2name = N'intImportingTemplateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplate',
    @level2type = N'COLUMN',
    @level2name = N'strTemplateCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplate',
    @level2type = N'COLUMN',
    @level2name = N'strTemplateDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplate',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetImportingTemplate',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'