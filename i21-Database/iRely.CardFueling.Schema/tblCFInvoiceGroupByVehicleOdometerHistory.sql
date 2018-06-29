CREATE TABLE [dbo].[tblCFInvoiceGroupByVehicleOdometerHistory] (
    [strVehicleNumber]        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]            INT            NULL,
    [intLastOdometer]         INT            NULL,
    [dtmMinDate]              DATETIME       NULL,
    [strInvoiceNumberHistory] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL
);

