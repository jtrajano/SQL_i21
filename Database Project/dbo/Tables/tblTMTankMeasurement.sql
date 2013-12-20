CREATE TABLE [dbo].[tblTMTankMeasurement] (
    [intConcurrencyID]     INT             CONSTRAINT [DEF_tblTMTankMeasurement_intConcurrencyID] DEFAULT ((0)) NULL,
    [intTankMeasurementID] INT             IDENTITY (1, 1) NOT NULL,
    [intSiteDeviceID]      INT             CONSTRAINT [DEF_tblTMTankMeasurement_intSiteDeviceID] DEFAULT ((0)) NOT NULL,
    [dblTankSize]          NUMERIC (18, 6) CONSTRAINT [DEF_tblTMTankMeasurement_dblTankSize] DEFAULT ((0)) NULL,
    [dblTankCapacity]      NUMERIC (18, 6) CONSTRAINT [DEF_tblTMTankMeasurement_dblTankCapacity] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMTankMeasurement] PRIMARY KEY CLUSTERED ([intTankMeasurementID] ASC)
);

