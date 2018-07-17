CREATE TABLE [dbo].[tblCFAccountQuote] (
    [intAccountQuoteId]   INT             IDENTITY (1, 1) NOT NULL,
    [intSiteId]           INT             NULL,
    [strSite]             NVARCHAR (50)   NULL,
    [strAddress]          NVARCHAR (500)  NULL,
    [strCity]             NVARCHAR (50)   NULL,
    [strState]            NVARCHAR (50)   NULL,
    [intItem1]            INT             NULL,
    [strItem1]            NVARCHAR (50)   NULL,
    [dblItem1Price]       NUMERIC (18, 6) NULL,
    [intItem2]            INT             NULL,
    [strItem2]            NVARCHAR (50)   NULL,
    [dblItem2Price]       NUMERIC (18, 6) NULL,
    [intItem3]            INT             NULL,
    [strItem3]            NVARCHAR (50)   NULL,
    [dblItem3Price]       NUMERIC (18, 6) NULL,
    [intItem4]            INT             NULL,
    [strItem4]            NVARCHAR (50)   NULL,
    [dblItem4Price]       NUMERIC (18, 6) NULL,
    [intItem5]            INT             NULL,
    [strItem5]            NVARCHAR (50)   NULL,
    [dblItem5Price]       NUMERIC (18, 6) NULL,
    [intEntityCustomerId] INT             NULL,
	[dtmEffectiveDate]	  DATETIME		  NULL,
	[intEntityUserId]	  INT			  NULL,
    [intConcurrencyId]    INT             CONSTRAINT [DF_tblCFAccountQuote_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFAccountQuote] PRIMARY KEY CLUSTERED ([intAccountQuoteId] ASC)
);



