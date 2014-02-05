CREATE TABLE [dbo].[tblTMDeviceType] (
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    [intDeviceTypeID]  INT           IDENTITY (1, 1) NOT NULL,
    [strDeviceType]    NVARCHAR (70) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]       BIT           DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMDeviceType] PRIMARY KEY CLUSTERED ([intDeviceTypeID] ASC),
    CONSTRAINT [UQ_tblTMDeviceType_strDeviceType] UNIQUE NONCLUSTERED ([strDeviceType] ASC)
);

