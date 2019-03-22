CREATE TABLE [dbo].[tblCFNetworkCost] (
    [intNetworkCostId] INT             IDENTITY (1, 1) NOT NULL,
    [intSiteId]        INT             NULL,
    [intNetworkId]     INT             NOT NULL,
    [dtmDate]          DATETIME        NULL,
    [intItemId]        INT             NULL,
    [dblTransferCost]  NUMERIC (18, 6) NULL,
    [dblTaxesPerUnit]  NUMERIC (18, 6) NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF_tblCFNetworkCost_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFNetworkCost] PRIMARY KEY CLUSTERED ([intNetworkCostId] ASC) WITH (FILLFACTOR = 70)
);
GO

CREATE NONCLUSTERED INDEX [tblCFNetworkCost_intSiteId_intNetworkId_intItemId]
    ON [dbo].[tblCFNetworkCost]([intSiteId] ASC, [intNetworkId] ASC, [intItemId] ASC)
    INCLUDE([dtmDate], [dblTransferCost]);
GO

