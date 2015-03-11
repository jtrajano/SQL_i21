CREATE TABLE [dbo].[tblSCTicketDiscount]
(
	[intTicketDiscountId] INT NOT NULL  IDENTITY, 
    [intTicketId] INT NOT NULL, 
    [strDiscountCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dblGradeReading] DECIMAL(7, 3) NOT NULL, 
    [strCalcMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [dblDiscountAmount] DECIMAL(9, 6) NOT NULL, 
    [strShrinkWhat] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [dblShrinkPercent] DECIMAL(7, 3) NOT NULL, 
	[ysnGraderAutoEntry] BIT NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSCTicketDiscount_intTicketDiscountId] PRIMARY KEY ([intTicketDiscountId]), 
    CONSTRAINT [UK_tblSCTicketDiscount_intTicketId_strDiscountCode] UNIQUE ([intTicketId],[strDiscountCode]), 
    CONSTRAINT [FK_tblSCTicketDiscount_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'intTicketDiscountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'strDiscountCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grade Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'dblGradeReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'strCalcMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'dblDiscountAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shrink What',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'strShrinkWhat'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shrink Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'dblShrinkPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurreny Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grader Auto Entry',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketDiscount',
    @level2type = N'COLUMN',
    @level2name = N'ysnGraderAutoEntry'