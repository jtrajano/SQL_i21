CREATE TABLE [dbo].[tblCFAdvanceMappingDetail] (
    [intAdvanceMappingDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intAdvanceMappingId]       INT            NOT NULL,
    [strRecordType]             NVARCHAR (100) NULL,
    [intRecordTypePosition]     INT            NULL,
    [intRecordTypeLength]       INT            NULL,
    [strFileType]               NVARCHAR (50)  NULL,
    [intLinkFieldPosition]      INT            NULL,
    [intLinkFieldLength]        INT            NULL,
    [strSequenceId]             NVARCHAR (50)  NULL,
    [intImportMapping]          INT            NULL,
	[strRuleId]					NVARCHAR (100) NULL,
    [intConcurrencyId]          INT            CONSTRAINT [DF_tblCFAdvanceMappingId_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFAdvanceMappingId] PRIMARY KEY CLUSTERED ([intAdvanceMappingDetailId] ASC),
    CONSTRAINT [FK_tblCFAdvanceMappingDetail_tblCFAdvanceMapping] FOREIGN KEY ([intAdvanceMappingId]) REFERENCES [dbo].[tblCFAdvanceMapping] ([intAdvanceMappingId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCFAdvanceMappingDetail_tblSMImportFileHeader] FOREIGN KEY ([intImportMapping]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId])
);

