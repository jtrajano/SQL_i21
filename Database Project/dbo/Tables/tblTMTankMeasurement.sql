CREATE TABLE [dbo].[tblTMTankMeasurement] (
    [intConcurrencyId]     INT             DEFAULT 1 NOT NULL,
    [intTankMeasurementID] INT             IDENTITY (1, 1) NOT NULL,
    [intSiteDeviceID]      INT             DEFAULT 0 NOT NULL,
    [dblTankSize]          NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblTankCapacity]      NUMERIC (18, 6) DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMTankMeasurement] PRIMARY KEY CLUSTERED ([intTankMeasurementID] ASC)
);

