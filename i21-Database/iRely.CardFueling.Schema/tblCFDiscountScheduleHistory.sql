CREATE TABLE [dbo].[tblCFDiscountScheduleHistory] (
    [intCustomerId]            INT             NULL,
    [intAccountId]             INT             NULL,
    [intFromQty]               INT             NULL,
    [intThruQty]               INT             NULL,
    [dblRate]                  NUMERIC (18, 6) NULL,
    [intDiscountScheduleId]    INT             NULL,
    [intDiscountSchedDetailId] INT             NULL,
    [strInvoiceNumberHistory]  NVARCHAR (MAX)  NULL
);

