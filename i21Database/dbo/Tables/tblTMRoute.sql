CREATE TABLE [dbo].[tblTMRoute] (
    [intRouteId]       INT           IDENTITY (1, 1) NOT NULL,
    [strRouteId]       NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMRoute] PRIMARY KEY CLUSTERED ([intRouteId] ASC)
);

