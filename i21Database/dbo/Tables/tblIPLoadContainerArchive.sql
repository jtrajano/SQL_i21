CREATE TABLE tblIPLoadContainerArchive
(
	intStageLoadContainerId		INT IDENTITY(1,1),
	intStageLoadId				INT NOT NULL,
	strCustomerReference		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContainerNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContainerType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblGrossWt					NUMERIC(18, 6),
	dblTareWt					NUMERIC(18, 6),
	dblQuantity					NUMERIC(18, 6),

	CONSTRAINT [PK_tblIPLoadContainerArchive_intStageLoadContainerId] PRIMARY KEY (intStageLoadContainerId),
	CONSTRAINT [FK_tblIPLoadContainerArchive_tblIPLoadArchive_intStageLoadId] FOREIGN KEY ([intStageLoadId]) REFERENCES [tblIPLoadArchive]([intStageLoadId]) ON DELETE CASCADE
)
