CREATE TABLE [dbo].[tblEMContactDetail]
(
	[intContactDetailId]			INT NOT NULL IDENTITY(1,1),
	[intEntityId]					INT NOT NULL,
	[intContactDetailTypeId]		INT NOT NULL,	
	[strValue]						NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL, 		
	[intConcurrencyId]				INT CONSTRAINT [DF_tblEMContactDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblEMContactDetail] PRIMARY KEY CLUSTERED ([intContactDetailId] ASC),	
	CONSTRAINT [FK_tblEMContactDetail_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblEMContactDetail_tblEMContactDetailType] FOREIGN KEY ([intContactDetailTypeId]) REFERENCES [dbo].[tblEMContactDetailType] ([intContactDetailTypeId]) ,

)
