CREATE TABLE [dbo].[tblGRDiscountSchedule]
(
	[intDiscountScheduleId] INT NOT NULL  IDENTITY, 
    [intCurrencyId] INT NOT NULL, 
    [intCommodityId] INT NOT NULL, 
    [strDiscountDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblGRDiscountSchedule_intDiscountScheduleId] PRIMARY KEY ([intDiscountScheduleId]), 
    CONSTRAINT [FK_tblGRDiscountSchedule_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
    CONSTRAINT [FK_tblGRDiscountSchedule_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [UK_tblGRDiscountSchedule_strDiscountDescription_intCurrencyId_intCommodityId] UNIQUE ([strDiscountDescription], [intCurrencyId], [intCommodityId])
)