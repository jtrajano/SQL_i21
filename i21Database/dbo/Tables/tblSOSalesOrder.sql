CREATE TABLE [dbo].[tblSOSalesOrder] (
    [intSalesOrderId]       INT             IDENTITY (1, 1) NOT NULL,
    [strSalesOrderNumber]   NVARCHAR (25)   NULL,
    [strSalesOrderOriginId] NVARCHAR (8)    NULL,
    [intCustomerId]         INT             NOT NULL,
    [dtmDate]               DATETIME        NOT NULL,
    [dtmDueDate]            DATETIME        NOT NULL,
    [intCurrencyId]         INT             NOT NULL,
    [intCompanyLocationId]  INT             NULL,
    [intSalespersonId]      INT             NOT NULL,
    [intShipViaId]          INT             NOT NULL,
    [strPONumber]           NVARCHAR (25)   NULL,
    [intTermId]             INT             NOT NULL,
    [dblSalesOrderSubtotal] NUMERIC (18, 6) NULL,
    [dblShipping]           NUMERIC (18, 6) NULL,
    [dblTax]                NUMERIC (18, 6) NULL,
    [dblSalesOrderTotal]    NUMERIC (18, 6) NULL,
    [dblDiscount]           NUMERIC (18, 6) NULL,
    [dblAmountDue]          NUMERIC (18, 6) NULL,
    [dblPayment]            NUMERIC (18, 6) NULL,
    [strTransactionType]    NVARCHAR (25)   NOT NULL,
    [strOrderStatus]        NVARCHAR (25)   NULL,
    [intAccountId]          INT             NOT NULL,
    [dtmProcessDate]        DATETIME        NULL,
    [ysnProcessed]          BIT             CONSTRAINT [DF_tblSOSalesOrder_ysnPosted] DEFAULT ((0)) NOT NULL,
    [strComments]           NVARCHAR (250)  NULL,
    [strShipToLocationName] NVARCHAR (50)   NULL,
    [strShipToAddress]      NVARCHAR (100)  NULL,
    [strShipToCity]         NVARCHAR (30)   NULL,
    [strShipToState]        NVARCHAR (50)   NULL,
    [strShipToZipCode]      NVARCHAR (12)   NULL,
    [strShipToCountry]      NVARCHAR (25)   NULL,
    [strBillToLocationName] NVARCHAR (50)   NULL,
    [strBillToAddress]      NVARCHAR (100)  NULL,
    [strBillToCity]         NVARCHAR (30)   NULL,
    [strBillToState]        NVARCHAR (50)   NULL,
    [strBillToZipCode]      NVARCHAR (12)   NULL,
    [strBillToCountry]      NVARCHAR (25)   NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblSOSalesOrder_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    [intEntityId]           INT             CONSTRAINT [DF_tblSOSalesOrder_intEntityId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblSOSalesOrder] PRIMARY KEY CLUSTERED ([intSalesOrderId] ASC),
    CONSTRAINT [FK_tblSOSalesOrder_tblARCustomer_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intCustomerId]),
    CONSTRAINT [FK_tblSOSalesOrder_tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
);


GO
CREATE TRIGGER trgSalesOrderNumber
ON dbo.tblSOSalesOrder
AFTER INSERT
AS

DECLARE @inserted TABLE(intSalesOrderId INT)
DECLARE @count INT = 0
DECLARE @intSalesOrderId INT
DECLARE @SalesOrderNumber NVARCHAR(50)

INSERT INTO @inserted
SELECT intSalesOrderId FROM INSERTED ORDER BY intSalesOrderId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	
	--EXEC uspARFixStartingNumbers 17
	--IF(OBJECT_ID('tempdb..#tblTempAPByPassFixStartingNumber') IS NOT NULL) RETURN;
	EXEC uspSMGetStartingNumber 30, @SalesOrderNumber OUT

	SELECT TOP 1 @intSalesOrderId = intSalesOrderId FROM @inserted
	
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