CREATE TABLE [dbo].[tblSTCheckoutPaymentOptions]
(
	[intPaymentOptionsPrimId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
    [strPaymentOption] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intPaymentOptionId] INT NULL, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [dblAmount] DECIMAL(18, 6) NULL, 
    [dblRegisterAmount] DECIMAL(18, 6) NULL, 
    CONSTRAINT [PK_tblSTCheckoutPaymentOptions_intPaymentOptionsId] PRIMARY KEY ([intPaymentOptionsPrimId]), 
    CONSTRAINT [FK_tblSTCheckoutPaymentOptions_tblSTPaymentOption] FOREIGN KEY ([intPaymentOptionId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]), 
    CONSTRAINT [FK_tblSTCheckoutPaymentOptions_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) 
)
