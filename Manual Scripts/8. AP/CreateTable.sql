CREATE TABLE [dbo].[tblEntities] (
    [intEntityId] [int] NOT NULL IDENTITY,
    [strName] [nvarchar](max) NOT NULL,
    [strWebsite] [nvarchar](max) NOT NULL,
    [strInternalNotes] [nvarchar](max),
    CONSTRAINT [PK_dbo.tblEntities] PRIMARY KEY ([intEntityId])
)
CREATE TABLE [dbo].[tblEntityTypes] (
    [intEntityTypeId] [int] NOT NULL IDENTITY,
    [intEntityId] [int] NOT NULL,
    [strType] [nvarchar](max) NOT NULL,
    CONSTRAINT [PK_dbo.tblEntityTypes] PRIMARY KEY ([intEntityTypeId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblEntityTypes]([intEntityId])
CREATE TABLE [dbo].[tblEntityContacts] (
    [intEntityContactId] [int] NOT NULL IDENTITY,
    [intEntityId] [int] NOT NULL,
    [strName] [nvarchar](50) NOT NULL,
    [strTitle] [nvarchar](max),
    [strLocationName] [nvarchar](max),
    [strDepartment] [nvarchar](max),
    [strMobile] [nvarchar](max),
    [strPhone] [nvarchar](max),
    [strPhone2] [nvarchar](max),
    [strEmail] [nvarchar](max),
    [strEmail2] [nvarchar](max),
    [strFax] [nvarchar](max),
    [strNotes] [nvarchar](max),
    CONSTRAINT [PK_dbo.tblEntityContacts] PRIMARY KEY ([intEntityContactId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblEntityContacts]([intEntityId])
CREATE TABLE [dbo].[tblEntityLocations] (
    [intEntityLocationId] [int] NOT NULL IDENTITY,
    [intEntityId] [int] NOT NULL,
    [strLocationName] [nvarchar](50) NOT NULL,
    [strAddress] [nvarchar](max),
    [strCity] [nvarchar](max),
    [strCountry] [nvarchar](max),
    [strState] [nvarchar](max),
    [strZipCode] [nvarchar](max),
    [strEmail] [nvarchar](max),
    [strNotes] [nvarchar](max),
    [strW9Name] [nvarchar](max),
    [intShipViaId] [int] NOT NULL,
    [intTaxCodeId] [int] NOT NULL,
    [intTermsId] [int] NOT NULL,
    CONSTRAINT [PK_dbo.tblEntityLocations] PRIMARY KEY ([intEntityLocationId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblEntityLocations]([intEntityId])
ALTER TABLE [dbo].[tblEntityTypes] ADD CONSTRAINT [FK_dbo.tblEntityTypes_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblEntityContacts] ADD CONSTRAINT [FK_dbo.tblEntityContacts_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblEntityLocations] ADD CONSTRAINT [FK_dbo.tblEntityLocations_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE

GO

CREATE TABLE [dbo].[tblAPBillBatches] (
    [intBillBatchId] [int] NOT NULL IDENTITY,
    [intAccountID] [int] NOT NULL,
    CONSTRAINT [PK_dbo.tblAPBillBatches] PRIMARY KEY ([intBillBatchId])
)
ALTER TABLE dbo.tblAPBillBatches ADD strBillBatchNumber AS 'BB-' + CAST(intBillBatchId as varchar(5))
CREATE TABLE [dbo].[tblAPBills] (
    [intBillId] [int] NOT NULL IDENTITY,
    [intBillBatchId] [int] NOT NULL,
    [intVendorId] [int] NOT NULL,
    [intTermsId] [int] NOT NULL,
    [intTaxCodeId] [int] NOT NULL,
    [dtmDate] [datetime] NOT NULL,
    [dtmBillDate] [datetime] NOT NULL,
    [dtmDueDate] [datetime] NOT NULL,
    [intAccountID] [nvarchar](max),
    [strDescription] [nvarchar](max),
    [dblTotal] [decimal](18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.tblAPBills] PRIMARY KEY ([intBillId])
)
CREATE INDEX [IX_intBillBatchId] ON [dbo].[tblAPBills]([intBillBatchId])
CREATE TABLE [dbo].[tblAPVendors] (
    [intEntityId] [int] NOT NULL,
    [intEntityLocationId] [int] NOT NULL,
    [intEntityContactId] [int] NOT NULL,
    [intCurrencyId] [int] NOT NULL,
    [intVendorPayToId] [int],
    [intPaymentMethodId] [int] NOT NULL,
    [intShipViaId] [int],
    [intTaxCodeId] [int],
    [intGLAccountExpenseId] [int] NOT NULL,
    [intFederalTaxID] [nvarchar](max),
    [intTermsId] [nvarchar](max),
    [intVendorType] [int] NOT NULL,
    [strVendorId] [nvarchar](50),
    [strVendorAccountNum] [nvarchar](15),
    [str1099Name] [nvarchar](100),
    [str1099Type] [nvarchar](20),
    [str1099Category] [nvarchar](100),
    [ysnPymtCtrlActive] [bit] NOT NULL,
    [ysnPymtCtrlAlwaysDiscount] [bit] NOT NULL,
    [ysnPymtCtrlEFTActive] [bit] NOT NULL,
    [ysnPymtCtrlHold] [bit] NOT NULL,
    [ysnPrint1099] [bit] NOT NULL,
    [ysnWithholding] [bit] NOT NULL,
    [dblCreditLimit] [float] NOT NULL,
    [dtmW9Signed] [datetime] NOT NULL,
    [intCreatedUserId] [int] NOT NULL,
    [intLastModifiedUserId] [int] NOT NULL,
    [dtmLastModified] [datetime] NOT NULL,
    [dtmCreated] [datetime] NOT NULL,
    CONSTRAINT [PK_dbo.tblAPVendors] PRIMARY KEY ([intEntityId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblAPVendors]([intEntityId])
ALTER TABLE [dbo].[tblAPBills] ADD CONSTRAINT [FK_dbo.tblAPBills_dbo.tblAPBillBatches_intBillBatchId] FOREIGN KEY ([intBillBatchId]) REFERENCES [dbo].[tblAPBillBatches] ([intBillBatchId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblAPVendors] ADD CONSTRAINT [FK_dbo.tblAPVendors_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId])

GO

ALTER TABLE tblEntityContacts
ADD CONSTRAINT EntityContactName_Unique UNIQUE NONCLUSTERED(strName)

ALTER TABLE tblEntityLocations
ADD CONSTRAINT EntityLocatioName_Unique UNIQUE NONCLUSTERED(strLocationName)

ALTER TABLE tblAPVendors
ADD CONSTRAINT APVendorId_Unique UNIQUE NONCLUSTERED(strVendorId)