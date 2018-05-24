CREATE TABLE [dbo].[tblCFInvoiceGroupByVehicleOdometerHistory] (
    [strVehicleNumber]        NVARCHAR (MAX) NULL,
    [intAccountId]            INT            NULL,
    [intLastOdometer]         INT            NULL,
    [dtmMinDate]              DATETIME       NULL,
    [strInvoiceNumberHistory] NVARCHAR (MAX) NULL
);

