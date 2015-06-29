CREATE TABLE [dbo].[tblSOSalesOrder] (
    [intSalesOrderId]       INT             IDENTITY (1, 1) NOT NULL,
    [strSalesOrderNumber]   NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strSalesOrderOriginId] NVARCHAR (8)    COLLATE Latin1_General_CI_AS NULL,
    [intEntityCustomerId]         INT             NOT NULL,
    [dtmDate]               DATETIME        NOT NULL,
    [dtmDueDate]            DATETIME        NOT NULL,
    [intCurrencyId]         INT             NOT NULL,
    [intCompanyLocationId]  INT             NULL,
    [intEntitySalespersonId]      INT             NOT NULL,
    [intShipViaId]          INT             NULL,
    [strPONumber]           NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
	[strBOLNumber]			NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL, 
    [intTermId]             INT             NOT NULL,
    [dblSalesOrderSubtotal] NUMERIC (18, 6) NULL,
    [dblShipping]           NUMERIC (18, 6) NULL,
    [dblTax]                NUMERIC (18, 6) NULL,
    [dblSalesOrderTotal]    NUMERIC (18, 6) NULL,
    [dblDiscount]           NUMERIC (18, 6) NULL,
    [dblAmountDue]          NUMERIC (18, 6) NULL,
    [dblPayment]            NUMERIC (18, 6) NULL,
    [strTransactionType]    NVARCHAR (25)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strOrderStatus]        NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]          INT             NOT NULL,
    [dtmProcessDate]        DATETIME        NULL,
    [ysnProcessed]          BIT             CONSTRAINT [DF_tblSOSalesOrder_ysnPosted] DEFAULT ((0)) NOT NULL,
    [strComments]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
	[intFreightTermId]		INT				NULL, 
	[intShipToLocationId]   INT             NULL,
    [strShipToLocationName] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strShipToAddress]      NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strShipToCity]         NVARCHAR (30)   COLLATE Latin1_General_CI_AS NULL,
    [strShipToState]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strShipToZipCode]      NVARCHAR (12)   COLLATE Latin1_General_CI_AS NULL,
    [strShipToCountry]      NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
	[intBillToLocationId]   INT             NULL,
    [strBillToLocationName] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strBillToAddress]      NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strBillToCity]         NVARCHAR (30)   COLLATE Latin1_General_CI_AS NULL,
    [strBillToState]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strBillToZipCode]      NVARCHAR (12)   COLLATE Latin1_General_CI_AS NULL,
    [strBillToCountry]      NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblSOSalesOrder_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    [intEntityId]           INT             CONSTRAINT [DF_tblSOSalesOrder_intEntityId] DEFAULT ((0)) NOT NULL,   
    [intOrderedById]		INT NULL, 
    [intSplitId]			INT NULL, 
    [intQuoteTemplateId]	INT NULL, 
    [ysnPreliminaryQuote]	BIT NULL, 
    [strLostQuoteComment]	NVARCHAR(250)	COLLATE Latin1_General_CI_AS NULL, 
    [strLostQuoteCompetitor] NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
    [strLostQuoteReason]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL, 
    [strOrderType]          NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblSOSalesOrder] PRIMARY KEY CLUSTERED ([intSalesOrderId] ASC),
    CONSTRAINT [FK_tblSOSalesOrder_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
    CONSTRAINT [FK_tblSOSalesOrder_tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblEntityLocation_intShipToLocationId] FOREIGN KEY ([intShipToLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblEntityLocation_intBillToLocationId] FOREIGN KEY ([intBillToLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblARQuoteTemplate_intQuoteTemplateId] FOREIGN KEY ([intQuoteTemplateId]) REFERENCES [dbo].[tblARQuoteTemplate] ([intQuoteTemplateId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblEntity_intOrderedById] FOREIGN KEY ([intOrderedById]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblARCustomerSplit_intSplitId] FOREIGN KEY ([intSplitId]) REFERENCES [dbo].[tblARCustomerSplit] ([intSplitId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID])
);
GO

CREATE TRIGGER trgSalesOrderNumber
ON dbo.tblSOSalesOrder
AFTER INSERT
AS

DECLARE @inserted TABLE(intSalesOrderId INT, strTransactionType NVARCHAR(10))
DECLARE @count INT = 0
DECLARE @intSalesOrderId INT
DECLARE @SalesOrderNumber NVARCHAR(50)
DECLARE @strTransactionType NVARCHAR(10)

INSERT INTO @inserted
SELECT intSalesOrderId, strTransactionType FROM INSERTED ORDER BY intSalesOrderId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intSalesOrderId = intSalesOrderId, @strTransactionType = strTransactionType FROM @inserted

	IF(@strTransactionType IS NOT NULL AND @strTransactionType = 'Order')
		BEGIN
			EXEC uspSMGetStartingNumber 29, @SalesOrderNumber OUT
		END
	ELSE
		BEGIN
			EXEC uspSMGetStartingNumber 51, @SalesOrderNumber OUT
		END
	
	IF(@SalesOrderNumber IS NOT NULL)
	BEGIN
		UPDATE tblSOSalesOrder
			SET tblSOSalesOrder.strSalesOrderNumber = @SalesOrderNumber
		FROM tblSOSalesOrder A
		WHERE A.intSalesOrderId = @intSalesOrderId
	END

	DELETE FROM @inserted
	WHERE intSalesOrderId = @intSalesOrderId

END