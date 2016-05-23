CREATE TABLE [dbo].[tblARCommissionDetail]
(
	[intCommissionDetailId]			INT NOT NULL IDENTITY,
	[intCommissionId]				INT NOT NULL,
	[intEntityId]					INT NULL,
	[intSourceId]					INT NULL,
	[strSourceType]					NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[dtmSourceDate]					DATETIME NULL,
	[dblAmount]						NUMERIC(18,6) NULL,
	[intConcurrencyId]				INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionDetail_intCommissionDetailId] PRIMARY KEY CLUSTERED ([intCommissionDetailId] ASC),
	CONSTRAINT [FK_tblARCommissionDetail_tblARCommission] FOREIGN KEY ([intCommissionId]) REFERENCES [tblARCommission] ([intCommissionId]) ON DELETE CASCADE
)
