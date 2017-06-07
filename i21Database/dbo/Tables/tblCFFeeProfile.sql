CREATE TABLE [dbo].[tblCFFeeProfile] (
    [intFeeProfileId]  INT            IDENTITY (1, 1) NOT NULL,
    [strFeeProfileId]  NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceFormat] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFFeeProfile_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFFeeProfle] PRIMARY KEY CLUSTERED ([intFeeProfileId] ASC)
);

GO
CREATE UNIQUE NONCLUSTERED INDEX tblCFFeeProfile_UniqueFeeProfile
	ON tblCFFeeProfile (strFeeProfileId);
