CREATE TABLE [dbo].[tblCFInvoiceSummaryTempTable] (
    [intDiscountScheduleId]        INT             NULL,
    [intTermsCode]                 INT             NULL,
    [intTermsId]                   INT             NULL,
    [intARItemId]                  INT             NULL,
    [strDepartmentDescription]     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strShortName]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strProductDescription]        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strItemNumber]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strItemDescription]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
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



