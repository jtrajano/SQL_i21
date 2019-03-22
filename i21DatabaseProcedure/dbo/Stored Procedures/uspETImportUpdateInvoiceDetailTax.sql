CREATE PROCEDURE [dbo].[uspETImportUpdateInvoiceDetailTax]
	@intInvoiceDetailId INT
	,@dblTaxCategory1	NUMERIC(18, 6)		= 0
	,@dblTaxCategory2	NUMERIC(18, 6)		= 0
	,@dblTaxCategory3	NUMERIC(18, 6)		= 0
	,@dblTaxCategory4	NUMERIC(18, 6)		= 0
	,@dblTaxCategory5	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory6	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory7	NUMERIC(18, 6)		= 0
	,@dblTaxCategory8	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory9	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory10	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory11	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory12	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory13	NUMERIC(18, 6)		= 0
	,@dblTaxCategory14	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory15	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory16	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory17	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory18	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory19	NUMERIC(18, 6)		= 0
	,@dblTaxCategory20	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory21	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory22	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory23	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory24	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory25	NUMERIC(18, 6)		= 0
	,@dblTaxCategory26	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory27	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory28	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory29	NUMERIC(18, 6)  		= 0
	,@dblTaxCategory30	NUMERIC(18, 6)		= 0
	,@intTaxCategory1 INT 		= 0
	,@intTaxCategory2 INT		= 0
	,@intTaxCategory3 INT		= 0
	,@intTaxCategory4 INT		= 0
	,@intTaxCategory5 INT 		= 0
	,@intTaxCategory6 INT 		= 0
	,@intTaxCategory7 INT		= 0
	,@intTaxCategory8 INT 		= 0
	,@intTaxCategory9 INT 		= 0
	,@intTaxCategory10 INT  	= 0
	,@intTaxCategory11 INT  	= 0
	,@intTaxCategory12 INT  	= 0
	,@intTaxCategory13 INT		= 0
	,@intTaxCategory14 INT  	= 0
	,@intTaxCategory15 INT  	= 0
	,@intTaxCategory16 INT  	= 0
	,@intTaxCategory17 INT  	= 0
	,@intTaxCategory18 INT  	= 0
	,@intTaxCategory19 INT		= 0
	,@intTaxCategory20 INT  	= 0
	,@intTaxCategory21 INT  	= 0
	,@intTaxCategory22 INT  	= 0
	,@intTaxCategory23 INT  	= 0
	,@intTaxCategory24 INT  	= 0
	,@intTaxCategory25 INT		= 0
	,@intTaxCategory26 INT  	= 0
	,@intTaxCategory27 INT  	= 0
	,@intTaxCategory28 INT  	= 0
	,@intTaxCategory29 INT  	= 0
	,@intTaxCategory30 INT 		= 0
AS
BEGIN

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = (CASE WHEN dblTax = ISNULL(@dblTaxCategory1,0.0) THEN dblTax ELSE  ISNULL(@dblTaxCategory1,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax =  ISNULL(@dblTaxCategory1,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory1,0)
		AND intInvoiceDetailId = @intInvoiceDetailId
		

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = (CASE WHEN dblTax = ISNULL(@dblTaxCategory2,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory2,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory2,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory2,0)
		AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = (CASE WHEN dblTax = ISNULL(@dblTaxCategory3,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory3,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory3,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory3,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory4,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory4,0.0) END)
		,ysnTaxAdjusted = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory4,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory4,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory5,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory5,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory5,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory5,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory6,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory6,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory6,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory6,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory7,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory7,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory7,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory7,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory8,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory8,0.0) END) 
		,ysnTaxAdjusted =( CASE WHEN dblTax = ISNULL(@dblTaxCategory8,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory8,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory9,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory9,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory9,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory9,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory10,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory10,0.0) END) 
		,ysnTaxAdjusted =  (CASE WHEN dblTax = ISNULL(@dblTaxCategory10,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory10,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory11,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory11,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory11,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory11,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory12,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory12,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory12,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory12,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory13,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory13,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory13,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory13,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory14,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory14,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory14,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory14,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax =  ( CASE WHEN dblTax = ISNULL(@dblTaxCategory15,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory15,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory15,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory15,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory16,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory16,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory16,0.0)  THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory16,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory17,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory17,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory17,0.0)  THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory17,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory18,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory18,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory18,0.0)  THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory18,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory19,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory19,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory19,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory19,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory20,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory20,0.0) END) 
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory20,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory20,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory21,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory21,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory21,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory21,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory22,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory22,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory22,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory22,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory23,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory23,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory23,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory23,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory24,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory24,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory24,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory24,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory25,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory25,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory25,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory25,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory26,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory26,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory26,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory26,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory27,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory27,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory27,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory27,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory28,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory28,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory28,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory28,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory29,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory29,0.0) END)
		,ysnTaxAdjusted =  (CASE WHEN dblTax = ISNULL(@dblTaxCategory29,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory29,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = ( CASE WHEN dblTax = ISNULL(@dblTaxCategory30,0.0) THEN dblTax ELSE ISNULL(@dblTaxCategory30,0.0) END)
		,ysnTaxAdjusted = (CASE WHEN dblTax = ISNULL(@dblTaxCategory30,0.0) THEN 0 ELSE 1 END)
	WHERE intTaxCodeId = ISNULL(@intTaxCategory30,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

		
END
GO