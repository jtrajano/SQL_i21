CREATE TABLE [dbo].[tblSMFreightTerms]
(
	[intFreightTermId]	 INT				PRIMARY KEY IDENTITY(1,1)		NOT NULL, 
    [strFreightTerm]	 NVARCHAR(100)		COLLATE Latin1_General_CI_AS	NOT NULL, 
    [strFobPoint]		 NVARCHAR(100)		COLLATE Latin1_General_CI_AS	NOT NULL,
	[ysnActive]			 BIT				DEFAULT (1)						NOT NULL,
	[intConcurrencyId]	 INT				DEFAULT (1)						NOT NULL,
	CONSTRAINT [AK_tblSMFreightTerms_strFreightTerm] UNIQUE NONCLUSTERED ([strFreightTerm] ASC)
);
