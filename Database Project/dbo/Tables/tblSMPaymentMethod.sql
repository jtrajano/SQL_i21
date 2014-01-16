CREATE TABLE [dbo].[tblSMPaymentMethod] (
    [intPaymentMethodID] INT            IDENTITY (1, 1) NOT NULL,
    [strPaymentMethod]   NVARCHAR (100) NOT NULL,
    [ysnActive]          BIT            DEFAULT ((1)) NOT NULL,
    [intSort]            INT            NULL,
    CONSTRAINT [PK_tblSMPaymentMethod] PRIMARY KEY CLUSTERED ([intPaymentMethodID] ASC)
);

