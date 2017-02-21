CREATE TABLE [dbo].[tblIPEntityContactStage]
(
	[intStageEntityContactId] INT IDENTITY(1,1),
	[intStageEntityId] INT,
	[strEntityName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strFirstName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strLastName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strPhone] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	CONSTRAINT [PK_tblIPEntityContactStage_intStageEntityContactId] PRIMARY KEY ([intStageEntityContactId]),
	CONSTRAINT [FK_tblIPEntityContactStage_tblIPEntityStage_intStageEntityId] FOREIGN KEY ([intStageEntityId]) REFERENCES [tblIPEntityStage]([intStageEntityId]) ON DELETE CASCADE,
)
