CREATE TABLE [dbo].[tblEMEntityGroupDetail]
(
	[intEntityGroupDetailId]        INT				IDENTITY (1, 1) NOT NULL,
	[intEntityGroupId]				INT             NOT NULL,
    [intEntityId]					INT             NULL,        
	[intConcurrencyId]				INT             CONSTRAINT [DF__tmp_tblEMEntityGroupDetail__intEntityGroupDetailId__5132705A] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntityGroupDetail] PRIMARY KEY CLUSTERED ([intEntityGroupDetailId] ASC),	
	CONSTRAINT [FK_tblEMEntityGroupDetail_tblEMEntity] FOREIGN KEY([intEntityId]) REFERENCES [dbo].tblEMEntity([intEntityId]), 
	CONSTRAINT [FK_tblEMEntityGroupDetail_tblEMEntitySplit] FOREIGN KEY([intEntityGroupId]) REFERENCES [dbo].[tblEMEntityGroup]([intEntityGroupId]) ON DELETE CASCADE
)
