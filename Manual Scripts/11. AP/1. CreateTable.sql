CREATE TABLE [dbo].[tblEntities] (
    [intEntityId] [int] NOT NULL IDENTITY,
    [strName] [nvarchar](max) NOT NULL,
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
	[strContactName] [nvarchar](max),
    [strAddress] [nvarchar](max),
    [strCity] [nvarchar](max),
    [strCountry] [nvarchar](max),
    [strState] [nvarchar](max),
    [strZipCode] [nvarchar](max),
    [strEmail] [nvarchar](max),
    [strNotes] [nvarchar](max),
    [strW9Name] [nvarchar](max),
    [intShipViaId] [int],
    [intTaxCodeId] [int],
    [intTermsId] [int],
    [intWarehouseId] [int]
    CONSTRAINT [PK_dbo.tblEntityLocations] PRIMARY KEY ([intEntityLocationId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblEntityLocations]([intEntityId])
ALTER TABLE [dbo].[tblEntityTypes] ADD CONSTRAINT [FK_dbo.tblEntityTypes_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblEntityContacts] ADD CONSTRAINT [FK_dbo.tblEntityContacts_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblEntityLocations] ADD CONSTRAINT [FK_dbo.tblEntityLocations_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE

GO

CREATE TABLE [dbo].[tblAPBillBatches] (
    [intBillBatchId] [int] NOT NULL IDENTITY,
    [intAccountId] [int] NOT NULL,
    [strBillBatchNumber] [nvarchar](50),
	[strReference] [nvarchar](50),
	[dblTotal] [decimal](18, 2) NOT NULL,
	[ysnPosted] [bit] NULL DEFAULT(0),
    CONSTRAINT [PK_dbo.tblAPBillBatches] PRIMARY KEY ([intBillBatchId])
)
CREATE TABLE [dbo].[tblAPBills] (
    [intBillId] [int] NOT NULL IDENTITY,
    [strBillId] [nvarchar](50),
    [intBillBatchId] [int] NOT NULL,
    [strVendorId] [nvarchar](max),
    [strVendorOrderNumber] [nvarchar](max),
    [intTermsId] [int] NOT NULL,
    [intTaxCodeId] [int],
    [dtmDate] [datetime] NOT NULL,
    [dtmBillDate] [datetime] NOT NULL,
    [dtmDueDate] [datetime] NOT NULL,
    [intAccountId] [int] NOT NULL,
    [strDescription] [nvarchar](max),
    [dblTotal] [decimal](18, 2) NOT NULL,
	[dblAmountDue] [decimal](18, 2) NOT NULL,
    [ysnPosted] [bit] NOT NULL,
	[ysnPaid] [bit] NOT NULL,
    CONSTRAINT [PK_dbo.tblAPBills] PRIMARY KEY ([intBillId])
)
CREATE INDEX [IX_intBillBatchId] ON [dbo].[tblAPBills]([intBillBatchId])
CREATE TABLE [dbo].[tblAPPayments] (
    [intPaymentId] [int] NOT NULL IDENTITY,
    [intAccountId] [int] NOT NULL,
    [intBankAccountId] [int] NOT NULL,
    [intPaymentMethod] [int] NOT NULL,
    [intCurrencyID] [int] NOT NULL,
    [strVendorId] [nvarchar](max),
    [strPaymentInfo] [nvarchar](max),
    [strNotes] [nvarchar](max),
    [dtmDatePaid] [datetime] NOT NULL,
    [dblCredit] [decimal](18, 2) NOT NULL,
    [dblAmountPaid] [decimal](18, 2) NOT NULL,
    [dblUnappliedAmount] [decimal](18, 2) NOT NULL,
    [ysnPosted] [bit] NOT NULL,
    CONSTRAINT [PK_dbo.tblAPPayments] PRIMARY KEY ([intPaymentId])
)
CREATE TABLE [dbo].[tblAPPaymentDetails] (
    [intPaymentDetailId] [int] NOT NULL IDENTITY,
    [intPaymentId] [int] NOT NULL,
    [intBillId] [int] NOT NULL,
    [intTermsId] [int] NOT NULL,
    [intAccountId] [int] NOT NULL,
    [dtmDueDate] [datetime] NOT NULL,
    [dblDiscount] [decimal](18, 2) NOT NULL,
    [dblAmountDue] [decimal](18, 2) NOT NULL,
    [dblPayment] [decimal](18, 2) NOT NULL,
	[dblInterest] [decimal](18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.tblAPPaymentDetails] PRIMARY KEY ([intPaymentDetailId])
)
CREATE INDEX [IX_intPaymentId] ON [dbo].[tblAPPaymentDetails]([intPaymentId])
CREATE TABLE [dbo].[tblAPVendors] (
    [intEntityId] [int] NOT NULL,
    [intEntityLocationId] [int] NOT NULL,
    [intEntityContactId] [int] NOT NULL,
    [intCurrencyId] [int],
    [strVendorPayToId] [nvarchar](max),
    [intPaymentMethodId] [int] NOT NULL,
    [intShipViaId] [int],
    [intTaxCodeId] [int],
    [intGLAccountExpenseId] [int] NOT NULL,
    [intFederalTaxId] [nvarchar](max),
    [intTermsId] [nvarchar](max),
    [intVendorType] [int] NOT NULL,
    [strVendorId] [nvarchar](50),
	[strTaxState] [nvarchar](50),
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
    [ysnW9Signed] [bit] NOT NULL,
    [dblCreditLimit] [float] NOT NULL,
    [intCreatedUserId] [int] NOT NULL,
    [intLastModifiedUserId] [int] NOT NULL,
    [dtmLastModified] [datetime] NOT NULL,
    [dtmCreated] [datetime] NOT NULL,
    CONSTRAINT [PK_dbo.tblAPVendors] PRIMARY KEY ([intEntityId])
)
CREATE INDEX [IX_intEntityId] ON [dbo].[tblAPVendors]([intEntityId])
ALTER TABLE [dbo].[tblAPBills] ADD CONSTRAINT [FK_dbo.tblAPBills_dbo.tblAPBillBatches_intBillBatchId] FOREIGN KEY ([intBillBatchId]) REFERENCES [dbo].[tblAPBillBatches] ([intBillBatchId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblAPPaymentDetails] ADD CONSTRAINT [FK_dbo.tblAPPaymentDetails_dbo.tblAPPayments_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblAPPayments] ([intPaymentId]) ON DELETE CASCADE
ALTER TABLE [dbo].[tblAPVendors] ADD CONSTRAINT [FK_dbo.tblAPVendors_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId])

GO

--CHANGE COLLATION

--tblEntities
ALTER TABLE dbo.[tblEntities] ALTER COLUMN strName
           [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL;

ALTER TABLE dbo.[tblEntities] ALTER COLUMN [strWebsite]
           [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL;

ALTER TABLE dbo.[tblEntities] ALTER COLUMN [strInternalNotes]
           [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL;


--tblEntityTypes
ALTER TABLE dbo.[tblEntityTypes] ALTER COLUMN [strType]
           [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL;


--tblEntityContacts
ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strName]
           [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL;

ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strTitle]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strLocationName]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strDepartment]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strMobile]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strPhone]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strPhone2]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strEmail2]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strFax]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityContacts] ALTER COLUMN [strNotes]
           [nvarchar](max) COLLATE Latin1_General_CI_AS


