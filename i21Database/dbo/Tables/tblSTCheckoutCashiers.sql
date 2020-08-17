CREATE TABLE [dbo].[tblSTCheckoutCashiers] (
    [intCheckoutCashierId]  INT             IDENTITY (1, 1) NOT NULL,
    [intCheckoutId]         INT             NULL,
    [intCashierId]          INT             NULL,
    [dblTotalSales]         NUMERIC (18, 6) CONSTRAINT [DF_tblSTCheckoutCashiers_dblTotalSales] DEFAULT ((0)) NULL,
    [dblTotalPaymentOption] NUMERIC (18, 6) CONSTRAINT [DF_tblSTCheckoutCashiers_dblTotalPaymentOption] DEFAULT ((0)) NULL,
    [dblTotalDeposit]       NUMERIC (18, 6) CONSTRAINT [DF_tblSTCheckoutCashiers_dblTotalDeposit] DEFAULT ((0)) NULL,
    [intNumberOfVoids]      INT             CONSTRAINT [DF_tblSTCheckoutCashiers_intNumberOfVoids] DEFAULT ((0)) NULL,
    [dblVoidAmount]         NUMERIC (18, 6) CONSTRAINT [DF_tblSTCheckoutCashiers_dblVoidAmount] DEFAULT ((0)) NULL,
    [intNumberOfRefunds]    INT             CONSTRAINT [DF_tblSTCheckoutCashiers_intNumberOfRefunds] DEFAULT ((0)) NULL,
    [dblRefundAmount]       NUMERIC (18, 6) CONSTRAINT [DF_tblSTCheckoutCashiers_dblRefundAmount] DEFAULT ((0)) NULL,
    [intOverrideCount]      INT             CONSTRAINT [DF_tblSTCheckoutCashiers_intOverrideCount] DEFAULT ((0)) NULL,
    [intNoSalesCount]       INT             CONSTRAINT [DF_tblSTCheckoutCashiers_intNoSalesCount] DEFAULT ((0)) NULL,
    [intCustomerCount]      INT             CONSTRAINT [DF_tblSTCheckoutCashiers_intCustomerCount] DEFAULT ((0)) NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblSTCheckoutCashiers_intConcurrencyId] DEFAULT ((1)) NULL,

    CONSTRAINT [PK_tblSTCheckoutCashiers] PRIMARY KEY CLUSTERED ([intCheckoutCashierId] ASC),
    CONSTRAINT [FK_tblSTCheckoutCashiers_tblSTCashier] FOREIGN KEY ([intCashierId]) REFERENCES [dbo].[tblSTCashier] ([intCashierId]),
    CONSTRAINT [FK_tblSTCheckoutCashiers_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [dbo].[tblSTCheckoutHeader] ([intCheckoutId])
);

