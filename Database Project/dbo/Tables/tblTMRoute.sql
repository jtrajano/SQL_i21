CREATE TABLE [dbo].[tblTMRoute] (
    [intRouteID]       INT           IDENTITY (1, 1) NOT NULL,
    [strRouteID]       NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMRoute] PRIMARY KEY CLUSTERED ([intRouteID] ASC)
);

