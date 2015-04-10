CREATE TABLE [dbo].[tblCFPriceIndex] (
    [intPriceIndexId]  INT            IDENTITY (1, 1) NOT NULL,
    [strPriceIndex]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFPriceIndex_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFPriceIndex] PRIMARY KEY CLUSTERED ([intPriceIndexId] ASC)
);

