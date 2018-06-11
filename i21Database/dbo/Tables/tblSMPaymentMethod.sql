CREATE TABLE [dbo].[tblSMPaymentMethod] (
    [intPaymentMethodID] INT IDENTITY (1, 1) NOT NULL,
    [strPaymentMethod] NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPaymentMethodCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL, 
    [strPrefix] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
    [intNumber] INT NOT NULL DEFAULT 1,
    [intAccountId] INT NULL , 
    [strPrintOption] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive] BIT DEFAULT ((1)) NOT NULL,
    [intSort] INT NOT NULL DEFAULT 0,
	[intOriginalId] INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMPaymentMethod] PRIMARY KEY CLUSTERED ([intPaymentMethodID] ASC), 
    CONSTRAINT [AK_tblSMPaymentMethod_PaymentMethod] UNIQUE (strPaymentMethod),
	CONSTRAINT [FK_tblSMPaymentMethod_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId])
);


GO
