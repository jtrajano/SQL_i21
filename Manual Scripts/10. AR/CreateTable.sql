--CREATE TABLE [dbo].[tblEntities] (
--    [intEntityId] [int] NOT NULL IDENTITY,
--    [strName] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
--    [strType] [nvarchar](max) COLLATE Latin1_General_CI_AS ,
--    [strWebsite] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
--    [strInternalNotes] [nvarchar](max)  COLLATE Latin1_General_CI_AS ,
--    [RowVersion] rowversion NOT NULL,
--    CONSTRAINT [PK_dbo.tblEntities] PRIMARY KEY ([intEntityId])
--)
--CREATE TABLE [dbo].[tblEntityTypes] (
--    [intEntityTypeId] [int] NOT NULL IDENTITY,
--    [intEntityId] [int] NOT NULL,
--    [strType] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),
--    CONSTRAINT [PK_dbo.tblEntityTypes] PRIMARY KEY ([intEntityTypeId])
--)
--CREATE INDEX [IX_intEntityId] ON [dbo].[tblEntityTypes]([intEntityId])
--CREATE TABLE [dbo].[tblEntityContacts] (
--    [intEntityContactId] [int] NOT NULL IDENTITY,
--    [intEntityId] [int] NOT NULL,
--    [strContactName] [nvarchar](50)  COLLATE Latin1_General_CI_AS,
--    [strTitle] [nvarchar](max)  COLLATE Latin1_General_CI_AS,
--    [strPhone] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strEmail] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strAltPhone] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strAltEmail] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strFax] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strLocationName] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strDepartment] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strMobile] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strNotes] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    CONSTRAINT [PK_dbo.tblEntityContacts] PRIMARY KEY ([intEntityContactId])
--)
--CREATE INDEX [IX_intEntityId] ON [dbo].[tblEntityContacts]([intEntityId])
--CREATE TABLE [dbo].[tblEntityLocations] (
--    [intEntityLocationId] [int] NOT NULL IDENTITY,
--    [intEntityId] [int] NOT NULL,
--    [strLocationName] [nvarchar](50) COLLATE Latin1_General_CI_AS,
--    [strContactName] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strAddress] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strCity] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strState] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strZipCode] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strCountry] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [strEmail] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    [intShipViaId] [int],
--    [intTaxCodeId] [int],
--    [intTermsId] [int],
--    [intWarehouseId] [int],
--    [strNotes] [nvarchar](max) COLLATE Latin1_General_CI_AS,
--    CONSTRAINT [PK_dbo.tblEntityLocations] PRIMARY KEY ([intEntityLocationId])
--)
--CREATE INDEX [IX_intEntityId] ON [dbo].[tblEntityLocations]([intEntityId])

CREATE TABLE [dbo].[tblARCustomers] (
    [intEntityId] [int] NOT NULL,
    [strCustomerNumber] [nvarchar](15) COLLATE Latin1_General_CI_AS,
    [strType] [nvarchar](max) COLLATE Latin1_General_CI_AS,
    [dblCreditLimit] [decimal](18, 2) NOT NULL,
    [dblARBalance] [decimal](18, 2) NOT NULL,
    [strAccountNumber] [nvarchar](max) COLLATE Latin1_General_CI_AS,
    [strTaxNumber] [nvarchar](max) COLLATE Latin1_General_CI_AS,
    [strCurrency] [nvarchar](max) COLLATE Latin1_General_CI_AS,
    [intAccountStatusId] [int] NOT NULL,
    [intSalesRepId] [int] NOT NULL,
    [strPricing] [nvarchar](max) COLLATE Latin1_General_CI_AS,
    [strLevel] [nvarchar](max) COLLATE Latin1_General_CI_AS,
    [strTimeZone] [nvarchar](max) COLLATE Latin1_General_CI_AS,
    [ysnActive] [bit] NOT NULL,
    [intBillToId] [int],
    [intShipToId] [int],
    [intEntityContactId] [int] NOT NULL,
    [intEntityLocationId] [int] NOT NULL,
    CONSTRAINT [PK_dbo.tblARCustomers] PRIMARY KEY ([intEntityId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblARCustomers]([intEntityId])
--ALTER TABLE [dbo].[tblEntityTypes] ADD CONSTRAINT [FK_dbo.tblEntityTypes_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
--ALTER TABLE [dbo].[tblEntityContacts] ADD CONSTRAINT [FK_dbo.tblEntityContacts_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
--ALTER TABLE [dbo].[tblEntityLocations] ADD CONSTRAINT [FK_dbo.tblEntityLocations_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblARCustomers] ADD CONSTRAINT [FK_dbo.tblARCustomers_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId])
