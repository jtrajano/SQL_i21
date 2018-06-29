CREATE TABLE [dbo].[tblCFAdvanceMapping] (
    [intAdvanceMappingId] INT            IDENTITY (1, 1) NOT NULL,
    [strAdvanceMappingId] NVARCHAR (MAX) NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFAdvanceMapping_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFAdvanceMapping] PRIMARY KEY CLUSTERED ([intAdvanceMappingId] ASC)
);

