CREATE TABLE [dbo].[tblARMarketZone] (
    [intMarketZoneId]   INT            IDENTITY (1, 1) NOT NULL,
    [strMarketZoneCode] NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]    NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]  INT            NOT NULL,
    CONSTRAINT [PK_tblARMarketZone] PRIMARY KEY CLUSTERED ([intMarketZoneId] ASC)
);

