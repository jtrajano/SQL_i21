CREATE TABLE [dbo].[tblSTCheckoutPaymentOptions]
(
	[intPaymentOptionsPrimId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
    [strPaymentOptionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intPaymentOptionId] INT NULL, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
	[intItemId] INT NULL, 
    [intAccountId] INT NULL, 
    [dblAmount] DECIMAL(18, 6) NULL, 
    [dblRegisterAmount] DECIMAL(18, 6) NULL, 
    [intRegisterCount] INT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutPaymentOptions_intPaymentOptionsId] PRIMARY KEY ([intPaymentOptionsPrimId]), 
    CONSTRAINT [FK_tblSTCheckoutPaymentOptions_tblSTPaymentOption] FOREIGN KEY ([intPaymentOptionId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
    CONSTRAINT [FK_tblSTCheckoutPaymentOptions_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
	CONSTRAINT [FK_tblSTCheckoutPaymentOptions_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
    CONSTRAINT [FK_tblSTCheckoutPaymentOptions_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE
)
