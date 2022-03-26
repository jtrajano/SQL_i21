﻿CREATE TABLE [dbo].[tblRKFutOptTransactionImport]
(
	[intFutOptTransactionId] INT IDENTITY(1,1) NOT NULL,
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
	[dblNoOfContract] decimal(24,10),
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
	[strCreateDateTime] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strSelectedInstrumentType] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strCurrencyExchangeRateTypeId] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strBank] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strBuyBankAccount] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strBankAccount] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strOrderType] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[dblLimitRate] decimal(24,10),
	[strMarketDate] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnGTC] BIT,
	[strTransactionDate] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strMaturityDate] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblExchangeRate] decimal(24,10),
	[dblContractAmount] decimal(24,10),
	[dblMatchAmount] decimal(24,10),
	[dblFinanceForwardRate] decimal(24,10),
	[strContractNumber] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strContractSequence] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strAssignOrHedge] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnCommissionExempt] BIT,
	[ysnCommissionOverride] BIT,
	[dblCommission] DECIMAL(24, 10)
)