CREATE TABLE [dbo].[tblTMRoute] (
    [intRouteID]       INT           IDENTITY (1, 1) NOT NULL,
    [strRouteID]       NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyID] INT           CONSTRAINT [DF_tblTMRoute_intConcurrencyID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMRoute] PRIMARY KEY CLUSTERED ([intRouteID] ASC)
);

