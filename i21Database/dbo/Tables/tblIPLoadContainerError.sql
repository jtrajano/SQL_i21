CREATE TABLE tblIPLoadContainerError
(
	intStageLoadContainerId		INT IDENTITY(1,1),
	intStageLoadId				INT NOT NULL,
	strCustomerReference		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContainerNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContainerType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblGrossWt					NUMERIC(18, 6),
	dblTareWt					NUMERIC(18, 6),
	dblQuantity					NUMERIC(18, 6),

	CONSTRAINT [PK_tblIPLoadContainerError_intStageLoadContainerId] PRIMARY KEY (intStageLoadContainerId),
	CONSTRAINT [FK_tblIPLoadContainerError_tblIPLoadError_intStageLoadId] FOREIGN KEY ([intStageLoadId]) REFERENCES [tblIPLoadError]([intStageLoadId]) ON DELETE CASCADE
)
