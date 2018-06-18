CREATE TABLE [dbo].[tblCFCSRSingleQuote] (
    [intCSRSingleQuoteId] INT             IDENTITY (1, 1) NOT NULL,
    [intNetworkId]        INT             NULL,
    [intSiteId]           INT             NULL,
    [strAddress]          NVARCHAR (500)  NULL,
    [strCity]             NVARCHAR (50)   NULL,
    [strState]            NVARCHAR (50)   NULL,
    [intItem]             INT             NULL,
    [dblUnitCost]         NUMERIC (18, 6) NULL,
    [dblProfileRate]      NUMERIC (18, 6) NULL,
    [dblAdjRate]          NUMERIC (18, 6) NULL,
    [dblNetPrice]         NUMERIC (18, 6) NULL,
    [dblTaxes]            NUMERIC (18, 6) NULL,
    [dblGrossPrice]       NUMERIC (18, 6) NULL,
    [strNetwork]          NVARCHAR (50)   NULL,
    [strSite]             NVARCHAR (50)   NULL,
    [strItem]             NVARCHAR (50)   NULL,
	[intEntityUserId]	  INT			  NULL,
    [intConcurrencyId]    INT             CONSTRAINT [DF_tblCFCSRSingleQuote_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFCSRSingleQuote] PRIMARY KEY CLUSTERED ([intCSRSingleQuoteId] ASC)
);

