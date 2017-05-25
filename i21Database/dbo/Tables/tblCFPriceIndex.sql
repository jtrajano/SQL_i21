CREATE TABLE [dbo].[tblCFPriceIndex] (
    [intPriceIndexId]  INT            IDENTITY (1, 1) NOT NULL,
    [strPriceIndex]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFPriceIndex_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFPriceIndex] PRIMARY KEY CLUSTERED ([intPriceIndexId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCFPriceIndex_intPriceIndexId]
    ON [dbo].[tblCFPriceIndex]([intPriceIndexId] ASC);

GO
CREATE UNIQUE NONCLUSTERED INDEX tblCFPriceIndex_UniquePriceIndex
	ON tblCFPriceIndex (strPriceIndex);

