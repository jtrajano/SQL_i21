CREATE TABLE tblIPLoadNotifyPartiesStage
(
	intStageLoadNotifyPartiesId	INT IDENTITY(1,1),
	intStageLoadId				INT NOT NULL,
	strCustomerReference		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strPartyType				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strPartyName				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strPartyLocation			NVARCHAR(100) COLLATE Latin1_General_CI_AS,

	CONSTRAINT [PK_tblIPLoadNotifyPartiesStage_intStageLoadNotifyPartiesId] PRIMARY KEY (intStageLoadNotifyPartiesId),
	CONSTRAINT [FK_tblIPLoadNotifyPartiesStage_tblIPLoadStage_intStageLoadId] FOREIGN KEY ([intStageLoadId]) REFERENCES [tblIPLoadStage]([intStageLoadId]) ON DELETE CASCADE
)
