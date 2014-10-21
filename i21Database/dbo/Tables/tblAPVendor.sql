CREATE TABLE [dbo].[tblAPVendor] (
    [intEntityId]               INT            NOT NULL,
	[intVendorId]				INT				IDENTITY (1, 1) NOT NULL, 
    [intDefaultLocationId]       INT            NULL,
    [intDefaultContactId]        INT            NULL,
    [intCurrencyId]             INT            NULL,
    [strVendorPayToId]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intPaymentMethodId]        INT            NULL,
    [intTaxCodeId]              INT            NULL,
    [intGLAccountExpenseId]     INT            NULL ,
    [intVendorType]             INT            NOT NULL,
    [strVendorId]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strVendorAccountNum]       NVARCHAR (15)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPymtCtrlActive]         BIT            DEFAULT 1 NOT NULL,
    [ysnPymtCtrlAlwaysDiscount] BIT            DEFAULT 0 NOT NULL,
    [ysnPymtCtrlEFTActive]      BIT            DEFAULT 0 NOT NULL,
    [ysnPymtCtrlHold]           BIT            DEFAULT 0 NOT NULL,
    [ysnWithholding]            BIT            NOT NULL,
    [dblCreditLimit]            NUMERIC(18, 6)     NOT NULL,
    [intCreatedUserId]          INT            NULL,
    [intLastModifiedUserId]     INT            NULL,
    [dtmLastModified]           DATETIME       NULL,
    [dtmCreated]                DATETIME       NULL,
    [strTaxState]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [strTaxNumber] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [intBillToId] INT NULL, 
    [intShipFromId] INT NULL, 
    CONSTRAINT [PK_dbo.tblAPVendor] PRIMARY KEY CLUSTERED ([intEntityId] ASC),
    CONSTRAINT [FK_dbo.tblAPVendor_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
    CONSTRAINT [UK_strVendorId] UNIQUE NONCLUSTERED ([strVendorId] ASC),
	CONSTRAINT [UK_intVendorId] UNIQUE NONCLUSTERED ([intVendorId] ASC),
	CONSTRAINT [FK_dbo.tblAPVendor_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intGLAccountExpenseId) REFERENCES tblGLAccount(intAccountId)
);


GO
ALTER TABLE [dbo].[tblAPVendor] CHECK CONSTRAINT [FK_dbo.tblAPVendor_dbo.tblEntities_intEntityId];


GO
CREATE NONCLUSTERED INDEX [IX_intVendorId]
    ON [dbo].[tblAPVendor]([intVendorId] ASC);

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
			@value = N'Information about the Vendor',
			@level0type = N'SCHEMA',
			@level0name = N'dbo',
			@level1type = N'TABLE',
			@level1name = N'tblAPVendor',
			@level2type = NULL,
			@level2name = NULL