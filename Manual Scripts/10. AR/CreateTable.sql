CREATE TABLE [dbo].[tblEntities] (
    [intEntityId] [int] NOT NULL IDENTITY,
    [strName] [nvarchar](max) NOT NULL,
    [strType] [nvarchar](max),
    [strWebsite] [nvarchar](max) NOT NULL,
    [strInternalNotes] [nvarchar](max),
    [RowVersion] rowversion NOT NULL,
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
    [strContactName] [nvarchar](50),
    [strTitle] [nvarchar](max),
    [strPhone] [nvarchar](max),
    [strEmail] [nvarchar](max),
    [strAltPhone] [nvarchar](max),
    [strAltEmail] [nvarchar](max),
    [strFax] [nvarchar](max),
    [strLocationName] [nvarchar](max),
    [strDepartment] [nvarchar](max),
    [strMobile] [nvarchar](max),
    [strNotes] [nvarchar](max),
    CONSTRAINT [PK_dbo.tblEntityContacts] PRIMARY KEY ([intEntityContactId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblEntityContacts]([intEntityId])
CREATE TABLE [dbo].[tblEntityLocations] (
    [intEntityLocationId] [int] NOT NULL IDENTITY,
    [intEntityId] [int] NOT NULL,
    [strLocationName] [nvarchar](50),
    [strContactName] [nvarchar](max),
    [strAddress] [nvarchar](max),
    [strCity] [nvarchar](max),
    [strState] [nvarchar](max),
    [strZipCode] [nvarchar](max),
    [strCountry] [nvarchar](max),
    [strEmail] [nvarchar](max),
    [intShipViaId] [int],
    [intTaxCodeId] [int],
    [intTermsId] [int],
    [intWarehouseId] [int],
    [strNotes] [nvarchar](max),
    CONSTRAINT [PK_dbo.tblEntityLocations] PRIMARY KEY ([intEntityLocationId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblEntityLocations]([intEntityId])
CREATE TABLE [dbo].[tblARCustomer] (
    [intEntityId] [int] NOT NULL,
    [strCustomerNumber] [nvarchar](15),
    [dblCreditLimit] [decimal](18, 2) NOT NULL,
    [dblARBalance] [decimal](18, 2) NOT NULL,
    [strAccountNumber] [nvarchar](max),
    [strTaxNumber] [nvarchar](max),
    [strCurrency] [nvarchar](max),
    [intAccountStatusId] [int] NOT NULL,
    [intSalesRepId] [int] NOT NULL,
    [strPricing] [nvarchar](max),
    [strLevel] [nvarchar](max),
    [strTimeZone] [nvarchar](max),
    [ysnActive] [bit] NOT NULL,
    [intBillToId] [int],
    [intShipToId] [int],
    [intEntityContactId] [int] NOT NULL,
    [intEntityLocationId] [int] NOT NULL,
    CONSTRAINT [PK_dbo.tblARCustomer] PRIMARY KEY ([intEntityId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblARCustomer]([intEntityId])
ALTER TABLE [dbo].[tblEntityTypes] ADD CONSTRAINT [FK_dbo.tblEntityTypes_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblEntityContacts] ADD CONSTRAINT [FK_dbo.tblEntityContacts_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblEntityLocations] ADD CONSTRAINT [FK_dbo.tblEntityLocations_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblARCustomer] ADD CONSTRAINT [FK_dbo.tblARCustomer_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId])

--ALTER TABLE tblARCustomer
--ADD CONSTRAINT ARCustomerNumber_Unique UNIQUE NONCLUSTERED(strCustomerNumber)



--ALTER COLLATION
ALTER TABLE tblEntities ALTER COLUMN  [strName] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL 
ALTER TABLE tblEntities  ALTER COLUMN   strWebsite nvarchar(max) COLLATE Latin1_General_CI_AS NOT NULL 
ALTER TABLE tblEntities ALTER COLUMN	strInternalNotes nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntities ALTER COLUMN	strType nvarchar(max) COLLATE Latin1_General_CI_AS 

ALTER TABLE tblEntityTypes ALTER COLUMN	strType nvarchar(max) COLLATE Latin1_General_CI_AS NOT NULL 

ALTER TABLE tblEntityContacts ALTER COLUMN	strContactName nvarchar(50) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strTitle nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strPhone nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strEmail nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strAltPhone nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strAltEmail nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strFax nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strLocationName nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strDepartment nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strMobile nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityContacts ALTER COLUMN	strNotes nvarchar(max) COLLATE Latin1_General_CI_AS

ALTER TABLE tblEntityLocations ALTER COLUMN	strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityLocations ALTER COLUMN	strContactName nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityLocations ALTER COLUMN	strAddress nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityLocations ALTER COLUMN	strCity nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityLocations ALTER COLUMN	strState nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityLocations ALTER COLUMN	strZipCode nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityLocations ALTER COLUMN	strCountry nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityLocations ALTER COLUMN	strEmail nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblEntityLocations ALTER COLUMN	strNotes nvarchar(max) COLLATE Latin1_General_CI_AS

ALTER TABLE tblARCustomer ALTER COLUMN	strCustomerNumber nvarchar(15) COLLATE Latin1_General_CI_AS
ALTER TABLE tblARCustomer ALTER COLUMN	strAccountNumber nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblARCustomer ALTER COLUMN	strTaxNumber nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblARCustomer ALTER COLUMN	strCurrency nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblARCustomer ALTER COLUMN	strPricing nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblARCustomer ALTER COLUMN	strLevel nvarchar(max) COLLATE Latin1_General_CI_AS
ALTER TABLE tblARCustomer ALTER COLUMN	strTimeZone nvarchar(max) COLLATE Latin1_General_CI_AS