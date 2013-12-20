CREATE TABLE [dbo].[tblTMDeviceType] (
    [intConcurrencyID] INT           CONSTRAINT [DEF_tblTMDeviceType_intConcurrencyID] DEFAULT ((0)) NULL,
    [intDeviceTypeID]  INT           IDENTITY (1, 1) NOT NULL,
    [strDeviceType]    NVARCHAR (70) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMDeviceType_strDeviceType] DEFAULT ('') NOT NULL,
    [ysnDefault]       BIT           CONSTRAINT [DEF_tblTMDeviceType_ysnDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMDeviceType] PRIMARY KEY CLUSTERED ([intDeviceTypeID] ASC),
    CONSTRAINT [UQ_tblTMDeviceType_strDeviceType] UNIQUE NONCLUSTERED ([strDeviceType] ASC)
);

