CREATE TABLE [dbo].[tblCFInvoiceGroupByCardOdometerHistory] (
    [intCardId]               INT            NULL,
    [intAccountId]            INT            NULL,
    [intLastOdometer]         INT            NULL,
    [dtmMinDate]              DATETIME       NULL,
    [strInvoiceNumberHistory] NVARCHAR (MAX) NULL
);

