CREATE TABLE tblIPInvPostedReceipt
(
	intPostedReceiptId			INT IDENTITY(1,1),
	intInventoryReceiptId		INT,
	intUserId					INT,
	ysnPosted					BIT,

	intStatusId					INT,
	strMessage					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,

	CONSTRAINT [PK_tblIPInvPostedReceipt_intPostedReceiptId] PRIMARY KEY (intPostedReceiptId)
)
