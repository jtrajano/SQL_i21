CREATE TABLE [dbo].[tblCFInvoiceSummaryTempTable] (
    [intDiscountScheduleId]        INT             NULL,
    [intTermsCode]                 INT             NULL,
    [intTermsId]                   INT             NULL,
    [intARItemId]                  INT             NULL,
    [strDepartmentDescription]     NVARCHAR (MAX)  NULL,
    [strShortName]                 NVARCHAR (MAX)  NULL,
    [strProductDescription]        NVARCHAR (MAX)  NULL,
    [strItemNumber]                NVARCHAR (MAX)  NULL,
    [strItemDescription]           NVARCHAR (MAX)  NULL,
    [dblTotalQuantity]             NUMERIC (18, 6) NULL,
    [dblTotalGrossAmount]          NUMERIC (18, 6) NULL,
    [dblTotalNetAmount]            NUMERIC (18, 6) NULL,
    [dblTotalAmount]               NUMERIC (18, 6) NULL,
    [dblTotalTaxAmount]            NUMERIC (18, 6) NULL,
    [TotalFET]                     NUMERIC (18, 6) NULL,
    [TotalSET]                     NUMERIC (18, 6) NULL,
    [TotalSST]                     NUMERIC (18, 6) NULL,
    [TotalLC]                      NUMERIC (18, 6) NULL,
    [ysnIncludeInQuantityDiscount] BIT             NULL,
    [intAccountId]                 INT             NULL,
    [intTransactionId]             INT             NULL
);

