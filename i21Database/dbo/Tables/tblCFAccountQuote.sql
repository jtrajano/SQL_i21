CREATE TABLE [dbo].[tblCFAccountQuote] (
    [intAccountQuoteId] INT            IDENTITY (1, 1) NOT NULL,
    [intSiteId]         INT            NULL,
    [strSite]           NVARCHAR (50)  NULL,
    [strAddress]        NVARCHAR (500) NULL,
    [strCity]           NVARCHAR (50)  NULL,
    [strState]          NVARCHAR (50)  NULL,
    [intItem1]          INT            NULL,
    [strItem1]          NVARCHAR (50)  NULL,
    [intItem2]          INT            NULL,
    [strItem2]          NVARCHAR (50)  NULL,
    [intItem3]          INT            NULL,
    [strItem3]          NVARCHAR (50)  NULL,
    [intItem4]          INT            NULL,
    [strItem4]          NVARCHAR (50)  NULL,
    [intItem5]          INT            NULL,
    [strItem5]          NVARCHAR (50)  NULL,
    [intConcurrencyId]  INT            CONSTRAINT [DF_tblCFAccountQuote_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFAccountQuote] PRIMARY KEY CLUSTERED ([intAccountQuoteId] ASC)
);

