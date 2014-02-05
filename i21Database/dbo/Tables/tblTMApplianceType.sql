CREATE TABLE [dbo].[tblTMApplianceType] (
    [intConcurrencyId]   INT           DEFAULT 1 NOT NULL,
    [intApplianceTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strApplianceType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]         BIT           DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMApplianceType] PRIMARY KEY CLUSTERED ([intApplianceTypeID] ASC),
    CONSTRAINT [UQ_tblTMApplianceType_strApplianceType] UNIQUE NONCLUSTERED ([strApplianceType] ASC)
);

