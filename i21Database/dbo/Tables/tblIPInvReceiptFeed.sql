CREATE TABLE tblIPInvReceiptFeed
(
	intReceiptFeedId			INT IDENTITY(1,1),
	strCompanyLocation			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intInventoryReceiptId		INT,
	intInventoryReceiptItemId	INT,
	intReceiptFeedHeaderId		INT,
	strReceiptNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTransferNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strERPTransferOrderNo		NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	strCreatedBy				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intStatusId					INT,
	strMessage					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strFeedStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,

	CONSTRAINT [PK_tblIPInvReceiptFeed_intReceiptFeedId] PRIMARY KEY (intReceiptFeedId)
)
