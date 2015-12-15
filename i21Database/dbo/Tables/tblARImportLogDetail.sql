﻿CREATE TABLE [dbo].[tblARImportLogDetail]
(
	[intImportLogDetailId]		INT			  NOT NULL IDENTITY, 
    [intImportLogId]			INT			  NOT NULL,
	[strEventResult]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionNumber]		NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType]		NVARCHAR(30)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	[strLocationName]			NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL,	
	[strTerms]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate]					DATETIME	  NULL,
	[dtmDueDate]				DATETIME	  NULL,
	[dtmPostDate]				DATETIME	  NULL,
	[dtmShipDate]				DATETIME	  NULL,
	[strFreightTerm]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strShipVia]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSalespersonNumber]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strBOLNumber]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPONumber]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strComment]				NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strTaxGroup]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSiteNumber]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strItemNumber]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblSubtotal]				NUMERIC(18,6) NULL,
    [dblTax]					NUMERIC(18,6) NULL,
	[dblQuantity]				NUMERIC(18,6) NULL,
    [dblTotal]					NUMERIC(18,6) NULL,
    [dblDiscount]				NUMERIC(18,6) NULL,
    [dblAmountDue]				NUMERIC(18,6) NULL,
    [dblPayment]				NUMERIC(18,6) NULL,
	[dblPercentFull]			NUMERIC(18,6) NULL,
	[dblNewMeterReading]		NUMERIC(18,6) NULL,	
	[ysnSuccess]				BIT           NULL,
	[ysnImported]				BIT           NULL,	
    [intConcurrencyId]			INT           NOT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblARImportLogDetail_intImportLogDetailId] PRIMARY KEY CLUSTERED ([intImportLogDetailId] ASC), 
    CONSTRAINT [FK_tblARImportLogDetail_tblARImportLog] FOREIGN KEY ([intImportLogId]) REFERENCES [dbo].[tblARImportLog]([intImportLogId]) ON DELETE CASCADE
)
