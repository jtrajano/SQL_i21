CREATE TABLE tblARPostInvoiceItemAccount (
	 [intItemId]                         INT                                             NOT NULL
    ,[strItemNo]                         NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[strType]                           NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[intLocationId]                     INT                                             NOT NULL 
    ,[intCOGSAccountId]                  INT                                             NULL
    ,[intSalesAccountId]                 INT                                             NULL
    ,[intInventoryAccountId]             INT                                             NULL
    ,[intInventoryInTransitAccountId]    INT                                             NULL
    ,[intGeneralAccountId]               INT                                             NULL
    ,[intOtherChargeIncomeAccountId]     INT                                             NULL
    ,[intAccountId]                      INT                                             NULL
    ,[intDiscountAccountId]              INT                                             NULL
    ,[intMaintenanceSalesAccountId]      INT                                             NULL
    ,[strSessionId]                      NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
	,PRIMARY KEY CLUSTERED ([intItemId], [intLocationId], [strSessionId])
);
GO
CREATE INDEX [idx_tblARPostInvoiceItemAccount_strSessionId] ON [dbo].[tblARPostInvoiceItemAccount] (strSessionId)
GO