﻿CREATE TABLE [dbo].[tblRKFutOptTransactionImport_ErrLog]
(
	[intFutOptTransactionErrLogId] INT IDENTITY(1,1) NOT NULL,
	[intFutOptTransactionId] INT ,
	[strName] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strAccountNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strFutMarketName] nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
	[strInstrumentType] nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strSalespersonId] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strCurrency] nvarchar(40) COLLATE Latin1_General_CI_AS NULL,
	[strBrokerTradeNo] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strBuySell] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblNoOfContract] numeric(24,10),
	[strFutureMonth] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strOptionMonth] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strOptionType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblStrike] decimal(24,10),
	[dblPrice] decimal(24,10) ,
	[strReference] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strStatus] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strFilledDate] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strBook] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strSubBook] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] int,
	[strErrorMsg] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strCreateDateTime] nvarchar(50) COLLATE Latin1_General_CI_AS NULL
)