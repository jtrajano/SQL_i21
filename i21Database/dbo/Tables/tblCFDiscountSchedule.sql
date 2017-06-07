CREATE TABLE [dbo].[tblCFDiscountSchedule] (
    [intDiscountScheduleId]   INT            IDENTITY (1, 1) NOT NULL,
    [strDiscountSchedule]     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]          NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [ysnDiscountOnRemotes]    BIT            NULL,
    [ysnDiscountOnExtRemotes] BIT            NULL,
    [ysnShowOnCFInvoice]      BIT            NULL,
    [intConcurrencyId]        INT            CONSTRAINT [DF_tblCFDiscountSchedule_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFDiscountSchedule] PRIMARY KEY CLUSTERED ([intDiscountScheduleId] ASC)
);

GO 
CREATE UNIQUE NONCLUSTERED INDEX tblCFDiscountSchedule_UniqueDiscountSchedule
	ON tblCFDiscountSchedule (strDiscountSchedule);