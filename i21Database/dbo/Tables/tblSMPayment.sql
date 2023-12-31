﻿CREATE TABLE [dbo].[tblSMPayment] (
    [intPaymentId] [int] IDENTITY(1,1) NOT NULL,
	[strScreen] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[intTransactionPaymentId] [int] NOT NULL,
	[dtmDatePaid] [datetime] NOT NULL,
	[strPaymentMethod] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCardHolderName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strPaymentInfo] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCardType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strPaymentNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblAmountPaid] [numeric](18, 6) NOT NULL,
	[strAcqRefData] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strReference] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strBatchNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS  NULL,
	[strMemo] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strToken] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strProcessData] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionPostTime] [datetime] NULL,
	[dtmDateModified] [datetime] NOT NULL,
	[intEntityId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT (1),
    CONSTRAINT [PK_tblSMPayment] PRIMARY KEY CLUSTERED ([intPaymentId] ASC)
);
