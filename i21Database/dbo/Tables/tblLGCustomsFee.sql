CREATE TABLE tblLGCustomsFee 
(
	 [intCustomsFeeId] INT NOT NULL IDENTITY (1, 1),
	 [strOrigin] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	 [dblHarborFee] NUMERIC(18, 6),
	 [dblHarborFeeCap] NUMERIC(18, 6),
	 [dblProcessingFee] NUMERIC(18, 6),
	 [dblProcessingFeeCap] NUMERIC(18, 6),
	 [intConcurrencyId] INT NOT NULL DEFAULT 0,
	 CONSTRAINT [PK_tblLGCustomFee_intCustomsFeeId] PRIMARY KEY CLUSTERED ([intCustomsFeeId] ASC)
)