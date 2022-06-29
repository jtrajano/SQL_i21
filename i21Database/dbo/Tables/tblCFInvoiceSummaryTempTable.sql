CREATE TABLE [dbo].[tblCFInvoiceSummaryTempTable] (
    [intDiscountScheduleId]        INT             NULL,
    [intTermsCode]                 INT             NULL,
    [intTermsId]                   INT             NULL,
    [intARItemId]                  INT             NULL,
    [strDepartmentDescription]     NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strShortName]                 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strProductDescription]        NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strItemNumber]                NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strItemDescription]           NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
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
    [intTransactionId]             INT             NULL,
    [strGuid]                      NVARCHAR (100)  COLLATE Latin1_General_CI_AS  NULL,
    [strUserId]                    NVARCHAR (100)  COLLATE Latin1_General_CI_AS  NULL,
    [strStatementType]             NVARCHAR (100)  COLLATE Latin1_General_CI_AS  NULL
);







