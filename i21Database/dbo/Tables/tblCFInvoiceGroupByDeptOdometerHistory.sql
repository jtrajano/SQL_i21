CREATE TABLE [dbo].[tblCFInvoiceGroupByDeptOdometerHistory] (
    [strDepartment]           NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]            INT            NULL,
    [intLastOdometer]         INT            NULL,
    [dtmMinDate]              DATETIME       NULL,
    [strInvoiceNumberHistory] NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
);

