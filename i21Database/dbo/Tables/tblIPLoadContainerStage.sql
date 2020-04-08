CREATE TABLE tblIPLoadContainerStage
(
	intStageLoadContainerId		INT IDENTITY(1,1),
	intStageLoadId				INT NOT NULL,
	strCustomerReference		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContainerNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContainerType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblGrossWt					NUMERIC(18, 6),
	dblTareWt					NUMERIC(18, 6),
	dblQuantity					NUMERIC(18, 6),

	CONSTRAINT [PK_tblIPLoadContainerStage_intStageLoadContainerId] PRIMARY KEY (intStageLoadContainerId),
	CONSTRAINT [FK_tblIPLoadContainerStage_tblIPLoadStage_intStageLoadId] FOREIGN KEY ([intStageLoadId]) REFERENCES [tblIPLoadStage]([intStageLoadId]) ON DELETE CASCADE
)
