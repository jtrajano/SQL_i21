﻿CREATE TABLE [dbo].[tblCFUsageExceptionAlertStaging](
	[intUsageExceptionAlertStagingId] [int] IDENTITY(1,1)  NOT NULL,
	[strCustomerNumber] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	intTransactionLimit [int] DEFAULT 0 NOT NULL,
	[strEmailAddress] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strNetwork] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCardNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCardDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strProduct] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strProductDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strSiteName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSiteNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionDate] DATETIME NOT NULL,
	[dtmPeriodFrom] DATETIME NOT NULL,
	[dtmPeriodTo] DATETIME NOT NULL,
	[dblQuantity] NUMERIC(18,6) NULL,
	[dblTotalAmount] NUMERIC(18,6) NULL,
	[strDriverPin] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	ysnSendEmail BIT DEFAULT 0 NOT NULL,
	[strEmailDistributionOption] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFullAddress] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[blbMessageBody] VARBINARY(MAX) NULL, 
	intTransactionCount [int] DEFAULT 0 NOT NULL,
	intUserId [int] NOT NULL,
	intEntityId [int] NOT NULL,
	[intConcurrencyId] INT CONSTRAINT [DF_tblCFUsageExceptionAlertStaging_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFUsageExceptionAlertStaging] PRIMARY KEY CLUSTERED ([intUsageExceptionAlertStagingId] ASC),
 );
GO