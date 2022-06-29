CREATE TABLE [dbo].[tblCFDiscountScheduleHistory] (
    [intCustomerId]            INT             NULL,
    [intAccountId]             INT             NULL,
    [intFromQty]               INT             NULL,
    [intThruQty]               INT             NULL,
    [dblRate]                  NUMERIC (18, 6) NULL,
    [intDiscountScheduleId]    INT             NULL,
    [intDiscountSchedDetailId] INT             NULL,
    [strInvoiceNumberHistory]  NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
);

