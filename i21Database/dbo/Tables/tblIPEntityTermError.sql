CREATE TABLE [dbo].[tblIPEntityTermError]
(
	[intStageEntityTermId] INT IDENTITY(1,1),
	[intStageEntityId] INT,
	strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strTerm NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intTrxSequenceNo BIGINT,
	intParentTrxSequenceNo BIGINT,
	intActionId INT,
	intLineType INT,
	strAddress NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strCity NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strState NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strZip NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCountry NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strPhone NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFax NVARCHAR(100) COLLATE Latin1_General_CI_AS,

	CONSTRAINT [PK_tblIPEntityTermError_intStageEntityTermId] PRIMARY KEY ([intStageEntityTermId])
)
