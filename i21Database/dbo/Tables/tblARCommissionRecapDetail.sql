CREATE TABLE [dbo].[tblARCommissionRecapDetail]
(
	[intCommissionRecapDetailId]	INT NOT NULL IDENTITY,
	[intCommissionRecapId]			INT NOT NULL,
	[intEntityId]					INT NULL,
	[intSourceId]					INT NULL,
	[strSourceType]					NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[dtmSourceDate]					DATETIME NULL,
	[dblAmount]						NUMERIC(18,6) NULL,
	[intConcurrencyId]				INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionRecapDetail_intCommissionRecapDetailId] PRIMARY KEY CLUSTERED ([intCommissionRecapDetailId] ASC),
	CONSTRAINT [FK_tblARCommissionRecapDetail_tblARCommissionRecap] FOREIGN KEY ([intCommissionRecapId]) REFERENCES [tblARCommissionRecap] ([intCommissionRecapId]) ON DELETE CASCADE
)
