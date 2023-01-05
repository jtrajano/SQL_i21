CREATE TABLE tblIPPBBSDetailStage
(
	intPBBSDetailStageId		INT IDENTITY(1,1),
	intPBBSStageId				INT NOT NULL,
	strBlendCode				NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	intPBBSID					INT,
	strSpecificationCode		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblMinValue					NUMERIC(18, 6),
	dblMaxValue					NUMERIC(18, 6),
	dblPinPoint					NUMERIC(18, 6),

	CONSTRAINT [PK_tblIPPBBSDetailStage_intPBBSDetailStageId] PRIMARY KEY (intPBBSDetailStageId),
	CONSTRAINT [FK_tblIPPBBSDetailStage_tblIPPBBSStage_intPBBSStageId] FOREIGN KEY (intPBBSStageId) REFERENCES [tblIPPBBSStage](intPBBSStageId) ON DELETE CASCADE
)
