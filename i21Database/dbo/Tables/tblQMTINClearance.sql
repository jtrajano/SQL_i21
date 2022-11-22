CREATE TABLE [dbo].[tblQMTINClearance]
(
	[intTINClearanceId] 		INT IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] 			INT NULL DEFAULT ((1)),
    [strTINNumber] 				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCompanyLocationId]		INT NOT NULL,
	[intBatchId]				INT NULL,
	[ysnEmpty]					BIT NULL,
	CONSTRAINT [PK_tblQMTINClearance_intTINClearanceId] PRIMARY KEY CLUSTERED ([intTINClearanceId] ASC),	
	CONSTRAINT [FK_tblQMTINClearance_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
    CONSTRAINT [UK_tblQMTINClearance] UNIQUE (strTINNumber, intCompanyLocationId)
);