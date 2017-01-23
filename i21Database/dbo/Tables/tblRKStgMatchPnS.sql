﻿CREATE TABLE [dbo].[tblRKStgMatchPnS]
(
       [intStgMatchPnSId] INT IDENTITY(1,1) NOT NULL,
       [intConcurrencyId] INT NOT NULL, 
       [intMatchFuturesPSHeaderId] INT NOT NULL, 
       [intMatchNo] INT NOT NULL, 
       [dtmMatchDate] DATETIME NOT NULL, 
       [strCurrency] nvarchar(50)  COLLATE Latin1_General_CI_AS NOT NULL,
       [intCompanyLocationId] INT NULL, 
       [intCommodityId] INT NULL, 
       [intFutureMarketId] INT NULL, 
       [intFutureMonthId] int NULL, 
       [intEntityId] INT NULL, 
       [intBrokerageAccountId] INT NULL, 
       [dblMatchQty] NUMERIC(18, 6) NULL,
       [dblCommission] NUMERIC(18, 6) NULL,
       [dblNetPnL] NUMERIC(18, 6) NULL,
       [dblGrossPnL] NUMERIC(18, 6) NULL,        
	   [strBrokerName] nvarchar(50) COLLATE Latin1_General_CI_AS  NULL,
	   [strBrokerAccount] nvarchar(50) COLLATE Latin1_General_CI_AS  NULL,
	   [dtmPostingDate] datetime null,
       [strStatus] nvarchar(50) COLLATE Latin1_General_CI_AS  NULL,
	   [strMessage] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
	[strUserName] nvarchar(100) COLLATE Latin1_General_CI_AS  NULL
    CONSTRAINT [PK_tblRKStgMatchPnS_intStgMatchPnSId] PRIMARY KEY (intStgMatchPnSId),  	  
)