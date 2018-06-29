CREATE TABLE [dbo].[tblCFNetworkSiteTaxGroup] (
    [intNetworkSiteTaxGroupId] INT            IDENTITY (1, 1) NOT NULL,
    [intNetworkId]        INT            NULL,
    [strState]     NVARCHAR(2)            COLLATE Latin1_General_CI_AS NULL,
    [intTaxGroupId]   INT ,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFNetworkSiteTaxGroup_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFNetworkSiteTaxGroup] PRIMARY KEY CLUSTERED ([intNetworkSiteTaxGroupId] ASC),
	CONSTRAINT [uq_State] UNIQUE NONCLUSTERED ([intNetworkId] ASC,[strState] ASC),
    CONSTRAINT [FK_tblCFNetworkSiteTaxGroup_tblCFNetwork] FOREIGN KEY ([intNetworkId]) REFERENCES [dbo].[tblCFNetwork] ([intNetworkId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCFNetworkSiteTaxGroup_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId])
);





