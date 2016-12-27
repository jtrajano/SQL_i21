﻿CREATE TABLE [dbo].[tblTFTransactionSummary](
	[intTransactionSummaryId] INT IDENTITY NOT NULL,
	[strSummaryGuid] [uniqueidentifier] NOT NULL,
	[intTaxAuthorityId] INT NOT NULL,
	[strTaxAuthority] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFormCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intItemNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intItemSequenceNumber] INT NULL,
	[strSection] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strScheduleCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strColumn] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strColumnValue] NUMERIC(18, 2) NULL,
	[strSegment] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strProductCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxClass] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateRun] DATETIME NOT NULL,
	[dtmReportingPeriodBegin] DATETIME NULL,
	[dtmReportingPeriodEnd] DATETIME NULL,
	[strTaxPayerName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerAddress] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerIdentificationNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerFEIN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerDBA] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMotorCarrier] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strLicenseNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strEmail] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strFEINSSN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strZipCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTelephoneNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strContactName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFaxNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTransactionSummary] PRIMARY KEY ([intTransactionSummaryId])
)

GO