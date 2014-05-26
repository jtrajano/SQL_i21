CREATE TABLE [dbo].[tblARCustomerCategoryPrice] (
    [intCategoryPriceId] INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]        INT             NOT NULL,
    [strCategory]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dtmBeginDate]       DATETIME        NOT NULL,
    [dtmEndDate]         DATETIME        NULL,
    [dblDiscount]        NUMERIC (18, 6) NOT NULL DEFAULT ((0)),
    [strNotes]           NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]   INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerCategoryPrice] PRIMARY KEY CLUSTERED ([intCategoryPriceId] ASC)
);

