CREATE PROCEDURE [dbo].[uspARInitializeTempTableForAging]
AS
SET ANSI_NULLS ON
SET NOCOUNT ON

--CHANGES HERE SHOULD ALSO REFLECT IN PREDEPLOYMENT 14_RefreshARTempTables.sql

IF(OBJECT_ID('tempdb..##ARPOSTEDPAYMENT') IS NOT NULL) DROP TABLE ##ARPOSTEDPAYMENT
IF(OBJECT_ID('tempdb..##INVOICETOTALPREPAYMENTS') IS NOT NULL) DROP TABLE ##INVOICETOTALPREPAYMENTS
IF(OBJECT_ID('tempdb..##POSTEDINVOICES') IS NOT NULL) DROP TABLE ##POSTEDINVOICES
IF(OBJECT_ID('tempdb..##CASHREFUNDS') IS NOT NULL) DROP TABLE ##CASHREFUNDS
IF(OBJECT_ID('tempdb..##CASHRETURNS') IS NOT NULL) DROP TABLE ##CASHRETURNS
IF(OBJECT_ID('tempdb..##FORGIVENSERVICECHARGE') IS NOT NULL) DROP TABLE ##FORGIVENSERVICECHARGE
IF(OBJECT_ID('tempdb..##AGINGSTAGING') IS NOT NULL) DROP TABLE ##AGINGSTAGING
IF(OBJECT_ID('tempdb..##GLACCOUNTS') IS NOT NULL) DROP TABLE ##GLACCOUNTS
IF(OBJECT_ID('tempdb..##ADCUSTOMERS') IS NOT NULL) DROP TABLE ##ADCUSTOMERS
IF(OBJECT_ID('tempdb..##ADSALESPERSON') IS NOT NULL) DROP TABLE ##ADSALESPERSON
IF(OBJECT_ID('tempdb..##ADLOCATION') IS NOT NULL) DROP TABLE ##ADLOCATION
IF(OBJECT_ID('tempdb..##ADACCOUNTSTATUS') IS NOT NULL) DROP TABLE ##ADACCOUNTSTATUS
IF(OBJECT_ID('tempdb..##DELCUSTOMERS') IS NOT NULL) DROP TABLE ##DELCUSTOMERS
IF(OBJECT_ID('tempdb..##DELLOCATION') IS NOT NULL) DROP TABLE ##DELLOCATION
IF(OBJECT_ID('tempdb..##DELACCOUNTSTATUS') IS NOT NULL) DROP TABLE ##DELACCOUNTSTATUS
IF(OBJECT_ID('tempdb..##CREDITMEMOPAIDREFUNDED') IS NOT NULL) DROP TABLE ##CREDITMEMOPAIDREFUNDED 

CREATE TABLE ##DELCUSTOMERS (intEntityCustomerId	INT	NOT NULL PRIMARY KEY)
CREATE TABLE ##DELLOCATION (intCompanyLocationId INT NOT NULL PRIMARY KEY)
CREATE TABLE ##DELACCOUNTSTATUS (intAccountStatusId INT NOT NULL PRIMARY KEY)
CREATE TABLE ##ADSALESPERSON (intSalespersonId INT NOT NULL PRIMARY KEY)
CREATE TABLE ##ADLOCATION (intCompanyLocationId INT NOT NULL PRIMARY KEY)
CREATE TABLE ##ADACCOUNTSTATUS (intAccountStatusId INT, intEntityCustomerId INT)
CREATE TABLE ##ADCUSTOMERS (
	    intEntityCustomerId			INT	NOT NULL PRIMARY KEY
	  , strCustomerNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , strCustomerName				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	  , dblCreditLimit				NUMERIC(18, 6)
)
CREATE TABLE ##POSTEDINVOICES (
	   intInvoiceId					INT	NOT NULL PRIMARY KEY
	 , intEntityCustomerId			INT	NOT NULL
	 , intPaymentId					INT	NULL	 
	 , intCompanyLocationId			INT	NULL
	 , intEntitySalespersonId		INT	NULL
	 , strTransactionType			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NOT NULL
	 , strType						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL DEFAULT 'Standard' 
     , strBOLNumber					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	 , dblInvoiceTotal				NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblAmountDue					NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblDiscount					NUMERIC(18, 6)									NULL DEFAULT 0
	 , dblInterest					NUMERIC(18, 6)									NULL DEFAULT 0
	 , dtmPostDate					DATETIME										NULL
	 , dtmDueDate					DATETIME										NULL
	 , dtmDate						DATETIME										NULL
	 , dtmForgiveDate				DATETIME										NULL
	 , ysnForgiven					BIT												NULL
	 , ysnPaid						BIT												NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_##POSTEDINVOICES_intEntityCustomerId] ON [##POSTEDINVOICES]([intEntityCustomerId])
CREATE NONCLUSTERED INDEX [NC_Index_##POSTEDINVOICES_strTransactionType] ON [##POSTEDINVOICES]([strTransactionType])
CREATE NONCLUSTERED INDEX [NC_Index_##POSTEDINVOICES_dtmPostDate] ON [##POSTEDINVOICES]([dtmPostDate])
CREATE TABLE ##ARPOSTEDPAYMENT (
	   intPaymentId					INT												NOT NULL PRIMARY KEY
	 , dtmDatePaid					DATETIME										NULL
	 , dblAmountPaid				NUMERIC(18, 6)									NULL DEFAULT 0
	 , ysnInvoicePrepayment			BIT												NULL
	 , intPaymentMethodId			INT												NULL
     , strRecordNumber				NVARCHAR (25)   COLLATE Latin1_General_CI_AS	NULL
)
CREATE NONCLUSTERED INDEX [NC_Index_#ARPOSTEDPAYMENT] ON [##ARPOSTEDPAYMENT]([ysnInvoicePrepayment])
CREATE TABLE ##GLACCOUNTS (	
	  intAccountId					INT												NOT NULL PRIMARY KEY
	, strAccountCategory			NVARCHAR (100)   COLLATE Latin1_General_CI_AS	NULL
)
CREATE TABLE ##INVOICETOTALPREPAYMENTS (
	  intInvoiceId					INT												NULL
	, dblPayment					NUMERIC(18, 6)									NULL DEFAULT 0
)
CREATE TABLE ##CASHREFUNDS (
	   intOriginalInvoiceId			INT												NULL
	 , strDocumentNumber			NVARCHAR (25)   COLLATE Latin1_General_CI_AS	NULL
	 , dblRefundTotal				NUMERIC(18, 6)									NULL DEFAULT 0
)
CREATE TABLE ##CASHRETURNS (
      intInvoiceId					INT												NOT NULL PRIMARY KEY
	, intOriginalInvoiceId			INT												NULL
	, dblInvoiceTotal				NUMERIC(18, 6)									NULL DEFAULT 0
	, strInvoiceOriginId			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
    , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, dtmPostDate					DATETIME										NULL
)
CREATE TABLE ##FORGIVENSERVICECHARGE (
	   intInvoiceId					INT												NOT NULL PRIMARY KEY
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
)
CREATE TABLE ##CREDITMEMOPAIDREFUNDED (
	   intInvoiceId					INT												NOT NULL PRIMARY KEY
	 , strInvoiceNumber				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	 , strDocumentNumber			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
)