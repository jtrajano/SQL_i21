CREATE TABLE [dbo].[tblTMDeployedStatus] (
    [intConcurrencyID]    INT           CONSTRAINT [DEF_tblTMDeployedStatus_intConcurrencyID] DEFAULT ((0)) NULL,
    [intDeployedStatusID] INT           IDENTITY (1, 1) NOT NULL,
    [strDeployedStatus]   NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMDeployedStatus_strDeployedStatus] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMDeployedStatus] PRIMARY KEY CLUSTERED ([intDeployedStatusID] ASC)
);

