CREATE TABLE [dbo].[tblHDUpload]
(
		[intUploadId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketCommentId] [int] NULL,
	[strFileIdentifier] [uniqueidentifier] NOT NULL,
	[strFileName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFileLocation] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[blbFile] [varbinary](max) NULL,
	[intConcurrencyId] [int] NOT NULL, 
		CONSTRAINT [PK_tblHDUpload] PRIMARY KEY CLUSTERED ([intUploadId] ASC),
    CONSTRAINT [FK_HDUpload_Ticket] FOREIGN KEY ([intTicketCommentId]) REFERENCES [dbo].[tblHDTicketComment] ([intTicketCommentId]) on delete cascade
)
