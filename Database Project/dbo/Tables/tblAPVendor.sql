CREATE TABLE [dbo].[tblAPVendor] (
    [intEntityId]               INT            NOT NULL,
    [intEntityLocationId]       INT            NOT NULL,
    [intEntityContactId]        INT            NOT NULL,
    [intCurrencyId]             INT            NULL,
    [strVendorPayToId]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intPaymentMethodId]        INT            NOT NULL,
    [intShipViaId]              INT            NULL,
    [intTaxCodeId]              INT            NULL,
    [intGLAccountExpenseId]     INT            NULL,
    [strFederalTaxId]           NVARCHAR (MAX) NULL,
    [intTermsId]                NVARCHAR (MAX) NULL,
    [intVendorType]             INT            NOT NULL,
    [strVendorId]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strVendorAccountNum]       NVARCHAR (15)  COLLATE Latin1_General_CI_AS NULL,
    [str1099Name]               NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [str1099Type]               NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [str1099Category]           NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [ysnPymtCtrlActive]         BIT            NOT NULL DEFAULT 1,
    [ysnPymtCtrlAlwaysDiscount] BIT            NOT NULL DEFAULT 0,
    [ysnPymtCtrlEFTActive]      BIT            NOT NULL DEFAULT 0,
    [ysnPymtCtrlHold]           BIT            NOT NULL DEFAULT 0,
    [ysnPrint1099]              BIT            NOT NULL,
    [ysnWithholding]            BIT            NOT NULL,
    [ysnW9Signed]               BIT            NOT NULL,
    [dblCreditLimit]            FLOAT (53)     NOT NULL,
    [intCreatedUserId]          INT            NULL,
    [intLastModifiedUserId]     INT            NULL,
    [dtmLastModified]           DATETIME       NULL,
    [dtmCreated]                DATETIME       NULL,
    [strTaxState] NVARCHAR(50) NULL, 
    CONSTRAINT [PK_dbo.tblAPVendor] PRIMARY KEY CLUSTERED ([intEntityId] ASC),
    CONSTRAINT [FK_dbo.tblAPVendor_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]),
    CONSTRAINT [APVendorId_Unique] UNIQUE NONCLUSTERED ([strVendorId] ASC)
);


GO
ALTER TABLE [dbo].[tblAPVendor] NOCHECK CONSTRAINT [FK_dbo.tblAPVendor_dbo.tblEntities_intEntityId];




GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblAPVendor]([intEntityId] ASC);

