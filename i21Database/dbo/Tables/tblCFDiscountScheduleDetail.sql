﻿CREATE TABLE [dbo].[tblCFDiscountScheduleDetail] (
    [intDiscountSchedDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intDiscountScheduleId]    INT             NOT NULL,
    [intFromQty]               NUMERIC (18, 6) NULL,
    [intThruQty]               NUMERIC (18, 6) NULL,
    [dblRate]                  NUMERIC (18, 6) NULL,
    [intConcurrencyId]         INT             CONSTRAINT [DF_tblCFDiscountScheduleDetail_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFDiscountScheduleDetail] PRIMARY KEY CLUSTERED ([intDiscountSchedDetailId] ASC),
    CONSTRAINT [FK_tblCFDiscountScheduleDetail_tblCFDiscountSchedule] FOREIGN KEY ([intDiscountScheduleId]) REFERENCES [dbo].[tblCFDiscountSchedule] ([intDiscountScheduleId]) ON DELETE CASCADE
);



