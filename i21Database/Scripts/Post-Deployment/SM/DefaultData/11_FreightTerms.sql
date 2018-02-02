GO
	PRINT N'BEGIN INSERT DEFAULT COUNTRIES'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Truck') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId]) 
		VALUES (N'Truck', N'Destination ', 1 , 1) 
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Deliver') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId]) 
		VALUES (N'Deliver', N'Destination ', 1 , 1) 
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Pickup') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId]) 
		VALUES (N'Pickup', N'Origin ', 1 , 1) 
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Dlvd') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId]) 
		VALUES (N'Dlvd', N'Origin ', 1 , 1) 
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Rail') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId]) 
		VALUES (N'Rail', N'Origin ', 1 , 1) 
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Barge') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId]) 
		VALUES (N'Barge', N'Origin ', 1 , 1) 
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'Vessel') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId]) 
		VALUES (N'Vessel', N'Origin ', 1 , 1) 
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms where strFreightTerm = N'FOB') 
	BEGIN 
		INSERT [dbo].tblSMFreightTerms ([strFreightTerm], [strFobPoint], [ysnActive], [intConcurrencyId]) 
		VALUES (N'FOB', N'Origin ', 1 , 1) 
	END
GO
	PRINT N'END INSERT DEFAULT COUNTRIES'