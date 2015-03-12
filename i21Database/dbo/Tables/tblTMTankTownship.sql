CREATE TABLE [dbo].[tblTMTankTownship] (
    [intTankTownshipId] INT           IDENTITY (1, 1) NOT NULL,
    [strTankTownship]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]  INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMTownShip] PRIMARY KEY CLUSTERED ([intTankTownshipId] ASC),
	CONSTRAINT [UQ_tblTMTownShip_strTankTownship] UNIQUE NONCLUSTERED ([strTankTownship] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankTownship',
    @level2type = N'COLUMN',
    @level2name = N'intTankTownshipId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tank Township',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankTownship',
    @level2type = N'COLUMN',
    @level2name = N'strTankTownship'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMTankTownship',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'