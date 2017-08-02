CREATE TABLE [dbo].[tblSCDeliverySheet]
(
	[intDeliverySheetId] INT NOT NULL IDENTITY,
	[intEntityId] INT NOT NULL, 
    [intCompanyLocationId] INT NOT NULL, 
    [intItemId] INT NULL, 
    [intDiscountId] INT NULL, 
	[strDeliverySheetNumber] NVARCHAR(MAX) NULL,
    [dtmDeliverySheetDate] DATETIME NULL DEFAULT GETDATE(), 
	[intTicketTypeId] INT NULL, 
    [ysnActive] BIT NULL DEFAULT (0),
    [ysnPost] BIT NULL DEFAULT (0),
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
	CONSTRAINT [PK_tblSCDeliverySheet_intDeliverySheetId] PRIMARY KEY ([intDeliverySheetId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblGRDiscountId_intDiscountId] FOREIGN KEY ([intDiscountId]) REFERENCES [tblGRDiscountId]([intDiscountId]),
	CONSTRAINT [FK_tblSCDeliverySheet_tblSCListTicketTypes_intTicketTypeId] FOREIGN KEY ([intTicketTypeId]) REFERENCES [tblSCListTicketTypes]([intTicketTypeId])
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
    @value = N'Posted deliverysheet',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'ysnPost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active deliverysheet',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheet',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