--tblEntityLocations
ALTER TABLE dbo.[tblEntityLocations] ALTER COLUMN [strLocationName]
           [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL;

ALTER TABLE dbo.[tblEntityLocations] ALTER COLUMN [strAddress]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityLocations] ALTER COLUMN [strCity]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityLocations] ALTER COLUMN [strCountry]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityLocations] ALTER COLUMN [strState]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityLocations] ALTER COLUMN [strZipCode]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityLocations] ALTER COLUMN [strEmail]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityLocations] ALTER COLUMN [strNotes]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.[tblEntityLocations] ALTER COLUMN [strW9Name]
           [nvarchar](max) COLLATE Latin1_General_CI_AS

--ADD UNIQUE CONSTRAIN

ALTER TABLE tblEntityContacts
ADD CONSTRAINT EntityContactName_Unique UNIQUE NONCLUSTERED(strName)

ALTER TABLE tblEntityLocations
ADD CONSTRAINT EntityLocatioName_Unique UNIQUE NONCLUSTERED(strLocationName)

GO

--ADD AUTO GENERATE ALPHA NUMERIC

ALTER TABLE dbo.tblAPBillBatches 
	DROP COLUMN strBillBatchNumber
ALTER TABLE dbo.tblAPBillBatches 
	ADD strBillBatchNumber AS 'BB-' + CAST(intBillBatchId as varchar(5)) COLLATE Latin1_General_CI_AS

