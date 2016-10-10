CREATE PROCEDURE [dbo].[uspETImportUpdateInvoiceDetailTaxById]
	@intInvoiceDetailId INT
AS
BEGIN
	DECLARE @dblTaxCategory1 NUMERIC(18, 6) 
	DECLARE @dblTaxCategory2 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory3 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory4 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory5 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory6 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory7 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory8 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory9 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory10 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory11 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory12 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory13 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory14 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory15 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory16 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory17 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory18 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory19 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory20 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory21 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory22 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory23 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory24 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory25 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory26 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory27 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory28 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory29 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory30 NUMERIC(18, 6)

	DECLARE @intTaxCategory1 INT 
	DECLARE @intTaxCategory2 INT
	DECLARE @intTaxCategory3 INT
	DECLARE @intTaxCategory4 INT
	DECLARE @intTaxCategory5 INT
	DECLARE @intTaxCategory6 INT
	DECLARE @intTaxCategory7 INT
	DECLARE @intTaxCategory8 INT
	DECLARE @intTaxCategory9 INT
	DECLARE @intTaxCategory10 INT
	DECLARE @intTaxCategory11 INT
	DECLARE @intTaxCategory12 INT
	DECLARE @intTaxCategory13 INT
	DECLARE @intTaxCategory14 INT
	DECLARE @intTaxCategory15 INT
	DECLARE @intTaxCategory16 INT
	DECLARE @intTaxCategory17 INT
	DECLARE @intTaxCategory18 INT
	DECLARE @intTaxCategory19 INT
	DECLARE @intTaxCategory20 INT
	DECLARE @intTaxCategory21 INT
	DECLARE @intTaxCategory22 INT
	DECLARE @intTaxCategory23 INT
	DECLARE @intTaxCategory24 INT
	DECLARE @intTaxCategory25 INT
	DECLARE @intTaxCategory26 INT
	DECLARE @intTaxCategory27 INT
	DECLARE @intTaxCategory28 INT
	DECLARE @intTaxCategory29 INT
	DECLARE @intTaxCategory30 INT  

	DECLARE @intNewInvoiceId INT

	EXEC uspETImportUpdateInvoiceDetailTax
		@intInvoiceDetailId = @intInvoiceDetailId
		,@dblTaxCategory1	= @dblTaxCategory1	
		,@dblTaxCategory2	= @dblTaxCategory2	
		,@dblTaxCategory3	= @dblTaxCategory3	
		,@dblTaxCategory4	= @dblTaxCategory4	
		,@dblTaxCategory5	= @dblTaxCategory5	
		,@dblTaxCategory6	= @dblTaxCategory6	
		,@dblTaxCategory7	= @dblTaxCategory7	
		,@dblTaxCategory8	= @dblTaxCategory8	
		,@dblTaxCategory9	= @dblTaxCategory9	
		,@dblTaxCategory10	= @dblTaxCategory10	
		,@dblTaxCategory11	= @dblTaxCategory11	
		,@dblTaxCategory12	= @dblTaxCategory12	
		,@dblTaxCategory13	= @dblTaxCategory13	
		,@dblTaxCategory14	= @dblTaxCategory14	
		,@dblTaxCategory15	= @dblTaxCategory15	
		,@dblTaxCategory16	= @dblTaxCategory16	
		,@dblTaxCategory17	= @dblTaxCategory17	
		,@dblTaxCategory18	= @dblTaxCategory18	
		,@dblTaxCategory19	= @dblTaxCategory19	
		,@dblTaxCategory20	= @dblTaxCategory20	
		,@dblTaxCategory21	= @dblTaxCategory21	
		,@dblTaxCategory22	= @dblTaxCategory22	
		,@dblTaxCategory23	= @dblTaxCategory23	
		,@dblTaxCategory24	= @dblTaxCategory24	
		,@dblTaxCategory25	= @dblTaxCategory25	
		,@dblTaxCategory26	= @dblTaxCategory26	
		,@dblTaxCategory27	= @dblTaxCategory27	
		,@dblTaxCategory28	= @dblTaxCategory28	
		,@dblTaxCategory29	= @dblTaxCategory29	
		,@dblTaxCategory30	= @dblTaxCategory30	
		,@intTaxCategory1	= @intTaxCategory1	 
		,@intTaxCategory2	= @intTaxCategory2 
		,@intTaxCategory3	= @intTaxCategory3 
		,@intTaxCategory4	= @intTaxCategory4 
		,@intTaxCategory5	= @intTaxCategory5 
		,@intTaxCategory6	= @intTaxCategory6 
		,@intTaxCategory7	= @intTaxCategory7 
		,@intTaxCategory8	= @intTaxCategory8 
		,@intTaxCategory9	= @intTaxCategory9 
		,@intTaxCategory10	= @intTaxCategory10 
		,@intTaxCategory11	= @intTaxCategory11 
		,@intTaxCategory12	= @intTaxCategory12 
		,@intTaxCategory13	= @intTaxCategory13 
		,@intTaxCategory14	= @intTaxCategory14 
		,@intTaxCategory15	= @intTaxCategory15 
		,@intTaxCategory16	= @intTaxCategory16 
		,@intTaxCategory17	= @intTaxCategory17 
		,@intTaxCategory18	= @intTaxCategory18 
		,@intTaxCategory19	= @intTaxCategory19 
		,@intTaxCategory20	= @intTaxCategory20 
		,@intTaxCategory21	= @intTaxCategory21 
		,@intTaxCategory22	= @intTaxCategory22 
		,@intTaxCategory23	= @intTaxCategory23 
		,@intTaxCategory24	= @intTaxCategory24 
		,@intTaxCategory25	= @intTaxCategory25 
		,@intTaxCategory26	= @intTaxCategory26 
		,@intTaxCategory27	= @intTaxCategory27 
		,@intTaxCategory28	= @intTaxCategory28 
		,@intTaxCategory29	= @intTaxCategory29 
		,@intTaxCategory30	= @intTaxCategory30 
		
	

		
END
GO