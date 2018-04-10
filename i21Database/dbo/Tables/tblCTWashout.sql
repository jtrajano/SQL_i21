CREATE TABLE [dbo].[tblCTWashout]
(
	intWashoutId	    INT NOT NULL IDENTITY, 
	intSourceHeaderId   INT,
	intSourceDetailId   INT,
	strSourceNumber		NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intWashoutHeaderId  INT,
	intWashoutDetailId  INT,
	strWashoutNumber	NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblCashPrice	    NUMERIC(18,6),
	dblWashoutFee	    NUMERIC(18,6),
	ysnNewContract	    BIT,
	dblWTFutures	    NUMERIC(18,6),
	dblWTBasis		    NUMERIC(18,6),
	dblWTCashPrice	    NUMERIC(18,6),
	strDocType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intBillInvoiceId	INT,
	strBillInvoice		NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblAmount			NUMERIC(18,6),
	intConcurrencyId    INT NOT NULL, 
	intCreatedById	    INT,
	dtmCreated		    DATETIME,

	CONSTRAINT PK_tblCTWashout_intWashoutId PRIMARY KEY CLUSTERED (intWashoutId ASC), 
	CONSTRAINT UK_tblCTWashout_intSourceDetailId UNIQUE (intSourceDetailId),
	CONSTRAINT UK_tblCTWashout_intWashoutDetailId UNIQUE (intWashoutDetailId),
	CONSTRAINT [FK_tblCTWashout_tblCTContractDetail_intSourceDetailId] FOREIGN KEY (intSourceDetailId) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTWashout_tblCTContractDetail_intWashoutDetailId] FOREIGN KEY (intWashoutDetailId) REFERENCES [tblCTContractDetail]([intContractDetailId])
)
