--liquibase formatted sql

-- changeset Von:fnARValidateInvoiceSourceId.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARValidateInvoiceSourceId]
(
	 @SourceTransaction	NVARCHAR(250)
	,@SourceId			INT	= 0
)
RETURNS INT
AS
BEGIN
	DECLARE @SourceIdOut INT = 0
	SET @SourceIdOut = @SourceId
	
	IF @SourceTransaction = 'Direct'
		RETURN 0
		
	IF @SourceTransaction = 'Sales Order'
		RETURN 1		
		
	IF @SourceTransaction IN ('Invoice', 'Provisional')
		RETURN 2		
		
	IF @SourceTransaction = 'Transport Load'
		RETURN 3		
		
	IF @SourceTransaction = 'Inbound Shipment'
		RETURN 4		
		
	IF @SourceTransaction = 'Inventory Shipment'
		RETURN 5		
		
	IF @SourceTransaction = 'Card Fueling Transaction' OR @SourceTransaction = 'CF Tran'
		RETURN 6		
		
	IF @SourceTransaction = 'Transfer Storage'
		RETURN 7		
		
	IF @SourceTransaction = 'Sale OffSite'
		RETURN 8		
		
	IF @SourceTransaction = 'Settle Storage'
		RETURN 9		
		
	IF @SourceTransaction = 'Process Grain Storage'
		RETURN 10		
		
	IF @SourceTransaction = 'Consumption Site'
		RETURN 11		
		
	IF @SourceTransaction = 'Meter Billing'
		RETURN 12	
		
	IF @SourceTransaction = 'Load/Shipment Schedules'
		RETURN 13		

	IF @SourceTransaction = 'Credit Card Reconciliation'
		RETURN 14

	IF @SourceTransaction = 'Sales Contract'
		RETURN 15

	IF @SourceTransaction = 'Load Schedule'
		RETURN 16

	IF @SourceTransaction = 'CF Invoice'
		RETURN 17	

	IF @SourceTransaction = 'Ticket Management'
		RETURN 18

	IF @SourceTransaction = 'Agronomy'
		RETURN 18	

	RETURN @SourceIdOut
END



