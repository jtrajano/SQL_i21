CREATE TABLE [dbo].[tblIPItemUOMStage]
(
	intStageItemUOMId INT identity(1, 1),
	intStageItemId INT NOT NULL,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	dblNumerator NUMERIC(38,20),
	dblDenominator NUMERIC(38,20),
	CONSTRAINT [PK_tblIPItemUOMStage_intStageItemUOMId] PRIMARY KEY ([intStageItemUOMId]),
	CONSTRAINT [FK_tblIPItemUOMStage_tblIPItemStage_intStageItemId] FOREIGN KEY ([intStageItemId]) REFERENCES [tblIPItemStage]([intStageItemId]) ON DELETE CASCADE,  
)
