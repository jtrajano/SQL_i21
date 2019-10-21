CREATE TABLE [dbo].[tblSTCheckoutRegisterCorrections]
(
	[intCorrectionId] INT NOT NULL IDENTITY, 
    [intCheckoutId] INT NULL, 
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intCategoryId] INT NULL, 
	[intPaymentOptionId] INT NULL,
    [strReasonForCorrection] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intAccount] INT NULL, 
    [dblAmount] DECIMAL(18, 6) NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutRegisterCorrections_intCorrectionId] PRIMARY KEY ([intCorrectionId]), 
    CONSTRAINT [FK_tblSTCheckoutRegisterCorrections_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSTCheckoutRegisterCorrections_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]), 
    CONSTRAINT [FK_tblSTCheckoutRegisterCorrections_tblSTPaymentOption] FOREIGN KEY ([intPaymentOptionId]) REFERENCES [tblSTPaymentOption]([intPaymentOptionId]),
	CONSTRAINT [FK_tblSTCheckoutRegisterCorrections_tblGLAccount] FOREIGN KEY ([intAccount]) REFERENCES [tblGLAccount]([intAccountId]),
)
