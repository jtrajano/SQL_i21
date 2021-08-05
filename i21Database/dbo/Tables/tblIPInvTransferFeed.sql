CREATE TABLE tblIPInvTransferFeed
(
	intTransferFeedId			INT IDENTITY(1,1),
	strCompanyLocation			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryTransferId		INT,
	strTransferNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strERPTransferOrderNo		NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	strCreatedBy				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intStatusId					INT,
	strMessage					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strFeedStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,

	CONSTRAINT [PK_tblIPInvTransferFeed_intTransferFeedId] PRIMARY KEY (intTransferFeedId)
)
