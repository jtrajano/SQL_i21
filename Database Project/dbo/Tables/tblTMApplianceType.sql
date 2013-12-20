CREATE TABLE [dbo].[tblTMApplianceType] (
    [intConcurrencyID]   INT           CONSTRAINT [DEF_tblTMApplianceType_intConcurrencyID] DEFAULT ((0)) NULL,
    [intApplianceTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strApplianceType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMApplianceType_strApplianceType] DEFAULT ('') NOT NULL,
    [ysnDefault]         BIT           CONSTRAINT [DEF_tblTMApplianceType_ysnDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMApplianceType] PRIMARY KEY CLUSTERED ([intApplianceTypeID] ASC),
    CONSTRAINT [UQ_tblTMApplianceType_strApplianceType] UNIQUE NONCLUSTERED ([strApplianceType] ASC)
);

