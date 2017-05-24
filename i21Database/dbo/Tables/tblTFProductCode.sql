CREATE TABLE [dbo].[tblTFProductCode] (
    [intProductCodeId]    INT            IDENTITY (1, 1) NOT NULL,
    [intTaxAuthorityId]   INT            NOT NULL,
    [strProductCode]      VARCHAR (10)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strProductCodeGroup] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strNote]             NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
	[intMasterId] INT NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblTFProductCode_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFProductCode] PRIMARY KEY CLUSTERED ([intProductCodeId] ASC),
    CONSTRAINT [FK_tblTFProductCode_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [dbo].[tblTFTaxAuthority] ([intTaxAuthorityId]) ON DELETE CASCADE
);

