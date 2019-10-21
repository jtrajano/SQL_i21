CREATE TABLE [dbo].[tblSMTermCutoff]
(
	[intTermCutoffId]		INT PRIMARY KEY IDENTITY (1, 1)		NOT NULL,
	[intTermId]				INT									NOT NULL,
	--[dtmStartDate]			DATETIME							NOT NULL, 
	--[dtmEndDate]			DATETIME							NOT NULL, 
	[intFromDate]			INT									NOT NULL,
	[intToDate]				INT									NOT NULL,
	[intCutoff]				INT									NOT NULL,
	[intConcurrencyId]		[int]												NOT NULL DEFAULT ((1)), 
	CONSTRAINT [FK_tblSMTermCutoff_tblSMTerm] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID]),
)
