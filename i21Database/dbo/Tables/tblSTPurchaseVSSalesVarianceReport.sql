CREATE TABLE [dbo].[tblSTPurchaseVSSalesVarianceReport] (
    [intPurchaseVSSalesVarianceReportId] INT             IDENTITY (1, 1) NOT NULL,
    [intStoreId]                         INT             NULL,
    [intStoreNo]                         INT             NULL,
    [strStoreDescription]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intCategoryId]                      INT             NULL,
    [strCategoryCode]                    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCategoryDescription]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intItemId]                          INT             NULL,
    [strItemNo]                          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strItemDescription]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblSalesQuantity]                   NUMERIC (18, 6) NULL,
    [dblPurchaseQuantity]                NUMERIC (18, 6) NULL,
    [dblVarianceQuantity]                NUMERIC (18, 6) NULL,
    [dblVariancePercentage]              NUMERIC (18, 6) NULL,
    [intInvoiceId]                       INT             NULL,
    [dtmCheckoutDate]                    DATETIME        NULL,
    [intLocationId]                      INT             NULL,
	[intItemLocationId]					 INT			 NULL,
	[intCompanyLocationId]				 INT			 NULL,
    [intConcurrencyId]                   INT             CONSTRAINT [DF_tblSTPurchaseVSSalesVarianceReport_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblSTVariance] PRIMARY KEY CLUSTERED ([intPurchaseVSSalesVarianceReportId] ASC)
);

