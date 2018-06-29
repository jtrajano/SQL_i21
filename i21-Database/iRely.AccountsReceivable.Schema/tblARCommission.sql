CREATE TABLE [dbo].[tblARCommission]
(
	[intCommissionId]			INT NOT NULL IDENTITY,
	[intCommissionScheduleId]	INT NOT NULL,
	[intCommissionPlanId]		INT NULL,
	[intEntityId]				INT NULL,
	[intApproverEntityId]		INT NULL,
	[intPaymentId]				INT NULL,
	[intPaycheckId]				INT NULL,
	[dtmStartDate]				DATETIME NULL,
	[dtmEndDate]				DATETIME NULL,
	[ysnConditional]			BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnConditional] DEFAULT ((0)),
	[ysnApproved]				BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnApproved] DEFAULT ((0)),
	[ysnRejected]				BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnRejected] DEFAULT ((0)),
	[ysnPayroll]				BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnPayroll] DEFAULT ((0)),
	[ysnPayables]				BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnPayables] DEFAULT ((0)),
	[ysnPosted]					BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnPosted] DEFAULT ((0)),
	[ysnPaid]					BIT NOT NULL CONSTRAINT [DF_tblARCommission_ysnPaid] DEFAULT ((0)),
	[dblTotalAmount]			NUMERIC(18,6) NOT NULL DEFAULT 0,
	[strCommissionNumber]		NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,	
	[strReason]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblARCommission_intCommissionId] PRIMARY KEY CLUSTERED ([intCommissionId] ASC),
	CONSTRAINT [FK_tblARCommission_tblAPPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [tblAPPayment]([intPaymentId]),
	CONSTRAINT [FK_tblARCommission_tblPRPaycheck_intPaycheckId] FOREIGN KEY ([intPaycheckId]) REFERENCES [tblPRPaycheck]([intPaycheckId])
);

GO

CREATE UNIQUE NONCLUSTERED INDEX [UK_tblARCommission_strCommissionNumber]
ON dbo.tblARCommission(strCommissionNumber)
WHERE strCommissionNumber IS NOT NULL;