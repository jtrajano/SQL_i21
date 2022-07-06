CREATE TABLE [dbo].[tblCTTermCost]
(
	[intTermCostId] INT IDENTITY NOT NULL ,
	[intLoadingPortId] INT NOT NULL,
	[intDestinationPortId] INT NOT NULL,
	[intLoadingTermId] INT NOT NULL,
	[intDestinationTermId] INT NOT NULL,
	[intMarketZoneId] INT NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT((0)), 
    CONSTRAINT [PK_tblCTTermCost] PRIMARY KEY ([intTermCostId]),
	CONSTRAINT [UQ_tblCTTermCost] UNIQUE ([intLoadingPortId], [intDestinationPortId], [intLoadingTermId], [intDestinationTermId], [intMarketZoneId]), 
    CONSTRAINT [FK_tblCTTermCost_tblARMarketZone] FOREIGN KEY ([intMarketZoneId]) REFERENCES [tblARMarketZone]([intMarketZoneId]), 
    CONSTRAINT [FK_tblCTTermCost_LoadingPort] FOREIGN KEY ([intLoadingPortId]) REFERENCES [tblSMCity]([intCityId]), 
    CONSTRAINT [FK_tblCTTermCost_DestinationPort] FOREIGN KEY ([intDestinationPortId]) REFERENCES [tblSMCity]([intCityId]), 
	CONSTRAINT [FK_tblCTTermCost_LoadingTerm] FOREIGN KEY ([intLoadingTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]), 
    CONSTRAINT [FK_tblCTTermCost_DestinationTerm] FOREIGN KEY ([intDestinationTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]), 
)
