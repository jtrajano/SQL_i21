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
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<table id="t01" style="width:100%" border="1"><tbody><tr><th><span style="font-family: Arial; font-size:9">Due Date</span></th><th><span style="font-family: Arial; font-size:9">Invoice Number</span></th><th style="text-align:right"><span style="font-family: Arial; font-size:9">Amount Due</span></th></tr></tbody></table>', N'vyuARCollectionOverdueReport', N'dtmDueDate, strInvoiceNumber, dblTotalDue', N'dtmDueDate, strInvoiceNumber, dblTotalDue', N'Due Date, Invoice Number, Amount Due', 0, N'PH-6', 1, N'datetime, nvarchar, numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<table id="t01" style="width:100%" border="1"><tbody><tr><th><span style="font-family: Arial; font-size:9">Due Date</span></th><th><span style="font-family: Arial; font-size:9">Invoice Number</span></th><th style="text-align:right"><span style="font-family: Arial; font-size:9">Amount Due</span></th></tr></tbody></table>', N'vyuARCollectionOverdueReport', N'dtmDueDate, strInvoiceNumber, dblTotalDue', N'dtmDueDate, strInvoiceNumber, dblTotalDue', N'Due Date, Invoice Number, Amount Due', 0, N'PH-6', 1, N'datetime, nvarchar, numeric')
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
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-18', N'Sales', N'[EntityName]', N'vyuARCollectionCustomerReport', N'strCustomerName', N'nvarchar', N'strCustomerName', N'Customer Name', 0, 0)
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-18', N'Sales', N'[EntityName]', N'vyuARCollectionCustomerReport', N'strCustomerName', N'nvarchar', N'strCustomerName', N'Customer Name', 0, 0)
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
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-21', N'Sales', N'[Date]', N'vyuARCollectionCustomerReport', N'dtmLetterDate', N'datetime', N'dtmLetterDate', N'Letter Date', 0, 0)
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strDataType], [strPlaceHolderName], [strPlaceHolderDescription], [ysnTable], [intConcurrencyId]) VALUES (@intPlaceHolderId, N'PH-21', N'Sales', N'[Date]', N'vyuARCollectionCustomerReport', N'dtmLetterDate', N'datetime', N'dtmLetterDate', N'Letter Date', 0, 0)
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-22'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId]  IN ('PH-22')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-22" style="border:none" placeholder="Amount Overdue 1 Day" readonly="">', N'vyuARCollectionOverdueReport', N'dbl10DaysSum', N'dbl10DaysSum', N'Amount Overdue 1 Day', 0, N'PH-22', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-22" style="border:none" placeholder="Amount Overdue 1 Day" readonly="">', N'vyuARCollectionOverdueReport', N'dbl10DaysSum', N'dbl10DaysSum', N'Amount Overdue 1 Day', 0, N'PH-22', 0, N'numeric')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-23'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-23')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-23" style="border:none" placeholder="Amount Overdue 10 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl30DaysSum', N'dbl30DaysSum', N'Amount Overdue 10 Days', 0, N'PH-23', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-23" style="border:none" placeholder="Amount Overdue 10 Days" readonly="">', N'vyuARCollectionOverdueReport', N'dbl30DaysSum', N'dbl30DaysSum', N'Amount Overdue 10 Days', 0, N'PH-23', 0, N'numeric')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-24'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-24')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-24" style="border:none" placeholder="Total AR Amount Due" readonly="">', N'vyuARCollectionOverdueReport', N'dbl10DaysSum', N'dbl10DaysSum', N'Total AR Amount Due', 0, N'PH-24', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'<input type="value" name="PH-24" style="border:none" placeholder="Total AR Amount Due" readonly="">', N'vyuARCollectionOverdueReport', N'dbl10DaysSum', N'dbl10DaysSum', N'Total AR Amount Due', 0, N'PH-24', 0, N'numeric')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-25'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-25')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Entity Address]', N'vyuARCollectionCustomerReport', N'strCustomerAddress', N'strEntityAddress', N'Customer or Vendor Address', 0, N'PH-25', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Entity Address]', N'vyuARCollectionCustomerReport', N'strCustomerAddress', N'strEntityAddress', N'Customer or Vendor Address', 0, N'PH-25', 0, N'nvarchar')
END


IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-26'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-26')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Account Number]', N'vyuARCollectionCustomerReport', N'strAccountNumber', N'strAccountNumber', N'Customer or Vendor Account Number', 0, N'PH-26', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Account Number]', N'vyuARCollectionCustomerReport', N'strAccountNumber', N'strAccountNumber', N'Customer or Vendor Account Number', 0, N'PH-26', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-27'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-27')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[EntityPhoneNumber]', N'vyuARCollectionCustomerReport', N'strCustomerPhone', N'strCustomerPhone', N'Phone number of Customer, Vendor, Employee, etc.', 0, N'PH-27', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[EntityPhoneNumber]', N'vyuARCollectionCustomerReport', N'strCustomerPhone', N'strCustomerPhone', N'Phone number of Customer, Vendor, Employee, etc.', 0, N'PH-27', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-28'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-28')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[ARBalance]', N'vyuARCollectionOverdueReport', N'dbl10DaysSum', N'dblARBalance', N'Customer AR Balance', 0, N'PH-28', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[ARBalance]', N'vyuARCollectionOverdueReport', N'dbl10DaysSum', N'dblARBalance', N'Customer AR Balance', 0, N'PH-28', 0, N'numeric')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-29'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-29')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[CurrentUser]', N'vyuARCollectionCustomerReport', N'strCurrentUser', N'strCurrentUser', N'Currently logged user', 0, N'PH-29', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[CurrentUser]', N'vyuARCollectionCustomerReport', N'strCurrentUser', N'strCurrentUser', N'Currently logged user', 0, N'PH-29', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-30'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-30')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[TransactionDate]', N'vyuARCollectionOverdueReport', N'dtmDate', N'dtmDate', N'Invoice, voucher, sales order, etc. record/transaction date', 0, N'PH-30', 0, N'datetime')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[TransactionDate]', N'vyuARCollectionOverdueReport', N'dtmDate', N'dtmDate', N'Invoice, voucher, sales order, etc. record/transaction date', 0, N'PH-30', 0, N'datetime')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-31'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-31')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[TransactionNumber]', N'vyuARCollectionOverdueReport', N'strInvoiceNumber', N'strInvoiceNumber', N'Invoice, voucher, sales order, etc. record/transaction number', 0, N'PH-31', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[TransactionNumber]', N'vyuARCollectionOverdueReport', N'strInvoiceNumber', N'strInvoiceNumber', N'Invoice, voucher, sales order, etc. record/transaction number', 0, N'PH-31', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-32'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-32')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[TransactionTotal]', N'vyuARCollectionOverdueReport', N'dblInvoiceTotal', N'dblInvoiceTotal', N'Invoice, voucher, sales order, etc. record/transaction amount total', 0, N'PH-32', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[TransactionTotal]', N'vyuARCollectionOverdueReport', N'dblInvoiceTotal', N'dblInvoiceTotal', N'Invoice, voucher, sales order, etc. record/transaction amount total', 0, N'PH-32', 0, N'numeric')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-33'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-33')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[EffectiveDate]', N'vyuARCollectionOverdueReport', N'dtmDate', N'dtmDate', N'(reserved)', 0, N'PH-33', 0, N'datetime')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[EffectiveDate]', N'vyuARCollectionOverdueReport', N'dtmDate', N'dtmDate', N'(reserved)', 0, N'PH-33', 0, N'datetime')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-34'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-34')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Company Name]', N'vyuARCollectionCustomerReport', N'strCompanyName', N'strCompanyName', N'Name of the company', 0, N'PH-34', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Company Name]', N'vyuARCollectionCustomerReport', N'strCompanyName', N'strCompanyName', N'Name of the company', 0, N'PH-34', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-35'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-35')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Transaction Amount]', N'vyuARCollectionOverdueReport', N'dblInvoiceTotal', N'dblInvoiceTotal', N'Invoice, voucher, sales order, etc. record/transaction amount', 0, N'PH-35', 0, N'numeric')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Transaction Amount]', N'vyuARCollectionOverdueReport', N'dblInvoiceTotal', N'dblInvoiceTotal', N'Invoice, voucher, sales order, etc. record/transaction amount', 0, N'PH-35', 0, N'numeric')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-36'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-36')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Terms]', N'vyuARCollectionOverdueReport', N'strTerm', N'strTerm', N'Payment Terms used in Transaction', 0, N'PH-36', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[Terms]', N'vyuARCollectionOverdueReport', N'strTerm', N'strTerm', N'Payment Terms used in Transaction', 0, N'PH-36', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-37'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-37')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[EntityPhoneNumber]', N'vyuARCollectionCustomerReport', N'strCustomerPhone', N'strCustomerPhone', N'Phone number of Customer, Vendor, Employee, etc.', 0, N'PH-37', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[EntityPhoneNumber]', N'vyuARCollectionCustomerReport', N'strCustomerPhone', N'strCustomerPhone', N'Phone number of Customer, Vendor, Employee, etc.', 0, N'PH-37', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-38'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-38')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[ContactName]', N'vyuARCollectionCustomerReport', N'strContactName', N'strContactName', N'Name of Entity Contact', 0, N'PH-38', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[ContactName]', N'vyuARCollectionCustomerReport', N'strContactName', N'strContactName', N'Name of Entity Contact', 0, N'PH-38', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-39'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-39')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[ExpirationDate]', N'vyuARCollectionOverdueReport', N'dtmDate', N'dtmDate', N'Transaction Expiration (when applicable)', 0, N'PH-39', 0, N'datetime')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[ExpirationDate]', N'vyuARCollectionOverdueReport', N'dtmDate', N'dtmDate', N'Transaction Expiration (when applicable)', 0, N'PH-39', 0, N'datetime')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-40'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-40')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[CreatedByName]', N'vyuARCollectionOverdueReport', N'strCreatedByName', N'strCreatedByName', N'Name of who created the transaction', 0, N'PH-40', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[CreatedByName]', N'vyuARCollectionOverdueReport', N'strCreatedByName', N'strCreatedByName', N'Name of who created the transaction', 0, N'PH-40', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-41'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-41')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[CreatedByPhone]', N'vyuARCollectionOverdueReport', N'strCreatedByPhone', N'strCreatedByPhone', N'Phone number of who created the transaction', 0, N'PH-41', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[CreatedByPhone]', N'vyuARCollectionOverdueReport', N'strCreatedByPhone', N'strCreatedByPhone', N'Phone number of who created the transaction', 0, N'PH-41', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-42'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-42')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[CreatedByEmail]', N'vyuARCollectionOverdueReport', N'strCreatedByEmail', N'strCreatedByEmail', N'Email of who created the transaction', 0, N'PH-42', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[CreatedByEmail]', N'vyuARCollectionOverdueReport', N'strCreatedByEmail', N'strCreatedByEmail', N'Email of who created the transaction', 0, N'PH-42', 0, N'nvarchar')
END

IF EXISTS(SELECT * FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-43'))
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	DELETE FROM [tblARLetterPlaceHolder] WHERE [strPlaceHolderId] IN ('PH-43')
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[SalesPersonName]', N'vyuARCollectionOverdueReport', N'strSalesPersonName', N'strSalesPersonName', N'Sales Person of the created transaction', 0, N'PH-43', 0, N'nvarchar')
END
ELSE
BEGIN
	SELECT @intPlaceHolderId = MAX([intPlaceHolderId]) + 1 FROM tblARLetterPlaceHolder
	INSERT [dbo].[tblARLetterPlaceHolder] ([intPlaceHolderId], [strModules], [strPlaceHolder], [strSourceTable], [strSourceColumn], [strPlaceHolderName], [strPlaceHolderDescription], [intConcurrencyId], [strPlaceHolderId], [ysnTable], [strDataType]) VALUES (@intPlaceHolderId, N'Sales', N'[SalesPersonName]', N'vyuARCollectionOverdueReport', N'strSalesPersonName', N'strSalesPersonName', N'Sales Person of the created transaction', 0, N'PH-43', 0, N'nvarchar')
END


SET IDENTITY_INSERT [dbo].[tblARLetterPlaceHolder] OFF

 

