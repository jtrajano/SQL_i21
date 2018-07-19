CREATE TABLE [dbo].[tblSCDeliverySheet]
(
	[intDeliverySheetId] INT NOT NULL IDENTITY,
	[intEntityId] INT NOT NULL, 
    [intCompanyLocationId] INT NOT NULL, 
    [intItemId] INT NULL, 
    [intDiscountId] INT NULL, 
	[strDeliverySheetNumber] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [dtmDeliverySheetDate] DATETIME NULL DEFAULT GETDATE(), 
	[intCurrencyId] INT NULL,
	[intTicketTypeId] INT NULL, 
	[intSplitId] INT NULL, 
	[strSplitDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
    [intFarmFieldId] INT NULL,
    [dblGross] NUMERIC(38, 20) NULL DEFAULT ((0)),
	[dblShrink] NUMERIC(38, 20) NULL DEFAULT ((0)),
	[dblNet] NUMERIC(38, 20) NULL DEFAULT ((0)),
	[intStorageScheduleRuleId] INT NULL, 
	[intCompanyId] INT NULL,
    [ysnPost] BIT NULL DEFAULT (0),
	[strCountyProducer] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
	[strOfflineGuid] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '', 
    CONSTRAINT [PK_tblSCDeliverySheet_intDeliverySheetId] PRIMARY KEY ([intDeliverySheetId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblGRDiscountId_intDiscountId] FOREIGN KEY ([intDiscountId]) REFERENCES [tblGRDiscountId]([intDiscountId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblSCListTicketTypes_intTicketTypeId] FOREIGN KEY ([intTicketTypeId]) REFERENCES [tblSCListTicketTypes]([intTicketTypeId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblGRStorageScheduleRule_intStorageScheduleRuleId] FOREIGN KEY ([intStorageScheduleRuleId]) REFERENCES [dbo].[tblGRStorageScheduleRule] ([intStorageScheduleRuleId])
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
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket type id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor/Customer Currency',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'intCurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor/Customer Split',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'intSplitId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor/Customer Farm Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'intFarmFieldId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Posted deliverysheet',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'ysnPost'
GO
