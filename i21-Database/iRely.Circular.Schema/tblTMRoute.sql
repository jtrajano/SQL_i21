CREATE TABLE [dbo].[tblTMRoute] (
    [intRouteId]       INT           IDENTITY (1, 1) NOT NULL,
    [strRouteId]       NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMRoute] PRIMARY KEY CLUSTERED ([intRouteId] ASC),
	CONSTRAINT [UQ_tblTMRoute_strRouteId] UNIQUE NONCLUSTERED ([strRouteId] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMRoute',
    @level2type = N'COLUMN',
    @level2name = N'intRouteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'strRouteId',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMRoute',
    @level2type = N'COLUMN',
    @level2name = N'strRouteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMRoute',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'