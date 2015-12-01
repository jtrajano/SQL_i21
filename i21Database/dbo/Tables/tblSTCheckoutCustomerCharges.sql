CREATE TABLE [dbo].[tblSTCheckoutCustomerCharges]
(
	[intCustChargeId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
    [intCustomerId] INT NULL, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intInvoice] INT NULL, 
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblAmount] DECIMAL(18, 6) NULL, 
    [strComment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intProduct] INT NULL, 
    [dblUnitPrice] DECIMAL(18, 6) NULL, 
    [dblGallons] DECIMAL(18, 6) NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutCustomerCharges_intCustChargeId] PRIMARY KEY ([intCustChargeId]), 
	CONSTRAINT [FK_tblSTCheckoutCustomerCharges_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]), 
    CONSTRAINT [FK_tblSTCheckoutCustomerCharges_tblEntity] FOREIGN KEY ([intCustomerId]) REFERENCES [tblEntity]([intEntityId]), 
    CONSTRAINT [FK_tblSTCheckoutCustomerCharges_tblICItemUOM] FOREIGN KEY ([intProduct]) REFERENCES [tblICItemUOM]([intItemUOMId]) 
)
