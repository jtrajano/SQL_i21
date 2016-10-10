SET IDENTITY_INSERT [dbo].[tblARLetterPlaceHolder] ON 

DECLARE @intPlaceHolderId INT 
SET @intPlaceHolderId = 0

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-1')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (1, N'Sales', N'<input type="text" name="PH-1" style="border:none" placeholder="Customer Name" readonly="">', N'vyuARCollectionOverdueReport', N'strCustomerName', N'strCustomerName', N'Customer Name', 0, N'PH-1', 0, N'nvarchar')
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-2')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (2, N'Sales', N'<input type="text" name="PH-2" style="border:none" placeholder="Customer Address" readonly="">', N'vyuARCollectionOverdueReport', N'strCustomerAddress', N'strCustomerAddress', N'Customer Address', 0, N'PH-2', 0, N'nvarchar')
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-3')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-3" style="border:none" placeholder="Account Number" readonly="">', N'vyuARCollectionOverdueReport', N'strAccountNumber', N'strAccountNumber', N'Account Number', 0, N'PH-3', 0, N'nvarchar')
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-4')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-4" style="border:none" placeholder="Company Name" readonly="">', N'vyuARCollectionOverdueReport', N'strCompanyName', N'strCompanyName', N'Company Name', 0, N'PH-4', 0, N'nvarchar')
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-5')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-5" style="border:none" placeholder="Total AR Amount Overdue" readonly="">', N'vyuARCollectionOverdueReport', N'dbl0DaysSum', N'dbl0Days', N'Total AR amount Overdue', 0, N'PH-5', 0, N'nvarchar')
END
ELSE
BEGIN
	UPDATE tblARLetterPlaceHolder SET strSourceColumn = 'dbl0DaysSum' WHERE [strPlaceHolderId] = 'PH-5'
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-6')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<table id="t01" style="width:100%" border="1">
<tbody>
<tr>
	<th>
		<span style="font-family: Arial; font-size:9">
		Invoice Date
		</span>
	</th>
	<th>
		<span style="font-family: Arial; font-size:9">
		Invoice Number
		</span>
	</th>
	<th style="text-align:right">
		<span style="font-family: Arial; font-size:9">
		Amount Due
		</span>
	</th>
</tr>
</tbody>
</table>', N'vyuARCollectionOverdueReport', N'dtmDate, strInvoiceNumber, dblTotalDue', N'dtmDate, strInvoiceNumber, dblTotalDue', N'Invoice Date, Invoice Number, Amount Due', 0, N'PH-6', 1, N'datetime, nvarchar, numeric')
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-9')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-9" style="border:none" placeholder="Amount Overdue 30 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl30DaysSum', N'dbl30Days', N'Amount Overdue 30 Days', 0, N'PH-9', 0, N'numeric')
END
ELSE
BEGIN
	UPDATE tblARLetterPlaceHolder SET strSourceColumn = 'dbl30DaysSum' WHERE [strPlaceHolderId] = 'PH-9'
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-10')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-10" style="border:none" placeholder="Amount overdue 60 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl60DaysSum', N'dbl60Days', N'Amount Overdue 60 Days', 0, N'PH-10', 0, N'numeric')
END
ELSE
BEGIN
	UPDATE tblARLetterPlaceHolder SET strSourceColumn = 'dbl60DaysSum' WHERE [strPlaceHolderId] = 'PH-10'
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-11')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-11" style="border:none" placeholder="Amount Overdue 90 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl90DaysSum', N'dbl90Days', N'Amount Overdue 90 Days', 0, N'PH-11', 0, N'numeric')
END
ELSE
BEGIN
	UPDATE tblARLetterPlaceHolder SET strSourceColumn = 'dbl90DaysSum' WHERE [strPlaceHolderId] = 'PH-11'
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-12')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-12" style="border:none" placeholder="Terms" readonly="">', N'vyuARCollectionCreditViewReport', N'strTerm', N'strTerm', N'Terms', 0, N'PH-12', 0, N'nvarchar')
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-13')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-13" style="border:none" placeholder="Total AR balance" readonly="">', N'vyuARCollectionOverdueReport', N'dblInvoiceTotal', N'dblInvoiceTotal', N'Total AR balance', 0, N'PH-13', 0, N'numeric')
END

SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-14')
BEGIN
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-14" style="border:none" placeholder="Customer Phone" readonly="">', N'vyuARCollectionOverdueReport', N'strCustomerPhone', N'strCustomerPhone', N'Customer Phone', 0, N'PH-14', 0, N'nvarchar')
SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
END 

SET IDENTITY_INSERT [dbo].[tblARLetterPlaceHolder] OFF

 

