SET IDENTITY_INSERT [dbo].[tblARLetterPlaceHolder] ON 

DECLARE @intPlaceHolderId INT 
DECLARE @placeHolderCount INT

SET @intPlaceHolderId = 0

SELECT @placeHolderCount = COUNT(*) FROM tblARLetterPlaceHolder  

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-1')
BEGIN
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-1'
	IF @placeHolderCount = 0 
	BEGIN
		SET @intPlaceHolderId = 1  
	END 
	ELSE
	BEGIN
		SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder 
	END 	 
	
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-1" style="border:none" placeholder="Customer Name" readonly="">', N'vyuARCollectionOverdueReport', N'strCustomerName', N'strCustomerName', N'Customer Name', 0, N'PH-1', 0, N'nvarchar')
END
ELSE
BEGIN 
	IF @placeHolderCount = 0 
	BEGIN
		SET @intPlaceHolderId = 1  
	END 
	ELSE
	BEGIN
		SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder 
	END 	 
	
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-1" style="border:none" placeholder="Customer Name" readonly="">', N'vyuARCollectionOverdueReport', N'strCustomerName', N'strCustomerName', N'Customer Name', 0, N'PH-1', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-2')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-2'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-2" style="border:none" placeholder="Customer Address" readonly="">', N'vyuARCollectionOverdueReport', N'strCustomerAddress', N'strCustomerAddress', N'Customer Address', 0, N'PH-2', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-2" style="border:none" placeholder="Customer Address" readonly="">', N'vyuARCollectionOverdueReport', N'strCustomerAddress', N'strCustomerAddress', N'Customer Address', 0, N'PH-2', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-3')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-3'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-3" style="border:none" placeholder="Account Number" readonly="">', N'vyuARCollectionOverdueReport', N'strAccountNumber', N'strAccountNumber', N'Account Number', 0, N'PH-3', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-3" style="border:none" placeholder="Account Number" readonly="">', N'vyuARCollectionOverdueReport', N'strAccountNumber', N'strAccountNumber', N'Account Number', 0, N'PH-3', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-4')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-4'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-4" style="border:none" placeholder="Company Name" readonly="">', N'vyuARCollectionOverdueReport', N'strCompanyName', N'strCompanyName', N'Company Name', 0, N'PH-4', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-4" style="border:none" placeholder="Company Name" readonly="">', N'vyuARCollectionOverdueReport', N'strCompanyName', N'strCompanyName', N'Company Name', 0, N'PH-4', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-5')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-5'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-5" style="border:none" placeholder="Total AR Amount Overdue" readonly="">', N'vyuARCollectionOverdueReport', N'dbl10DaysSum', N'dbl10DaysSum', N'Total AR amount Overdue', 0, N'PH-5', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-5" style="border:none" placeholder="Total AR Amount Overdue" readonly="">', N'vyuARCollectionOverdueReport', N'dbl10DaysSum', N'dbl10DaysSum', N'Total AR amount Overdue', 0, N'PH-5', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-6')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-6'
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
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
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

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-7', 'PH-9'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId]  IN ('PH-7', 'PH-9')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-7" style="border:none" placeholder="Amount Overdue 30 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl30DaysSum', N'dbl30DaysSum', N'Amount Overdue 30 Days', 0, N'PH-7', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-7" style="border:none" placeholder="Amount Overdue 30 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl30DaysSum', N'dbl30DaysSum', N'Amount Overdue 30 Days', 0, N'PH-7', 0, N'numeric')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-8', 'PH-10'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-8', 'PH-10')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-8" style="border:none" placeholder="Amount overdue 60 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl60DaysSum', N'dbl60DaysSum', N'Amount Overdue 60 Days', 0, N'PH-8', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-8" style="border:none" placeholder="Amount overdue 60 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl60DaysSum', N'dbl60DaysSum', N'Amount Overdue 60 Days', 0, N'PH-8', 0, N'numeric')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-9', 'PH-11'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE  FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-9', 'PH-11')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-9" style="border:none" placeholder="Amount Overdue 90 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl90DaysSum', N'dbl90DaysSum', N'Amount Overdue 90 Days', 0, N'PH-9', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-9" style="border:none" placeholder="Amount Overdue 90 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl90DaysSum', N'dbl90DaysSum', N'Amount Overdue 90 Days', 0, N'PH-9', 0, N'numeric')
END

