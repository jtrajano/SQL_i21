CREATE TABLE [dbo].[tblARCommentMaintenance]
(
	[intCommentId]			INT NOT NULL IDENTITY, 
    [strCommentCode]		NVARCHAR(10)  COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCommentTitle]		NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCommentDesc]		NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionType]	NVARCHAR(25)  COLLATE Latin1_General_CI_AS NULL,
	[strType]			    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityCustomerId]	INT NULL, 
    [intCompanyLocationId]  INT NULL,
	[intConcurrencyId]		INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommentMaintenance_intCommentId] PRIMARY KEY CLUSTERED ([intCommentId] ASC),
	CONSTRAINT [FK_tblARCommentMaintenance_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
	CONSTRAINT [FK_tblARCommentMaintenance_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId])
)
