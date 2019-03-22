CREATE TABLE [dbo].[tblIPItemSubLocationStage]
(
	intStageItemSubLocationId INT identity(1, 1),
	intStageItemId INT NOT NULL,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strSubLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	ysnDeleted BIT DEFAULT 0,
	CONSTRAINT [PK_tblIPItemSubLocationStage_intStageItemSubLocationId] PRIMARY KEY ([intStageItemSubLocationId]),
	CONSTRAINT [FK_tblIPItemSubLocationStage_tblIPItemStage_intStageItemId] FOREIGN KEY ([intStageItemId]) REFERENCES [tblIPItemStage]([intStageItemId]) ON DELETE CASCADE, 
)
