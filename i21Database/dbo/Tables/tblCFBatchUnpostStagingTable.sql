CREATE TABLE [dbo].[tblCFAccountQuote] (
    [intAccountQuoteId]   INT             IDENTITY (1, 1) NOT NULL,
    [intSiteId]           INT             NULL,
    [strSite]             NVARCHAR (500)   NULL,
    [strAddress]          NVARCHAR (500)  NULL,
    [strCity]             NVARCHAR (50)   NULL,
    [strState]            NVARCHAR (50)   NULL,
    [intItem]			  INT             NULL,
    [strItem]			  NVARCHAR (50)   NULL,
    [dblItemPrice]		  NUMERIC (18, 6) NULL,
    [intEntityCustomerId] INT             NULL,
	[dtmEffectiveDate]	  DATETIME		  NULL,
	[intEntityUserId]	  INT			  NULL,
    [intConcurrencyId]    INT             CONSTRAINT [DF_tblCFAccountQuote_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFAccountQuote] PRIMARY KEY CLUSTERED ([intAccountQuoteId] ASC)
);
