CREATE TABLE [dbo].[tblCTEventMatrixDetail]
(
		intEventMatrixDetailId [int] IDENTITY(1,1) NOT NULL,
	intEventMatrixId [int] NOT NULL,
	intPositionId [int] NULL,
	intWeightGradeId [int] NULL,
	intEventId [int] NOT NULL,
	intNoOfDays	 [int] NOT NULL,
	intSort INT NOT NULL,
	ysnAffectAvlDate BIT NULL,
	intConcurrencyId INT NOT NULL, 
	CONSTRAINT [PK_tblCTEventMatrixDetail_intEventMatrixDetailId] PRIMARY KEY CLUSTERED ([intEventMatrixDetailId] ASC),
	CONSTRAINT [FK_tblCTEventMatrixDetail_tblCTEventMatrix_intEventMatrixId] FOREIGN KEY (intEventMatrixId) REFERENCES [tblCTEventMatrix](intEventMatrixId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTEventMatrixDetail_tblCTEvent_intEventId] FOREIGN KEY (intEventId) REFERENCES [tblCTEvent](intEventId),
	CONSTRAINT [FK_tblCTEventMatrixDetail_tblCTPosition_intPositionId] FOREIGN KEY (intPositionId) REFERENCES [tblCTPosition](intPositionId),
	CONSTRAINT [FK_tblCTEventMatrixDetail_tblCTWeightGrade_intWeightGradeId] FOREIGN KEY (intWeightGradeId) REFERENCES [tblCTWeightGrade](intWeightGradeId)
)
