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
	SET dblAdjustedTax = @dblTaxCategory1
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory1,0)
		AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory2
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory2,0)
		AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory3
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory3,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory4
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory4,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory5
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory5,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory6
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory6,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory7
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory7,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory8
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory8,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory9
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory9,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory10
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory10,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory11
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory11,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory12
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory12,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory13
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory13,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory14
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory14,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory15
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory15,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory16
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory16,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory17
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory17,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory18
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory18,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory19
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory19,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory20
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory20,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory21
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory21,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory22
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory22,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory23
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory23,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory24
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory24,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory25
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory25,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory26
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory26,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory27
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory27,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory28
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory28,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory29
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory29,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

	UPDATE tblARInvoiceDetailTax
	SET dblAdjustedTax = @dblTaxCategory30
		,ysnTaxAdjusted = 1
	WHERE intTaxCodeId = ISNULL(@intTaxCategory30,0)
	AND intInvoiceDetailId = @intInvoiceDetailId

		
END
GO