﻿CREATE TABLE [dbo].[tblCFInvoiceFeeStagingTable] (
    [intFeeLoopId]                  INT             NULL,
    [intAccountId]                  INT             NULL,
    [intTransactionId]              INT             NULL,
    [intCardId]                     INT             NULL,
    [intCustomerId]                 INT             NULL,
    [intTermID]                     INT             NULL,
    [intSalesPersonId]              INT             NULL,
    [intItemId]                     INT             NULL,
    [intARLocationId]               INT             NULL,
    [dblFeeRate]                    NUMERIC (18, 6) NULL,
    [dblQuantity]                   NUMERIC (18, 6) NULL,
    [dblFeeAmount]                  NUMERIC (18, 6) NULL,
    [dblFeeTotalAmount]             NUMERIC (18, 6) NULL,
    [strFeeDescription]             NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strFee]                        NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceFormat]              NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceReportNumber]        NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strCalculationType]            NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dtmTransactionDate]            DATETIME        NULL,
    [dtmInvoiceDate]                DATETIME        NULL,
    [dtmStartDate]                  DATETIME        NULL,
    [dtmEndDate]                    DATETIME        NULL,
    [strGuid]                       NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL,
    [strUserId]                     NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL,
    [intFeeProfileId]               INT             NULL,
    [strFeeProfileDescription]      NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dblTieredDiscountFeeAmount]    NUMERIC (18, 6) NULL
);





