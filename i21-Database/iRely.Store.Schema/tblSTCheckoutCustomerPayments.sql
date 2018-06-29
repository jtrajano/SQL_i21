CREATE TABLE [dbo].[tblSTCheckoutCustomerPayments]
(
	[intCustPaymentsId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
    [intCustomerId] INT NULL, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intInvoice] INT NULL, 
    [dblAmount] DECIMAL(18, 6) NULL, 
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strCheckNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strComment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
	[intItemId] INT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutCustomerPayments_intCustPaymentsId] PRIMARY KEY ([intCustPaymentsId]), 
	CONSTRAINT [FK_tblSTCheckoutCustomerPayments_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE ,
    CONSTRAINT [FK_tblSTCheckoutCustomerPayments_tblEMEntity] FOREIGN KEY ([intCustomerId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblSTCheckoutCustomerPayments_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES tblICItem([intItemId]) 
)
