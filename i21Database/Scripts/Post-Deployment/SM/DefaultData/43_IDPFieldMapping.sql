GO
	PRINT N'BEGIN INSERT DEFAULT FIELD FOR IDP FIELD MAPPING'
GO
	DECLARE @intScreenId INT

	--VOUCHER HEADER--
	SELECT @intScreenId = intScreenId FROM tblSMScreen WHERE strModule  = 'Accounts Payable' AND strNamespace = 'AccountsPayable.view.Voucher'
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Vendor')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Vendor', 'strVendor')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Invoice Date')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Invoice Date', 'dtmVoucherDate')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Tax')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Tax', 'dblTax')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Subtotal')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Subtotal', 'dblSubtotal')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Invoice No')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Invoice No', 'strVendorOrderNumber')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Ship Via')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Ship Via', 'strShipVia')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Book')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Book', 'strBook')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Sub Book')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Sub Book', 'strSubBook')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Check Comment')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Check Comment', 'strComment')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Reference')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex]) 
		VALUES (@intScreenId, 'Reference', 'strReference')
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Voucher Line Items')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex], [ysnDetailTable]) 
		VALUES (@intScreenId, 'Voucher Line Items', '', 1)
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Voucher Line Items')
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex], [ysnDetailTable]) 
		VALUES (@intScreenId, 'Voucher Line Items', '', 1)
	END

	--VOUCHER DETAIL--
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Misc Description' AND ysnDetail = 1)
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex], [ysnDetail]) 
		VALUES (@intScreenId, 'Misc Description', 'strMiscDescription', 1)
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Billed' AND ysnDetail = 1)
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex], [ysnDetail]) 
		VALUES (@intScreenId, 'Billed', 'dblQtyReceived', 1)
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Cost' AND ysnDetail = 1)
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex], [ysnDetail]) 
		VALUES (@intScreenId, 'Cost', 'dblCost', 1)
	END
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMIDPFieldMappingField WHERE intScreenId = @intScreenId AND strField = 'Subtotal' AND ysnDetail = 1)
	BEGIN
		INSERT [dbo].tblSMIDPFieldMappingField ([intScreenId], [strField], [strFieldDataIndex], [ysnDetail]) 
		VALUES (@intScreenId, 'Subtotal', 'dblTotal', 1)
	END

GO
	PRINT N'BEGIN INSERT DEFAULT FIELD FOR IDP FIELD MAPPING'
GO