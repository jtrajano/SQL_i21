CREATE TABLE [dbo].[tblTMMeterType] (
    [intConcurrencyId]    INT             DEFAULT 1 NOT NULL,
    [intMeterTypeID]      INT             IDENTITY (1, 1) NOT NULL,
    [strMeterType]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [dblConversionFactor] NUMERIC (18, 8) DEFAULT 0 NULL,
    [ysnDefault]          BIT             DEFAULT 0 NULL,
    CONSTRAINT [PK_tblTMMeterType] PRIMARY KEY CLUSTERED ([intMeterTypeID] ASC)
);

