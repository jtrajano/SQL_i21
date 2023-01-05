CREATE TABLE tblIPPBBSDetailError
(
	intPBBSDetailStageId		INT IDENTITY(1,1),
	intPBBSStageId				INT NOT NULL,
	strBlendCode				NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	intPBBSID					INT,
	strSpecificationCode		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblMinValue					NUMERIC(18, 6),
	dblMaxValue					NUMERIC(18, 6),
	dblPinPoint					NUMERIC(18, 6),

	CONSTRAINT [PK_tblIPPBBSDetailError_intPBBSDetailStageId] PRIMARY KEY (intPBBSDetailStageId),
	CONSTRAINT [FK_tblIPPBBSDetailError_tblIPPBBSError_intPBBSStageId] FOREIGN KEY (intPBBSStageId) REFERENCES [tblIPPBBSError](intPBBSStageId) ON DELETE CASCADE
)
