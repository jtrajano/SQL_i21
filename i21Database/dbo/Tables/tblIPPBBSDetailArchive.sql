CREATE TABLE tblIPPBBSDetailArchive
(
	intPBBSDetailStageId		INT IDENTITY(1,1),
	intPBBSStageId				INT NOT NULL,
	strBlendCode				NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	intPBBSID					INT,
	strSpecificationCode		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblMinValue					NUMERIC(18, 6),
	dblMaxValue					NUMERIC(18, 6),
	dblPinPoint					NUMERIC(18, 6),

	CONSTRAINT [PK_tblIPPBBSDetailArchive_intPBBSDetailStageId] PRIMARY KEY (intPBBSDetailStageId),
	CONSTRAINT [FK_tblIPPBBSDetailArchive_tblIPPBBSArchive_intPBBSStageId] FOREIGN KEY (intPBBSStageId) REFERENCES [tblIPPBBSArchive](intPBBSStageId) ON DELETE CASCADE
)
