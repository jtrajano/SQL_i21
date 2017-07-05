﻿CREATE TABLE [dbo].[tblSCDeliverySheet]
(
	[intDeliverySheetId] INT NOT NULL IDENTITY,
	[intEntityId] INT NULL, 
    [intCompanyLocationId] INT NULL, 
	[strDeliverySheetNumber] NVARCHAR(MAX) NULL,
    [dtmDeliverySheetDate] DATETIME NULL, 
	[intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblSCDeliverySheet_intDeliverySheetId] PRIMARY KEY ([intDeliverySheetId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'intDeliverySheetId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'strDeliverySheetNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'dtmDeliverySheetDate'