IF NOT EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-10', 'PH-12'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-10', 'PH-12')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-10" style="border:none" placeholder="Terms" readonly="">', N'vyuARCollectionOverdueReport', N'strTerm', N'strTerm', N'Terms', 0, N'PH-10', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-10" style="border:none" placeholder="Terms" readonly="">', N'vyuARCollectionOverdueReport', N'strTerm', N'strTerm', N'Terms', 0, N'PH-10', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-11', 'PH-13'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-11', 'PH-13')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-11" style="border:none" placeholder="Total AR balance" readonly="">', N'vyuARCollectionOverdueReport', N'dbl121DaysSum', N'dbl121DaysSum', N'Total AR balance', 0, N'PH-11', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-11" style="border:none" placeholder="Total AR balance" readonly="">', N'vyuARCollectionOverdueReport', N'dbl121DaysSum', N'dbl121DaysSum', N'Total AR balance', 0, N'PH-11', 0, N'numeric')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-12', 'PH-14'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-12', 'PH-14')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-12" style="border:none" placeholder="Company Phone" readonly="">', N'vyuARCollectionOverdueReport', N'strCompanyPhone', N'strCompanyPhone', N'Company Phone', 0, N'PH-12', 0, N'nvarchar') 
END 
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-12" style="border:none" placeholder="Company Phone" readonly="">', N'vyuARCollectionOverdueReport', N'strCompanyPhone', N'strCompanyPhone', N'Company Phone', 0, N'PH-12', 0, N'nvarchar') 
END


IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-13')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-13'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-13" style="border:none" placeholder="Customer Name" readonly="">', N'vyuARCollectionCustomerReport', N'strCustomerName', N'strCustomerName', N'Customer Name', 0, N'PH-13', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-13" style="border:none" placeholder="Customer Name" readonly="">', N'vyuARCollectionCustomerReport', N'strCustomerName', N'strCustomerName', N'Customer Name', 0, N'PH-13', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-14')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-14'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-14" style="border:none" placeholder="Terms" readonly="">', N'vyuARCollectionCustomerReport', N'strTerm', N'strTerm', N'Terms', 0, N'PH-14', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-14" style="border:none" placeholder="Terms" readonly="">', N'vyuARCollectionCustomerReport', N'strTerm', N'strTerm', N'Terms', 0, N'PH-14', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-15'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-15')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-15" style="border:none" placeholder="Company Phone" readonly="">', N'vyuARCollectionCustomerReport', N'strCompanyPhone', N'strCompanyPhone', N'Company Phone', 0, N'PH-15', 0, N'nvarchar') 
END 
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-15" style="border:none" placeholder="Company Phone" readonly="">', N'vyuARCollectionCustomerReport', N'strCompanyPhone', N'strCompanyPhone', N'Company Phone', 0, N'PH-15', 0, N'nvarchar') 
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-16')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-16'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-16" style="border:none" placeholder="Company Name" readonly="">', N'vyuARCollectionCustomerReport', N'strCompanyName', N'strCompanyName', N'Company Name', 0, N'PH-16', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="text" name="PH-16" style="border:none" placeholder="Company Name" readonly="">', N'vyuARCollectionCustomerReport', N'strCompanyName', N'strCompanyName', N'Company Name', 0, N'PH-16', 0, N'nvarchar')
END


IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-17')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-17'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-17', N'Sales', N'<table id="t01" style="width:100%" border="1">
<tbody>
<tr>
	<th>
		<span style="font-family: Arial; font-size:9">
		Document #
		</span>
	</th>
	<th>
		<span style="font-family: Arial; font-size:9">
		Date
		</span>
	</th>
	<th>
		<span style="font-family: Arial; font-size:9">
		Terms
		</span>
	</th>
	<th>
		<span style="font-family: Arial; font-size:9">
		Due Date
		</span>
	</th>
	<th style="text-align:right">
		<span style="font-family: Arial; font-size:9">
		Amount Due
		</span>
	</th>
</tr>
</tbody>
</table>', N'vyuARServiceChargeInvoiceReport', N'strInvoiceNumber, dtmDate, strTerm, dtmDueDate, dblTotalDue', N'nvarchar, datetime, nvarchar, datetime, numeric', N'strInvoiceNumber, dtmDate, strTerm, dtmDueDate, dblTotalDue', N'Document #, Date, Terms, Due Date, Amount Due', 1, 0)

END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-17', N'Sales', N'<table id="t01" style="width:100%" border="1">
<tbody>
<tr>
	<th>
		<span style="font-family: Arial; font-size:9">
		Document #
		</span>
	</th>
	<th>
		<span style="font-family: Arial; font-size:9">
		Date
		</span>
	</th>
	<th>
		<span style="font-family: Arial; font-size:9">
		Terms
		</span>
	</th>
	<th>
		<span style="font-family: Arial; font-size:9">
		Due Date
		</span>
	</th>
	<th style="text-align:right">
		<span style="font-family: Arial; font-size:9">
		Amount Due
		</span>
	</th>
</tr>
</tbody>
</table>', N'vyuARServiceChargeInvoiceReport', N'strInvoiceNumber, dtmDate, strTerm, dtmDueDate, dblTotalDue', N'nvarchar, datetime, nvarchar, datetime, numeric', N'strInvoiceNumber, dtmDate, strTerm, dtmDueDate, dblTotalDue', N'Document #, Date, Terms, Due Date, Amount Due', 1, 0)
END


IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-18')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-18'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-18', N'Sales', N'[EntityName]', N'vyuARServiceChargeInvoiceReport', N'strCustomerName', N'nvarchar', N'strCustomerName', N'Customer Name', 0, 0)
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-18', N'Sales', N'[EntityName]', N'vyuARServiceChargeInvoiceReport', N'strCustomerName', N'nvarchar', N'strCustomerName', N'Customer Name', 0, 0)
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-19')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-19'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-19', N'Sales', N'[CompanyName]', N'vyuARServiceChargeInvoiceReport', N'strCompanyName', N'nvarchar', N'strCompanyName', N'Company Name', 0, 0)
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-19', N'Sales', N'[CompanyName]', N'vyuARServiceChargeInvoiceReport', N'strCompanyName', N'nvarchar', N'strCompanyName', N'Company Name', 0, 0)
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-20')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-20'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-20', N'Sales', N'[TransactionTotal]', N'vyuARServiceChargeInvoiceReport', N'dblInvoiceTotal', N'numeric', N'dblInvoiceTotal', N'Total Finance Charge Amount Due', 0, 0)
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-20', N'Sales', N'[TransactionTotal]', N'vyuARServiceChargeInvoiceReport', N'dblInvoiceTotal', N'numeric', N'dblInvoiceTotal', N'Total Finance Charge Amount Due', 0, 0)
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-21')
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] = 'PH-21'
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-21', N'Sales', N'[Date]', N'vyuARServiceChargeInvoiceReport', N'dtmLetterDate', N'datetime', N'dtmLetterDate', N'Letter Date', 0, 0)
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-21', N'Sales', N'[Date]', N'vyuARServiceChargeInvoiceReport', N'dtmLetterDate', N'datetime', N'dtmLetterDate', N'Letter Date', 0, 0)
END

SET IDENTITY_INSERT [dbo].[tblARLetterPlaceHolder] OFF

 

