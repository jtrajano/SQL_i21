CREATE TABLE [dbo].[tblCTContractAdjustment]
(
	intAdjustmentId INT IDENTITY,
	intContractDetailId INT NOT NULL,
	strAdjustmentNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	dtmAdjustmentDate DATETIME NOT NULL,
	strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dblAdjustedQty NUMERIC(18, 6) NOT NULL,
	dblCancellationPrice NUMERIC(18, 6),
	dblGainLossPerUnit NUMERIC(18, 6) NULL,
	dblCancelFeePerUnit NUMERIC(18, 6),
	dblCancelFeeFlatAmount NUMERIC(18, 6),
	dblTotalGainLoss NUMERIC(18, 6),
	dblTotalFee NUMERIC(18, 6),
	intAccountId INT,
	intCreatedById INT,
	dtmCreated DATETIME,
	intLastModifiedById INT,
	dtmLastModified DATETIME,
	intConcurrencyId INT NOT NULL,
    CONSTRAINT [PK_tblCTContractAdjustment_intAdjustmentId] PRIMARY KEY CLUSTERED ([intAdjustmentId] ASC), 
	CONSTRAINT [FK_tblCTContractAdjustment_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTContractAdjustment_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId])
)