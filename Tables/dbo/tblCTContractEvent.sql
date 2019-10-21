CREATE TABLE [dbo].[tblCTContractEvent]
(
	intContractEventId INT IDENTITY(1,1) NOT NULL,
	intContractDetailId INT NOT NULL,
	intPositionId [int] NULL,
	intWeightGradeId [int] NULL,
	intEventId [int] NOT NULL,
	intNoOfDays	 [int] NOT NULL,
	intSort INT NOT NULL,
	ysnAffectAvlDate BIT NULL,
	dtmExpectedEventDate	datetime,
	dtmActualEventDate	datetime,
	intActualNoOfDays INT NULL,
	[intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblCTContractEvent_intContractEventId] PRIMARY KEY CLUSTERED ([intContractEventId] ASC),
	CONSTRAINT [FK_tblCTContractEvent_tblCTContractDetail_intContractDetailId] FOREIGN KEY (intContractDetailId) REFERENCES [tblCTContractDetail](intContractDetailId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractEvent_tblCTPosition_intPositionId] FOREIGN KEY (intPositionId) REFERENCES [tblCTPosition](intPositionId),
	CONSTRAINT [FK_tblCTContractEvent_tblCTWeightGrade_intWeightGradeId] FOREIGN KEY (intWeightGradeId) REFERENCES [tblCTWeightGrade](intWeightGradeId),
	CONSTRAINT [FK_tblCTContractEvent_tblCTEvent_intEventId] FOREIGN KEY (intEventId) REFERENCES [tblCTEvent](intEventId)

)
