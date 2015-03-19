CREATE TABLE [dbo].[tblARMarketZone] (
    [intMarketZoneId]   INT            IDENTITY (1, 1) NOT NULL,
    [strMarketZoneCode] NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]    NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]  INT            NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblARMarketZone_intMarketZoneId] PRIMARY KEY CLUSTERED ([intMarketZoneId] ASC),
	CONSTRAINT [UQ_tblARMarketZone_strMarketZoneCode] UNIQUE NONCLUSTERED ([strMarketZoneCode] ASC)
);