ALTER TABLE dbo.tblAPBills 
	DROP COLUMN strBillId
ALTER TABLE dbo.tblAPBills 
	ADD strBillId AS 'BL-' + CAST(intBillId as varchar(5)) COLLATE Latin1_General_CI_AS

--CHANGE COLLATION

--tblAPBills
ALTER TABLE dbo.[tblAPBills] ALTER COLUMN [strVendorId]
           [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL;

ALTER TABLE dbo.[tblAPBills] ALTER COLUMN [strVendorOrderNumber]
           [nvarchar](max) COLLATE Latin1_General_CI_AS;

ALTER TABLE dbo.[tblAPBills] ALTER COLUMN [strDescription]
           [nvarchar](max) COLLATE Latin1_General_CI_AS;

--tblAPPayments
ALTER TABLE dbo.[tblAPPayments] ALTER COLUMN [strVendorId]
           [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL;

ALTER TABLE dbo.[tblAPPayments] ALTER COLUMN [strPaymentInfo]
           [nvarchar](max) COLLATE Latin1_General_CI_AS;

ALTER TABLE dbo.[tblAPPayments] ALTER COLUMN [strNotes]
           [nvarchar](max) COLLATE Latin1_General_CI_AS;

--tblAPVendors
ALTER TABLE dbo.[tblAPVendors] ALTER COLUMN [strVendorPayToId]
           [nvarchar](max) COLLATE Latin1_General_CI_AS;

ALTER TABLE dbo.[tblAPVendors] ALTER COLUMN [strVendorId]
           [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL;

ALTER TABLE dbo.[tblAPVendors] ALTER COLUMN [strVendorAccountNum]
           [nvarchar](15) COLLATE Latin1_General_CI_AS;

ALTER TABLE dbo.[tblAPVendors] ALTER COLUMN [str1099Name]
           [nvarchar](100) COLLATE Latin1_General_CI_AS;

ALTER TABLE dbo.[tblAPVendors] ALTER COLUMN [str1099Type]
           [nvarchar](20) COLLATE Latin1_General_CI_AS ;

ALTER TABLE dbo.[tblAPVendors] ALTER COLUMN [str1099Category]
           [nvarchar](100) COLLATE Latin1_General_CI_AS;

ALTER TABLE dbo.[tblAPBillBatches]
	ALTER COLUMN [strReference] [nvarchar](50) COLLATE Latin1_General_CI_AS

--ADD UNIQUE CONSTRAINT

ALTER TABLE tblAPVendors
ADD CONSTRAINT APVendorId_Unique UNIQUE NONCLUSTERED(strVendorId)

--ALTER TABLE tblAPVendors
--ADD CONSTRAINT APVendorId_Unique UNIQUE NONCLUSTERED(strVendorId)



--IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ImportBills]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
--DROP PROCEDURE [dbo].ImportBills
--GO
--CREATE PROCEDURE ImportBills
	
--AS

--SET QUOTED_IDENTIFIER OFF
--SET ANSI_NULLS ON
--SET NOCOUNT ON
--SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

----back up
--IF(EXISTS(SELECT 1 FROM sys.tables WHERE name = 'tblAPOriginBills')) DROP TABLE tblAPOriginBills
--SELECT * INTO tblAPOriginBills FROM aptrxmst 

--IF(EXISTS(SELECT 1 FROM sys.tables WHERE name = 'tblAPOriginBillsPosted')) DROP TABLE tblAPOriginBillsPosted
--SELECT * INTO tblAPOriginBillsPosted FROM aptrxmst 

--SELECT * FROM aptrxmst

--INSERT INTO [dbo].[tblAPBills] ([intBillBatchId], [strVendorId], [strVendorOrderNumber], [intTermsId], [intTaxCodeId], [dtmDate], [dtmBillDate], [dtmDueDate], [intAccountId], [strDescription], [dblTotal], [ysnPosted], [ysnPaid])
--SELECT 
--	0
--	,A.aptrx_vnd_no
--	,A.aptrx_ivc_no
--	,
--	FROM aptrxmst A
--	INNER JOIN aptrxmst B ON A.aptrx_ivc_no = B.aptrx_ivc_no