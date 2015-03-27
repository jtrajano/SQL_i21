CREATE TABLE [dbo].[tblSMPaymentMethod] (
    [intPaymentMethodID] INT            IDENTITY (1, 1) NOT NULL,
    [strPaymentMethod]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPaymentMethodCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL, 
    [intAccountId] INT NULL DEFAULT 0, 
    [strPrintOption] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]            INT            NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMPaymentMethod] PRIMARY KEY CLUSTERED ([intPaymentMethodID] ASC), 
    CONSTRAINT [AK_tblSMPaymentMethod_PaymentMethod] UNIQUE (strPaymentMethod)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPaymentMethod',
    @level2type = N'COLUMN',
    @level2name = N'intPaymentMethodID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Payment Method Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPaymentMethod',
    @level2type = N'COLUMN',
    @level2name = N'strPaymentMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Payment Method is Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPaymentMethod',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPaymentMethod',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMPaymentMethod',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'