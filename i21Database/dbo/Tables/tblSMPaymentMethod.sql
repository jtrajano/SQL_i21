CREATE TABLE [dbo].[tblSMPaymentMethod] (
    [intPaymentMethodID] INT            IDENTITY (1, 1) NOT NULL,
    [strPaymentMethod]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnActive]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]            INT            NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMPaymentMethod] PRIMARY KEY CLUSTERED ([intPaymentMethodID] ASC)
);

