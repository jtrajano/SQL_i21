﻿CREATE TABLE [dbo].[tblSOSalesOrder] (
    [intSalesOrderId]			INT             IDENTITY (1, 1) NOT NULL,
    [strSalesOrderNumber]		NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strSalesOrderOriginId]		NVARCHAR (25)	COLLATE Latin1_General_CI_AS NULL,
    [intEntityCustomerId]       INT             NULL,
    [dtmDate]					DATETIME        NOT NULL,
    [dtmDueDate]				DATETIME        NOT NULL,
	[dtmExpirationDate]         DATETIME        NULL,
    [intCurrencyId]				INT             NOT NULL,
    [intCompanyLocationId]		INT             NULL,
    [intEntitySalespersonId]    INT       NULL,
    [intShipViaId]				INT             NULL,
    [strPONumber]				NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
	[strBOLNumber]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL, 
    [intTermId]					INT             NOT NULL,
    [dblSalesOrderSubtotal]		NUMERIC (18, 6) NULL,
    [dblShipping]				NUMERIC (18, 6) NULL,
    [dblTax]					NUMERIC (18, 6) NULL,
    [dblSalesOrderTotal]		NUMERIC (18, 6) NULL,
    [dblDiscount]				NUMERIC (18, 6) NULL,
	[dblDiscountAvailable]		NUMERIC(18, 6)	NULL DEFAULT 0,	
    [dblAmountDue]				NUMERIC (18, 6) NULL,
    [dblPayment]				NUMERIC (18, 6) NULL,
    [strTransactionType]		NVARCHAR (25)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strType]					NVARCHAR (25)   COLLATE Latin1_General_CI_AS DEFAULT 'Standard' NULL,
    [strOrderStatus]			NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]				INT             NOT NULL,
    [dtmProcessDate]			DATETIME        NULL,
    [ysnProcessed]				BIT             CONSTRAINT [DF_tblSOSalesOrder_ysnPosted] DEFAULT ((0)) NOT NULL,
	[ysnShipped]				BIT				CONSTRAINT [DF_tblSOSalesOrder_ysnShipped] DEFAULT ((0)) NOT NULL,
	[ysnRecurring]				BIT				NULL,
	[ysnQuote]					BIT				CONSTRAINT [DF_tblSOSalesOrder_ysnQuote] DEFAULT ((0)) NULL,
	[ysnPreliminaryQuote]		BIT				NULL,
    [strComments]				NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS NULL,
	[strFooterComments]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[intFreightTermId]			INT				NULL, 
	[intShipToLocationId]		INT             NULL,
    [strShipToLocationName]		NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strShipToAddress]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strShipToCity]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strShipToState]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strShipToZipCode]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strShipToCountry]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[intBillToLocationId]		INT             NULL,
    [strBillToLocationName]		NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strBillToAddress]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strBillToCity]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strBillToState]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strBillToZipCode]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strBillToCountry]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]			INT             CONSTRAINT [DF_tblSOSalesOrder_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    [intEntityId]				INT             CONSTRAINT [DF_tblSOSalesOrder_intEntityId] DEFAULT ((0)) NOT NULL,   
    [intOrderedById]			INT				NULL, 
    [intSplitId]				INT				NULL, 
    [intQuoteTemplateId]		INT				NULL,      
    [strLostQuoteComment]		NVARCHAR(250)	COLLATE Latin1_General_CI_AS NULL, 
    [strLostQuoteCompetitor]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
    [strLostQuoteReason]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
	[strQuoteType]				NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,     
	[dblTotalWeight]			NUMERIC(18, 6)	NULL DEFAULT 0,
	[intEntityContactId]		INT				NULL,
	[dblTotalTermDiscount]		NUMERIC(18, 6)	NULL DEFAULT 0,	
	[intDocumentMaintenanceId]  INT				NULL,
	[intRecipeGuideId]			INT				NULL,
    CONSTRAINT [PK_tblSOSalesOrder] PRIMARY KEY CLUSTERED ([intSalesOrderId] ASC),
    CONSTRAINT [FK_tblSOSalesOrder_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
    CONSTRAINT [FK_tblSOSalesOrder_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblEMEntityLocation_intShipToLocationId] FOREIGN KEY ([intShipToLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblEMEntityLocation_intBillToLocationId] FOREIGN KEY ([intBillToLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblARQuoteTemplate_intQuoteTemplateId] FOREIGN KEY ([intQuoteTemplateId]) REFERENCES [dbo].[tblARQuoteTemplate] ([intQuoteTemplateId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblEMEntity_intOrderedById] FOREIGN KEY ([intOrderedById]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblEMEntitySplit_intSplitId] FOREIGN KEY ([intSplitId]) REFERENCES [dbo].[tblEMEntitySplit] ([intSplitId]),
	CONSTRAINT [FK_tblSOSalesOrder_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID])    
);
GO

CREATE TRIGGER trgSalesOrderNumber
ON dbo.tblSOSalesOrder
AFTER INSERT
AS

DECLARE @inserted TABLE(intSalesOrderId INT, strTransactionType NVARCHAR(10), intCompanyLocationId INT)
DECLARE @count INT = 0
DECLARE @intSalesOrderId INT
DECLARE @intCompanyLocationId INT
DECLARE @SalesOrderNumber NVARCHAR(50)
DECLARE @strTransactionType NVARCHAR(25)
DECLARE @intMaxCount INT = 0
DECLARE @intStartingNumberId INT = 0

INSERT INTO @inserted
SELECT intSalesOrderId, strTransactionType, intCompanyLocationId FROM INSERTED ORDER BY intSalesOrderId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intSalesOrderId = intSalesOrderId, @strTransactionType = strTransactionType, @intCompanyLocationId = intCompanyLocationId FROM @inserted

	SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
	FROM tblSMStartingNumber 
	WHERE strTransactionType = CASE WHEN @strTransactionType = 'Order' THEN 'Sales Order' 
									WHEN @strTransactionType = 'Quote' THEN 'Quote' END

	IF(@intStartingNumberId <> 0)
		EXEC uspSMGetStartingNumber @intStartingNumberId, @SalesOrderNumber OUT, @intCompanyLocationId
	
	IF(@SalesOrderNumber IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblSOSalesOrder WHERE strSalesOrderNumber = @SalesOrderNumber)
			BEGIN
				SET @SalesOrderNumber = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strSalesOrderNumber, 4, 10))) FROM tblSOSalesOrder WHERE strTransactionType = @strTransactionType
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
				EXEC uspSMGetStartingNumber @intStartingNumberId, @SalesOrderNumber OUT, @intCompanyLocationId
			END
		
		UPDATE tblSOSalesOrder
			SET tblSOSalesOrder.strSalesOrderNumber = @SalesOrderNumber
		FROM tblSOSalesOrder A
		WHERE A.intSalesOrderId = @intSalesOrderId
	END

	DELETE FROM @inserted
	WHERE intSalesOrderId = @intSalesOrderId

END