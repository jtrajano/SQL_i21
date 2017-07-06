CREATE TABLE [dbo].[tblSCDeliverySheet]
(
	[intDeliverySheetId] INT NOT NULL IDENTITY,
	[intEntityId] INT NOT NULL, 
    [intCompanyLocationId] INT NOT NULL, 
	[strDeliverySheetNumber] NVARCHAR(MAX) NULL,
    [dtmDeliverySheetDate] DATETIME NULL DEFAULT GETDATE(), 
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
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
    @level2name = N'intCompanyLocationId'
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