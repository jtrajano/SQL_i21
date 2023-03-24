CREATE TABLE [dbo].[tblSTCheckoutDepartmetTotals] (
    [intDepartmentTotalId]               INT             IDENTITY (1, 1) NOT NULL,
    [intCheckoutId]                      INT             NULL,
    [intCategoryId]                      INT             NULL,
    [intTotalSalesCount]                 INT             NULL,
    [dblTotalSalesAmountRaw]             DECIMAL (18, 6) NULL,
    [dblRegisterSalesAmountRaw]          DECIMAL (18, 6) NULL,
    [dblTotalSalesAmountComputed]        DECIMAL (18, 6) NULL,
    [dblRegisterSalesAmountComputed]     DECIMAL (18, 6) NULL,
    [strDepartmentTotalsComment]         NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [intPromotionalDiscountsCount]       INT             NULL,
    [dblPromotionalDiscountAmount]       DECIMAL (18, 6) NULL,
    [intManagerDiscountCount]            INT             NULL,
    [dblManagerDiscountAmount]           DECIMAL (18, 6) NULL,
    [intRefundCount]                     INT             NULL,
    [dblRefundAmount]                    DECIMAL (18, 6) NULL,
    [intItemsSold]                       INT             NULL,
    [dblTaxAmount1]                      DECIMAL (18, 6) NULL,
    [dblTaxAmount2]                      DECIMAL (18, 6) NULL,
    [dblTaxAmount3]                      DECIMAL (18, 6) NULL,
    [dblTaxAmount4]                      DECIMAL (18, 6) NULL,
    [intItemId]                          INT             NULL,    
    [intConcurrencyId]                   INT             NULL,
    [dblTotalLotterySalesAmountComputed] DECIMAL (18, 6) CONSTRAINT [DF_tblSTCheckoutDepartmetTotals_dblTotalLotterySalesAmountComputed] DEFAULT ((0)) NULL,
    [intLotteryItemsSold]                INT             CONSTRAINT [DF_tblSTCheckoutDepartmetTotals_intLotteryItemsSold] DEFAULT ((0)) NULL,
    [ysnLotteryItemAdded]                BIT             CONSTRAINT [DF_tblSTCheckoutDepartmetTotals_ysnLotteryItemAdded] DEFAULT ((0)) NULL,
    [intSubcategoriesId]                 INT             NULL,
    [strRegisterCode]                    NVARCHAR(50)    COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblSTCheckoutDepartmetTotals_intDepartmentTotalId] PRIMARY KEY CLUSTERED ([intDepartmentTotalId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_tblSTCheckoutDepartmetTotals_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId]),
    CONSTRAINT [FK_tblSTCheckoutDepartmetTotals_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
    CONSTRAINT [FK_tblSTCheckoutDepartmetTotals_tblSTSubCategories] FOREIGN KEY ([intSubcategoriesId]) REFERENCES [dbo].[tblSTSubCategories] ([intSubcategoriesId]),
    CONSTRAINT [FK_tblSTCheckoutDepartmetTotals_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [dbo].[tblSTCheckoutHeader] ([intCheckoutId]) ON DELETE CASCADE
);
GO

CREATE NONCLUSTERED INDEX [IX_tblSTCheckoutDepartmetTotals_intCheckoutId]
    ON [dbo].[tblSTCheckoutDepartmetTotals]([intCheckoutId] ASC);
GO
