CREATE TABLE [dbo].[tblIPItemSubLocationArchive]
(
	intStageItemSubLocationId INT identity(1, 1),
	intStageItemId INT NOT NULL,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strSubLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	ysnDeleted BIT DEFAULT 0,
	CONSTRAINT [PK_tblIPItemSubLocationArchive_intStageItemSubLocationId] PRIMARY KEY ([intStageItemSubLocationId]) 
)
