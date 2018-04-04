CREATE PROCEDURE [dbo].[uspETImportUpdateInvoiceDetailTaxById]
	@intInvoiceDetailId INT
	,@intImportBaseEngineeringId INT
	,@intTaxGroupId INT
	,@ysnRecomputeTax BIT = 0
	,@ysnOverFill BIT = 0
	,@TotalQuantity NUMERIC(18,6) = 0
	,@PrebuyQuantity NUMERIC(18,6) = 0
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
    SELECT TOP 1 
		@intTaxCategory1    =   category01
		,@intTaxCategory2    =   category02
		,@intTaxCategory3    =   category03
		,@intTaxCategory4    =   category04
		,@intTaxCategory5    =   category05
		,@intTaxCategory6    =   category06
		,@intTaxCategory7    =   category07
		,@intTaxCategory8    =   category08
		,@intTaxCategory9    =   category09
		,@intTaxCategory10    =  category10
		,@intTaxCategory11    =  category11
		,@intTaxCategory12    =  category12
		,@intTaxCategory13    =  category13
		,@intTaxCategory14    =  category14
		,@intTaxCategory15    =  category15
		,@intTaxCategory16    =  category16
		,@intTaxCategory17    =  category17
		,@intTaxCategory18    =  category18
		,@intTaxCategory19    =  category19
		,@intTaxCategory20    =  category20
		,@intTaxCategory21    =  category21
		,@intTaxCategory22    =  category22
		,@intTaxCategory23    =  category23
		,@intTaxCategory24    =  category24
		,@intTaxCategory25    =  category25
		,@intTaxCategory26    =  category26
		,@intTaxCategory27    =  category27
		,@intTaxCategory28    =  category28
		,@intTaxCategory29    =  category29
		,@intTaxCategory30    =  category30
    FROM vyuSMBEExportTax
	WHERE code = @intTaxGroupId


	--CASE WHEN ysnLoad = 1 THEN intNoOfLoad ELSE dblDetailQuantity END

	
	SELECT TOP 1 
		@dblTaxCategory1 =  dblTaxCategory1  - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory1 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory2  =  dblTaxCategory2  - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory2 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory3  =  dblTaxCategory3  - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory3 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory4  =  dblTaxCategory4  - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory4 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory5  =  dblTaxCategory5  - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory5 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory6  =  dblTaxCategory6  - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory6 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory7  =  dblTaxCategory7  - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory7 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory8  =  dblTaxCategory8  - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory8 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory9  =  dblTaxCategory9  - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory9 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory10 =  dblTaxCategory10   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory10 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory11 =  dblTaxCategory11   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory11 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory12 =  dblTaxCategory12   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory12 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory13 =  dblTaxCategory13   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory13 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory14 =  dblTaxCategory14   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory14 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory15 =  dblTaxCategory15   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory15 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory16 =  dblTaxCategory16   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory16 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory17 =  dblTaxCategory17   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory17 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory18 =  dblTaxCategory18   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory18 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory19 =  dblTaxCategory19   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory19 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory20 =  dblTaxCategory20   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory20 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory21 =  dblTaxCategory21   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory21 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory22 =  dblTaxCategory22   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory22 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory23 =  dblTaxCategory23   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory23 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory24 =  dblTaxCategory24   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory24 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory25 =  dblTaxCategory25   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory25 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory26 =  dblTaxCategory26   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory26 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory27 =  dblTaxCategory27   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory27 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory28 =  dblTaxCategory28   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory28 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory29 =  dblTaxCategory29   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory29 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 
		,@dblTaxCategory30 =  dblTaxCategory30   - (CASE WHEN @ysnOverFill = 1 THEN (SELECT TOP 1 dblTax FROM tblARInvoiceDetailTax WHERE intTaxCodeId = @intTaxCategory30 AND intInvoiceDetailId = @intInvoiceDetailId ) ELSE 0 END) 

		--,@dblTaxCategory2 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory2 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory2 THEN 0 ELSE 0 END) ELSE dblTaxCategory2 END)
		--,@dblTaxCategory3 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory3 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory3 THEN 0 ELSE 0 END) ELSE dblTaxCategory3 END)
		--,@dblTaxCategory4 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory4 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory4 THEN 0 ELSE 0 END) ELSE dblTaxCategory4 END)
		--,@dblTaxCategory5 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory5 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory5 THEN 0 ELSE 0 END) ELSE dblTaxCategory5 END)
		--,@dblTaxCategory6 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory6 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory6 THEN 0 ELSE 0 END) ELSE dblTaxCategory6 END)
		--,@dblTaxCategory7 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory7 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory7 THEN 0 ELSE 0 END) ELSE dblTaxCategory7 END)
		--,@dblTaxCategory8 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory8 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory8 THEN 0 ELSE 0 END) ELSE dblTaxCategory8 END)
		--,@dblTaxCategory9 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory9 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory9 THEN 0 ELSE 0 END) ELSE dblTaxCategory9 END)
		--,@dblTaxCategory10 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory10 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory10 THEN 0 ELSE 0 END) ELSE dblTaxCategory10 END)
		--,@dblTaxCategory11 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory11 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory11 THEN 0 ELSE 0 END) ELSE dblTaxCategory11 END)
		--,@dblTaxCategory12 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory12 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory12 THEN 0 ELSE 0 END) ELSE dblTaxCategory12 END)
		--,@dblTaxCategory13 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory13 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory13 THEN 0 ELSE 0 END) ELSE dblTaxCategory13 END)
		--,@dblTaxCategory14 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory14 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory14 THEN 0 ELSE 0 END) ELSE dblTaxCategory14 END)
		--,@dblTaxCategory15 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory15 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory15 THEN 0 ELSE 0 END) ELSE dblTaxCategory15 END)
		--,@dblTaxCategory16 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory16 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory16 THEN 0 ELSE 0 END) ELSE dblTaxCategory16 END)
		--,@dblTaxCategory17 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory17 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory17 THEN 0 ELSE 0 END) ELSE dblTaxCategory17 END)
		--,@dblTaxCategory18 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory18 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory18 THEN 0 ELSE 0 END) ELSE dblTaxCategory18 END)
		--,@dblTaxCategory19 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory19 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory19 THEN 0 ELSE 0 END) ELSE dblTaxCategory19 END)
		--,@dblTaxCategory20 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory20 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory20 THEN 0 ELSE 0 END) ELSE dblTaxCategory20 END)
		--,@dblTaxCategory21 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory21 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory21 THEN 0 ELSE 0 END) ELSE dblTaxCategory21 END)
		--,@dblTaxCategory22 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory22 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory22 THEN 0 ELSE 0 END) ELSE dblTaxCategory22 END)
		--,@dblTaxCategory23 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory23 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory23 THEN 0 ELSE 0 END) ELSE dblTaxCategory23 END)
		--,@dblTaxCategory24 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory24 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory24 THEN 0 ELSE 0 END) ELSE dblTaxCategory24 END)
		--,@dblTaxCategory25 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory25 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory25 THEN 0 ELSE 0 END) ELSE dblTaxCategory25 END)
		--,@dblTaxCategory26 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory26 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory26 THEN 0 ELSE 0 END) ELSE dblTaxCategory26 END)
		--,@dblTaxCategory27 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory27 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory27 THEN 0 ELSE 0 END) ELSE dblTaxCategory27 END)
		--,@dblTaxCategory28 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory28 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory28 THEN 0 ELSE 0 END) ELSE dblTaxCategory28 END)
		--,@dblTaxCategory29 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory29 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory29 THEN 0 ELSE 0 END) ELSE dblTaxCategory29 END)
		--,@dblTaxCategory30 = (CASE WHEN @ysnRecomputeTax = 1  THEN ((@PrebuyQuantity/@TotalQuantity) * dblTaxCategory30 ) - (CASE WHEN @ysnOverFill = (@PrebuyQuantity/@TotalQuantity) * dblTaxCategory30 THEN 0 ELSE 0 END) ELSE dblTaxCategory30 END)
	FROM tblETImportBaseEngineering

	WHERE intImportBaseEngineeringId = @intImportBaseEngineeringId


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