CREATE TABLE tblIPSampleTestResultStage
(
	intStageSampleTestResultId	INT IDENTITY(1,1),
	intStageSampleId			INT NOT NULL,
	strSampleNumber				NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	strTestName					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strPropertyName				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strActualValue				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strTestComment				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,

	CONSTRAINT [PK_tblIPSampleTestResultStage_intStageSampleTestResultId] PRIMARY KEY ([intStageSampleTestResultId]),
	CONSTRAINT [FK_tblIPSampleTestResultStage_tblIPSampleStage_intStageSampleId] FOREIGN KEY ([intStageSampleId]) REFERENCES [tblIPSampleStage]([intStageSampleId]) ON DELETE CASCADE
)
