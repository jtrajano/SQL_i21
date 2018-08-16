CREATE TABLE [dbo].[tblRKStgOptionMatchPnS]
(
       [intStgOptionMatchPnSId] INT IDENTITY(1,1) NOT NULL,
       [intConcurrencyId] INT NOT NULL,        
       [intMatchNo] INT NOT NULL, 
       [dtmMatchDate] DATETIME NOT NULL, 
       [strCurrency] nvarchar(100)  COLLATE Latin1_General_CI_AS NOT NULL,
       [strLocationName] nvarchar(100)  COLLATE Latin1_General_CI_AS NOT NULL,
       [strFutMarketName] nvarchar(100)  COLLATE Latin1_General_CI_AS NOT NULL, 
       [strOptionMonth] nvarchar(100)  COLLATE Latin1_General_CI_AS NOT NULL,   
       [strBook] nvarchar(100)  COLLATE Latin1_General_CI_AS  NULL, 
       [strSubBook] nvarchar(100)  COLLATE Latin1_General_CI_AS  NULL, 
       [strBrokerName] nvarchar(100)  COLLATE Latin1_General_CI_AS NOT NULL,
       [strAccountNumber] nvarchar(100)  COLLATE Latin1_General_CI_AS NOT NULL,
       [dblGrossPnL] NUMERIC(18, 6) NULL,
       [dtmPostingDate] DATETIME,        
	   [strUserName] nvarchar(50) COLLATE Latin1_General_CI_AS  NULL
    CONSTRAINT [PK_tblRKStgOptionMatchPnS_intStgOptionMatchPnSId] PRIMARY KEY (intStgOptionMatchPnSId)  
)