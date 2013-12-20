CREATE TABLE [dbo].[tblTMTankTownship] (
    [intTankTownshipID] INT           IDENTITY (1, 1) NOT NULL,
    [strTankTownship]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyID]  INT           CONSTRAINT [DF_tblTMTownShip_intConcurrencyID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMTownShip] PRIMARY KEY CLUSTERED ([intTankTownshipID] ASC)
);

